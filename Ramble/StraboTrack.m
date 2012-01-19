//
//  StraboTrack.m
//  StraboGIS
//
//  Created by Thomas Beatty on 1/15/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "StraboTrack.h"

@implementation StraboTrack

@synthesize trackPath, fileName, trackType, latitude, longitude, date;

-(NSDictionary *)getFilePaths {
    if ([trackType isEqualToString:@"video"]) {
        
        // Make the file paths from the track path, the filename, and a specific extension.
        NSURL * jsonFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.json", self.fileName] relativeToURL:self.trackPath];
        NSURL * videoFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.mov", self.fileName] relativeToURL:self.trackPath];
        
        // Organize the keys and values into arrays
        NSArray * keys = [NSArray arrayWithObjects:@"jsonFilePath", @"videoFilePath", nil];
        NSArray * values = [NSArray arrayWithObjects:jsonFilePath, videoFilePath, nil];
        
        // Return a dictionary using the arrays for keys and values
        return [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
    } else if ([trackType isEqualToString:@"images"]) {
        
        // Make the file paths from the track path, the filename, and a specific extension.
        NSURL * jsonFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.json", self.fileName] relativeToURL:self.trackPath];
        NSURL * imageFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.iso", self.fileName] relativeToURL:self.trackPath];
        NSURL * audioFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.caf", self.fileName] relativeToURL:self.trackPath];
        
        // Organize the keys and values into arrays
        NSArray * keys = [NSArray arrayWithObjects:@"jsonFilePath", @"imageFilePath", @"audioFilePath", nil];
        NSArray * values = [NSArray arrayWithObjects:jsonFilePath, imageFilePath, audioFilePath, nil];
        
        // Return a dictionary using the arrays for keys and values
        return [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
    } else {
        return nil;
    }
}

@end
