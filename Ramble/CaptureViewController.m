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

@interface CaptureViewController (CameraDataCollectorDelegate) <CameraDataCollectorDelegate>
-(void)videoRecordingDidBegin;
-(void)videoRecordingDidEnd;
-(void)videoRecordingFailedWithError:(NSError *)error;
@end

@interface CaptureViewController (LocalFileManagerDelegate) <LocalFileManagerDelegate>
-(void)saveTemporaryFilesFailedWithError:(NSError *)error;
-(void)temporaryFilesWereSaved;
@end

@interface CaptureViewController (InternalMethods)
-(void)recordLocationIfRecording;
-(void)startRecording;
-(void)stopRecording;
@end

@implementation CaptureViewController

@synthesize delegate;

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isRecording = NO;
    localFileManager = [[LocalFileManager alloc] init];
    localFileManager.delegate = self;
    preferencesManager = [[PreferencesManager alloc] init];
    
    // Set up the location stuff
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationDataCollector = [[LocationDataCollector alloc] init];
    locationDataCollector.delegate = self;
    
    // Set up the camera stuff
    cameraDataCollector = [[CameraDataCollector alloc] init];
    cameraDataCollector.delegate = self;
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[cameraDataCollector session]];
    captureVideoPreviewLayer.frame = videoPreviewView.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
    
    // Start updating the location
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

-(void)viewWillAppear:(BOOL)animated {
    
    // Turbocharge the accuracy if necessary
    if ([preferencesManager precisionLocationModeOn]) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    
    // Turbocharge the video quality if necessary
    if ([preferencesManager videoModeIsHigh]) {
        cameraDataCollector.session.sessionPreset = AVCaptureSessionPreset640x480;
    } else {
        cameraDataCollector.session.sessionPreset = AVCaptureSessionPreset352x288;
    }
    
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    // Hide the status bar
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated {
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    // Show the status bar
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Turn off the location updater
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    // Release any retained subviews of the main view.
    videoPreviewView = nil;
    locationManager = nil;
    locationDataCollector = nil;
    cameraDataCollector = nil;
    captureVideoPreviewLayer = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Handling

-(IBAction)recordButtonPressed:(id)sender {
    if (isRecording) {
        [self stopRecording];
        [recordButton setTitle:@"Rec" forState:UIControlStateNormal];
    } else {
        [self startRecording];
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

@end

@implementation CaptureViewController (InternalMethods)

-(void)recordLocationIfRecording {
    if (isRecording) {
        
        double direction;
        if ([preferencesManager compassModeMagnetic]) {
            direction = currentHeading.magneticHeading;
        } else {
            direction = currentHeading.trueHeading;
        }
        
        [locationDataCollector addDataPointWithLatitude:[currentLocation coordinate].latitude 
                                  withLongitude:[currentLocation coordinate].longitude 
                                    withHeading:direction
                                  withTimestamp:[[NSDate date] timeIntervalSinceDate:recordingStartTime]
                                   withAccuracy:[currentLocation horizontalAccuracy]];
    }
}

-(void)startRecording {
    [cameraDataCollector startRecording];
    [locationDataCollector clearDataPoints];
    recordingStartTime = [NSDate date];
    isRecording = YES;
}

-(void)stopRecording {
    isRecording = NO;
    // Once the user hits the stop button, start a loading screen
    [activityIndicator startAnimating];
    
    [cameraDataCollector stopRecording];
    [locationDataCollector writeJSONFileForTracktype:@"video" withCompassMode:@"mode" withOrientation:@"vertical"];
}

- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration 
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform = 
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

@end

@implementation CaptureViewController (CLLocationManagerDelegate)

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 5.0) {
        currentLocation = newLocation;
        [self recordLocationIfRecording];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    currentHeading = newHeading;
    
    double direction;
    if ([preferencesManager compassModeMagnetic]) {
        direction = newHeading.magneticHeading;
    } else {
        direction = newHeading.trueHeading;
    }
    
    [self recordLocationIfRecording];
    [self rotateImage:compassImage duration:0.1 
                curve:UIViewAnimationCurveLinear degrees:-direction];
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

@implementation CaptureViewController (CameraDataCollectorDelegate)

-(void)videoRecordingDidBegin {
    
}

-(void)videoRecordingDidEnd {
    // Save temporary files
    [localFileManager saveTemporaryFiles];
    if ([self.delegate respondsToSelector:@selector(parentShouldUpdateThumbnail)]) {
        [self.delegate parentShouldUpdateThumbnail];
    }
}

-(void)videoRecordingFailedWithError:(NSError *)error {
    
}

@end

@implementation CaptureViewController (LocalFileManagerDelegate)

-(void)saveTemporaryFilesFailedWithError:(NSError *)error {
    NSLog(@"Were");
    [activityIndicator stopAnimating];
}

-(void)temporaryFilesWereSaved {
    NSLog(@"Temporary Files Saved.");
    // This is the last step in the process. Notify the user of completion
    [activityIndicator stopAnimating];
}

@end