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

@implementation LoginManager

@synthesize delegate, facebook, currentUser;

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
        if ([defaults objectForKey:STRAccessTokenKey]) {
            self.currentUser.authToken = [defaults objectForKey:STRAccessTokenKey];
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

@end

@implementation LoginManager (InternalMethods)

-(NSString *)processForAuthToken:(NSData *)responseData {
    NSError * error = nil;
    NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"Error processing the JSON data.");
        return nil;
    }
    NSString * serverErrors = [[jsonData objectForKey:@"errors"] objectAtIndex:0];
    if ([serverErrors isEqualToString:@"true"]) {
        NSLog(@"Error submitted from the server.");
        return nil;
    } else {
        return [[jsonData objectForKey:@"user"] objectForKey:@"authtoken"];
    }
}

-(BOOL)logInWithStrabo {
    // Only log in if facebook is good to go
    if ([facebook isSessionValid]) {
        
        // Create a request to log the user in
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginServerURL]];
        NSString *params = [[NSString alloc] initWithFormat:@"username=%@&password=%@", @"username", @"passowrd"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Send the request to the API
        NSError * error = nil;
        NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        //NSLog(@"ResponseData: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        
        // Receive an authtoken back
        NSString * authToken = [self processForAuthToken:responseData];
        
        // Store the authtoken in NSUserDefaults
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:authToken forKey:STRAccessTokenKey];
        [defaults synchronize];
        
        // Update the current user object
        self.currentUser.authToken = authToken;
        
        if (error || !self.currentUser.authToken) {
            return false;
            if ([self.delegate respondsToSelector:@selector(straboLoginDidFailWithError:)]) {
                [self.delegate straboLoginDidFailWithError:error];
            }
        } else {
            return true;
        }
    }
    // User not logged in because facebook
    // session returned not valid.
    return false;
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

@implementation LoginManager (FBSessionDelegate)

-(void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:FBAccessTokenKey];
    [defaults setObject:[facebook expirationDate] forKey:FBExpirationDateKey];
    [defaults synchronize];
    self.currentUser = [[CurrentUser alloc] init];
    
    // Now that the user is logged in with Facebook,
    // log the user into the Strabo system
    if ([self logInWithStrabo]) {
        if ([self.delegate respondsToSelector:@selector(userDidLoginSuccessfully)]) {
            [self.delegate userDidLoginSuccessfully];
        }
    }
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