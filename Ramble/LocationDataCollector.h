//
//  LocationDataCollector.h
//  Ramble
//
//  Created by Thomas Beatty on 1/16/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

/*!
 @header 
    @CFBundleIdentifier com.strabogis.StraboGIS
    @encoding utf-8
 @copyright Copyright 2012 Strabo LLC. All rights reserved.
 @updated 2012-01-16
 @abstract Collects location datapoints and writes a JSON file containing collected points.
 @discussion A model to collect location datapoints during the recording of a track and then write those datapoints to a JSON temporary file in the required Strabo JSON file format.
 */

#import <Foundation/Foundation.h>

@protocol LocationDataCollectorDelegate

@optional

/*!
 @method writeJSONFileSuccessful
 @abstract Called if the JSON file was successfully written to a temporary file.
 */
-(void)writeJSONFileSuccessful;

/*!
 @method writeJSONFileFailedWithError:
 @abstract Notifies the delegate that there were errors writing the JSON file.
 */
-(void)writeJSONFileFailedWithError:(NSError *)error;

@end

@interface LocationDataCollector : NSObject {
    id delegate;
    NSMutableArray * dataPoints;
}

@property(strong)id delegate;

-(id)init;

/*!
 @method addDataPointWithLatitude:withLongitude:withHeading:withTimestamp:
 @abstract Adds a datapoint to the dataPoints array.
 @discussion Adds a datapoint to the dataPoints array. A datapoint object is a dictionary containing double primitive types relevant to the keys "latitude", "longitude", "heading", and "timestamp".
 @param latitude The latitude as a double.
 @param
 */
-(void)addDataPointWithLatitude:(double)latitude withLongitude:(double)longitude withHeading:(double)heading withTimestamp:(double)timestamp withAccuracy:(double)accuracy;

/*!
 @method writeJSONFile
 @abstract Writes the JSON file from the collected datapoints.
 @discussion Writes a JSON file to the temporary folder using a unique name generated from the time of recording and the device identifier. The JSON file contains all points in the dataPoints array.
 @param trackType A string representing the type of track being written. Possible values include "image" or "video".
 @param compassMode A string containing the compass mode - either true or magnetic.
 @param orientation - not implemented yet. Sets default value as vertical independent of input param.
 */
-(void)writeJSONFileForTracktype:(NSString *)trackType withCompassMode:(NSString *)compassMode withOrientation:(NSString *)orientation;

/*!
 @method clearDataPoints
 @abstract Clear datapoints so that a new set can be recorded.
 @discussion Clears the datapoints to record a new set. Calling this method before recording new points ensures that a JSON file associated with a movie will not hold old data.
 */
-(void)clearDataPoints;

@end
