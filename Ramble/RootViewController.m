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
    
    // Test the facebook login
//    self.loginManager = [[LoginManager alloc] init];
//    if (![self.loginManager currentUser]) {
//        NSLog(@"User is not logged in. Now logging user in.");
//        [self.loginManager logInWithFacebook];
//    }
    //self.loginManager = [[LoginManager alloc] init];
    //3[self.loginManager logInWithFacebook];
    
    // Load the array of child controllers from the storyboard
    UIStoryboard * theStoryboard = self.storyboard;
    captureViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"CaptureViewController"];
    listViewController = [theStoryboard instantiateViewControllerWithIdentifier:@"NavController"];
    
    // Set up the controllers' views
    captureViewController.view.frame = subView.frame;
    listViewController.view.frame = subView.frame;
    
    [self addChildViewController:captureViewController];
    [self addChildViewController:listViewController];
    
    // Set up the first child controller
    [subView addSubview:captureViewController.view]; // Use Capture View
    //[subview addSubview:listViewController.view]; // Use List View
    
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

-(IBAction)tableViewButtonPressed:(id)sender {
    [self transitionFromViewController:captureViewController toViewController:listViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];
}

-(IBAction)cameraViewButtonPressed:(id)sender {
    [self transitionFromViewController:listViewController toViewController:captureViewController duration:0 options:UIViewAnimationTransitionFlipFromLeft animations:^{} completion:nil];
}

@end
