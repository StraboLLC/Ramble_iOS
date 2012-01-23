//
//  UploadManager.h
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @header 
    @CFBundleIdentifier com.strabogis.StraboGIS
    @encoding utf-8
 @copyright Copyright 2011 Strabo LLC. All rights reserved.
 @updated 2011-08-15
 @abstract An object to manage a the upload of a strabo track.
 @discussion An object that manages the uploading of a track to the website. It is recommended that a new upload manager be created for each set of files uploaded.
 */
@interface UploadManager : NSObject {
    
}

/*!
 @method uploadTrack
 @abstract Uploads a track to the website.
 @discussion Discovers the track files based on the name of the track. Then uploads the files via a php post request
 @param
 @result
 */
-(void)uploadTrack:(NSString *)trackName;


@end
