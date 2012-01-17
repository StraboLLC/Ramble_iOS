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

@interface CaptureViewController : UIViewController {
    CLLocationManager * locationManager;
    LocationDataCollector * dataCollector;
    
    // Variables to hold the current device information
    CLLocation * currentLocation;
    CLHeading * currentHeading;
    
    BOOL isRecording;
}
/*
@property(nonatomic, strong)CLLocationManager * locationManager;
@property(nonatomic, strong)LocationDataCollector * dataCollector;
@property(nonatomic, strong)CLLocation * currentLocation;
@property(nonatomic, strong)CLHeading * currentHeading;*/

/*!
 @method startRecording
 @abstract Start recording both video and location data.
 @discussion 
 */
-(IBAction)startRecording:(id)sender;

/*!
 @method stopRecording
 @abstract Stop recording both video and location data.
 @discussion
 */
-(IBAction)stopRecording:(id)sender;

@end
