//
//  UploadManager.h
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalFileManager.h"
#import "Constants.h"

/**
 The UploadManagerDelegate protocol defines optional methods for receiving status updates about an asynchronous upload.
 
 Because the uploader uploads data asynchronously (so as to not tie-up the system while an upload is in progress), when you implement an UploadManager, you should implement these methods to track the progress of an upload.
 */
@protocol UploadManagerDelegate

@optional

/**
 Called when an upload has started.
 */
-(void)uploadStarted;

/**
 Called when upload progress has been made.
 
 Whenever a packet of data has been uploaded, this method is called and the percentage of the request sent is calculated.
 
 @param percentComplete The fraction (out of 1) of the post request that has been sent to the server.
 */
-(void)uploadProgressMade:(double)percentComplete;

/**
 Called whenever the upload has stopped without finishing.
 
 This could be called for any reason after [startUpload](UploadManager startUpload). It will also be called if the [cancelCurrentUpload](UploadManager cancelCurrentUpload) method is called.
 
 @param cancelled Boolean value which returns True if the upload stopped because [cancelCurrentUpload](UploadManager cancelCurrentUpload) was called.
 
 @param error Nil if there was no error or if the error is unknown. Otherwise, contains the error which caused the failed upload.
 */
-(void)uploadStopped:(BOOL)cancelled withError:(NSError *)error;

/**
 Called when the upload has successfully completed.
 
 This method will only be called if the entire post request was sent and application receives proper confirmation from the server response that the complete post request was received.
 */
-(void)uploadCompleted;
@end

/**
 An object to manage the uploading of a Strabo track.
 
 The UploadManager manages the uploading of a track to the web application. It is recommended that a new upload manager be created for each set of files uploaded to avoid any possible glitches.
 */
@interface UploadManager : NSObject {
    id delegate;
    NSURLConnection * currentConnection;
    NSURLRequest * currentRequest;
    NSMutableData * receivedData;
}

///---------------------------------------------------------------------------------------
/// @name Specifying a Delegate
///---------------------------------------------------------------------------------------

/**
 The delegate for the receiver.
 */
@property(strong)id delegate;

///---------------------------------------------------------------------------------------
/// @name Creating an Upload Manager
///---------------------------------------------------------------------------------------

/**
 Returns an initialized UploadManager instance.
 
 @return An initialized UploadManager object.
 */
-(id)init;

///---------------------------------------------------------------------------------------
/// @name Handling an Upload
///---------------------------------------------------------------------------------------

/**
 Builds a post request with all of the necessary information for a specific track.
 
 It should be noted that this method does not actually upload the track itself. The pre-processed request should be sent with startUpload.
 */
-(void)generateUploadRequestFor:(NSString *)trackName inAlbum:(NSString *)album withAuthtoken:(NSString *)authToken withID:(NSString *)userID;

/**
 Sends a post request to the server (specified in Constants.h) built with generateUploadRequestFor:inAlbum:withAuthToken:withID:. 
 */
-(void)startUpload;

/**
 Cancels an upload started with startUpload. 
 
 Calls the [uploadStopped:withError](UploadManagerDelegate uploadStopped:withError) delegate method. Can be called at any time after an upload is started.
 */
-(void)cancelCurrentUpload;

@end
