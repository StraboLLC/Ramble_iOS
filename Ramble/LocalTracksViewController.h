//
//  LocalTracksViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/31/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackDetailViewController.h"
#import "PreferencesViewController.h"
#import "LocalFileManager.h"
#import "TrackListItem.h"
#import "StraboTrack.h"
#import "Constants.h"

@interface LocalTracksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    LocalFileManager * localFileManager;
    NSArray * localTrackNames;
    
    IBOutlet UITableView * mainTableView;
    
    IBOutlet TrackListItem * tblCell;
}

@end
