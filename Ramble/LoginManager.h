//
//  LoginManager.h
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "FBConnect.h"
#import "CurrentUser.h"

@interface LoginManager : NSObject {
    Facebook * facebook;
    CurrentUser * currentUser;
    
}

@property(nonatomic, retain)Facebook * facebook;
@property(nonatomic, retain)CurrentUser * currentUser;

-(id)init;

-(void)logInWithFacebook;

@end
