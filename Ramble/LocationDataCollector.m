//
//  LocationDataCollector.m
//  Ramble
//
//  Created by Thomas Beatty on 1/16/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LocationDataCollector.h"

@interface LocationDataCollector (InternalMethods)

-(NSString *)tempFilePath;

@end

@implementation LocationDataCollector

@synthesize delegate;

-(id)init {
    if (self) {
        // Custom initialization done here
        [self clearDataPoints];
    }
    return self;
}

-(void)addDataPointWithLatitude:(double)latitude 
                  withLongitude:(double)longitude 
                    withHeading:(double)heading 
                  withTimestamp:(double)timestamp 
                   withAccuracy:(double)accuracy {
    // Write the numbers into strings for convenience
    NSString *latitudeStr = [NSString stringWithFormat:@"%2.6f", latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%3.6f", longitude];
    NSString *headingStr = [NSString stringWithFormat:@"%2.2f", heading];
    NSString *timestampStr = [NSString stringWithFormat:@"%f", timestamp];
    NSString *accuracyStr = [NSString stringWithFormat:@"%f", accuracy];
    
    // Create arrays for the new datapoint:
    NSArray * keys = [NSArray arrayWithObjects:@"latitude", @"longitude", @"heading", @"timestamp", @"accuracy", nil];
    NSArray * values = [NSArray arrayWithObjects:latitudeStr, longitudeStr, headingStr, timestampStr, accuracyStr, nil];
    NSDictionary * dataPoint = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    // Add the dataPoint to the array of dataPoints
    [dataPoints addObject:dataPoint];
}

-(void)writeJSONFileForTracktype:(NSString *)trackType 
                 withCompassMode:(NSString *)compassMode 
                 withOrientation:(NSString *)orientation {
    // Create a new object to represent the device
    UIDevice * myDevice = [UIDevice currentDevice];
    
    // Create keys and values for the main dictionary
    NSArray * keys = [NSArray arrayWithObjects:
                      @"title", 
                      @"captureDate", 
                      @"tracktype", 
                      @"deviceModel", 
                      @"softwareVersion", 
                      @"deviceName", 
                      @"compass", 
                      @"orientation",
                      @"taggedPeople"
                      @"taggedPlaces"
                      @"uploadDate"
                      @"points", 
                      nil];
    
    NSArray * values = [NSArray arrayWithObjects:
                        @"", 
                        [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]], 
                        trackType, 
                        [myDevice model],
                        [myDevice systemVersion], 
                        [myDevice name], 
                        compassMode, 
                        orientation,
                        [NSArray arrayWithObject:nil],
                        [NSArray arrayWithObject:nil],
                        @"",
                        dataPoints, 
                        nil];
    
    // Enter the values into a dictionary
    NSDictionary * track = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjects:values forKeys:keys] forKey:@"track"];
    
    // Create the output stream to write the file to the temp folder
    NSOutputStream * output = [NSOutputStream outputStreamToFileAtPath:[self tempFilePath] append:NO];
    [output open];
    
    // Write the JSON file to the temporary folder designated by the output stream
    NSError * error = nil;
    if ([NSJSONSerialization writeJSONObject:track toStream:output options:0 error:&error]) {
        if (!error) {
            // Notify the delegate of a success
            if ([self.delegate respondsToSelector:@selector(writeJSONFileSuccessful)]) {
                [self.delegate writeJSONFileSuccessful];
            }
        } else {
            // Notify the delgate of an error
            if ([self.delegate respondsToSelector:@selector(writeJSONFileFailedWithError:)]) {
                [self.delegate writeJSONFileFailedWithError:error];
            }
        }
    } else {
        // Notify the delgate of an error
        if ([self.delegate respondsToSelector:@selector(writeJSONFileFailedWithError:)]) {
            [self.delegate writeJSONFileFailedWithError:error];
        }
    }
}

-(void)clearDataPoints {
    // Clear current datapoints object
    dataPoints = nil;
    // Make a new array for the datapoints object
    dataPoints = [[NSMutableArray alloc] init];
}

@end

@implementation LocationDataCollector (InternalMethods)

// Return a string containing the temporary directory of the 
-(NSString *)tempFilePath {
    
    // Make the output path from components
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"output", @".json"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            if ([self.delegate respondsToSelector:@selector(writeJSONFileFailedWithError:)]) {
                [self.delegate writeJSONFileFailedWithError:error];
            }            
        }
    }
    return outputPath;
}

@end
