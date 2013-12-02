//
//  URLUtil.h
//  Redacted
//
//  Created by Joshua Brot on 11/30/13.
//
//

#import <Foundation/Foundation.h>

@class Result;

@interface URLUtil : NSObject <NSURLConnectionDataDelegate>

+ (NSString *) serverURLString;
+ (NSURL *) serverURL;

+ (NSString *) urlencode: (NSString *) encode;

+ (Result *) retrieveURLString: (NSString *) string;
+ (Result *) retrieveURLString: (NSString *) string Cancel: (BOOL *) cancelled;

+ (Result *) retrieveURL: (NSURL *) url;
+ (Result *) retrieveURL: (NSURL *) url Cancel: (BOOL *) cancelled;

+ (Result *) retrieveRequest: (NSURLRequest *) request;
+ (Result *) retrieveRequest: (NSURLRequest *) request Cancel: (BOOL *) cancelled;

@end
