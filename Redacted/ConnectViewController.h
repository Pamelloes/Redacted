//
//  ConnectViewController.h
//  Redacted
//
//  Created by Joshua Brot on 11/24/13.
//
//

#import <UIKit/UIKit.h>

@interface ConnectViewController : UIViewController {
	UIProgressView *progress;
	UILabel *label;
}

- (void) updateProgress: (NSString *) statusLine;

- (IBAction) showAcknoledgements:(id)sender;

@property (nonatomic, strong) IBOutlet UIProgressView *progress;
@property (nonatomic, strong) IBOutlet UILabel *label;

@end
