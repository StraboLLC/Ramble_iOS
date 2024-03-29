//
//  CameraDataCollector.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

/**
 Undocumented pending reorganization with the New Ramble.
 */
@protocol CameraDataCollectorDelegate
@optional
-(void)videoRecordingFailedWithError:(NSError *)error;
-(void)videoRecordingDidBegin;
-(void)videoRecordingDidEnd;
-(void)videoRecordingWasCanceled;
@end

/**
 Undocumented pending reorganization with the New Ramble.
 */
@interface CameraDataCollector : NSObject {
    id delegate;
    
    AVCaptureSession * session;
    AVCaptureDeviceInput * audioInput;
    AVCaptureDeviceInput * videoInput;
    AVCaptureVideoDataOutput * videoDataOutput;
    AVCaptureAudioDataOutput * audioDataOutput;
    AVCaptureMovieFileOutput * movieFileOutput;
    
}

@property(strong)id delegate;
@property(nonatomic, strong)AVCaptureSession * session;
@property(nonatomic, strong)AVCaptureDeviceInput * audioInput;
@property(nonatomic, strong)AVCaptureDeviceInput * videoInput;
@property(nonatomic, strong)AVCaptureAudioDataOutput * audioDataOutput;
@property(nonatomic, strong)AVCaptureVideoDataOutput * videoDataOutput;
@property(nonatomic, strong)AVCaptureMovieFileOutput * movieFileOutput;
@property (nonatomic,readonly,getter=isRecording) BOOL recording;

-(id)init;
-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation)deviceOrientation;
-(void)stopRecording;
-(void)cancelRecording;
-(BOOL)isRecording;
+(AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end
