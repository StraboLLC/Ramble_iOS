//
//  RambleNavigationController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/31/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LocalTracksNavigationController.h"

@interface LocalTracksNavigationController (InternalMethods)
-(void)shouldPresentRootAccessoryView;
@end

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
    
    // Make sure that the back button doesn't appear initially
    backButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Make sure the status bar is grey
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:YES];
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
    backButton.hidden = NO;
    [self addChildViewController:viewController];
    ((UIViewController *)self.childViewControllers.lastObject).view.frame = CGRectMake(subView.frame.size.width, 
                                                                                       0, 
                                                                                       subView.frame.size.width, 
                                                                                       subView.frame.size.height);
    float transitionDuration = 0.25;
    [self transitionFromViewController:[self.childViewControllers objectAtIndex:self.childViewControllers.count-2]
                      toViewController:[self.childViewControllers lastObject] 
                              duration:transitionDuration 
                               options:UIViewAnimationOptionTransitionNone 
                            animations:^(void){
                                
                                UIView * hostView = [[self.childViewControllers objectAtIndex:self.childViewControllers.count-2] view];
                                UIGraphicsBeginImageContext(hostView.frame.size);
                                [hostView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                
                                CGRect incommingViewFrame = CGRectMake(0, 
                                                                       0, 
                                                                       subView.frame.size.width, 
                                                                       subView.frame.size.height);
                                
                                CGRect outgoingViewFrame = CGRectMake(-320, 0, subView.frame.size.width, subView.frame.size.height);
                                
                                [UIView animateWithDuration:transitionDuration
                                                      delay:0.0
                                                    options:0
                                                 animations:^{
                                                     hostView.frame = outgoingViewFrame;
                                                     ((UIViewController *)self.childViewControllers.lastObject).view.frame = incommingViewFrame;
                                                 } 
                                                 completion:^(BOOL finished){
                                                     NSLog(@"Animation Complete");
                                                 }];
                                
                            } 
                            completion:nil];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController * topViewController = self.childViewControllers.lastObject;
    UIViewController * nextViewController = [self.childViewControllers objectAtIndex:self.childViewControllers.count-2];
    nextViewController.view.frame = CGRectMake(-subView.frame.size.width, 
                                               0, 
                                               subView.frame.size.width, 
                                               subView.frame.size.height);
    float transitionDuration = 0.25;
    [self transitionFromViewController:topViewController
                      toViewController:nextViewController 
                              duration:transitionDuration
                               options:0 
                            animations:^{
                                
                                UIView * hostView = [topViewController view];
                                UIGraphicsBeginImageContext(hostView.frame.size);
                                [hostView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                
                                CGRect incommingViewFrame = CGRectMake(0, 
                                                                       0, 
                                                                       subView.frame.size.width, 
                                                                       subView.frame.size.height);
                                
                                CGRect outgoingViewFrame = CGRectMake(320, 0, subView.frame.size.width, subView.frame.size.height);
                                
                                [UIView animateWithDuration:transitionDuration
                                                      delay:0.0
                                                    options:0
                                                 animations:^{
                                                     hostView.frame = outgoingViewFrame;
                                                     nextViewController.view.frame = incommingViewFrame;
                                                 } 
                                                 completion:^(BOOL finished){
                                                     NSLog(@"Animation Complete");
                                                 }];
                            } 
                            completion:^(BOOL finished){
                                // If popping to the root view controller
                                if (self.childViewControllers.count < 1) {
                                    backButton.hidden = YES;
                                    accessoryButton.hidden = NO;
                                }
                                [self.childViewControllers.lastObject removeFromParentViewController];
                            }];
    return topViewController;
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

-(IBAction)accessoryButtonPressed:(id)sender {
    [self shouldPresentRootAccessoryView];
}

@end

@implementation LocalTracksNavigationController (InternalMethods)

// Implement this method to present the accessory view.
-(void)shouldPresentRootAccessoryView {
    
}

@end