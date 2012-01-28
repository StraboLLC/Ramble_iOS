//
//  LocalTracksTableViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/21/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackDetailViewController.h"
#import "PreferencesViewController.h"
#import "LocalFileManager.h"
#import "TrackListItem.h"
#import "StraboTrack.h"

@interface LocalTracksTableViewController : UITableViewController {
    LocalFileManager * localFileManager;
    NSArray * localTrackNames;
    
    IBOutlet TrackListItem * tblCell;
}

-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)prefsButtonPressed:(id)sender;

@end
