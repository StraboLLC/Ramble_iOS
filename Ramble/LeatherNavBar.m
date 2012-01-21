//
//  LeatherNavBar.m
//  Ramble
//
//  Created by Thomas Beatty on 1/21/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LeatherNavBar.h"

@implementation LeatherNavBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width, 50);
    return newSize;
}

- (void)drawRect:(CGRect)rect {
    // Add here to customize the navigation bar
    //UIImage *image = [UIImage imageNamed: @"NavigationBar.png"];
    //[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    // For now, just draw some red
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef redColor = [UIColor redColor].CGColor;
    CGContextSetFillColorWithColor(context, redColor);
    //CGContextFillRect(context, self.bounds);
    CGRect fillBox = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextFillRect(context, fillBox);
    
}

@end
