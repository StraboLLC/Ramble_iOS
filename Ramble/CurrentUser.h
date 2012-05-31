//
//  CurrentUser.h
//  Ramble
//
//  Created by Thomas Beatty on 1/19/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


/** Keeps track of the information that relates to the current user.
 
 This object holds information pertaining to a Strabo user.
 */
@interface CurrentUser : NSObject {
    NSString * authToken;
    NSNumber * userID;
}

///---------------------------------------------------------------------------------------
/// @name User Login Data
///---------------------------------------------------------------------------------------

/** Strabo-specific authtoken generated from a combination of the facebook authtoken and Strabo-specific credentials. */
@property(nonatomic, strong)NSString * authToken;

/** The user's facebook User ID, which is identical to the Strabo-specific User ID */
@property(nonatomic, strong)NSNumber * userID;

@end
