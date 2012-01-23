//
//  LocalFileManager.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/12/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StraboTrack.h"

@protocol LocalFileManagerDelegate
@optional
-(void)saveTemporaryFilesFailedWithError:(NSError *)error;
-(void)localFileManagerFailedWithError:(NSError *)error;

@end

@interface LocalFileManager : NSObject {
    id delegate;
    NSFileManager * fileManager;
}

@property(strong)id delegate;

-(id)init;

/*!
 @method saveTemporaryFiles
 @abstract Finds the temporary strabo file componenets in the temporary folder saves them permanently.
 @discussion Finds the output.mov and output.json files in the temp folder and moves them to the 
 @return NSArray Returns an array of the string names of all of the ".strabo" files within the local documents directory.
 */
-(void)saveTemporaryFiles;

/*!
 @method docsDirectoryPath
 @abstract Returns the local documents directory path.
 @discussion Pretty simple... not much more to discuss. A pretty helpful utility method, though.
 @result NSString The path of the local documents directory.
 */
-(NSString *)docsDirectoryPath;

/*!
 @method allLocalStraboFilenames;
 @abstract Gets a list of all local .strabo files
 @discussion Searches through the documents directory for all strabo videos 
 @return NSArray Returns an array of the string names of all of the ".strabo" files within the local documents directory.
 */
-(NSArray *)allLocalStraboTracknames;

/*!
 @method allLocalFiles
 @abstract Constructs an array of file objects for all local files.
 @discussion Searches for local strabo files and constructs an array of file objects for all local files. Note that this operation takes some time and system resources and if only the existance of directories is necessary, the list of local strabo filenames should be used.
 @return
 */
-(NSArray *)allLocalStraboTracks;

/*!
 @method straboTrackWithName:
 @abstract Gets the strabo track with the designated name
 @discussion Returns a strabo track object with the name specified in the parameters.
 @param trackName The name of the strabo track, excluding the file extension.
 @return StraboTrack Returns an object of custom type StraboTrack
 */
-(StraboTrack *)straboTrackWithName:(NSString *)trackName;

/*!
 @method deleteStraboFile:
 @abstract Deletes a strabo file with a given name from the local device.
 @discussion Searches the local directory structure for a strabo file (directory) with this name and then deletes the strabo file (directory) and its contents.
 @param fileName The name of the strabo file, excluding the file extension.
 */
-(void)deleteStraboTrack:(NSString *)trackName;

@end
