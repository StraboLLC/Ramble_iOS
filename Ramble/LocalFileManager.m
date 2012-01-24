//
//  LocalFileManager.m
//  StraboGIS
//
//  Created by Thomas Beatty on 1/12/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LocalFileManager.h"

@interface LocalFileManager (InternalMethods)

-(NSString *)tempDirectoryPath;
-(NSString *)createStraboFileDocumentsSubDirectoryWithName:(NSString *)directoryName;

@end

@implementation LocalFileManager

@synthesize delegate;

-(id)init {
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc] init];
    }
    
    return self;
}

-(void)saveTemporaryFiles {
    
    NSError * error = nil;
    
    // Get the paths to the temp files
    NSString * movFilePath = [[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"];
    NSString * jsonFilePath = [[self tempDirectoryPath] stringByAppendingPathComponent:@"output.json"];
    
    // Check to make sure the temp files exist
    if (![fileManager fileExistsAtPath:movFilePath] || ![fileManager fileExistsAtPath:jsonFilePath]) {
        if ([self.delegate respondsToSelector:@selector(saveTemporaryFilesFailedWithError:)]) {
            [self.delegate saveTemporaryFilesFailedWithError:nil];
        }
        return;
    }
    
    // Generate a directory name for the .strabo documents sub directory
    NSString * UNIXTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    // Generate a name for the files
    NSString * trackName = [NSString stringWithFormat:@"%@-%@", @"UUID", UNIXTime];
    
    // Create the new subdirectory
    NSString * newDirectoryPath = [self createStraboFileDocumentsSubDirectoryWithName:trackName];
    
    // Copy the files 
    [fileManager copyItemAtPath:movFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]] error:&error];
    [fileManager copyItemAtPath:jsonFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]] error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(saveTemporaryFilesFailedWithError:)]) {
            [self.delegate saveTemporaryFilesFailedWithError:error];
        }
        return;
    }
}

-(NSString *)docsDirectoryPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

-(NSArray *)allLocalStraboTracknames {
    NSError * error = nil;
    NSArray * files = [fileManager contentsOfDirectoryAtPath:[self docsDirectoryPath] error:&error];
    if (error && [self.delegate respondsToSelector:@selector(localFileManagerFailedWithError:)]) {
        [self.delegate localFileManagerFailedWithError:error];
        return nil;
    }
    return files;
}

-(NSArray *)allLocalStraboTracks {
    
    NSArray * trackNames = [self allLocalStraboTracknames];
    
    // Create an array to hold the new StraboTrack objects
    NSMutableArray *straboTracks = [NSMutableArray array];
    
    // Create the enumerator
    NSEnumerator * enumerator = [trackNames objectEnumerator];
    id trackName;
    
    // Cycle through the filenames
    while (trackName = [enumerator nextObject]) {
        // Execute for each file
        // Add a strabo track with the proper
        // name to the array of tracks.
        [straboTracks addObject:[StraboTrack straboTrackFromFileWithName:trackName]];
    }
    return straboTracks;
}

-(void)deleteStraboTrack:(NSString *)trackName {
    
}

@end

@implementation LocalFileManager (InternalMethods)

-(NSString *)tempDirectoryPath {
    NSString * outputPath = [[NSString alloc] initWithFormat:@"%@", NSTemporaryDirectory()];
    return outputPath;
}

-(NSString *)createStraboFileDocumentsSubDirectoryWithName:(NSString *)directoryName {
    
    NSString *fullPath = [[self docsDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    NSError *error = nil;
    
    [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(saveTemporaryFilesFailedWithError:)]) {
            [self.delegate saveTemporaryFilesFailedWithError:error];
        }
    }
    return fullPath;
}

@end