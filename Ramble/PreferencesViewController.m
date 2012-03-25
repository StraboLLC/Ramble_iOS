//
//  PreferencesViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/24/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController (LoginManagerDelegate) <LoginManagerDelegate>
-(void)userDidLoginSuccessfully;
-(void)facebookLoginDidFailWithError:(NSError *)error;
-(void)straboLoginDidFailWithError:(NSError *)error;
@end

@implementation PreferencesViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    preferencesManager = [[PreferencesManager alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    loginManager = appDelegate.loginManager;
    loginManager.delegate = self;
    
    // Set the UI inputs appropriately
    [locationModeSwitch setOn:[preferencesManager precisionLocationModeOn] animated:NO];
    [videoModeSwitch setOn:[preferencesManager videoModeIsHigh] animated:NO];
    [launchScreenSwitch setOn:[preferencesManager launchToCaptureMode] animated:NO];
    if ([preferencesManager compassModeMagnetic]) {
        headingSelector.selectedSegmentIndex = 1;
    } else {
        headingSelector.selectedSegmentIndex = 0;
    }
    
    // Hide the activity indicator
    [activityIndicator stopAnimating];
    
    // Check the user's login status and
    // update the login button appropriately
    if (loginManager.currentUser == nil) {
        [logInButton setTitle:@"Log In" forState:UIControlStateNormal];
        NSLog(@"User is not logged in.");
    } else {
        [logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    
    // Make sure the status bar is grey
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Handling

-(IBAction)locationModeSwitchDidChange:(id)sender {
    [preferencesManager setPrecisionLocationModeOn:locationModeSwitch.on];
}

-(IBAction)videoModeSwitchDidChange:(id)sender {
    [preferencesManager setVideoModeIsHigh:videoModeSwitch.on];
}

-(IBAction)launchScreenSwitchDidChange:(id)sender {
    [preferencesManager setLaunchToCaptureMode:launchScreenSwitch.on];
}

-(IBAction)headingSelectorDidChange:(id)sender {
    if (headingSelector.selectedSegmentIndex == 1) {
        [preferencesManager setCompassModeMagnetic:true];
    } else {
        [preferencesManager setCompassModeMagnetic:false];
    }
}

-(IBAction)logInButtonPressed:(id)sender {

    NSLog(@"Login Button Pressed");
    
    if ([logInButton.titleLabel.text isEqualToString:@"Log Out"]) {
        NSLog(@"Loggin the user out");
        // Log the user out
        [loginManager logOut];
        
        // Update the login button to reflect the change
        [logInButton setTitle:@"Log In" forState:UIControlStateNormal];
        
    } else if ([logInButton.titleLabel.text isEqualToString:@"Log In"]){
        NSLog(@"Logging the user in.");
        
        // Start animating the activityIndicator
        [activityIndicator startAnimating];
        
        // Log the user in
        [loginManager logInWithFacebook];
    }
}


-(IBAction)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end

@implementation PreferencesViewController (LoginManagerDelegate)

-(void)userDidLoginSuccessfully {
    [logInButton setTitle:@"Log Out" forState:UIControlStateNormal];

    [activityIndicator stopAnimating];
}

-(void)facebookLoginDidFailWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

-(void)straboLoginDidFailWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

@end