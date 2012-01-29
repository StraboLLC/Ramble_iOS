//
//  TrackListItem.h
//  Ramble
//
//  Created by Thomas Beatty on 1/27/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

/*!
 @header 
    @CFBundleIdentifier com.strabogis.Ramble
    @encoding utf-8
 @copyright Copyright 2011 Strabo LLC. All rights reserved.
 @updated 2012-08-15
 */

#import <UIKit/UIKit.h>

@interface TrackListItem : UITableViewCell {
    IBOutlet UILabel * title;
    IBOutlet UILabel * dateTaken;
    IBOutlet UIImageView * thumbnailImage;
    
    // Use to identify the associated track
    NSString * trackNameTag;
}

/*!
 @property title
 @abstract The title of the item in the list.
 @discussion A UILabel containing a string value that represents the title as it will be displayed on the list item in the table view.
 */
@property(nonatomic, strong) IBOutlet UILabel * title;

/*!
 @property dateTaken
 @abstract The date that the track was captured.
 @discussion A UILabel that contains the string value (title) of a nicely formatted capture date.
 */
@property(nonatomic, strong) IBOutlet UILabel * dateTaken;


@property(nonatomic, strong) IBOutlet UIImageView * thumbnailImage;

/*!
 @property trackNameTag
 @abstract A unique name identifying the track
 @discussion A unique name, usually the "trackName" property of the StraboTrack object represented by the cell, so that the cell can identify the StraboTrack object to push to display as a detail view.
 */
@property(nonatomic, strong) NSString * trackNameTag;

@end
