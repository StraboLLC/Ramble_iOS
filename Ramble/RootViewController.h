//
//  ViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"
#import "LoginManager.h"

@interface RootViewController : UIViewController {
    CaptureViewController * captureViewController;
    UIViewController * listViewController;
    
    LoginManager * loginManager;
    
    IBOutlet UIView * subView;
}

@property(nonatomic, strong)LoginManager * loginManager;

-(IBAction)tableViewButtonPressed:(id)sender;
-(IBAction)cameraViewButtonPressed:(id)sender;

@end
