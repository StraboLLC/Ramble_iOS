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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Test the facebook login
    self.loginManager = [[LoginManager alloc] init];
    if (![self.loginManager currentUser]) {
        NSLog(@"User is not logged in. Now logging user in.");
        [self.loginManager logInWithFacebook];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
