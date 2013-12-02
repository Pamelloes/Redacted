//
//  UsernameRegistrationViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import <UIKit/UIKit.h>

@interface UsernameRegistrationViewController : UIViewController {
	UIProgressView *progress;
	UILabel *label;
}

- (void) failureWithError: (NSError *) error;
- (void) failureWithString: (NSString *) error;

- (void) recievedKey: (NSString *) key;

@property (nonatomic, strong) IBOutlet UIProgressView *progress;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
