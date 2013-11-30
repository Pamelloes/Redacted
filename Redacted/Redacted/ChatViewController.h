//
//  ChatViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/29/13.
//
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UITableViewController {
	UIBarButtonItem *settings;
	UIBarButtonItem *newchat;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *settings;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *newchat;

@end
