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

static const int ddLogLevel = LOG_LEVEL_INFO;

typedef enum {
	SENDING_REQUEST,
	WAITING_FOR_KEY,
	COMPLETING,
	VALIDATING
} rstate;

@interface UsernameRegistrationViewController () {
	NSMutableData *data;
	NSURLConnection *conn;
	BOOL active;
	rstate state;
}

- (NSString *) urlencode: (NSString *) str;

@end

@implementation UsernameRegistrationViewController

@synthesize progress, label;

- (void)viewDidLoad {
    [super viewDidLoad];
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble"]];
	
	state = SENDING_REQUEST;
	
	AppDelegate *ad = (AppDelegate *) [UIApplication sharedApplication].delegate;
	
	NSData *body = [[NSString stringWithFormat:@"name=%@&pkey=%@&addr=%@", [self urlencode:ad.root.name], [self urlencode:ad.root.pkey], [self urlencode:ad.root.addr]] dataUsingEncoding:NSUTF8StringEncoding];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://rqs5owaukvnh37b4.onion/register.php"]];
	[req setHTTPMethod:@"POST"];
	[req setValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
	[req setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:body];
	
	data = [[NSMutableData alloc] init];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
	
	active = YES;
	
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
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://rqs5owaukvnh37b4.onion/confirm.php?name=%@&key=%@",
																			   [self urlencode:ad.root.name], [self urlencode:key]]]];
		data = [[NSMutableData alloc] init];
		conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		active = YES;
	});
}

- (void) failureWithError:(NSError *)error {
	DDLogError(@"Error: %@", error);
}

- (void) failureWithString:(NSString *)error {
	DDLogError(@"Error: %@", error);
}

- (NSString *) urlencode:(NSString *)str {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) str, NULL, CFSTR("!*'();:@&=+$,/?%#[]\" "), kCFStringEncodingUTF8));
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dat {
	[data appendData:dat];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	active = NO;
	[self failureWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	active = NO;
	
	NSError *error;
	NSDictionary *json = [(NSData *)data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&error];
	if (error != nil) {
		[self connection:connection didFailWithError:error];
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
			NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://rqs5owaukvnh37b4.onion/exists.php?name=%@", [self urlencode:ad.root.name]]]];
			data = [[NSMutableData alloc] init];
			conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
			active = YES;
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
