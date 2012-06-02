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
-(void)animateCompassFrom:(UIInterfaceOrientation)oldOrientation to:(UIInterfaceOrientation)newOrientation;
-(void)animateCompassOutFrom:(UIInterfaceOrientation)oldOrientation;
-(void)animateCompassInTo:(NSNumber *)newOrientation;
-(void)recordLocationIfRecording;
-(void)startRecording;
-(void)stopRecording;
-(void)cancelRecording;
-(void)animateRecordingLight;
-(void)stopAnimatingRecordingLight;
-(void)flashRecordingLightOn;
-(void)flashRecordingLightOff;
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
    
    // Set the duration of the flashing rec button
    flashDuration = (double)2.0;
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"Capture View will appear - Setting Up");
    
    // Make sure the status bar is translucent
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
                                                animated:YES];
    
    // Prevent the screen from going black while recording
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // Turbocharge the accuracy if necessary
    if ([preferencesManager precisionLocationModeOn]) {
        NSLog(@"Setting location accuracy - precisionLocationModeOn");
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    } else {
        NSLog(@"Setting location accuracy - precisionLocationModeOff");
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    // Turbocharge the video quality if necessary
    if ([preferencesManager videoModeIsHigh]) {
        NSLog(@"Setting video quality - videoModeIsHigh");
        cameraDataCollector.session.sessionPreset = AVCaptureSessionPreset640x480;
    } else {
        NSLog(@"Setting video quality - videoModeIsLow");
        cameraDataCollector.session.sessionPreset = AVCaptureSessionPreset352x288;
    }
    
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    NSLog(@"Capture View Controller will disappear before recording terminated.");
    NSLog(@"Stopping recording session and saving video.");
    
    [self cancelRecording];
    
    NSLog(@"Turning location off");
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    // Allow the idle timer to take over when the user is not capturing video
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidUnload {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // We don't actually want to rotate anything here...
    // we just want to move the compass to the proper side
    // and take care of the video recording orientation change
    NSLog(@"Capture view controller should change orientation to: %i", interfaceOrientation);
    
    // Animate the compass to the proper side
    [self animateCompassFrom:currentOrientation to:interfaceOrientation];
    
    // Finally, change our local variable for orientation
    currentOrientation = interfaceOrientation;
    
    // Don't acutally rotate the screen!
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Handling

-(IBAction)recordButtonPressed:(id)sender {
    if (isRecording) {
        [self stopRecording];
        [recordButton setImage:[UIImage imageNamed:@"recordUP"] forState:UIControlStateNormal];
        [self stopAnimatingRecordingLight];
    } else {
        [self startRecording];
        [recordButton setImage:[UIImage imageNamed:@"recordDOWN"] forState:UIControlStateNormal];
        [self animateRecordingLight];       
    }
}

@end

@implementation CaptureViewController (InternalMethods)

-(void)animateCompassFrom:(UIInterfaceOrientation)oldOrientation to:(UIInterfaceOrientation)newOrientation {
    // Animate the compass out
    [self animateCompassOutFrom:oldOrientation];
    
    // Animate the compass in
    [self performSelector:@selector(animateCompassInTo:) withObject:[NSNumber numberWithInt:newOrientation] afterDelay:(0.5)];
}

-(void)animateCompassOutFrom:(UIInterfaceOrientation)oldOrientation {
    if (oldOrientation == 1) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelay:0.0];
        
        CGRect tempFrame = compassElementsView.frame;
        tempFrame.origin.y = self.view.bounds.size.height;
        
        compassElementsView.frame = tempFrame;
        
        [UIView commitAnimations];
    }
    
    
}

-(void)animateCompassInTo:(NSNumber *)newOrientation {
    UIInterfaceOrientation orientation = newOrientation.intValue;
    if (orientation == 1) {
        
    } else if (orientation == 2) {
        
    } else if (orientation == 3) {
        
        compassElementsView.transform = CGAffineTransformMakeRotation(90);
        CGRect tempFrame = compassElementsView.frame;
        tempFrame.origin.y = 0;
        tempFrame.origin.x = 0;
        compassElementsView.frame = tempFrame;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelay:0.0];
        
        CGRect newFrame = tempFrame;
        newFrame.origin.x = 84;
        
        compassElementsView.frame = newFrame;
        
        [UIView commitAnimations];
        
    } else {
        
    }
}

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
    NSLog(@"Starting recording");
    [cameraDataCollector startRecordingWithOrientation:self.interfaceOrientation];
    [locationDataCollector clearDataPoints];
    recordingStartTime = [NSDate date];
    isRecording = YES;
    
    // Force record first datapoint
    [self recordLocationIfRecording];
}

-(void)stopRecording {
    NSLog(@"Stopping recording");
    isRecording = NO;
    // Once the user hits the stop button, start a loading screen
    [activityIndicator startAnimating];
    
    [cameraDataCollector stopRecording];
    
    // Set up the proper strings to pass to the LocationDataCollector
    NSString * compassModeString = (preferencesManager.compassModeMagnetic) ? @"magnetic" : @"true";
    NSString * currentOrientationString = ((currentOrientation == UIInterfaceOrientationPortrait) || (currentOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? @"vertical" : @"horizontal";
    
    [locationDataCollector writeJSONFileForTracktype:@"video" withCompassMode:compassModeString withOrientation:currentOrientationString];
}

-(void)cancelRecording {
    
    NSLog(@"Stopping recording");
    isRecording = NO;
    
    [cameraDataCollector stopRecording];
    [locationDataCollector writeJSONFileForTracktype:@"video" withCompassMode:@"mode" withOrientation:@"vertical"];
}

-(void)animateRecordingLight {
    recordLight.hidden = NO;
    [self flashRecordingLightOn];
    flashTimer = [NSTimer scheduledTimerWithTimeInterval:flashDuration 
                                                  target:self
                                                selector:@selector(flashRecordingLightOn) 
                                                userInfo:nil 
                                                 repeats:YES];
}

-(void)stopAnimatingRecordingLight {
    [flashTimer invalidate];
    recordLight.hidden = YES;
}

-(void)flashRecordingLightOn {
    if (isRecording) {
        //[NSTimer scheduledTimerWithTimeInterval:(flashDuration/2) target:self selector:@selector(flashRecordingLightOff) userInfo:nil repeats:NO];
        [self performSelector:@selector(flashRecordingLightOff) withObject:self afterDelay:(flashDuration/2)];
        // Animate on
        recordLight.alpha = 0.0;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:(flashDuration/2)];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        recordLight.alpha = 1.0;
        
        [UIView commitAnimations];
    }
}

-(void)flashRecordingLightOff {
    if (isRecording) {
        // Animate off
        recordLight.alpha = 1.0;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:(flashDuration/2)];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        recordLight.alpha = 0.0;
        
        [UIView commitAnimations];
    }
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
    NSLog(@"JSON file written");
}

-(void)writeJSONFileFailedWithError:(NSError *)error {
    NSLog(@"JSON file failed with error: %@", error);
}

@end

@implementation CaptureViewController (CameraDataCollectorDelegate)

-(void)videoRecordingDidBegin {
    NSLog(@"Video recording ended");
}

-(void)videoRecordingDidEnd {
    // Save temporary files
    NSLog(@"Video recording ended");
    [localFileManager saveTemporaryFiles];
    if ([self.delegate respondsToSelector:@selector(parentShouldUpdateThumbnail)]) {
        [self.delegate parentShouldUpdateThumbnail];
    }
}

-(void)videoRecordingFailedWithError:(NSError *)error {
    NSLog(@"Video recording failed: %@", error);
}

@end

@implementation CaptureViewController (LocalFileManagerDelegate)

-(void)saveTemporaryFilesFailedWithError:(NSError *)error {
    NSLog(@"Temporary file save failed with error: %@", error);
    [activityIndicator stopAnimating];
}

-(void)temporaryFilesWereSaved {
    NSLog(@"Temporary Files Saved.");
    // This is the last step in the process. Notify the user of completion
    [activityIndicator stopAnimating];
}

@end