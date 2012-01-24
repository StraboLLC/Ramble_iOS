//
//  TrackDetailViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/23/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "TrackDetailViewController.h"

@interface TrackDetailViewController (UploadManagerDelegate) <UploadManagerDelegate>
-(void)uploadProgressMade:(double)percentComplete;
-(void)uploadStopped:(BOOL)cancelled withError:(NSError *)error;
-(void)uploadCompleted;
@end

@implementation TrackDetailViewController

@synthesize straboTrack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([straboTrack.trackTitle isEqualToString:@""]) {
        titleLabel.text = @"Some CG Title";
    } else {
        titleLabel.text = [self.straboTrack trackTitle];
    }
    
    NSLog(@"StraboTrack Information: \n title:%@ \n date: %@", self.straboTrack.trackTitle, self.straboTrack.captureDate);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Button Handling

-(IBAction)uploadButtonPressed:(id)sender {
    
    if ([straboTrack.uploadedDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]]) {
        NSLog(@"File has never been uploaded before");
    } else {
        NSLog(@"File HAS been uploaded before");
    }
    
    // Set a new upload manager
    uploadManager = [[UploadManager alloc] init];
    uploadManager.delegate = self;
    
    // Set up the upload view
    uploadProgress.progress = 0;
    [actionButton setTitle:@"Cancel" forState:UIControlStateNormal];
    uploadView.hidden = NO;
    uploadStatusLabel.text = @"Upload in Progress";
    
    // Fire up the uploader
    [uploadManager generateUploadRequestFor:[straboTrack trackName] inAlbum:@"Mobile Uploads" withAuthtoken:@"asdfjkl1234567890"];
    [uploadManager startUpload];
    
}

-(IBAction)actionButtonPressed:(id)sender {
    if ([actionButton.titleLabel.text isEqualToString:@"Cancel"]) {
        // Stop the upload
        [uploadManager cancelCurrentUpload];
        uploadView.hidden = YES;
    } else {
        uploadView.hidden = YES;
    }
}

-(IBAction)cancelButtonPressed:(id)sender {

}

@end

@implementation TrackDetailViewController (UploadManagerDelegate)

-(void)uploadProgressMade:(double)percentComplete {
    uploadProgress.progress = percentComplete;
}

-(void)uploadStopped:(BOOL)cancelled withError:(NSError *)error {
    // Release the upload manager
    uploadManager = nil;
    uploadStatusLabel.text = [NSString stringWithFormat:@"Error: ", error];
    [actionButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    
}

-(void)uploadCompleted {
    // Release the upload manager
    uploadManager = nil;
    uploadStatusLabel.text = @"Upload Completed";
    [actionButton setTitle:@"Neat!" forState:UIControlStateNormal];
    
    // Save the upload date in the StraboFile
    
    self.straboTrack.uploadedDate = [NSDate date];
    [self.straboTrack save];
}

@end
