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
-(void)generateVideoThumbnailAtPath:(NSString *)outputPath error:(NSError **)error;
-(CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;

@end

@implementation LocalFileManager

@synthesize delegate;

-(id)init {
    self = [super init];
    if (self) {
        fileManager = [NSFileManager defaultManager];
        preferencesManager = [[PreferencesManager alloc] init];
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
    NSString * trackName = [NSString stringWithFormat:@"%@-%@", [preferencesManager applicationUUID], UNIXTime];
    
    // Create the new subdirectory
    NSString * newDirectoryPath = [self createStraboFileDocumentsSubDirectoryWithName:trackName];
    
    // Copy the files 
    [fileManager copyItemAtPath:movFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", trackName]] error:&error];
    [fileManager copyItemAtPath:jsonFilePath toPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]] error:&error];
    
    // Generate a thumbnail image
    [self generateVideoThumbnailAtPath:[newDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", trackName]] error:&error];
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(saveTemporaryFilesFailedWithError:)]) {
            [self.delegate saveTemporaryFilesFailedWithError:error];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(temporaryFilesWereSaved)]) {
        [self.delegate temporaryFilesWereSaved];
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
//#warning Not very good error handling here. Complete with blocking in the tableviewcontroller
    StraboTrack * track = [StraboTrack straboTrackFromFileWithName:trackName];
    NSError * error = nil;
    NSLog(@"Track to remove: %@", track.trackPath);
    [fileManager removeItemAtPath:track.trackPath.absoluteString error:&error];
    if (error) {
        NSLog(@"An error occurred deleting the file: %@", error);
    }
}

-(StraboTrack *)mostRecentTrack {
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.docsDirectoryPath error:nil];
    NSLog(@"Getting strabo file from: %@", directoryContents);
    return [StraboTrack straboTrackFromFileWithName:directoryContents.lastObject];
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

-(void)generateVideoThumbnailAtPath:(NSString *)outputPath error:(NSError *__autoreleasing *)error{
    
    NSURL * temporaryMovieFilePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mov"]];
    
    AVURLAsset * theFileAsset = [AVURLAsset URLAssetWithURL:temporaryMovieFilePath options:nil];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:theFileAsset];
    // Set the maximum size of the image. Constrained to aspect ratio
    generator.maximumSize = CGSizeMake(300, 300);
    
    NSError *err = nil;
    CMTime time = CMTimeMakeWithSeconds(0,30);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    UIImage * image = [UIImage imageWithCGImage:[self CGImageRotatedByAngle:imgRef angle:-90]];
    
    if (err) {
        // Set the error
    }
    
    // Set the image orientation
    //UIImage *currentImage = [UIImage imageWithCGImage:imgRef scale:1.0 orientation:UIImageOrientationDown];
    
    // Write image to PNG
    [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
    
    NSLog(@"Image Rotation Complete");
}

- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle {
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
    
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, YES);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   imgRef);
    
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
    
	return rotatedImage;
}

@end