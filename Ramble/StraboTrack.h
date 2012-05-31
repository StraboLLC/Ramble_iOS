//
//  StraboTrack.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/15/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The StraboTrack is an object containing the filepaths to the track along with data about the track. It pulls information from the directory containing all of the files associated with a track and presents them in an accessible way.
 
 ##Creating StraboTrack Objects

 StraboTrack objects should be created when accessing or editing any information associated with a track. To create a StraboTrack, use the class method straboTrackFromFileWithName:. It is not recommended to instantiate a new StraboTrack without the use of this method.
 
 ##Editing the StraboTrack Information
 
 The JSON file associated with a track should never be altered directly. You should change information about a track by creating a new StraboTrack object, manipulating it, and saving your changes.
 
 First, create a new StraboTrack object. After changing the desired properties, call the saveChanges method to ensure that any changes to the object are written to the associated documents. It should be noted that most of the properties associated with the StraboTrack are generated automatically directly from the track's associated files. The only editable properties are:
 
 - trackTitle
 - taggedPeople
 - taggedPlaces
 - uploadedDate
 */

@interface StraboTrack : NSObject {
    NSURL * trackPath;
    NSURL * jsonPath;
    NSURL * mediaPath;
    NSURL * thumbnailPath;
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

///---------------------------------------------------------------------------------------
/// @name File Paths
///---------------------------------------------------------------------------------------

/**
 Returns the path to the directory containing all of the files associated with a track.
 */
@property(readonly) NSURL * trackPath;

/**
 Returns the path to the .JSON file associated with the track. 
 
 Documentation for this file can be found at the following link: [JSON docs](/mobile/JSON/index.html).
 */
@property(readonly) NSURL * jsonPath;

/**
 Returns the path to the video or image.
 */
@property(readonly) NSURL * mediaPath;

/**
 Returns the path to a thumbnail image of the track.
 
 This file is either one of the first frames of the video or it is a scaled-down version of the image.
 */
@property(readonly) NSURL * thumbnailPath;

/**
 The name of the track, excluding an extension. 
 
 The name of the files, not the user-defined trackTitle of the track. It should be noted that every file associated with the track has an identical file name but a different extension.
 */
@property(readonly) NSString * trackName;

///---------------------------------------------------------------------------------------
/// @name User-Defined Track Properties
///---------------------------------------------------------------------------------------

/**
 The user-defined title of the track.
 
 A string containing an optional, user-defined title for the track. The trackTitle is set to nil by default unless it is otherwise defined. This string is scrubbed free of special characters upon setting so that the web application is not confused.
 */
@property(nonatomic, strong, setter=setTrackTitle:) NSString * trackTitle;

/**
 An array specifying the names of people tagged in the track.
 
 @warning *Important* The structure of this array is undefined and undocumented. The web app does not yet know how to parse this information.
 */
@property(nonatomic, strong) NSMutableArray * taggedPeople;

/**
 An array specifying the names of places tagged in the track.
 
 @warning *Important* The structure of this array is undefined and undocumented. The web app does not yet know how to parse this information.
 */
@property(nonatomic, strong) NSMutableArray * taggedPlaces;

/**
 The date that the track was uploaded.
 
 Should return nil if the track has never been uploaded to the web application. Otherwise returns the date of upload formatted as an NSDate.
 */
@property(nonatomic, strong) NSDate * uploadedDate;

///---------------------------------------------------------------------------------------
/// @name Associated Geographical Data
///---------------------------------------------------------------------------------------

/**
 The first latitude position recorded in the track.
 */
@property(readonly) NSNumber * latitude;

/**
 The first longitude position recorded in the track.
 */
@property(readonly) NSNumber * longitude;

///---------------------------------------------------------------------------------------
/// @name Other Track Data
///---------------------------------------------------------------------------------------

/**
 The type of track files contained within this directory.
 
 This string has two possible values: "video" and "image". It specifies whether the track contains a still image file or a movie file.
 */
@property(readonly) NSString * trackType;

/**
 The time and date of the start of the track.
 
 The time and date of the captured track. This is the time that the recording started and is generated automatically according to the clock on the user's device at the time of capture.
 */
@property(readonly) NSDate * captureDate;

///---------------------------------------------------------------------------------------
/// @name Class Methods
///---------------------------------------------------------------------------------------

/**
 Builds a new StraboTrack object related to the TrackName specified.
 
 This method should be used to construct a StraboTrack object whenever the data of the StraboTrack needs to be accessed. It pulls from the JSON file and the relevant media files to determine all of the attributes of the track.
 
 @param trackName Should be the name of the track as a string without an extension. This is the same as every filename associated with the track. Note that this is NOT the same as the user-defined trackTitle.
 */
+(StraboTrack *)straboTrackFromFileWithName:(NSString *)trackName;

///---------------------------------------------------------------------------------------
/// @name Instance Methods
///---------------------------------------------------------------------------------------

/**
 Saves any changes to the StraboTrack object by writing them to the appropriate files.
 
 Should be called after any alteration to readwrite properties are made.
 */
-(BOOL)saveChanges;

/**
 Builds a dictionary of the local file paths relevant to this track.
 
 Returns all file paths relevant to this track. Will either contain ("videoFile" and "jsonFile") or ("imageFile" and "audioFile" and "jsonFile"), depending on the trackType (as discussed above).
 
 @bug *Deprecated* Use the properties trackPath, jsonPath, mediaPath, and thumbnailPath of a StraboTrack object to retrieve the file paths associated with a track.
 */
-(NSDictionary *)getFilePaths __attribute__((deprecated));

@end
