//
//  LocationDataCollector.h
//  Ramble
//
//  Created by Thomas Beatty on 1/16/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationDataCollectorDelegate

@optional

/*!
 Called by writeJSONFile:withCompassMode:withOrientation: if the JSON file is successfully written to a temporary file.
 */
-(void)writeJSONFileSuccessful;

/*!
 Notifies the delegate that there were errors writing the JSON file.
 
 @param error The error which caused the file writing to fail. Nil if the error is unknown.
 */
-(void)writeJSONFileFailedWithError:(NSError *)error;

@end

/**
 Collects location datapoints and writes a JSON file in the [appropriate format](http://doc.strabogis.com/mobile/JSON/index.html) for transfer to the web application.
 */
@interface LocationDataCollector : NSObject {
    id delegate;
    NSMutableArray * dataPoints;
}

///---------------------------------------------------------------------------------------
/// @name Specifying a Delegate
///---------------------------------------------------------------------------------------

/**
 The delegate for the receiver.
 */
@property(strong)id delegate;

///---------------------------------------------------------------------------------------
/// @name Creating a New UploadManager
///---------------------------------------------------------------------------------------

/**
 Returns an initialized UploadManager instance.
 
 @return An initialized UploadManager object.
 */
-(id)init;

///---------------------------------------------------------------------------------------
/// @name Handling Datapoints
///---------------------------------------------------------------------------------------

/**
 Adds a collected location datapoint to the dataPoints array.
 
 Adds a datapoint to the dataPoints array. A datapoint object is a dictionary containing double primitive types relevant to the keys "latitude", "longitude", "heading", and "timestamp". This method should be called to add a datapoint whenever a change in location or heading is sensed during the recording of a track.
 
 @param latitude The latitude double value.
 
 @param longitude The longitude double value.
 
 @param heading The 360 degree heading double value.
 
 @param timestamp The Unix timestamp double value.
 
 @param accuracy The accuracy double value.
 */
-(void)addDataPointWithLatitude:(double)latitude withLongitude:(double)longitude withHeading:(double)heading withTimestamp:(double)timestamp withAccuracy:(double)accuracy;

/**
 Writes the JSON file from the collected datapoints.
 
 Writes a JSON file to the temporary folder using a unique name generated from the time of recording and the device identifier. The JSON file contains all points in the dataPoints array in the format specified [here](http://doc.strabogis.com/mobile/JSON/index.html).
 
 @param trackType A string representing the type of track being written. Possible values include "image" or "video".
 
 @param compassMode A string containing the compass mode - either true or magnetic.
 
 @param orientation - not implemented yet. Sets default value as vertical independent of input param.
 
 @warning Horizontal recording orientation is not currently supported.
 */
-(void)writeJSONFileForTracktype:(NSString *)trackType withCompassMode:(NSString *)compassMode withOrientation:(NSString *)orientation;

/**
 Clear datapoints so that a new set of points can be recorded.

 Calling this method before recording new points ensures that a JSON file associated with a movie will not hold old data. Thus, the same LocationDataCollector object can be used for multiple recordings, limiting the number of new objects that must be created at the time of recording start.
 */
-(void)clearDataPoints;

@end
