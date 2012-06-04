//
//  ViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

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
    
    preferencesManager = [[PreferencesManager alloc] init];
    localFileManager = [[LocalFileManager alloc] init];
    
    // Load the child controllers from the storyboard
    UIStoryboard * theStoryboard = self.storyboard;
    captureViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"Capture"];
    captureViewController.delegate = self;
    
    // Set up the controllers' views
    captureViewController.view.frame = subView.frame;
    
    [self addChildViewController:captureViewController];
    
    // Set up the first child controller
    // based on user preferences
    [subView addSubview:captureViewController.view];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    captureViewController = nil;
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

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation==UIInterfaceOrientationPortrait);
}

#pragma mark Instance Methods

-(void)deviceDidRotate:(NSNotification *)notification {
    // Pass the orientation notification on to the captureViewController child
    if (captureViewController) {
        [captureViewController deviceDidRotate:notification];
    }
}

-(void)transitionToFeedList {
    [self transitionFromViewController:captureViewController toViewController:feedViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil]; 
    [self updateButtonIcon];
}

-(void)transitionToCaptureMode {
    [self transitionFromViewController:feedViewController toViewController:captureViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];
    [self updateButtonIcon];
}

#pragma mark Button Handling

-(IBAction)toggleViewButtonPressed:(id)sender {
    PreferencesViewController * preferencesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Preferences"];
    [self presentViewController:preferencesViewController animated:YES completion:NULL];
}

-(IBAction)recentCaptureViewButtonPressed:(id)sender {
    LocalTracksNavigationController * tracksNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalTracksNavigation"];
    [self presentViewController:tracksNavController animated:YES completion:NULL];
}

@end

@implementation RootViewController (InternalMethods)

-(void)refreshVideoThumbnail {
    
}

-(void)updateButtonIcon {
}

@end

@implementation RootViewController (CaptureViewControllerDelegate)

-(void)parentShouldUpdateThumbnail {
    NSLog(@"Thumbnail Delegate Method Called");
    [self refreshVideoThumbnail];
}

@end
