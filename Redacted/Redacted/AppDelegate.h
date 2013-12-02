//
//  AppDelegate.h
//  OnionBrowser
//
//  Copyright (c) 2012 Mike Tigas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TorController.h"

#define DNT_HEADER_UNSET 0
#define DNT_HEADER_CANTRACK 1
#define DNT_HEADER_NOTRACK 2

#define UA_SPOOF_NO 0
#define UA_SPOOF_WIN7_TORBROWSER 1
#define UA_SPOOF_SAFARI_MAC 2

#define X_DEVICE_IS_IPHONE 0
#define X_DEVICE_IS_IPAD 1
#define X_DEVICE_IS_SIM 2

@class HTTPServer, RedactedCrypto, Configuration, User, UserManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	TorController *tor;
	HTTPServer *httpServer;
	
	RedactedCrypto *crypto;
	
	Configuration *config;
	User *root;
	
	UserManager *usermanager;
	
	UIWindow *window;
	
	UINavigationController *rootNavigationController;
}

- (void) showChatWindow;
- (void) showWelcomeWindow;

- (void) updateProgress: (NSString *) statusLine;
- (void) updateProgressComplete;

- (void) recievedRegistrationKey: (NSString *) key;
- (void) registrationComplete;

- (void) failureWithError: (NSError *) error;
- (void) failureWithString: (NSString *) error;

- (void) storyboardTransitionComplete: (UIViewController *) controller;

- (void)updateTorrc;
- (NSURL *)applicationDocumentsDirectory;
- (void)wipeAppData;
- (NSUInteger) deviceType;

@property (nonatomic, strong, readonly) TorController *tor;
@property (nonatomic, strong, readonly) HTTPServer *httpServer;

@property (nonatomic, strong, readonly) RedactedCrypto *crypto;

@property (nonatomic, strong, readonly) Configuration *config;
@property (nonatomic, strong, readonly) User *root;

@property (nonatomic, strong, readonly) UserManager *usermanager;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (nonatomic) Byte spoofUserAgent;
@property (nonatomic) Byte dntHeader;
@property (nonatomic) Boolean usePipelining;

@property (nonatomic) NSMutableArray *sslWhitelistedDomains; // for self-signed

@property (nonatomic) Boolean doPrepopulateBookmarks;

@end
