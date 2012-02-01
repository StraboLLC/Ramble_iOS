//
//  RambleNavigationController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/31/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LocalTracksNavigationController.h"

@implementation LocalTracksNavigationController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the initial view controller from the storyboard
    localTracksViewController = (LocalTracksViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocalTracks"];
    
    // Set up the view
    localTracksViewController.view.frame = CGRectMake(0, 0, subView.frame.size.width, subView.frame.size.height);
    [self addChildViewController:localTracksViewController];
    
    // Add the first child controller
    [subView addSubview:localTracksViewController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Transition Methods

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self addChildViewController:viewController];
    ((UIViewController *)self.childViewControllers.lastObject).view.frame = CGRectMake(0, 0, subView.frame.size.height, subView.frame.size.width); 
    [self transitionFromViewController:[self.childViewControllers objectAtIndex:self.childViewControllers.count-2]
                      toViewController:[self.childViewControllers lastObject] 
                              duration:0 options:UIViewAnimationTransitionFlipFromLeft 
                            animations:^{} 
                            completion:nil];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController * topViewController =self.childViewControllers.lastObject;
    [self transitionFromViewController:topViewController
                      toViewController:[self.childViewControllers objectAtIndex:self.childViewControllers.count-2] 
                              duration:0 options:UIViewAnimationTransitionFlipFromLeft 
                            animations:^{} 
                            completion:^(BOOL finished){
                                [self.childViewControllers.lastObject removeFromParentViewController];
                            }];
    return topViewController; // To prevent compiler complaints
}

#pragma mark - Button Handling

-(IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)backButtonPressed:(id)sender {
    if (self.childViewControllers.count > 1) {
        [self popViewControllerAnimated:NO];
    }
}

@end
