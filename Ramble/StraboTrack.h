//
//  StraboTrack.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/15/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StraboTrack : NSObject {
    NSURL * trackPath;
    NSString * trackName;
    NSString * trackType;
    NSNumber * latitude;
    NSNumber * longitude;
    NSDate * createdDate;
    NSMutableArray * taggedPeople;
    NSMutableArray * taggedPlaces;
    NSDate * uploadedDate;
}

/*!
 @property directoryPath
 @abstract The path to the track directory.
 @discussion This is the path to the local directory containing the files relevant to a specific track. 
 */
@property(nonatomic, strong) NSURL * trackPath;

/*!
 @property trackName
 @abstract The name of all of the files in the track directory.
 @discussion All of the files within a specific track directory have the same name, but have different file extensions. This is a string containing the name of these files, not including their extensions.
 */
@property(nonatomic, strong) NSString * trackName;

/*!
 @property trackType;
 @abstract The type of track files contained within this directory.
 @discussion This string has two possible values: "video" and "image". A video track contains a video file and a json file. An audio track contains an image file, an audio file, and a json file.
 */
@property(nonatomic, strong) NSString * trackType;

/*!
 @property latitude
 @abstract The latitude of the track.
 @discussion The latitude of the captured track. In the case of a video track, this value is equal to the latitude of the first captured location.
 */
@property(nonatomic, strong) NSNumber * latitude;

/*!
 @property longitude
 @abstract The longitude of the track.
 @discussion The longitude of the captured track. In the case of a video track, this value is equal to the longitude of the first captured location.
 */
@property(nonatomic, strong) NSNumber * longitude;

/*!
 @property date
 @abstract The time and date of the start of the track.
 @discussion The time and date of the captured track. This is the time that the recording started.
 */
@property(nonatomic, strong) NSDate * createdDate;

@property(nonatomic, strong) NSMutableArray * taggedPeople;
@property(nonatomic, strong) NSMutableArray * taggedPlaces;
@property(nonatomic, strong) NSDate * uploadedDate;

+(StraboTrack *)straboTrackFromFileWithName:(NSString *)trackName;
-(BOOL)save;

/*!
 @method getFilePaths
 @abstract Builds a dictionary of the local file paths relevant to this track.
 @discussion Creates a dictionary for 
 @result NSDictionary Returns all file paths relevant to this track. Will either contain ("videoFile" and "jsonFile") or ("imageFile" and "audioFile" and "jsonFile"), depending on the trackType (as discussed above).
 */
-(NSDictionary *)getFilePaths;

@end
