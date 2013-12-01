//
//  NewChatViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <UIKit/UIKit.h>

#import "TITokenField.h"

@interface NewChatViewController : UIViewController <TITokenFieldDelegate> {
	UIToolbar *toolbar;
}

- (IBAction) close:(id)sender;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

@end
