//
//  URLUtil.m
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import "URLUtil.h"

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
	if (fail) dispatch_async(dispatch_get_main_queue(), ^{
		fail(error);
	});
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (complete) dispatch_async(dispatch_get_main_queue(), ^{
		complete(data);
	});
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

+ (NSURLConnection *) retrieveURLString: (NSString *) string Completed: (void (^)(NSData *)) completed {
	return [URLUtil retrieveURL:[NSURL URLWithString:string] Completed:completed];
}

+ (NSURLConnection *) retrieveURLString: (NSString *) string Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure {
	return [URLUtil retrieveURL:[NSURL URLWithString:string] Completed:completed Failure:failure];
}

+ (NSURLConnection *) retrieveURL: (NSURL *) url Completed: (void (^)(NSData *)) completed {
	return [URLUtil retrieveRequest:[NSURLRequest requestWithURL:url] Completed:completed];
}

+ (NSURLConnection *) retrieveURL: (NSURL *) url Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure {
	return [URLUtil retrieveRequest:[NSURLRequest requestWithURL:url] Completed:completed Failure:failure];
}

+ (NSURLConnection *) retrieveRequest: (NSURLRequest *) request Completed: (void (^)(NSData *)) completed {
	return [self retrieveRequest:request Completed:completed Failure:nil];
}

+ (NSURLConnection *) retrieveRequest: (NSURLRequest *) request Completed: (void (^)(NSData *)) completed Failure: (void (^)(NSError *)) failure {
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:[[URLUtil alloc] initWithCompleted:completed Failure:failure]];
	dispatch_async(dispatch_get_main_queue(), ^{
		[conn start];
	});
	return conn;
}

@end
