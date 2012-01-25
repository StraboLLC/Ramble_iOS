//
//  PreferencesManager.m
//  Ramble
//
//  Created by Thomas Beatty on 1/24/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "PreferencesManager.h"

@implementation PreferencesManager

-(id)init {
    if (self) {
        // Customize initialization here
        defaults = [NSUserDefaults standardUserDefaults];
        
        // Set defaults if they do not exist
        if (![defaults objectForKey:STRPrecisionLocationModeOnKey] || ![defaults objectForKey:STRCompassModeMagneticKey] || ![defaults objectForKey:STRLaunchToCaptureModeKey]) {
            [defaults setObject:[NSNumber numberWithBool:false] forKey:STRPrecisionLocationModeOnKey];
            [defaults setObject:[NSNumber numberWithBool:true] forKey:STRCompassModeMagneticKey];
            [defaults setObject:[NSNumber numberWithBool:true] forKey:STRLaunchToCaptureModeKey];
            [defaults synchronize];
        }
    }
    return self;
}

-(void)setPrecisionLocationModeOn:(BOOL)precisionLocationModeOn {
    [defaults setObject:[NSNumber numberWithBool:precisionLocationModeOn] forKey:STRPrecisionLocationModeOnKey];
    [defaults synchronize];
}

-(BOOL)precisionLocationModeOn {
    return [[defaults objectForKey:STRPrecisionLocationModeOnKey] boolValue];
}

-(void)setCompassModeMagnetic:(BOOL)compassModeMagnetic {
    [defaults setObject:[NSNumber numberWithBool:compassModeMagnetic] forKey:STRCompassModeMagneticKey];
    [defaults synchronize];
}

-(BOOL)compassModeMagnetic {
    return [[defaults objectForKey:STRCompassModeMagneticKey] boolValue];
}

-(void)setLaunchToCaptureMode:(BOOL)launchToCaptureMode {
    [defaults setObject:[NSNumber numberWithBool:launchToCaptureMode] forKey:STRLaunchToCaptureModeKey];
    [defaults synchronize];
}

-(BOOL)launchToCaptureMode {
    return [[defaults objectForKey:STRLaunchToCaptureModeKey] boolValue];
}

@end
