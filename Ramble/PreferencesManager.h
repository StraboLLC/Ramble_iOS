//
//  PreferencesManager.h
//  Ramble
//
//  Created by Thomas Beatty on 1/24/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface PreferencesManager : NSObject {
    NSUserDefaults * defaults;
}

// User-controlled Preferences
-(void)setPrecisionLocationModeOn:(BOOL)precisionLocationModeOn;
-(BOOL)precisionLocationModeOn;

-(void)setCompassModeMagnetic:(BOOL)compassModeMagnetic;
-(BOOL)compassModeMagnetic;

-(void)setLaunchToCaptureMode:(BOOL)launchToCaptureMode;
-(BOOL)launchToCaptureMode;

// Admin Preferences
-(NSString *)applicationUUID;

@end
