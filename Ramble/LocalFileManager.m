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
-(NSString *)docsDirectoryPath;

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
    NSString * directoryName = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    // Generate a name for the files
    NSString * fileName = [NSString stringWithFormat:@"%@-%@", @"UUID", directoryName];
    
    // Create the new subdirectory
    NSString * newDirectoryPath = [self createStraboFileDocumentsSubDirectoryWithName:directoryName];
    
    // Copy the files 
    [fileManager copyItemAtPath:movFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]] error:&error];
    [fileManager copyItemAtPath:jsonFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", fileName]] error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(saveTemporaryFilesFailedWithError:)]) {
            [self.delegate saveTemporaryFilesFailedWithError:error];
        }
        return;
    }
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

-(NSString *)docsDirectoryPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

@end