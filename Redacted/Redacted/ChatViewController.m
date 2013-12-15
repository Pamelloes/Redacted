//
//  ChatViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/29/13.
//
//

#import "ChatViewController.h"

#import "AppDelegate.h"
#import "ContactsDataSource.h"
#import "ContactViewController.h"

@interface CenteredIV : UIImageView
@end

@implementation CenteredIV

- (void) setFrame:(CGRect)frame {
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	[super setFrame:CGRectMake((width - 225) / 2.0f, 0, 225, 45)];
}

@end

@interface ChatViewController () {
	BOOL barvis;
	BOOL animating;
	
	ContactsDataSource *cds;
}

@end

@implementation ChatViewController

@synthesize tableView, edit, done, newchat, newcontact, tabbar, tabpos, settings, messages, contacts;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]" options:0 metrics:nil views:@{@"table":tableView}]];
	tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + 49, tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right);
	
	cds = [[ContactsDataSource alloc] initObject];
	
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

	done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	CenteredIV *image = [[CenteredIV alloc] initWithImage:[UIImage imageNamed:@"Redacted"]];
	image.frame = CGRectMake(0, 0, 80, 44);
	image.contentMode = UIViewContentModeScaleAspectFit;
	self.navigationItem.titleView = image;
	
	[cds reloadData];
	[tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	[ad storyboardTransitionComplete: self];
}

- (void) viewWillDisappear:(BOOL)animated {
	if (tableView.editing) [self edit:nil];
}

- (IBAction) navigationBarTapped:(id)sender {
	if (animating) return;
	barvis = !barvis;
	animating = YES;
	tabpos.constant = barvis ? 0 : -49;
	tabbar.alpha = 1.0;
	[tabbar setNeedsUpdateConstraints];
	[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + (barvis ? 49 : -49), tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right);
		[tabbar layoutIfNeeded];
	} completion: ^(BOOL finished){
		tabbar.alpha = barvis ? 1.0 : 0.0;
		animating = NO;
	}];
}

- (IBAction) edit:(id)sender {
	if (tableView.isEditing) {
		[self.navigationItem setLeftBarButtonItem:edit animated:YES];
		[tableView setEditing:NO animated:YES];
	} else {
		[self.navigationItem setLeftBarButtonItem:done animated:YES];
		[tableView setEditing:YES animated:YES];
	}
}

- (void) showSettings:(id)sender {
	
}

- (void) showMessages:(id)sender {
	if (animating) return;
	animating = YES;
	tableView.dataSource = self;
	tableView.delegate = self;
	[UIView transitionWithView:tableView duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[tableView reloadData];
	} completion: ^(BOOL finished){
		animating = NO;
	}];
	[self.navigationItem setRightBarButtonItem:newchat animated:YES];
}

- (void) showContacts:(id)sender {
	if (animating) return;
	animating = YES;
	tableView.dataSource = cds;
	tableView.delegate = cds;
	[cds reloadData];
	[UIView transitionWithView:tableView duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[tableView reloadData];
	} completion: ^(BOOL finished){
		animating = NO;
	}];
	[self.navigationItem setRightBarButtonItem:newcontact animated:YES];
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
- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"Contact"]) {
		ContactViewController *cvc = (ContactViewController *) [segue destinationViewController];
		Contact *c = [cds contactForIndexPath:tableView.indexPathForSelectedRow];
		cvc.contact = c;
	}
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item == settings) [self showSettings: nil];
	else if (item == messages) [self showMessages: nil];
	else if (item == contacts) [self showContacts: nil];
}

@end
