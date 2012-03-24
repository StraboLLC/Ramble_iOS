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
#import "NSString+MD5.h"

@protocol LoginManagerDelegate
@optional
-(void)userDidLoginSuccessfully;
-(void)facebookLoginDidFailWithError:(NSError *)error;
-(void)straboLoginDidFailWithError:(NSError *)error;
@end

@interface LoginManager : NSObject {
    id delegate;
    Facebook * facebook;
    CurrentUser * currentUser;
}

@property(strong)id delegate;
@property(nonatomic, retain)Facebook * facebook;
@property(nonatomic, retain)CurrentUser * currentUser;

-(void)logInWithFacebook;
-(void)logOut;

@end
