//
//  FeedViewController.m
//  Ramble
//
//  Created by Thomas Beatty on 1/28/12.
//  Copyright (c) 2012 Strabo LLC. All rights reserved.
//

#import "FeedViewController.h"

@implementation FeedViewController

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"cellBackground.png"];
	[feedTableView setBackgroundColor:[UIColor colorWithPatternImage:img]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support section headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Title";
}
*/
 
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if ([indexPath indexAtPosition:0] == 0) { 
    //        // If a row is in the first section then it is the local files row
    //        // push a table view controller with the local files
    //        
    //        //UIStoryboard * theStoryboard = self.storyboard;
    //        LocalTracksTableViewController * localTracksTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocalTracks"];
    //        
    //        //LocalTracksTableViewController * localTracksTableViewController = [[LocalTracksTableViewController alloc] init];
    //        localTracksTableViewController.title = @"Potz Haz Skillz";
    //        
    //        // Pass the selected object to the new view controller.
    //        [self.navigationController pushViewController:localTracksTableViewController animated:YES];
    //        
    //    } else {
    //        // Navigation logic may go here. Create and push another view controller.
    //        CloudTracksTableViewController * cloudTracksTableViewController = [[CloudTracksTableViewController alloc] init];
    //        cloudTracksTableViewController.title = @"Mad Skillz";
    //        
    //        // Pass the selected object to the new view controller.
    //        [self.navigationController pushViewController:cloudTracksTableViewController animated:YES];
    //    }
}

#pragma mark Button Handling

-(IBAction)prefsButtonPressed:(id)sender {
    PreferencesViewController * preferencesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Preferences"];
    [self presentModalViewController:preferencesViewController animated:YES];
}


@end
