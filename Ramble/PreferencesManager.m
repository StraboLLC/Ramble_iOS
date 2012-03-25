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
        
        // Create a UUID for the device, if it does not already exist
        if (![defaults objectForKey:STRUUIDKey]) {
            NSString * UUID = [NSString stringWithFormat:@"%@", CFUUIDCreateString(NULL, CFUUIDCreate(NULL))];
            NSLog(@"UUID: %@", UUID);
            [defaults setObject:UUID forKey:STRUUIDKey];
        }
        
        // Set defaults if they do not exist
        if (![defaults objectForKey:STRPrecisionLocationModeOnKey] || ![defaults objectForKey:STRCompassModeMagneticKey] || ![defaults objectForKey:STRLaunchToCaptureModeKey] || ![defaults objectForKey:STRVideoModeHighKey]) {
            [defaults setObject:[NSNumber numberWithBool:false] forKey:STRPrecisionLocationModeOnKey];
            [defaults setObject:[NSNumber numberWithBool:true] forKey:STRCompassModeMagneticKey];
            [defaults setObject:[NSNumber numberWithBool:true] forKey:STRLaunchToCaptureModeKey];
            [defaults setObject:[NSNumber numberWithBool:false] forKey:STRVideoModeHighKey];
            [defaults synchronize];
        }
    }
    return self;
}

#pragma mark User Settings

-(void)setPrecisionLocationModeOn:(BOOL)precisionLocationModeOn {
    NSLog(@"Precision mode set: %@", precisionLocationModeOn ? @"YES" : @"NO");
    [defaults setObject:[NSNumber numberWithBool:precisionLocationModeOn] forKey:STRPrecisionLocationModeOnKey];
    [defaults synchronize];
}

-(BOOL)precisionLocationModeOn {
    return [[defaults objectForKey:STRPrecisionLocationModeOnKey] boolValue];
}

-(void)setCompassModeMagnetic:(BOOL)compassModeMagnetic {
    NSLog(@"Compass mode magnetic set: %@", compassModeMagnetic ? @"YES" : @"NO");
    [defaults setObject:[NSNumber numberWithBool:compassModeMagnetic] forKey:STRCompassModeMagneticKey];
    [defaults synchronize];
}

-(BOOL)compassModeMagnetic {
    return [[defaults objectForKey:STRCompassModeMagneticKey] boolValue];
}

-(void)setLaunchToCaptureMode:(BOOL)launchToCaptureMode {
    NSLog(@"Launch to capture mode set: %@", launchToCaptureMode ? @"YES" : @"NO");
    [defaults setObject:[NSNumber numberWithBool:launchToCaptureMode] forKey:STRLaunchToCaptureModeKey];
    [defaults synchronize];
}

-(BOOL)launchToCaptureMode {
    return [[defaults objectForKey:STRLaunchToCaptureModeKey] boolValue];
}

-(void)setVideoModeIsHigh:(BOOL)videoModeIsHigh {
    NSLog(@"Video high accuracy mode set: %@", videoModeIsHigh ? @"YES" : @"NO");
    [defaults setObject:[NSNumber numberWithBool:videoModeIsHigh] forKey:STRVideoModeHighKey];
    [defaults synchronize];
}

-(BOOL)videoModeIsHigh {
    return [[defaults objectForKey:STRVideoModeHighKey] boolValue];
}

#pragma mark Administrator Settings

-(NSString *)applicationUUID {
    return [defaults objectForKey:STRUUIDKey];
}

@end
