//
//  LocalTracksNavigationController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/31/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalTracksViewController.h"
#import "TrackDetailViewController.h"

@interface LocalTracksNavigationController : UIViewController {
    
    UIViewController * localTracksViewController;
    IBOutlet UIView * subView;
}

-(IBAction)doneButtonPressed:(id)sender;

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
-(UIViewController *)popViewControllerAnimated:(BOOL)animated;

@end
