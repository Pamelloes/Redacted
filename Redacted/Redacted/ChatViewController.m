//
//  ChatViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/29/13.
//
//

#import "ChatViewController.h"

#import "AppDelegate.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize settings, newchat;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Redacted"]];
	image.frame = CGRectMake(0, 0, 100, 44);
	image.contentMode = UIViewContentModeScaleAspectFit;
	self.navigationItem.titleView = image;
}

- (void) viewDidAppear:(BOOL)animated {
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	[ad storyboardTransitionComplete: self];
	
	/*[self.navigationController setNavigationBarHidden:NO animated:NO];
		
		//self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
		
		//ad.rootNavigationController.navigationBar.barTintColor = [UIColor greenColor];
		
		//NSLog(@"%@ %@ %@", self.navigationItem, self.navigationController.navigationItem, self.navigationController.navigationBar.topItem);
		
		[self.navigationItem setTitle:@"TEST!"];

		//[self.navigationController.navigationBar setItems:[NSArray arrayWithObject: nav] animated:NO];
		
		UINavigationItem *item = self.navigationItem;
		NSLog(@"%@ %@ %@ %@", item, ad.rootNavigationController.navigationItem, item.leftBarButtonItem, settings);
		item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"o3o" style:UIBarButtonItemStyleBordered target:nil action:nil];
		item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"o4o" style:UIBarButtonItemStyleBordered target:nil action:nil];
	//});*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
