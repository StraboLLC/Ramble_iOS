//
//  LoginManager.m
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LoginManager.h"

@interface LoginManager (FBSessionDelegate) <FBSessionDelegate>

@end

@implementation LoginManager

@synthesize facebook, currentUser;

-(id)init {
    self = [super init];
    if (self) {
        
        self.currentUser = nil;
        
        // Perform custom initialization here
        facebook = [[Facebook alloc] initWithAppId:@"303445329701888" andDelegate:self];
        
        // Check for previous authentication
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:FBAccessTokenKey]
            && [defaults objectForKey:FBExpirationDateKey]) {
            // Perform actions now that we know the user is logged in
            facebook.accessToken = [defaults objectForKey:FBAccessTokenKey];
            facebook.expirationDate =[defaults objectForKey:FBExpirationDateKey];
            self.currentUser = [[CurrentUser alloc] init];
        }
        
    }
    return self;
}

-(void)logInWithFacebook {
    // Use facebook to log in if session is invalid
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
}

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

@end

@implementation LoginManager (FBSessionDelegate)

-(void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:FBAccessTokenKey];
    [defaults setObject:[facebook expirationDate] forKey:FBExpirationDateKey];
    [defaults synchronize];
    self.currentUser = [[CurrentUser alloc] init];
}

-(void)fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:FBAccessTokenKey]) {
        [defaults removeObjectForKey:FBAccessTokenKey];
        [defaults removeObjectForKey:FBExpirationDateKey];
        [defaults synchronize];
    }
    if (self.currentUser) {
        self.currentUser = nil;
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled {
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
}

- (void)fbSessionInvalidated {   
}

@end