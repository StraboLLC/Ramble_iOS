//
//  LocalFileManager.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/12/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "StraboTrack.h"
#import "PreferencesManager.h"

/**
 Optional methods called to help determin file handling progress.
 */
@protocol LocalFileManagerDelegate
@optional

/**
 Called by [saveTemporaryFiles](LocalFileManager saveTemporaryFiles) if there was an error.
 
 @param error The error which caused [saveTemporaryFiles](LocalFileManager saveTemporaryFiles) to fail.
 */
-(void)saveTemporaryFilesFailedWithError:(NSError *)error;

/**
 Called by [saveTemporaryFiles](LocalFileManager saveTemporaryFiles) if file save was successful.
 */
-(void)temporaryFilesWereSaved;

/**
 Called for other file management errors.
 
 @param error The error thrown by the LocalFileManager.
 */
-(void)localFileManagerFailedWithError:(NSError *)error;
@end

/**
 The LocalFileManager object is a custom file manager with methods which aid in the handling of the library of StraboTracks.
 */
@interface LocalFileManager : NSObject {
    id delegate;
    NSFileManager * fileManager;
    PreferencesManager * preferencesManager;
}

///---------------------------------------------------------------------------------------
/// @name Specifying a Delegate
///---------------------------------------------------------------------------------------

/**
 The delegate for the receiver.
 */
@property(strong)id delegate;

///---------------------------------------------------------------------------------------
/// @name Creating a New LocalFileManager
///---------------------------------------------------------------------------------------

/**
 Returns an initialized LocalFileManager instance.
 
 @return An initialized LocalFileManager object.
 */
-(id)init;

///---------------------------------------------------------------------------------------
/// @name Path Utilities
///---------------------------------------------------------------------------------------

/*!
 Gets the path to the local documents directory.
 
 @return NSString The path of the local documents directory.
 */
-(NSString *)docsDirectoryPath;

///---------------------------------------------------------------------------------------
/// @name Manipulating Tracks
///---------------------------------------------------------------------------------------

/*!
 Finds the temporary strabo file componenets in the temporary folder saves them permanently.
 
 Finds the output.mov and output.json files in the temp folder and moves them to the proper location in the documents directory heirarchy.
 */
-(void)saveTemporaryFiles;

/*!
 Gets a list of all local .strabo files.
 
 Searches through the documents directory for all strabo tracks.
 
 @return NSArray Returns an array of strings: names of all of the tracks within the local documents directory.
 */
-(NSArray *)allLocalStraboTracknames;

/*!
 Constructs an array of file objects for all local files.
 
 Searches for local strabo files and constructs an array of [StraboTrack](StraboTrack) objects for all local tracks. Note that this operation takes some time and system resources. If you are searching only for the existance of the track directories or a list of track names, the allLocalStraboTracknames should be used.
 
 @return NSArray An array of all locally existing StraboTrack objects.
 */
-(NSArray *)allLocalStraboTracks;

/*!
 Finds the most recently recorded track
 
 Enumerates through the documents directory to find the track with the most recent creation date. Then creates and returns the corresponding StraboTrack object.
 
 @return StraboTrack The most recently recorded StraboTrack of object type [StraboTrack](StraboTrack).
 */
-(StraboTrack *)mostRecentTrack;

/*!
 Deletes a strabo file with a given name from the local device.
 
 Searches the local directory structure for a track with this name and then deletes the track (directory) and its contents.
 
 @param fileName The name of the strabo file, excluding the file extension. Known in [StraboTrack](StraboTrack) as "trackName."
 */
-(void)deleteStraboTrack:(NSString *)trackName;

@end
