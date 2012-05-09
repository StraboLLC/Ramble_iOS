//
//  TrackDetailViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/23/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "TrackDetailViewController.h"

@interface TrackDetailViewController (InternalMethods)
-(BOOL)setUploadState;
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

// Constants for view animation with keyboard
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat VERTICAL_SLIDE_DISTANCE = 50;

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
        [self setUploadState];
    }
    
    // Set the background of the view
    UIImage *background = [UIImage imageNamed:@"cellBackground.png"];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:background]];
    
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
    // [thumbnailButton setBackgroundImage:[UIImage imageWithContentsOfFile:self.straboTrack.thumbnailPath.absoluteString] forState:UIControlStateNormal];
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

-(IBAction)playButtonPressed:(id)sender {
    
    NSLog(@"Preparing video playback");
    
    NSURL * resourcePath = [NSURL fileURLWithPath:[straboTrack videoPath].absoluteString];
    
    NSLog(@"Buffering video at URL: %@", resourcePath);
    
    previewPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:resourcePath];
    previewPlayer.moviePlayer.useApplicationAudioSession = NO;
    
    [self presentMoviePlayerViewControllerAnimated:previewPlayer];
}

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
    NSLog(@"Requesting Upload to: %@", userID);
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

-(BOOL)setUploadState {
    if ([straboTrack.uploadedDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]]) {
        NSLog(@"File has never been uploaded before");
        // Set the upload button to up and enabled
        [uploadButton setBackgroundImage:[UIImage imageNamed:@"uploadUp"] forState:UIControlStateNormal];
        [uploadButton setEnabled:YES];

        return false;
    } else {
        NSLog(@"File HAS been uploaded before.");
        // Depress and disable the upload button
        [uploadButton setBackgroundImage:[UIImage imageNamed:@"uploadDown"] forState:UIControlStateNormal];
        uploadButton.enabled = NO;
        
        return true;
    }
}

@end

@implementation TrackDetailViewController (UITextFieldDelegate)

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // Animate the view up so the keyboard does not hide the text fields
    
    // Set the desired frames
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= VERTICAL_SLIDE_DISTANCE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    // Animate the view back down to its original position
    
    // Set the desired frames
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += VERTICAL_SLIDE_DISTANCE;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    // Save the edited text
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
    
    if (percentComplete == 1) {
        uploadStatusLabel.text = @"Confirming Upload";
    }
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
    
    NSLog(@"Setting upload date: True");
    
    self.straboTrack.uploadedDate = [NSDate date];
    [self.straboTrack save];
    
    // Ensure that the user can't upload again
    // (after a successful upload)
    [self setUploadState];
    
}

@end
