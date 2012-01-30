//
//  UploadManager.m
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "UploadManager.h"

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@interface UploadManager (InternalMethods)
-(void)handleResponse:(NSData *)responseJSONdata;
@end

@interface UploadManager (NSURLConnectionDelegate) <NSURLConnectionDelegate>
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end

@implementation UploadManager

@synthesize delegate;

-(id)init {
    if (self) {
        // Customize initialization here
        
    }
    return self;
}

-(void)generateUploadRequestFor:(NSString *)trackName inAlbum:(NSString *)album withAuthtoken:(NSString *)authToken withID:(NSString *)userID{
    
    LocalFileManager * localFileManager = [[LocalFileManager alloc] init];
    
    // Find the three data files
    NSString * videoFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]]];
    NSString * jsonFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]]];
    NSString * thumbnailFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", trackName]]];
    
    // Error Handling... Make sure the files exist
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:videoFilePath] || ![fileManager fileExistsAtPath:jsonFilePath] || ![fileManager fileExistsAtPath:thumbnailFilePath]) {
        NSLog(@"Files to upload do not exist.");
        if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
            [self.delegate uploadStopped:NO withError:nil];
        }
        return;
    }
    
    // Create the request
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadServerURL]];
    
    // Create the request
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSLog(@"Uploading using authToken: %@", authToken);
    
    // setting up the body:
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"filetype\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"video"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"auth_token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:authToken] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"filename\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:trackName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:userID] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"videofile\"; filename=\"%@.mov\"\r\n", trackName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithContentsOfFile:videoFilePath]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imagefile\"; filename=\"%@.png\"\r\n", trackName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithContentsOfFile:thumbnailFilePath]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"JSONfile\"; filename=\"%@.json\"\r\n", trackName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithContentsOfFile:jsonFilePath]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postRequest setHTTPBody:postBody];
    
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString:uploadServerURL] host]];
    
    currentRequest = postRequest;
}

-(void)startUpload {
    
    currentConnection = [[NSURLConnection alloc] initWithRequest:currentRequest delegate:self];
    
    currentRequest = nil;
    
    // Get ready to receive data
    receivedData = [[NSMutableData data] init];
    
    // Fire up the connection
    if (currentConnection) {
        [currentConnection start];
    } else {
        if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
            [self.delegate uploadStopped:NO withError:nil];
        }
    }
}

-(void)cancelCurrentUpload {
    [currentConnection cancel];
    if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:YES withError:nil];
    }
    
}

@end

@implementation UploadManager (InternalMethods)

-(void)handleResponse:(NSData *)responseJSONdata {
    
    // *** UNCOMMENT THIS SHIT WHEN ERROR HANDLING IS WORKED OUT *** //
    
    NSError * error = nil;
    NSDictionary * dataDictionary =  [NSJSONSerialization JSONObjectWithData:responseJSONdata options:0 error:&error];
    NSString * serverError = [[dataDictionary objectForKey:@"errors"] objectAtIndex:0];
    
    // Make sure the JSON data was processed properly
    if (error && [self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        NSLog(@"Handler reports an error");
        [self.delegate uploadStopped:NO withError:error];
    } else if ([serverError isEqualToString:@"true"] && [self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        // Report a server error
        NSLog(@"Handler reports an error");
        [self.delegate uploadStopped:NO withError:nil];
    } else {
        // If there are no possible errors, notify the delegate
        // that the upload was completed successfully.
        if ([self.delegate respondsToSelector:@selector(uploadCompleted)]) {
            [self.delegate uploadCompleted];
        }
    }
    
}

@end

@implementation UploadManager (NSURLConnectionDelegate)

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Reset the received data
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData
    [receivedData appendData:data];
    NSLog(@"Response Data Partial: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Notify the delegate of an error
    NSLog(@"Connection failed with error: %@", error);
    if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:NO withError:error];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Make sure that the delegate is informed of 100% progress
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        [self.delegate uploadProgressMade:1];
    }
    // Handle the data response internally first
    NSData * data = [NSData dataWithData:receivedData];
    NSLog(@"Response Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self handleResponse:data];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // Notify the delegate that uploading progress has been made
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        NSLog(@"Upload Progress Made: %f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
        [self.delegate uploadProgressMade:((double)totalBytesWritten/(double)totalBytesExpectedToWrite)];
    }
}

@end