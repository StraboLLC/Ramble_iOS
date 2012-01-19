//
//  LocalFileManager.h
//  StraboGIS
//
//  Created by Thomas Beatty on 1/12/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocalFileManagerDelegate
@optional
-(void)saveTemporaryFilesFailedWithError:(NSError *)error;
-(void)fileManagerFailedWithError:(NSError *)error;

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

-(NSString *)docsDirectoryPath;

/*!
 @method allLocalStraboFilenames;
 @abstract Gets a list of all local .strabo files
 @discussion Searches through the documents directory for all strabo videos 
 @return NSArray Returns an array of the string names of all of the ".strabo" files within the local documents directory.
 */
-(NSArray *)allLocalStraboFilenames;

/*!
 @method allLocalFiles
 @abstract Constructs an array of file objects for all local files.
 @discussion Searches for local strabo files and constructs an array of file objects for all local files. Note that this operation takes some time and system resources and if only the existance of directories is necessary, the list of local strabo filenames should be used.
 @return
 */
-(NSArray *)allLocalStraboFiles;

-(void)deleteStraboFile:(NSString *)fileName;

@end
