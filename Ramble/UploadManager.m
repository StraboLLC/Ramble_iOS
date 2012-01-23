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
@end

@interface UploadManager (NSURLConnectionDownloadDelegate) <NSURLConnectionDownloadDelegate>
-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;
-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL;
-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;
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
    NSString * imageFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", trackName]];
    NSString * videoFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]];
    NSString * jsonFilePath = [localFileManager.docsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]];

    // Create the request
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadServerURL]];
    NSString *params = [[NSString alloc] initWithFormat:@"filetype=video&authtoken=%@&videofile=%@&JSONfile=%@&imagefile=%@&filename=%@&addtoalbum=%@", authToken, [NSData dataWithContentsOfFile:videoFilePath], [NSData dataWithContentsOfFile:jsonFilePath], [NSData dataWithContentsOfFile:imageFilePath], trackName, album];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    currentRequest = postRequest;
}

-(void)startUpload {
    
    currentConnection = [[NSURLConnection alloc] initWithRequest:currentRequest delegate:self];
    
    currentRequest = nil;
    
    if (currentConnection) {
        [currentConnection start];
    } else {
        NSLog(@"New Connection could not be initialized");
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
    if ([self.delegate respondsToSelector:@selector(uploadStopped:withError:)]) {
        [self.delegate uploadStopped:NO withError:error];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSData * data = [NSData dataWithData:receivedData];
    [self handleResponse:data];
}

@end

@implementation UploadManager (NSURLConnectionDownloadDelegate)

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    
    // Calculate the percent complete (between 0 and 1)
    double percentComplete = totalBytesWritten/expectedTotalBytes;
    
    // Report the percent complete to the delegate if it responds to the proper protocol method
    if ([self.delegate respondsToSelector:@selector(uploadProgressMade:)]) {
        [self.delegate uploadProgressMade:percentComplete];
    }
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    
}

@end
