//
//  LoginManager.m
//  Ramble
//
//  Created by Thomas Beatty on 1/18/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LoginManager.h"

@interface LoginManager (InternalMethods)
-(NSString *)processForAuthToken:(NSData *)responseData;
-(BOOL)logInWithStrabo;
-(void)logOutFromStrabo;
@end

@interface LoginManager (FBSessionDelegate) <FBSessionDelegate>
@end

@interface LoginManager (FBRequestDelegate) <FBRequestDelegate>
@end

@implementation LoginManager

@synthesize delegate, facebook, currentUser;

-(id)init {
    self = [super init];
    NSLog(@"Init Called");
    if (self) {
        NSLog(@"Self Checked");
        self.currentUser = nil;
        
        // Perform custom initialization here
        self.facebook = [[Facebook alloc] initWithAppId:@"303445329701888" andDelegate:self];
        
        // Check for previous authentication
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:FBAccessTokenKey]) {
            // Perform actions now that we know the user is logged in
            NSLog(@"Login Manager says that the user is logged in");
            self.facebook.accessToken = [defaults objectForKey:FBAccessTokenKey];
            self.facebook.expirationDate =[defaults objectForKey:FBExpirationDateKey];
            self.currentUser = [[CurrentUser alloc] init];
        }
        if ([defaults objectForKey:STRAccessTokenKey]) {
            self.currentUser.authToken = [defaults objectForKey:STRAccessTokenKey];
        }
        
    }
    return self;
}

-(void)logInWithFacebook {
    // Use facebook to log in if session is invalid
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:nil];
    }
}

-(void)logOut {
    [self.facebook logout];
}

@end

@implementation LoginManager (InternalMethods)

-(NSString *)processForAuthToken:(NSData *)responseData {
    NSError * error = nil;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    NSNumber * userID = [dict objectForKey:@"id"];
    NSLog(@"FBUser ID: %i", userID.intValue);
    NSString * unencryptedAuthtoken = [NSString stringWithFormat:@"%i%@", userID.intValue, STRSaltHash];
    NSLog(@"Authtoken: %@", [unencryptedAuthtoken MD5]);
    if (error) return nil;
    return [unencryptedAuthtoken MD5];
    
}

-(BOOL)logInWithStrabo {
    // Only log in if facebook is good to go
    if ([self.facebook isSessionValid]) {
        [self.facebook requestWithGraphPath:@"me" andDelegate:self];
    }
    // User not logged in because facebook
    // session returned not valid.
    return true;
}

-(void)logOutFromStrabo {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:STRAccessTokenKey]) {
        [defaults removeObjectForKey:STRAccessTokenKey];
        [defaults synchronize];
    }
    if (self.currentUser) {
        self.currentUser = nil;
    }
}

@end

@implementation LoginManager (FBRequestDelegate)

- (void)requestLoading:(FBRequest *)request {
    
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    // Part of the login process. When the response from facebook is received
    // process the response for the user's id and then generate an authtoken.
    NSLog(@"ResponseData: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString * authToken = [self processForAuthToken:data];
    
    if (authToken) {
    // Save the authtoken
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authToken forKey:STRAccessTokenKey];
    [defaults synchronize];
    
    self.currentUser.authToken = authToken;
        if ([self.delegate respondsToSelector:@selector(userDidLoginSuccessfully)]) {
            [self.delegate userDidLoginSuccessfully];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(straboLoginDidFailWithError:)]) {
            [self.delegate straboLoginDidFailWithError:nil];
        }
    }
}

@end

@implementation LoginManager (FBSessionDelegate)

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:FBAccessTokenKey];
    [defaults setObject:[self.facebook expirationDate] forKey:FBExpirationDateKey];
    [defaults synchronize];
    self.currentUser = [[CurrentUser alloc] init];
    
    NSLog(@"Defaults auth Key Saved: %@", [defaults objectForKey:FBAccessTokenKey]);
    // Now that the user is logged in with Facebook,
    // log the user into the Strabo system
    [self logInWithStrabo];
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
    NSLog(@"Logged out of facebook");
    // When logging out the facebook user, log the user out of Strabo
    [self logOutFromStrabo];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    if ([self.delegate respondsToSelector:@selector(straboLoginDidFailWithError:)]) {
        [self.delegate straboLoginDidFailWithError:nil];
    }
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
}

- (void)fbSessionInvalidated {   
}

@end