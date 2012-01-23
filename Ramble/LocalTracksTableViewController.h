//
//  LocalTracksTableViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/21/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalFileManager.h"
#import "StraboTrack.h"

@interface LocalTracksTableViewController : UITableViewController {
    LocalFileManager * localFileManager;
    NSArray * localTrackNames;
}

@end
