//
//  ChatViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/29/13.
//
//

#import "ChatViewController.h"

#import "AppDelegate.h"

@interface ChatViewController () {
	BOOL barvis;
	BOOL animating;
}

@end

@implementation ChatViewController

@synthesize tableView, edit, newchat, tabbar, tabpos, settings, messages, contacts;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]" options:0 metrics:nil views:@{@"table":tableView}]];
	tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + 49, tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right);
	
	barvis = YES;
	animating = NO;
	tabbar.selectedItem = messages;
	
	CALayer *layer = tabbar.layer;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8;
	layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(tabbar.bounds.origin.x, tabbar.bounds.origin.y + tabbar.bounds.size.height - 1, tabbar.bounds.size.width, 1)].CGPath;
	layer.shouldRasterize = YES;

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
	
	/*UIView *view = self.view.superview;
	if (!view) return;
	NSLog(@"%@ %@", view, overlay);
	[overlay removeFromSuperview];
	[view addSubview:overlay];
	[view bringSubviewToFront:overlay];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:0 metrics:nil views:@{@"toolbar":overlay}]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar(==44)]" options:0 metrics:nil views:@{@"toolbar":overlay}]];
	overlay.backgroundColor = [UIColor blackColor];*/
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

- (IBAction) navigationBarTapped:(id)sender {
	if (animating) return;
	barvis = !barvis;
	animating = YES;
	tabpos.constant = barvis ? 0 : -49;
	[tabbar setNeedsUpdateConstraints];
	[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + (barvis ? 49 : -49), tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right);
		[tabbar layoutIfNeeded];
		tabbar.alpha = barvis ? 1.0 : 0.0;
	} completion: ^(BOOL finished){
		animating = NO;
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chat" forIndexPath:indexPath];
    
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
