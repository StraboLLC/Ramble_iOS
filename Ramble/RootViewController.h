//
//  ViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/17/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"

@interface RootViewController : UIViewController {
    LoginManager * loginManager;
}

@property(nonatomic, strong)LoginManager * loginManager;

@end
