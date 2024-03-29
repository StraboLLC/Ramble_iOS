//
//  ViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"
#import "TrackDetailViewController.h"
#import "LocalTracksNavigationController.h"
#import "PreferencesViewController.h"
#import "PreferencesManager.h"
#import "LoginManager.h"

@interface RootViewController : UIViewController {
    CaptureViewController * captureViewController;
    
    UIViewController * feedViewController;
    
    LoginManager * loginManager;
    PreferencesManager * preferencesManager;
    LocalFileManager * localFileManager;
    
    IBOutlet UIView * subView;
    IBOutlet UIImageView * rightButtonIcon;
}

@property(nonatomic, strong)LoginManager * loginManager;

-(IBAction)toggleViewButtonPressed:(id)sender;
-(IBAction)recentCaptureViewButtonPressed:(id)sender;

-(void)transitionToFeedList;
-(void)transitionToCaptureMode;

@end
