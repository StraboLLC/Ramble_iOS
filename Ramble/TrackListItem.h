//
//  TrackListItem.h
//  Ramble
//
//  Created by Thomas Beatty on 1/27/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackListItem : UITableViewCell {
    IBOutlet UILabel * title;
    IBOutlet UILabel * dateTaken;
    IBOutlet UIImageView * thumbnailImage;
    
    // Use to identify the associated track
    NSString * trackNameTag;
}


@property(nonatomic, strong) IBOutlet UILabel * title;
@property(nonatomic, strong) IBOutlet UILabel * dateCaptured;
@property(nonatomic, strong) IBOutlet UIImageView * thumbnailImage;

@property(nonatomic, strong) NSString * trackNameTag;

@end
