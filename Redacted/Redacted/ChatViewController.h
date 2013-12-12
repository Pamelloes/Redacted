//
//  ChatViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/29/13.
//
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITabBarDelegate, UITableViewDataSource> {
	UITableView *tableView;
	
	UIBarButtonItem *edit;
	UIBarButtonItem *done;
	UIBarButtonItem *newchat;
	UIBarButtonItem *newcontact;
	
	UITabBar *tabbar;
	NSLayoutConstraint *tabpos;
	UITabBarItem *settings;
	UITabBarItem *messages;
	UITabBarItem *contacts;
}

- (IBAction) navigationBarTapped:(id)sender;

- (IBAction) showMessages:(id)sender;
- (IBAction) showSettings:(id)sender;
- (IBAction) showContacts:(id)sender;

- (IBAction) edit:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *edit;
@property (nonatomic, strong) UIBarButtonItem *done;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *newchat;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *newcontact;

@property (nonatomic, strong) IBOutlet UITabBar *tabbar;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tabpos;
@property (nonatomic, strong) IBOutlet UITabBarItem *settings;
@property (nonatomic, strong) IBOutlet UITabBarItem *messages;
@property (nonatomic, strong) IBOutlet UITabBarItem *contacts;

@end
