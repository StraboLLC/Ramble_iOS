//
//  UploadManager.m
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "UploadManager.h"

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

-(void)generateUploadRequestFor:(NSString *)trackName inAlbum:(NSString *)album withAuthtoken:(NSString *)authToken {
    LocalFileManager * localFileManager = [[LocalFileManager alloc] init];
    // Find the three data files
    //NSString * imageFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", trackName]];
    NSString * videoFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]];
    NSString * jsonFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]];

    // Create the request
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadServerURL]];
    NSString *params = [[NSString alloc] initWithFormat:@"filetype=video&authtoken=%@&videofile=%@&JSONfile=%@&imagefile=nil&filename=%@&addtoalbum=%@", authToken, [NSData dataWithContentsOfFile:videoFilePath], [NSData dataWithContentsOfFile:jsonFilePath], trackName, album];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
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
    NSError * error = nil;
    NSDictionary * dataDictionary =  [NSJSONSerialization JSONObjectWithData:responseJSONdata options:0 error:&error];
    NSString * serverError = [[dataDictionary objectForKey:@"errors"] objectAtIndex:0];
    
    // Make sure the JSON data was processed properly
    if (error && [self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:NO withError:error];
    } else if ([serverError isEqualToString:@"true"] && [self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        // Report a server error
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
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Notify the delegate of an error
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
    [self handleResponse:data];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // Notify the delegate that uploading progress has been made
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        [self.delegate uploadProgressMade:(totalBytesWritten/totalBytesExpectedToWrite)];
    }
}

@end