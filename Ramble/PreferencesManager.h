//
//  PreferencesManager.h
//  Ramble
//
//  Created by Thomas Beatty on 1/24/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

/**
 Manages preferences as an abstraction to NSUserDefaults.
 
 Use this object to set the application preferences and get the status of preferences. Methods are similar to setters and getters but directly reference and alter key associated values located in the NSUserDefaults standardUserDefaults object. Because of their similarity to setters and getters for properties, the instance methods of this class are referred to with the "setter" and "getter" nomenclature.
 
 The main purpose of having this object rather than accessing NSUserDefaults directly is to alleviate the need to continually reference the NSUserDefaults key strings (annoying to remember and make other code more confusing).
 */
@interface PreferencesManager : NSObject {
    NSUserDefaults * defaults;
}

///---------------------------------------------------------------------------------------
/// @name User-Determined Preferences
///---------------------------------------------------------------------------------------

/**
 Setter for precision location mode.
 
 @param precisionLocationModeOn True or false boolean to specify if precision location mode should be on or off.
 */
-(void)setPrecisionLocationModeOn:(BOOL)precisionLocationModeOn;

/**
 Getter for precision location mode.
 
 A [CaptureViewController](CaptureViewController) object should check this value when starting a new Location Manager.
 */
-(BOOL)precisionLocationModeOn;

/**
 Setter for magnetic compass mode.
 
 @param compassModeMagnetic True or False boolean to specify if magnetic compass mode should be on or off.
 */
-(void)setCompassModeMagnetic:(BOOL)compassModeMagnetic;

/**
 Getter for magnetic compass mode.
 
 A [CaptureViewController](CaptureViewController) object should check this value before setting the compass mode. If magnetic compass mode is off, the compass should give true heading rather than magnetic.
 */
-(BOOL)compassModeMagnetic;

/**
 Setter for launch to capture mode.
 
 @param launchToCaptureMode Boolean to specify if launch to capture mode should be on or off.
 */
-(void)setLaunchToCaptureMode:(BOOL)launchToCaptureMode __attribute__((deprecated));

/**
 Getter for launch to capture mode.
 
 This setting should be checked in the application delegate or in the root view controller to determine the first screen to show when the application launches.
 
 @warning This method is unused as of version 0.1.4
 */
-(BOOL)launchToCaptureMode __attribute__((deprecated));

/**
 Setter for high quality video mode.
 
 @param videoModeIsHigh Boolean to specify if the video recording should be high quality.
 */
-(void)setVideoModeIsHigh:(BOOL)videoModeIsHigh;

/**
 Getter for high quality video mode.
 
 This setting should be checked by the [CaptureViewController](CaptureViewController) to determine the quality of video recording.
 */
-(BOOL)videoModeIsHigh;

///---------------------------------------------------------------------------------------
/// @name Administrative Preferences
///---------------------------------------------------------------------------------------

/**
 Generates a UUID specific to this application.
 
 Alternative to using a device UUID as a unique string to this installed application as device UUIDs are deprecated in iOS 5. Should be combined with a date/time and used for generating [trackNames](StraboTrack trackName), or filenames that need to be completely unique to a track.
 */
-(NSString *)applicationUUID;

@end
