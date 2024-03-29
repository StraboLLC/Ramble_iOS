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
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
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

-(void)generateUploadRequestFor:(NSString *)trackName inAlbum:(NSString *)album withAuthtoken:(NSString *)authToken withID:(NSString *)userID toFacebook:(BOOL)uploadToFacebook {
    
    LocalFileManager * localFileManager = [[LocalFileManager alloc] init];
    
    // Find the three data files
    NSString * videoFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]]];
    NSString * jsonFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]]];
    NSString * thumbnailFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", trackName]]];
    
    // Error Handling... Make sure the files exist
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:videoFilePath] || ![fileManager fileExistsAtPath:jsonFilePath] || ![fileManager fileExistsAtPath:thumbnailFilePath]) {
        NSLog(@"Files not found while generating request.");
        if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
            [self.delegate uploadStopped:NO withError:nil];
        }
        return;
    }
    
    NSString * uploadToFacebookString = (uploadToFacebook) ? @"true" : @"false";
    
    if (uploadToFacebook) {
        NSLog(@"Post request requires facebook upload."); 
    } else {
        NSLog(@"Post request does not require facebook upload.");
    }
    
    // Create the request
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadServerURL]];
    
    // Set the request method to post
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSLog(@"Uploading using authToken: %@, and userID: %@ to facebook: %@.", authToken, userID, uploadToFacebookString);
    
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
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"upload_to_facebook\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:uploadToFacebookString] dataUsingEncoding:NSUTF8StringEncoding]];
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
        if ([self.delegate respondsToSelector:@selector(uploadStarted)]) {
            [self.delegate uploadStarted];
        }
    } else {
        
        NSLog(@"Error initiating connection. Alerting delegate.");
        
        if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
            [self.delegate uploadStopped:NO withError:nil];
        }
    }
}

-(void)cancelCurrentUpload {
    [currentConnection cancel];
    
    NSLog(@"Upload canceled. Alerting delegate.");
    
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
    NSLog(@"Upload connection received partial response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSString * userName = STRUserName;
    NSString * password = STRPassword;
    NSURLCredential * credential = [NSURLCredential credentialWithUser:userName 
                                                              password:password 
                                                           persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
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
    NSLog(@"Connection finished receiving response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self handleResponse:data];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // Notify the delegate that uploading progress has been made
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        NSLog(@"Upload connection progress made: %f", (double)totalBytesWritten/(double)totalBytesExpectedToWrite);
        [self.delegate uploadProgressMade:((double)totalBytesWritten/(double)totalBytesExpectedToWrite)];
    }
}

@end