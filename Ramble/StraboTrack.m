//
//  StraboTrack.m
//  StraboGIS
//
//  Created by Thomas Beatty on 1/15/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "StraboTrack.h"

@implementation StraboTrack

@synthesize trackPath, jsonPath, videoPath, thumbnailPath, trackName, trackTitle, trackType, latitude, longitude, captureDate, taggedPeople, taggedPlaces, uploadedDate;

+(StraboTrack *)straboTrackFromFileWithName:(NSString *)trackName {
    StraboTrack * straboTrack = [[StraboTrack alloc] init];
    
    // Find the JSON file from the trackName
    NSString * jsonFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", trackName]]];
    NSString * trackFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:trackName];
    
    // Read the JSON file
    NSData * data = [[NSFileManager defaultManager] contentsAtPath:jsonFilePath];
    
    if (data) {
        NSError * error = nil;
        NSDictionary * trackDictionary = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] objectForKey:@"track"];
        
        // Enter relevant info into the strabo track object
        straboTrack.trackName = trackName;
        straboTrack.trackPath = [NSURL URLWithString:trackFilePath];
        straboTrack.jsonPath = [NSURL URLWithString:jsonFilePath];
        straboTrack.videoPath = [NSURL URLWithString:[trackFilePath stringByAppendingFormat:[NSString stringWithFormat:@"%@.mov", trackName]]];
        straboTrack.thumbnailPath = [straboTrack.trackPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", straboTrack.trackName]];
        straboTrack.trackTitle = [trackDictionary objectForKey:@"title"];
        straboTrack.trackType = [trackDictionary objectForKey:@"tracktype"];
        straboTrack.latitude = [[[trackDictionary objectForKey:@"points"] objectAtIndex:0] objectForKey:@"latitude"];
        straboTrack.longitude = [[[trackDictionary objectForKey:@"points"] objectAtIndex:0] objectForKey:@"longitude"];
        straboTrack.captureDate = [NSDate dateWithTimeIntervalSince1970:[[trackDictionary objectForKey:@"captureDate"] integerValue]];
        straboTrack.taggedPeople = [trackDictionary objectForKey:@"taggedPeople"];
        straboTrack.taggedPlaces = [trackDictionary objectForKey:@"taggedPlaces"];
        straboTrack.uploadedDate = [NSDate dateWithTimeIntervalSince1970:[[trackDictionary objectForKey:@"uploadDate"] integerValue]];
        
        return straboTrack;
        
    } else {
        return nil;
    }
}

-(BOOL)save {
    
    // Find the associated JSON file
    NSString * jsonFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[self.trackName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", self.trackName]]];
    
    // Parse the file into Data
    NSData * data = [[NSFileManager defaultManager] contentsAtPath:jsonFilePath];
    NSError * error = nil;
    
    NSMutableDictionary * trackDictionary = [[NSMutableDictionary alloc] init];
    [trackDictionary addEntriesFromDictionary:[[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] objectForKey:@"track"]];
    
    
    [trackDictionary setObject:self.trackTitle forKey:@"title"];
    [trackDictionary setObject:self.taggedPeople forKey:@"taggedPeople"];
    [trackDictionary setObject:self.taggedPlaces forKey:@"taggedPlaces"];
    [trackDictionary setObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]] forKey:@"uploadDate"];
    
    NSDictionary * jsonDictionary = [NSDictionary dictionaryWithObject:trackDictionary forKey:@"track"];
    
    NSOutputStream * output = [NSOutputStream outputStreamToFileAtPath:jsonFilePath append:NO];
    [output open];
    
    // Write the JSON file to the temporary folder designated by the output stream
    
    if ([NSJSONSerialization writeJSONObject:jsonDictionary toStream:output options:0 error:&error]) {
        if (!error) {
            NSLog(@"File Save Successful");
        } else {
            // Notify the delgate of an error
            NSLog(@"An error occurred saving the file");
        }
    } else {
        // Notify the delgate of an error
        NSLog(@"An error occurred saving the file");
    }
    
    return YES;
}

-(NSDictionary *)getFilePaths {
    if ([trackType isEqualToString:@"video"]) {
        
        // Make the file paths from the track path, the filename, and a specific extension.
        NSURL * jsonFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.json", self.trackName] relativeToURL:self.trackPath];
        NSURL * videoFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.mov", self.trackName] relativeToURL:self.trackPath];
        
        // Organize the keys and values into arrays
        NSArray * keys = [NSArray arrayWithObjects:@"jsonFilePath", @"videoFilePath", nil];
        NSArray * values = [NSArray arrayWithObjects:jsonFilePath, videoFilePath, nil];
        
        // Return a dictionary using the arrays for keys and values
        return [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
    } else if ([trackType isEqualToString:@"images"]) {
        
        // Make the file paths from the track path, the filename, and a specific extension.
        NSURL * jsonFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.json", self.trackName] relativeToURL:self.trackPath];
        NSURL * imageFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.iso", self.trackName] relativeToURL:self.trackPath];
        NSURL * audioFilePath = [NSURL URLWithString:[NSString stringWithFormat:@"%@.caf", self.trackName] relativeToURL:self.trackPath];
        
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
