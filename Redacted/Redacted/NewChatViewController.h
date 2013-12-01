//
//  NewChatViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <UIKit/UIKit.h>

@interface NewChatViewController : UIViewController {
	UIToolbar *toolbar;
}

- (IBAction) close:(id)sender;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@end
