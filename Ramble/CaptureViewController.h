//
//  CaptureViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/16/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDataCollector.h"
#import "CameraDataCollector.h"
#import "LocalFileManager.h"
#import "PreferencesManager.h"

@protocol CaptureViewControllerDelegate
@optional
-(void)parentShouldUpdateThumbnail;
@end

@interface CaptureViewController : UIViewController {
    id delegate;
    
    CLLocationManager * locationManager;
    LocationDataCollector * locationDataCollector;
    CameraDataCollector * cameraDataCollector;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    LocalFileManager * localFileManager;
    PreferencesManager * preferencesManager;
    NSDate * recordingStartTime;
    BOOL isRecording;
    
    NSTimer * flashTimer;
    
    // Variables to hold the current device location information
    CLLocation * currentLocation;
    CLHeading * currentHeading;
    
    // UI Outlets
    IBOutlet UIButton * recordButton;
    IBOutlet UIImageView * recordLight;
    IBOutlet UIView * videoPreviewView;
    IBOutlet UIImageView * compassImage;
    IBOutlet UIActivityIndicatorView * activityIndicator;
}

@property(strong) id delegate;

/*!
 @method recordButtonPressed:
 @abstract Handler for the record button.
 @discussion Starts or stops recording depending on the current recording state of the local isRecording boolean value.
 */
-(IBAction)recordButtonPressed:(id)sender;

@end
