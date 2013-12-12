//
//  UsernameRegistrationViewController.m
//  Redacted
//
//  Created by Joshua Brot on 11/28/13.
//
//

#import "UsernameRegistrationViewController.h"

#import "JSONKit.h"
#import "AppDelegate.h"
#import "User.h"
#import "DDLog.h"
#import "URLUtil.h"
#import "Result.h"
#import "UserManager.h"

typedef enum {
	SENDING_REQUEST,
	WAITING_FOR_KEY,
	COMPLETING,
	VALIDATING
} rstate;

@interface UsernameRegistrationViewController () {
	NSTimer *loop;
	
	Result *res;
	BOOL cancelled;
	
	rstate state;
}

- (void) checkStatus: (NSTimer *) timer;

@end

@implementation UsernameRegistrationViewController

@synthesize progress, label;

- (void)viewDidLoad {
    [super viewDidLoad];
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	
	state = SENDING_REQUEST;
	
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	
	NSData *body = [[NSString stringWithFormat:@"name=%@&pkey=%@&addr=%@", [URLUtil urlencode:ad.usermanager.local.name], [URLUtil urlencode:ad.usermanager.local.pkey], [URLUtil urlencode:ad.usermanager.local.addr]] dataUsingEncoding:NSUTF8StringEncoding];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://rqs5owaukvnh37b4.onion/register.php"]];
	[req setHTTPMethod:@"POST"];
	[req setValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:body];
	
	cancelled = NO;
	res = [URLUtil retrieveRequest:req Cancel:&cancelled];
	
	loop = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkStatus:) userInfo:nil repeats:YES];
}

- (void) recievedKey: (NSString *) key {
	if (state != WAITING_FOR_KEY) {
		[self failureWithString:@"Recieved key in invalid state!"];
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		state = COMPLETING;
		
		[progress setProgress:0.8 animated:YES];
		label.text = @"Completing registration...";
		
		AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
		cancelled = NO;
		res = [URLUtil retrieveURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://rqs5owaukvnh37b4.onion/confirm.php?name=%@&key=%@",
																			   [URLUtil urlencode:ad.usermanager.local.name], [URLUtil urlencode:key]]] Cancel:&cancelled];
	});
}

- (void) failureWithError:(NSError *)error {
	DDLogError(@"Error: %@", error);
}

- (void) failureWithString:(NSString *)error {
	DDLogError(@"Error: %@", error);
}

#pragma mark - NSURLConnectionDelegate Methods

- (void) checkStatus:(NSTimer *)timer {
	if (!res || ![Result isResolved:res]) return;
	
	Result *result = res;
	res = nil;
	
	if (result.result != SUCCESS) {
		[self failureWithError:result.error];
		return;
	}
	
	NSError *error;
	NSDictionary *json = [result.data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
	if (error != nil) {
		[self failureWithError:error];
		return;
	}
	
	if ([json objectForKey:@"error"]) {
		[self failureWithString:[json objectForKey:@"error"]];
		return;
	} else if ((state == SENDING_REQUEST || state == COMPLETING) && ![(NSNumber *)[json objectForKey:@"success"] boolValue]) {
		[self failureWithString:@"Registration not successful."];
		return;
	} else if (state == VALIDATING && ![(NSNumber *)[json objectForKey:@"exists"] boolValue]) {
		[self failureWithString:@"Registration not successful."];
		return;
	}
	
	if (state == SENDING_REQUEST) {
		state = WAITING_FOR_KEY;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[progress setProgress:0.4 animated:YES];
			label.text = @"Waiting for response...";
		});
	} else if (state == COMPLETING) {
		state = VALIDATING;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[progress setProgress:0.9 animated:YES];
			label.text = @"Validating...";
			
			AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
			cancelled = NO;
			res = [URLUtil retrieveURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://rqs5owaukvnh37b4.onion/exists.php?name=%@", [URLUtil urlencode:ad.usermanager.local.name]]] Cancel:&cancelled];
		});
	} else if (state == VALIDATING) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[progress setProgress:1.0 animated:YES];
			label.text = @"Complete!";
			
			AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
			[ad registrationComplete];
		});
	} else {
		[self failureWithString:@"Recieved key in invalid state!"];
	}
}

@end
