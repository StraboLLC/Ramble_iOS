//
//  ViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

// An alteration

#import "RootViewController.h"

@interface RootViewController (InternalMethods)
-(void)refreshVideoThumbnail;
-(void)updateButtonIcon;
@end

@interface RootViewController (CaptureViewControllerDelegate) <CaptureViewControllerDelegate>
-(void)parentShouldUpdateThumbnail;
@end

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
    localFileManager = [[LocalFileManager alloc] init];
    
    [self refreshVideoThumbnail];
    
    // Load the child controllers from the storyboard
    UIStoryboard * theStoryboard = self.storyboard;
    captureViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"Capture"];
    captureViewController.delegate = self;
    feedViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"Feed"];
    
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
    
    [self updateButtonIcon];
    
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
    
    [self refreshVideoThumbnail];
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
    LocalTracksNavigationController * tracksNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalTracksNavigation"];
    
//    if (localFileManager.mostRecentTrack) {
//        TrackDetailViewController * trackDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrackDetail"];
//        trackDetailViewController.straboTrack = localFileManager.mostRecentTrack;
//        [tracksNavController pushViewController:trackDetailViewController animated:NO];
//        
//        [self presentViewController:tracksNavController animated:YES completion:NULL];
//    }
    
    [self presentViewController:tracksNavController animated:YES completion:NULL];
}

#pragma mark Methods

-(void)transitionToFeedList {
    currentViewControllerIsCapture = false;
    [self transitionFromViewController:captureViewController toViewController:feedViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil]; 
    [self updateButtonIcon];
}

-(void)transitionToCaptureMode {
    currentViewControllerIsCapture = true;
    [self transitionFromViewController:feedViewController toViewController:captureViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];
    [self updateButtonIcon];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

@end

@implementation RootViewController (InternalMethods)

-(void)refreshVideoThumbnail {
    StraboTrack * straboTrack = localFileManager.mostRecentTrack;
    if (straboTrack) {
        lastVideoThumbnail.image = [UIImage imageWithContentsOfFile:localFileManager.mostRecentTrack.thumbnailPath.absoluteString];
    } else {
        lastVideoThumbnail.image = nil;
    }
}

-(void)updateButtonIcon {
    if (currentViewControllerIsCapture) {
        rightButtonIcon.image = [UIImage imageNamed:@"listIcon.png"];
    } else {
        rightButtonIcon.image = [UIImage imageNamed:@"cameraIcon.png"];
    }
}

@end

@implementation RootViewController (CaptureViewControllerDelegate)

-(void)parentShouldUpdateThumbnail {
    NSLog(@"Thumbnail Delegate Method Called");
    [self refreshVideoThumbnail];
}

@end
