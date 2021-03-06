//
//  RedactedHTTPConnection.m
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import "RedactedHTTPConnection.h"

#import "HTTPLogging.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "HTTPDataResponse.h"
#import "HTTPErrorResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"
#import "RedactedWebSocket.h"

#import "AppDelegate.h"
#import "RedactedCrypto.h"
#import "JSONKit.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_LEVEL_INFO; // | HTTP_LOG_FLAG_TRACE;

@implementation RedactedHTTPConnection

@synthesize socket;

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([path hasPrefix:@"/registration?"]) {
		HTTPLogInfo(@"Registration Request: %@", path);
		NSDictionary *dict = [self parseGetParams];
		NSString *raw = [dict objectForKey:@"key"];
		AppDelegate * ad = [UIApplication sharedApplication].delegate;
		BOOL success = true;
		if ((success = raw != nil)) {
			NSData *data = [[NSData alloc] initWithBase64EncodedString:raw options:0];
			if ((success = data != nil)) {
				NSString *key = [[NSString alloc] initWithData: [ad.crypto decryptData:data key:ad.crypto.privateKeyRef] encoding:NSUTF8StringEncoding];
				if ((success = key != nil)) {
					[ad recievedRegistrationKey:key];
				} else [ad failureWithString:@"Recieved data was not encrypted properly!"];
			} else [ad failureWithString:@"Recieved data was not in a valid format!"];
		} else [ad failureWithString:@"Recieved data nil!"];
		NSError *error;
		NSString *str = [@{@"success": [NSNumber numberWithBool:success]} JSONStringWithOptions:JKSerializeOptionNone error:&error];
		if (error != nil) {
			HTTPLogError(@"Error creating JSON: %@", error);
			return [[HTTPErrorResponse alloc] initWithErrorCode:500];
		} else if (!str) {
			HTTPLogError(@"Error creating JSON: nil string");
			return [[HTTPErrorResponse alloc] initWithErrorCode:500];
		}
		HTTPLogInfo(@"%@", str);
		return [[HTTPDataResponse alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	if ([path isEqualToString:@"/WebSocketTest2.js"]) {
		// The socket.js file contains a URL template that needs to be completed:
		//
		// ws = new WebSocket("%%WEBSOCKET_URL%%");
		//
		// We need to replace "%%WEBSOCKET_URL%%" with whatever URL the server is running on.
		// We can accomplish this easily with the HTTPDynamicFileResponse class,
		// which takes a dictionary of replacement key-value pairs,
		// and performs replacements on the fly as it uploads the file.
		
		NSString *wsLocation;
		
		NSString *wsHost = [request headerField:@"Host"];
		if (wsHost == nil) {
			NSString *port = [NSString stringWithFormat:@"%hu", [asyncSocket localPort]];
			wsLocation = [NSString stringWithFormat:@"ws://localhost:%@/service", port];
		} else {
			wsLocation = [NSString stringWithFormat:@"ws://%@/service", wsHost];
		}
		
		NSDictionary *replacementDict = [NSDictionary dictionaryWithObject:wsLocation forKey:@"WEBSOCKET_URL"];
		
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path] forConnection:self separator:@"%%" replacementDictionary:replacementDict];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
	HTTPLogTrace2(@"%@[%p]: webSocketForURI: %@", THIS_FILE, self, path);
	
	if([path isEqualToString:@"/service"])
	{
		HTTPLogInfo(@"MyHTTPConnection: Creating MyWebSocket...");
		
		return [[RedactedWebSocket alloc] initWithRequest:request socket:asyncSocket];
	}
	
	return [super webSocketForURI:path];
}

@end
