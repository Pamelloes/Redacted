//
//  URLUtil.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "URLUtil.h"

#import "MAFuture.h"
#import "Result.h"

@interface URLUtil () {
	NSMutableData *data;
	void (^complete)(NSData *);
	void (^fail)(NSError *);
}

- (instancetype) initWithCompleted: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure;

@end

@implementation URLUtil

- (instancetype) initWithCompleted:(void (^)(NSData *))completed Failure:(void (^)(NSError *))failure {
	self = [super init];
	if (self) {
		complete = completed;
		fail = failure;
		data = [[NSMutableData alloc] init];
	}
	return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dat {
	[data appendData:dat];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (fail) fail(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (complete) complete(data);
}

+ (NSString *) serverURLString {
	return @"http://rqs5owaukvnh37b4.onion/";
}

+ (NSURL *) serverURL {
	return [NSURL URLWithString:[URLUtil serverURLString]];
}

+ (NSString *) urlencode:(NSString *)str {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) str, NULL, CFSTR("!*'();:@&=+$,/?%#[]\" "), kCFStringEncodingUTF8));
}

+ (Result *) retrieveURLString: (NSString *) string {
	return [URLUtil retrieveURL:[NSURL URLWithString:string]];
}

+ (Result *) retrieveURLString: (NSString *) string  Cancel: (BOOL *) cancelled {
	return [URLUtil retrieveURL:[NSURL URLWithString:string] Cancel:cancelled];
}

+ (Result *) retrieveURL: (NSURL *) url {
	return [URLUtil retrieveRequest:[NSURLRequest requestWithURL:url]];
}

+ (Result *) retrieveURL: (NSURL *) url Cancel: (BOOL *) cancelled {
	return [URLUtil retrieveRequest:[NSURLRequest requestWithURL:url] Cancel:cancelled];
}

+ (Result *) retrieveRequest: (NSURLRequest *) request {
	return [URLUtil retrieveRequest:request Cancel: NULL];
}

+ (Result *) retrieveRequest: (NSURLRequest *) request Cancel: (BOOL *) cancelled {
	return MABackgroundFuture(^{
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		
		__block BOOL complete = NO;
		__block NSData *data = nil;
		__block NSError *error = nil;
		
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:[[URLUtil alloc] initWithCompleted:^(NSData *dat) {
			data = dat;
			complete = YES;
		} Failure: ^(NSError *err){
			error = err;
			complete = YES;
		}] startImmediately:NO];
		[conn setDelegateQueue:queue];
		[conn start];
		
		while (!complete && !(cancelled != NULL && *cancelled)) [NSThread sleepForTimeInterval:0.02];
		if (cancelled != NULL && *cancelled) [conn cancel];
		
		restype result = (data ? SUCCESS : (error ? FAILURE : UNKNOWN));
		return [[Result alloc] initWithResult:result Error:error Data:result == SUCCESS ? data : conn];
	});
}

@end
