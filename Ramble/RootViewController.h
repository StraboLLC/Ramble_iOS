//
//  ViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"
#import "PreferencesManager.h"
#import "LoginManager.h"

@interface RootViewController : UIViewController {
    CaptureViewController * captureViewController;
    UINavigationController * listViewController;
    
    LoginManager * loginManager;
    PreferencesManager * preferencesManager;
    
    IBOutlet UIView * subView;
}

@property(nonatomic, strong)LoginManager * loginManager;

-(IBAction)tableViewButtonPressed:(id)sender;
-(IBAction)cameraViewButtonPressed:(id)sender;

-(void)transitionToCaptureMode;

@end
