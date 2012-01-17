//
//  CaptureViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/16/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "CaptureViewController.h"

@interface CaptureViewController (CLLocationManagerDelegate) <CLLocationManagerDelegate>
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
@end

@interface CaptureViewController (LocationDataCollectorDelegate) <LocationDataCollectorDelegate>
-(void)writeJSONFileSuccessful;
-(void)writeJSONFileFailedWithError:(NSError *)error;
@end

@interface CaptureViewController (InternalMethods)
-(void)recordLocationIfRecording;
@end

@implementation CaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isRecording = NO;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        dataCollector = [[LocationDataCollector alloc] init];
        dataCollector.delegate = self;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)startRecording:(id)sender {
    isRecording = YES;
    // Some changes
}

-(IBAction)stopRecording:(id)sender {
    isRecording = NO;
    [dataCollector writeJSONFileForTracktype:@"video" withCompassMode:@"mode" withOrientation:@"vertical"];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Start updating the location
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Turn off the location updater
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

@implementation CaptureViewController (InternalMethods)

-(void)recordLocationIfRecording {
    if (isRecording) {
        [dataCollector addDataPointWithLatitude:[currentLocation coordinate].latitude 
                                  withLongitude:[currentLocation coordinate].longitude 
                                    withHeading:[currentHeading trueHeading]
                                  withTimestamp:0.0
                                   withAccuracy:[currentLocation horizontalAccuracy]];
    }
}

@end

@implementation CaptureViewController (CLLocationManagerDelegate)

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 5.0) {
        [self recordLocationIfRecording];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

@end

@implementation CaptureViewController (LocationDataCollectorDelegate)

-(void)writeJSONFileSuccessful {
    NSLog(@"JSON file appears to have written successfully");
}

-(void)writeJSONFileFailedWithError:(NSError *)error {
    NSLog(@"JSON writing failed with error: %@", error);
}

@end