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

/**
 The LoginManagerDelegate protocol defines optional methods for receiving status updates about a login to the Strabo and Facebook systems.
 */
@protocol LoginManagerDelegate

@optional

/**
 Called upon successful login to both the Strabo and Facebook systems.
 */
-(void)userDidLoginSuccessfully;

/**
 Called if the facebook login failed.
 
 @param error The error which caused the Facebook login to fail.
 */
-(void)facebookLoginDidFailWithError:(NSError *)error;

/**
 Called if the strabo login failed.
 
 @param error The error which caused the Strabo login to fail.
 */
-(void)straboLoginDidFailWithError:(NSError *)error;
@end

/**
 The LoginManager is used to log a user into any web services associated with the product.
 
 Due to the nature of the Facebook login API, the application delegate should instantiate only one LoginManager at application start. To reference information about the current logged in user, it is important to refreence the specific LoginManager whose parent is the AppDelegate. Again, due to the nature of the Facebook API, the LoginManager is not a standalone login system and needs to be connected with the AppDelegate to receive callbacks from Facebook.
 
 @bug The LoginManager should be a standalone system its tie to the AppDelegate will need to be severed in a future version of the application.
 
 ##Working with CurrentUser
 
 Accessing CurrentUser from other parts of the application can be done by obtaining a pointer to the LoginManager which is the child of the AppDelegate. This can be done by using code similar to the following:
 
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        LoginManager * loginManager = appDelegate.loginManager;
 
 Then the [CurrentUser](CurrentUser) object can be accessed (it is the object associated with the object currentUser) to obtain essential user information.
 
 ##Login Flow
 
 When logInWithFacebook is called, the object attempts to log into the facebook system. If Facebook login is successful, the application performs the necessary tasks to log into the Strabo system. Once a Strabo login is completed successfully, the LoginManager alerts its [delegate](LoginManagerDelegate). If there are any errors in either the Facebook or Strabo logins, seperate error delegate methods are called, alerting the receiver of a failed login.
 
 ##Checking for a Current User
 
 To check to see if a user is currently logged in, determine if the currentUser property is set to nil. A nil response verifies that a user is not currently logged in while a non-nil response verifies the presence of a logged in user. For example:
        
        if (currentUser) {
            NSLog("User is logged in. Now logging the current user out");
            [loginManager logOut];
        } else {
            NSLog("There is no user currently logged in");
        }
 */
@interface LoginManager : NSObject {
    id delegate;
    Facebook * facebook;
    CurrentUser * currentUser;
}

///---------------------------------------------------------------------------------------
/// @name Specifying a Delegate
///---------------------------------------------------------------------------------------
 
/**
 The delegate for the receiver.
 */
@property(strong)id delegate;

/**
 The Facebook object necessary for the Facebook login.
 
 This is the facebook login object specified in the Facebook login [API](https://developers.facebook.com/docs/mobile/ios/build/#implementsso).
 */
@property(nonatomic, retain)Facebook * facebook;

/**
 A [CurrentUser](CurrentUser) object to hold login information about the current user.
 
 The currentUser should be set to nil if the user is not logged in.
 */
@property(nonatomic, retain)CurrentUser * currentUser;

/**
 Logs the user in using the Facebook API.
 
 If the facebook login is successful, the user is then logged into the Strabo system. This method sets that chain of calls in motion.
 */
-(void)logInWithFacebook;

/**
 Logs the user out.
 
 This performs the necessary tasks to log the user out. At the end of the log out process, the currentUser property will be set to nil.
 */
-(void)logOut;

@end
