//
//  ViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "RootViewController.h"
#import "LoginManager.h"

@implementation RootViewController

@synthesize loginManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Listen for the app re-entering the foreground
    // Uncomment this if you want the app to switch
    // to capture mode after becomming active
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToCaptureMode) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    preferencesManager = [[PreferencesManager alloc] init];
    
    // Load the array of child controllers from the storyboard
    UIStoryboard * theStoryboard = self.storyboard;
    captureViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"CaptureViewController"];
    feedViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    
    // Set up the controllers' views
    captureViewController.view.frame = subView.frame;
    feedViewController.view.frame = subView.frame;
    
    [self addChildViewController:captureViewController];
    [self addChildViewController:feedViewController];
    
    // Set up the first child controller
    // based on user preferences
    if ([preferencesManager launchToCaptureMode]) {
        currentViewControllerIsCapture = true;
        [subView addSubview:captureViewController.view];
    } else {
        currentViewControllerIsCapture = false;
        [subView addSubview:feedViewController.view];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Handling

-(IBAction)toggleViewButtonPressed:(id)sender {
    if (currentViewControllerIsCapture) {
        [self transitionToFeedList];
    } else {
        [self transitionToCaptureMode];
    }
}

-(IBAction)recentCaptureViewButtonPressed:(id)sender {
    UINavigationController * tracksViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalTracksViewController"];
    [self presentViewController:tracksViewController animated:YES completion:NULL];
}

#pragma mark Methods

-(void)transitionToFeedList {
    currentViewControllerIsCapture = false;
    [self transitionFromViewController:captureViewController toViewController:feedViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];    
}

-(void)transitionToCaptureMode {
    currentViewControllerIsCapture = true;
    [self transitionFromViewController:feedViewController toViewController:captureViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];
}

@end
