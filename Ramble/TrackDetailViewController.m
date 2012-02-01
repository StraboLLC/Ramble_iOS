//
//  TrackDetailViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/23/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "TrackDetailViewController.h"

@interface TrackDetailViewController (InternalMethods)
-(BOOL)setFileHasBeenUploaded;
@end

@interface TrackDetailViewController (UploadManagerDelegate) <UploadManagerDelegate>
-(void)uploadProgressMade:(double)percentComplete;
-(void)uploadStopped:(BOOL)cancelled withError:(NSError *)error;
-(void)uploadCompleted;
@end

@interface TrackDetailViewController (UITextFieldDelegate) <UITextFieldDelegate>
-(void)textFieldDidBeginEditing:(UITextField *)textField;
-(void)textFieldDidEndEditing:(UITextField *)textField;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    loginManager = appDelegate.loginManager;
    if (!loginManager.currentUser) {
        uploadButton.hidden = YES;
        statusLabel.text = @"Please log in to upload this capture.";
    } else {
        // Display content conditional on the file's upload history
        [self setFileHasBeenUploaded];
    }
    // Set up the display with the proper track information
    
    // Set the title
    if (![self.straboTrack.trackTitle isEqualToString:@""]) {
        titleTextField.text = self.straboTrack.trackTitle;
    }
    
    // Set the date
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; 
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy hh:mm" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    dateLabel.text = [formatter stringFromDate:straboTrack.captureDate];
    
    // Load the thumbnail image
    thumbnailImage.image = [UIImage imageWithContentsOfFile:self.straboTrack.thumbnailPath.absoluteString];
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
    
    // Only upload if the track has never been uploaded before.
    
    // Set a new upload manager
    uploadManager = [[UploadManager alloc] init];
    uploadManager.delegate = self;
    
    // Set up the upload view
    uploadProgress.progress = 0;
    [actionButton setTitle:@"Cancel" forState:UIControlStateNormal];
    uploadView.hidden = NO;
    uploadStatusLabel.text = @"Upload in Progress";
    
    // Fire up the uploader
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * authToken = appDelegate.loginManager.currentUser.authToken;
    NSString * userID = [NSString stringWithFormat:@"%@", appDelegate.loginManager.currentUser.userID];
    [uploadManager generateUploadRequestFor:[straboTrack trackName] inAlbum:@"Mobile Uploads" withAuthtoken:authToken withID:userID];
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

@end

@implementation TrackDetailViewController (InternalMethods)

-(BOOL)setFileHasBeenUploaded {
    if ([straboTrack.uploadedDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]]) {
        NSLog(@"File has never been uploaded before");
        statusLabel.text = nil;
        return false;
    } else {
        NSLog(@"File HAS been uploaded before.");
        statusLabel.text = @"You have uploaded this file before. You may not upload it again.";
        uploadButton.enabled = NO;
        return true;
    }
}

@end

@implementation TrackDetailViewController (UITextFieldDelegate)

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.straboTrack.trackTitle = textField.text;
    [self.straboTrack save];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
