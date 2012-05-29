//
//  StraboTrack.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/15/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The StraboTrack is an object containing the filepaths to the track 
 */

@interface StraboTrack : NSObject {
    NSURL * trackPath;
    NSString * trackName;
    NSString * trackTitle;
    NSString * trackType;
    NSNumber * latitude;
    NSNumber * longitude;
    NSDate * captureDate;
    NSMutableArray * taggedPeople;
    NSMutableArray * taggedPlaces;
    NSDate * uploadedDate;
}

/**
 @property trackPath
 @abstract This is the path to the directory of the track.
 @discussion This is the path to the directory containing the video and data files.
 */
@property(nonatomic, strong) NSURL * trackPath;

/**
 @property jsonPath
 @abstract The path to the relevant JSON file.
 @discussion The path to the JSON file located within the track package. File has a .json extension.
 */
@property(nonatomic, strong) NSURL * jsonPath;

/**
 @property videoPath
 @abstract The path to the relevant video file.
 @discussion The path to the Quicktime video file located within the track package. File has a .mov extension.
 */
@property(nonatomic, strong) NSURL * videoPath;

/**
 @property thumbnailPath
 @abstract The path to the relevant thumbnail file.
 @discussion The path to the thumbnail PNG file located within the track package. File has a .png extension.
 */
@property(nonatomic, strong) NSURL * thumbnailPath;

/**
 @property trackName
 @abstract The name of all of the files in the track directory.
 @discussion All of the files within a specific track directory have the same name, but have different file extensions. This is a string containing the name of these files, not including their extensions.
 */
@property(nonatomic, strong) NSString * trackName;

/**
 @property trackTitle
 @abstract The user-defined title of the track
 @discussion A string containing an optional, user-defined title for the track. The trackTitle is set to nil by default.
 */
@property(nonatomic, strong, setter=setTrackTitle:) NSString * trackTitle;

/**
 @property trackType;
 @abstract The type of track files contained within this directory.
 @discussion This string has two possible values: "video" and "image". A video track contains a video file and a json file. An audio track contains an image file, an audio file, and a json file.
 */
@property(nonatomic, strong) NSString * trackType;

/**
 @property latitude
 @abstract The latitude of the track.
 @discussion The latitude of the captured track. In the case of a video track, this value is equal to the latitude of the first captured location.
 */
@property(nonatomic, strong) NSNumber * latitude;

/**
 @property longitude
 @abstract The longitude of the track.
 @discussion The longitude of the captured track. In the case of a video track, this value is equal to the longitude of the first captured location.
 */
@property(nonatomic, strong) NSNumber * longitude;

/**
 @property date
 @abstract The time and date of the start of the track.
 @discussion The time and date of the captured track. This is the time that the recording started.
 */
@property(nonatomic, strong) NSDate * captureDate;

@property(nonatomic, strong) NSMutableArray * taggedPeople;
@property(nonatomic, strong) NSMutableArray * taggedPlaces;
@property(nonatomic, strong) NSDate * uploadedDate;

/**
 @method straboTrackFromFileWithName
 @abstract Builds a dictionary of the local file paths relevant to this track.
 @discussion Creates a dictionary for 
 @result NSDictionary Returns all file paths relevant to this track. Will either contain ("videoFile" and "jsonFile") or ("imageFile" and "audioFile" and "jsonFile"), depending on the trackType (as discussed above).
 */
+(StraboTrack *)straboTrackFromFileWithName:(NSString *)trackName;
-(BOOL)save;

/**
 @function getFilePaths
 @abstract Builds a dictionary of the local file paths relevant to this track.
 @discussion Creates a dictionary for 
 @result NSDictionary Returns all file paths relevant to this track. Will either contain ("videoFile" and "jsonFile") or ("imageFile" and "audioFile" and "jsonFile"), depending on the trackType (as discussed above).
 */
-(NSDictionary *)getFilePaths;

@end
