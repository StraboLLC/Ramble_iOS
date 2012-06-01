//
//  PreferencesViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/24/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PreferencesManager.h"
#import "LoginManager.h"

@interface PreferencesViewController : UIViewController {
    PreferencesManager * preferencesManager;
    LoginManager * loginManager;
    
    IBOutlet UIView * buttonPanelView;
    
    IBOutlet UISwitch * locationModeSwitch;
    IBOutlet UISwitch * videoModeSwitch;
    IBOutlet UISegmentedControl * headingSelector;
    
    IBOutlet UIActivityIndicatorView * activityIndicator;
    
    IBOutlet UIButton * logInButton;
}

-(IBAction)locationModeSwitchDidChange:(id)sender;
-(IBAction)videoModeSwitchDidChange:(id)sender;
-(IBAction)headingSelectorDidChange:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;

-(IBAction)logInButtonPressed:(id)sender;

@end
