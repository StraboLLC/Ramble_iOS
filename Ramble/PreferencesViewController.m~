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
-(void)resetButtonGraphics;
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
    
    UIImage *background = [UIImage imageNamed:@"cellBackground.png"];
	[buttonPanelView setBackgroundColor:[UIColor colorWithPatternImage:background]];
    
    // Set the UI inputs appropriately
    [locationModeSwitch setOn:[preferencesManager precisionLocationModeOn] animated:NO];
    [videoModeSwitch setOn:[preferencesManager videoModeIsHigh] animated:NO];
    if ([preferencesManager compassModeMagnetic]) {
        headingSelector.selectedSegmentIndex = 1;
    } else {
        headingSelector.selectedSegmentIndex = 0;
    }
    
    // Hide the activity indicator
    [activityIndicator stopAnimating];
    
    // Check the user's login status and
    // update the login button appropriately
    [self resetButtonGraphics];
    
//    if (loginManager.currentUser == nil) {
//        [logInButton setTitle:@"Log In" forState:UIControlStateNormal];
//        NSLog(@"User is not logged in.");
//    } else {
//        [logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
//    }
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

-(IBAction)headingSelectorDidChange:(id)sender {
    if (headingSelector.selectedSegmentIndex == 1) {
        [preferencesManager setCompassModeMagnetic:true];
    } else {
        [preferencesManager setCompassModeMagnetic:false];
    }
}

-(IBAction)logInButtonPressed:(id)sender {

    NSLog(@"Login Button Pressed");
    
    [logInButton setEnabled:NO];
    
    if (loginManager.currentUser != nil) {
        NSLog(@"Logging the user out");
        // Log the user out
        [loginManager logOut];
        
        // Update the login button to reflect the change
        [self resetButtonGraphics];
        
    } else {
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
    
    // Update the login button to reflect the change
    [self resetButtonGraphics];

    [activityIndicator stopAnimating];
}

-(void)facebookLoginDidFailWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

-(void)straboLoginDidFailWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

-(void)resetButtonGraphics {
    
    [logInButton setEnabled:YES];
    
    if (loginManager.currentUser == nil) {
        
        NSLog(@"Setting the login button to display a login dialog");

        [logInButton setBackgroundImage:[UIImage imageNamed:@"loginUp"] forState:UIControlStateNormal];
        [logInButton setBackgroundImage:[UIImage imageNamed:@"loginDown"] forState:UIControlStateHighlighted];
        
    } else {

        NSLog(@"Setting the login button to display a logout dialog");
        
        [logInButton setBackgroundImage:[UIImage imageNamed:@"logoutUp"] forState:UIControlStateNormal];
        [logInButton setBackgroundImage:[UIImage imageNamed:@"logoutDown"] forState:UIControlStateHighlighted];
    }
}

@end