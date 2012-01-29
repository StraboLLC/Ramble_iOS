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
    
//  	NSURL * temporaryMovieFilePath = [NSURL URLWithString:[[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"]];
//    AVURLAsset *asset = [AVURLAsset assetWithURL:temporaryMovieFilePath];
//    
//    // Now export the video file
//    AVAssetExportSession * sessionExporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPreset640x480];
//    sessionExporter.outputURL = [NSURL URLWithString:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]]];
//    NSLog(@"Available File Types: %@", sessionExporter.supportedFileTypes);
//    sessionExporter.outputFileType = @"com.apple.quicktime-movie";
//    
//    [sessionExporter exportAsynchronouslyWithCompletionHandler:^{
//        
//        switch ([sessionExporter status]) {
//            case AVAssetExportSessionStatusFailed:
//                NSLog(@"Export failed: %@", [[sessionExporter error] localizedDescription]);
//                break;
//            case AVAssetExportSessionStatusCancelled:
//                NSLog(@"Export canceled");
//                break;
//            default:
//                break;
//        }
//    }];
    
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
    
    // Take a screenshot for a preview
  	
    NSLog(@"Generate Video Thumbnail Called");
    
  	NSURL * temporaryMovieFilePath = [NSURL URLWithString:[[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"]];
  	
    NSLog(@"About to generate image from movie: %@", temporaryMovieFilePath);
    
    AVAsset *asset = [AVAsset assetWithURL:temporaryMovieFilePath];
    
    if (asset) {
        NSLog(@"Asset tracks: %@", asset.tracks.count);
    }
    
    if (asset.readable) {
        NSLog(@"Asset is readable");
    }
    if (asset.playable) {
        NSLog(@"Asset is playable");
    }
    if (asset.exportable) {
        NSLog(@"Asset is exportable");
    }
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    if (!generator) {
        NSLog(@"Generator is nil");
    }
    
    NSError *err = nil;
    CMTime time = CMTimeMakeWithSeconds(0,30);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    if (err) {
        NSLog(@"Error generating image: %@", err);
    }
    UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
    currentImg = nil; // Delete this line... it's just to avoid a compiler complaint.
    //NSString * pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    
    //NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(currentImg)];
	//[imageData writeToFile:pngPath atomically:YES];
    
    //    NSURL * videoPath = [NSURL URLWithString:[[self tempDirectoryPath] stringByAppendingPathComponent:@"output.mov"]];
    //    
    //    NSLog(@"Resource Path: %@", videoPath);
    //    
    //    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoPath];
    //    player.movieSourceType = MPMovieSourceTypeFile;
    //    
    //    UIImage * thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionExact];
    //    
    //    if (!thumbnail) {
    //        NSLog(@"Image Selection Failed");
    //    }
    //    
    //    [player stop];
    //    player = nil;
    //    
    //    NSString * pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    //    
    //    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(thumbnail)];
    //    
    //    NSLog(@"Image Data: %@", imageData);
    //    
    //   	[imageData writeToFile:pngPath atomically:YES];
}

@end