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
-(void)generateVideoThumbnail;

@end

@implementation LocalFileManager

@synthesize delegate;

-(id)init {
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc] init];
        preferencesManager = [[PreferencesManager alloc] init];
    }
    
    return self;
}

-(void)saveTemporaryFiles {
    
    //[self generateVideoThumbnail];
    
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
    NSString * trackName = [NSString stringWithFormat:@"%@-%@", [preferencesManager applicationUUID], UNIXTime];
    
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

-(void)generateVideoThumbnail {
    
#warning Thumbnail generation is not yet functional.
    
    // Take a screenshot for a preview
  	
    //    NSLog(@"Generate Video Thumbnail Called");
    //    
    //  	NSURL * temporaryMovieFilePath = [NSURL URLWithString:[[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"]];
    //   	
    //    NSLog(@"About to generate image from movie: %@", temporaryMovieFilePath);
    //    
    //    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:temporaryMovieFilePath options:nil];
    //    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //    NSError *err = nil;
    //    CMTime time = CMTimeMakeWithSeconds(0,30);
    //    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    //    
    //    if (err) {
    //        NSLog(@"Error generating image: %@", err);
    //    }
    //    UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
    //    
    //    NSString * pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    //    
    //    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(currentImg)];
    //	[imageData writeToFile:pngPath atomically:YES];
    
//    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"]]];
//    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//    [player stop];
//    player = nil;
    
    //NSString * pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    
    //NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(thumbnail)];
   	//[thumbnail writeToFile:pngPath atomically:YES];
}

@end