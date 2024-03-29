//
//  AppDelegate.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    LoginManager * loginManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginManager * loginManager;

@end