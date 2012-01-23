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

/*!
 @header 
    @CFBundleIdentifier com.strabogis.StraboGIS
    @encoding utf-8
 @copyright Copyright 2011 Strabo LLC. All rights reserved.
 @updated 2011-08-15
 @abstract An object to manage a the upload of a strabo track.
 @discussion An object that manages the uploading of a track to the website. It is recommended that a new upload manager be created for each set of files uploaded.
 */

@protocol UploadManagerDelegate

@optional
-(void)uploadProgressMade:(double)percentComplete;
-(void)uploadStopped:(BOOL)cancelled withError:(NSError *)error;
-(void)uploadCompleted;
@end

@interface UploadManager : NSObject {
    id delegate;
    NSURLConnection * currentConnection;
    NSURLRequest * currentRequest;
    NSMutableData * receivedData;
}

@property(strong)id delegate;

-(id)init;

/*!
 @method uploadTrack
 @abstract Uploads a track to the website.
 @discussion Discovers the track files based on the name of the track. Then uploads the files via a php post request
 @param trackName The name of the track (should be the same as the contained track files) with no file extension.
 */
-(void)generateUploadRequestFor:(NSString *)trackName inAlbum:(NSString *)album withAuthtoken:(NSString *)authToken;

-(void)startUpload;

-(void)cancelCurrentUpload;

@end
