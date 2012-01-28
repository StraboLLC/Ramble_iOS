//
//  FeedViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/28/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"


@interface FeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView * feedTableView;
}

-(IBAction)prefsButtonPressed:(id)sender;

@end
