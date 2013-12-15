//
//  NewContactViewController.m
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import "ContactViewController.h"

#import "User.h"
#import "Contact.h"
#import "Configuration.h"
#import "Result.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "UserCell.h"

@interface ContactViewController () {
	UIView *content;
	
	NSMutableArray *cells;
	
	BOOL kb;
	CGSize kbSize;
	
	BOOL newc;
}

- (void) keyboardWillShow: (NSNotification *) notif;
- (void) keyboardWillHide: (NSNotification *) notif;

- (UIView *) firstResponderForView: (UIView *) view;

- (void) saveChanges;

@end

@implementation ContactViewController

@synthesize editing,contact;
@synthesize scrollView,cancel,done,editd;
@synthesize card,image,imaged,first,firstd,last,lastd,company,companyd;
@synthesize header,edit,add,users,ubottom;

- (void) viewDidLoad {
	kb = NO;
	if (!contact) {
		newc = YES;
		editing = YES;
		
		self.navigationItem.title = @"New Contact";
		
		NSError *error;
		contact = [Contact newEntityWithError:&error];
		if (error) DDLogError(@"Could not create new contact: %@", contact);
		
		contact.first = @"";
		contact.last = @"";
		contact.company = @"";
		
		cells = [[NSMutableArray alloc] initWithCapacity: 3];
		[cells addObject:[[UserCell alloc] initWithController:self User:nil Editing:YES]];
	} else {
		newc = NO;
		
		self.navigationItem.title = @"";
		
		cells = [[NSMutableArray alloc] initWithCapacity: [contact.users count]];
		for (User * u in contact.users) [cells addObject:[[UserCell alloc] initWithController:self User:u Editing:YES]];
	}
	
	content = self.view;
	content.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = content.frame;
	scrollView.contentSize = content.frame.size;
	scrollView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	scrollView.scrollEnabled = NO;
	[scrollView addSubview:content];
	
	const double rotate = 0.01;
	
	image.transform = CGAffineTransformMakeRotation(rotate);
	imaged.transform = CGAffineTransformMakeRotation(rotate);
	first.transform = CGAffineTransformMakeRotation(rotate);
	first.text = contact.first;
	firstd.transform = CGAffineTransformMakeRotation(rotate);
	firstd.text = contact.first;
	last.transform = CGAffineTransformMakeRotation(rotate);
	last.text = contact.last;
	lastd.transform = CGAffineTransformMakeRotation(rotate);
	lastd.text = contact.last;
	company.transform = CGAffineTransformMakeRotation(rotate);
	company.text = contact.company;
	companyd.transform = CGAffineTransformMakeRotation(rotate);
	companyd.text = contact.company;
	
	card.transform = CGAffineTransformMakeRotation(-rotate);
	
	CALayer *layer = card.layer;
	layer.allowsEdgeAntialiasing = YES;
	layer.cornerRadius = 5.0f;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8f;
	//layer.shadowPath = [UIBezierPath bezierPathWithRect:card.bounds].CGPath;
	
	layer = header.layer;
	layer.zPosition = 1;
	layer.masksToBounds = NO;
	layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
	layer.shadowColor = [[UIColor blackColor] CGColor];
	layer.shadowRadius = 1.0f;
	layer.shadowOpacity = 0.8f;
	layer.shadowPath = [UIBezierPath bezierPathWithRect:header.bounds].CGPath;
	
	edit.enabled = [cells count] > 1;
	
	image.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	image.titleLabel.textAlignment = NSTextAlignmentCenter;
	image.titleLabel.font = [UIFont systemFontOfSize:18.0f];
	layer = image.layer;
	layer.allowsEdgeAntialiasing = YES;
	layer.cornerRadius = 38.0f;
	layer.borderColor = [UIColor lightGrayColor].CGColor;
	layer.borderWidth = 2.0f;
	
	users.separatorInset = UIEdgeInsetsZero;
	users.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
	users.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	[self setEditing:editing];
}

- (UIView *) view {
	return scrollView ? scrollView : [super view];
}

- (void) viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) checkStatus {
	BOOL enabled = YES;
	for (UserCell *cell in cells) if (!cell.user) enabled = NO;
	done.enabled = enabled;
}

- (void) setContact:(Contact *) ctc {
	if (contact == ctc) return;
	
	if (!self.isViewLoaded) {
		contact = ctc;
		return;
	}
	
	if (!ctc) {
		newc = YES;
		editing = YES;
		
		self.navigationItem.title = @"New Contact";
		
		NSError *error;
		contact = [Contact newEntityWithError:&error];
		if (error) DDLogError(@"Could not create new contact: %@", contact);
		
		contact.first = @"";
		contact.last = @"";
		contact.company = @"";
		
		cells = [[NSMutableArray alloc] initWithCapacity: 3];
		[cells addObject:[[UserCell alloc] initWithController:self User:nil Editing:YES]];
	} else {
		newc = NO;
		
		self.navigationItem.title = @"";
		
		contact = ctc;
		cells = [[NSMutableArray alloc] initWithCapacity: [contact.users count]];
		for (User * u in contact.users) [cells addObject:[[UserCell alloc] initWithController:self User:u Editing:YES]];
	}
	
	edit.enabled = [cells count] > 1;
	
	[users reloadData];
	[self setEditing: editing];
}

- (void) setEditing:(BOOL)edt {
	[self setEditing:edt Animated:NO];
}

- (void) setEditing:(BOOL)edt Animated:(BOOL)animate {
	if (newc) return;
	
	void (^animation) () = ^void () {
		if (edt) {
			imaged.alpha = 0.0f;
			firstd.alpha = 0.0f;
			lastd.alpha = 0.0f;
			companyd.alpha = 0.0f;
			
			image.alpha = 1.0f;
			first.alpha = 1.0f;
			first.text = contact.first;
			last.alpha = 1.0f;
			last.text = contact.last;
			company.alpha = 1.0f;
			company.text = company.text;
			
			edit.alpha = 1.0f;
			add.alpha = 1.0f;
			for (UserCell *c in cells) c.editmode = YES;
			[self checkStatus];
		} else {
			[[self firstResponderForView: scrollView] resignFirstResponder];
			
			imaged.alpha = 1.0f;
			firstd.alpha = 1.0f;
			firstd.text = contact.first;
			lastd.alpha = 1.0f;
			lastd.text = contact.last;
			companyd.alpha = 1.0f;
			companyd.text = contact.company;
			
			image.alpha = 0.0f;
			first.alpha = 0.0f;
			last.alpha = 0.0f;
			company.alpha = 0.0f;
			
			edit.alpha = 0.0f;
			add.alpha = 0.0f;
			for (UserCell *c in cells) c.editmode = NO;
			[self checkStatus];
		}
	};
	
	if (animate) [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion: nil];
	else animation();
	
	if (edt) {
		[self.navigationItem setLeftBarButtonItem:cancel animated:animate];
		[self.navigationItem setRightBarButtonItem:done animated:animate];
	} else {
		[self.navigationItem setLeftBarButtonItem:nil animated:animate];
		[self.navigationItem setRightBarButtonItem:editd animated:animate];
	}
}

- (void) saveChanges {
	contact.first = first.text;
	contact.last = last.text;
	contact.company = company.text;
	
	for (User *u in [NSSet setWithSet:contact.users]) u.contact = nil;
	NSMutableArray *usrs = [[NSMutableArray alloc] initWithCapacity:[cells count]];
	for (UserCell *uc in cells) {
		((User *)[uc.user objectInCurrentThreadContext]).contact = contact;
		[usrs addObject:uc.user];
	}
	contact.users = [NSSet setWithArray:usrs];
}

#pragma mark - Keyboard Methods

- (void) keyboardWillShow: (NSNotification *) notif {
	kb = YES;
	
	NSDictionary* info = [notif userInfo];
	kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	[self focus: [self firstResponderForView:scrollView] Duration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue Curve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
}

- (void) keyboardWillHide: (NSNotification *) notif {
	kb = NO;
	
	NSDictionary* info = [notif userInfo];
	kbSize = CGSizeZero;
	
	[self focus: nil Duration:((NSNumber *)info[UIKeyboardAnimationDurationUserInfoKey]).doubleValue Curve:((NSNumber *)info[UIKeyboardAnimationCurveUserInfoKey]).intValue];
}

- (void) focus:(UIView *) view Duration: (NSTimeInterval) dur Curve: (UIViewAnimationCurve) curve {
	if ([view isDescendantOfView:users]) {
		UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0.0, kbSize.height, 0.0);
		if (UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) && UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, contentInsets)) return;

		ubottom.constant = 17;
		[users setNeedsUpdateConstraints];
		
		CGRect frame = [users convertRect: CGRectMake(users.bounds.origin.x, users.bounds.origin.y - 17, users.bounds.size.width, users.bounds.size.height) toView:scrollView];
		
		[UIView beginAnimations:@"Expand" context:nil];
		[UIView setAnimationCurve: curve];
		[UIView setAnimationDuration: dur];
		[users layoutIfNeeded];
		scrollView.contentInset = contentInsets;
		scrollView.scrollIndicatorInsets = contentInsets;
		[self.scrollView scrollRectToVisible:frame animated:NO];
		[UIView commitAnimations];
	} else {
		UIEdgeInsets contentInsets = UIEdgeInsetsZero;
		if (UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) && UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, contentInsets)) return;
		
		if (ubottom.constant != 0) {
			ubottom.constant = 0;
			[users setNeedsUpdateConstraints];
		}
		
		[UIView beginAnimations:@"Reset" context:nil];
		[UIView setAnimationCurve: curve];
		[UIView setAnimationDuration: dur];
		[users layoutIfNeeded];
		scrollView.contentInset = contentInsets;
		scrollView.scrollIndicatorInsets = contentInsets;
		[self.scrollView scrollRectToVisible:CGRectZero animated:NO];
		[UIView commitAnimations];
	}
	
}

- (UIView *) firstResponderForView:(UIView *)view {
	if ([view isFirstResponder]) return view;
	for (UIView *vw in view.subviews) {
		UIView *fr = [self firstResponderForView:vw];
		if (fr) return fr;
	}
	return nil;
}

#pragma mark - IBActions

- (IBAction) cancel:(id)sender {
	if (newc) {
		[contact delete];
		
		NSError *error = [Contact commit];
		if (error) DDLogError(@"Could not save deletion!");
		
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self setEditing:NO Animated:YES];
	}
}

- (IBAction) done:(id)sender {
	if (newc) {
		[self saveChanges];
		
		NSError *error;
		AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
		[ad.usermanager.config addContactsObject: contact];
		error = [Contact commit];
		if (error) DDLogError(@"Unable to commit new contact: %@", error);
		
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[self saveChanges];
		
		NSError *error = [Contact commit];
		if (error) DDLogError(@"Unable to save changes: %@", error);
		
		[self setEditing:NO Animated:YES];
	}
}

- (IBAction) navigationBarTapped:(id)sender {
	[self bgTap:sender];
}

- (IBAction) bgTap:(id)sender {
	[[self firstResponderForView:self.scrollView] resignFirstResponder];
}

- (IBAction) add:(id)sender {
	[cells addObject:[[UserCell alloc] initWithController:self User:nil Editing:YES]];
	[users insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[cells count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	edit.enabled = YES;
}

- (IBAction) edit:(id)sender {
	if (users.isEditing) {
		[edit setTitle:@"Edit" forState:UIControlStateNormal];
		[users setEditing:NO animated:YES];
	} else {
		[edit setTitle:@"Done" forState:UIControlStateNormal];
		[users setEditing:YES animated:YES];
	}
}

- (IBAction) beginEditing:(id)sender {
	[self setEditing:YES Animated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self focus:textField Duration:0.2 Curve:UIViewAnimationCurveEaseInOut];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (CGRectContainsPoint(users.bounds, [touch locationInView:users])) return false;
	return true;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [cells count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cells count] == 1) return UITableViewCellEditingStyleNone;
	else return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [cells removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		if ([cells count] == 1) {
			if (users.isEditing) [self edit:nil];
			edit.enabled = NO;
		}
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells count] != 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells count] != 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
