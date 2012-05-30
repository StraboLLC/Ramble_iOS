//
//  TrackListItem.h
//  Ramble
//
//  Created by Thomas Beatty on 1/27/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A list item associated with a .xib file which defines how items are formatted on the track list. Contains the information for what is displayed on a specific item.
 */

@interface TrackListItem : UITableViewCell {
    IBOutlet UILabel * title;
    IBOutlet UILabel * dateTaken;
    IBOutlet UIImageView * thumbnailImage;
    
    // Use to identify the associated track
    NSString * trackNameTag;
}

/*!
 The title of the item in the list.
 
 A UILabel containing a string value that represents the title as it will be displayed on the list item in the table view.
 */
@property(nonatomic, strong) IBOutlet UILabel * title;

/*!
 The date that the track was captured.
 
 A UILabel that contains the string value (title) of a nicely formatted capture date.
 */
@property(nonatomic, strong) IBOutlet UILabel * dateTaken;


@property(nonatomic, strong) IBOutlet UIImageView * thumbnailImage;

/*!
 A unique name identifying the track
 
 A unique name, usually the "trackName" property of the StraboTrack object represented by the cell, so that the cell can identify the StraboTrack object to push to display as a detail view.
 */
@property(nonatomic, strong) NSString * trackNameTag;

@end
