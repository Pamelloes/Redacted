//
//  RedactedHTTPConnection.h
//  Redacted
//
//  Created by Joshua Brot on 11/25/13.
//
//

#import "HTTPConnection.h"

@class RedactedWebSocket;

@interface RedactedHTTPConnection : HTTPConnection {
	RedactedWebSocket *socket;
}

@property (nonatomic, strong) RedactedWebSocket *socket;

@end
