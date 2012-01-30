//
//  LocalTracksTableViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/21/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "LocalTracksTableViewController.h"

@interface LocalTracksTableViewController (InternalMethods)
-(TrackListItem *)configureCell:(TrackListItem *)cell forTrack:(NSString *)trackName;
@end

@implementation LocalTracksTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    localFileManager = [[LocalFileManager alloc] init];
    localTrackNames = [localFileManager allLocalStraboTracknames];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Reload the data, just in case the user edited anything
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [localTrackNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"trackListItemCell";
    
    TrackListItem * cell = (TrackListItem *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TrackListItem" owner:self options:nil];
        cell = tblCell;
    }
    
    // Configure the cell...
    NSString * trackName = [localTrackNames objectAtIndex:[indexPath indexAtPosition:1]];
    return [self configureCell:cell forTrack:trackName];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    TrackDetailViewController * trackDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrackDetail"];
    TrackListItem * cell = (TrackListItem *)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Requesting a cell: %@", cell.trackNameTag);
    trackDetailViewController.straboTrack = [StraboTrack straboTrackFromFileWithName:cell.trackNameTag];
    [self.navigationController pushViewController:trackDetailViewController animated:YES];
}

#pragma mark - Button Handling

-(IBAction)doneButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end

@implementation LocalTracksTableViewController (InternalMethods)

-(TrackListItem *)configureCell:(TrackListItem *)cell forTrack:(NSString *)trackName {
    // Acquire the necessary information to fill out the track
    // Get the track
    StraboTrack * track = [StraboTrack straboTrackFromFileWithName:trackName];
    NSString * title = nil;
    if (![track.trackTitle isEqualToString:@""]) {
        title = track.trackTitle;
    } else {
        // Generate a custom name for the track
        title = [NSString stringWithFormat:@"%.1f-cap.strabo", [track.captureDate timeIntervalSince1970]];
    }
    
    // Truncate the title if necessary
    NSString * shortTitle = nil;
    if (title.length <= 30) {
        shortTitle = title;
    } else {
        // String is too long: Truncate
        NSRange stringRange = {0, MIN([title length], 25)};
        stringRange = [title rangeOfComposedCharacterSequencesForRange:stringRange];
        shortTitle = [NSString stringWithFormat:@"%@...", [title substringWithRange:stringRange]];
    }
    
    // Generate the formatted date string
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; 
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy hh:mm" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    // Path for the thumbnail image
    NSURL * thumbnailURL = [track.trackPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", track.trackName]];
    NSLog(@"Image URL: %@", thumbnailURL);
    
    cell.thumbnailImage.image = [UIImage imageWithContentsOfFile:track.thumbnailPath.absoluteString];
    cell.trackNameTag = trackName;
    cell.title.text = shortTitle;
    cell.dateTaken.text = [formatter stringFromDate:track.captureDate];
    return cell;
}

@end
