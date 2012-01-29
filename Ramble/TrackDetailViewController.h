//
//  TrackDetailViewController.h
//  Ramble
//
//  Created by Thomas Beatty on 1/23/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"
#import "Constants.h"
#import "StraboTrack.h"
#import "LocalFileManager.h"
#import "UploadManager.h"

@interface TrackDetailViewController : UIViewController {
    
    UploadManager * uploadManager;
    StraboTrack * straboTrack;

    // Detail View Outlets
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * dateLabel;
    IBOutlet UITextField * titleTextField;
    
    // Uploading View Outlets
    IBOutlet UIView * uploadView;
    IBOutlet UIProgressView * uploadProgress;
    IBOutlet UILabel * uploadStatusLabel;
    IBOutlet UIButton * actionButton;
    IBOutlet UIImageView * thumbnailImage;
}


@property(nonatomic, strong)StraboTrack * straboTrack;


-(IBAction)uploadButtonPressed:(id)sender;
-(IBAction)actionButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;

@end
