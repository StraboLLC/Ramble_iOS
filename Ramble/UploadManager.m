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
    NSLog(@"Post Request Generated");
}

-(void)startUpload {
    
    currentConnection = [[NSURLConnection alloc] initWithRequest:currentRequest delegate:self];
    
    currentRequest = nil;
    
    // Get ready to receive data
    receivedData = [[NSMutableData data] init];
    
    if (currentConnection) {
        [currentConnection start];
        NSLog(@"Connection Started");
    } else {
        NSLog(@"New Connection could not be initialized");
        if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
            [self.delegate uploadStopped:NO withError:nil];
        }
    }
}

-(void)cancelCurrentUpload {
    NSLog(@"Upload Cancelled");
    [currentConnection cancel];
    if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:YES withError:nil];
    }
    
}

@end

@implementation UploadManager (InternalMethods)

-(void)handleResponse:(NSData *)responseJSONdata {
    
    NSLog(@"File Upload Completed. Response from server: /n%@", [[NSString alloc] initWithData:responseJSONdata encoding:NSUTF8StringEncoding]);
    
    if ([self.delegate respondsToSelector:@selector(uploadCompleted)]) {
        [self.delegate uploadCompleted];
    }
}

@end

@implementation UploadManager (NSURLConnectionDelegate)

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Reset the received data
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error Connecting: %@", error);
    if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:NO withError:error];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection did finish loading");
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        [self.delegate uploadProgressMade:1];
    }
    NSData * data = [NSData dataWithData:receivedData];
    [self handleResponse:data];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"Made some uploading progress");
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        [self.delegate uploadProgressMade:(totalBytesWritten/totalBytesExpectedToWrite)];
    }
}

@end