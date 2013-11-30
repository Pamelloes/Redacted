//
//  ConnectViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/24/13.
//
//

#import "ConnectViewController.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController

@synthesize progress, label;

- (void)viewDidLoad {
    [super viewDidLoad];
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
}

- (void) updateProgress:(NSString *)statusLine {
    NSRange progress_loc = [statusLine rangeOfString:@"BOOTSTRAP PROGRESS="];
    NSRange progress_r = NSMakeRange(progress_loc.location + progress_loc.length, 2);
	
    NSString *progress_str = @"";
    if (progress_loc.location != NSNotFound)  progress_str = [statusLine substringWithRange:progress_r];
	
	[progress setProgress:[progress_str floatValue]/100.0f animated:YES];
	
    NSRange summary_loc = [statusLine rangeOfString:@" SUMMARY="];
    NSString *summary_str = @"";
    if (summary_loc.location != NSNotFound) summary_str = [statusLine substringFromIndex:summary_loc.location+summary_loc.length+1];
    NSRange summary_loc2 = [summary_str rangeOfString:@"\""];
    if (summary_loc2.location != NSNotFound) summary_str = [summary_str substringToIndex:summary_loc2.location];
	
	label.text = summary_str;
}

- (void) showAcknoledgements:(id)sender {
	NSLog(@"Acknowledgements...");
}

@end
