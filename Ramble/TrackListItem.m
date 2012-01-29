//
//  TrackListItem.m
//  Ramble
//
//  Created by Thomas Beatty on 1/27/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "TrackListItem.h"

@implementation TrackListItem

@synthesize title, dateTaken, thumbnailImage, trackNameTag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
