//
//  NSString+MD5.h
//  Ramble
//
//  Created by Thomas Beatty on 1/25/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Extends NSString with a function produce a string encrypted with the MD5 hash algorithm.
 */

@interface NSString(MD5)

/**
 Hashes a given string with the MD5 algorithm.
 */
-(NSString *)MD5;

@end
