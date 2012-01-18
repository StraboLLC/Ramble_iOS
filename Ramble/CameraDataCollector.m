//
//  CameraDataCollector.m
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "CameraDataCollector.h"

@interface CameraDataCollector (AVCaptureFileOutputRecordingDelegate) <AVCaptureFileOutputRecordingDelegate>



@end

@interface CameraDataCollector (InternalMethods)

-(AVCaptureDevice *)cameraWithPosition: (AVCaptureDevicePosition)position;
-(AVCaptureDevice *)frontFacingCamera;
-(AVCaptureDevice *)backFacingCamera;
-(AVCaptureDevice *)audioDevice;
-(NSURL *)tempFileURL;

@end

@implementation CameraDataCollector

@synthesize delegate;
@synthesize session, audioInput, videoInput, audioDataOutput, videoDataOutput, movieFileOutput, recording;

-(id)init {
    self = [super init];
    if (self) {
        self.session = [[AVCaptureSession alloc] init];
        self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
        self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        // set the session configuration
        [self.session beginConfiguration];
        
        // set the video quality
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        
        if ([self.session canAddInput:self.audioInput]) {                
            [self.session addInput:self.audioInput];
        }
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
        }
        if ([self.session canAddOutput:self.movieFileOutput]) {
            [self.session addOutput:self.movieFileOutput];
        }
        
        [self.session commitConfiguration];
        
        if (![self.session isRunning]) {
            [self.session startRunning];
            NSLog(@"Session is running");
        }
    }
    
    return self;
}

-(void)startRecording {
    AVCaptureConnection *videoConnection = [CameraDataCollector connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [[self movieFileOutput] startRecordingToOutputFileURL:self.tempFileURL
                                        recordingDelegate:self];
}

-(void)stopRecording {
    [[self movieFileOutput] stopRecording];
}

-(BOOL)isRecording {
    return [[self movieFileOutput] isRecording];
}

+(AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

@end

@implementation CameraDataCollector (InternalMethods)

-(AVCaptureDevice *)cameraWithPosition: (AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

-(AVCaptureDevice *)frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

-(AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

-(AVCaptureDevice *)audioDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

-(NSURL *)tempFileURL {
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            if ([self.delegate respondsToSelector:@selector(videoRecordingFailedWithError:)]) {
                [self.delegate videoRecordingFailedWithError:error];
            }            
        }
    }
    return outputURL;
}

@end

@implementation CameraDataCollector (AVCaptureFileOutputRecordingDelegate)

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    if ([self.delegate respondsToSelector:@selector(videoRecordingDidBegin)]) {
        [self.delegate videoRecordingDidBegin];
    }
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    if (error && [delegate respondsToSelector:@selector(videoRecordingFailedWithError:)]) {
        [delegate videoRecordingFailedWithError:error];
    } else if ([delegate respondsToSelector:@selector(videoRecordingDidEnd)]) {
        [delegate videoRecordingDidEnd];
    }
}

@end
