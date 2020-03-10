//
//  RCTWonderPush.h
//  WonderPushLib
//
//  Created by Apple on 08/03/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTWonderPush : NSObject
+ (RCTWonderPush *) sharedInstance;
- (void)setClientId:(NSString *)clientId secret:(NSString *)clientSecret;
- (void)setLogging:(BOOL)enable;
- (BOOL)isReady;
- (BOOL)isInitialized;
- (void)setupDelegateForApplication;
- (void)setupDelegateForUserNotificationCenter;
- (void)subscribeToNotifications;
- (void)unsubscribeFromNotifications;
- (BOOL)isSubscribedToNotifications;
@end

NS_ASSUME_NONNULL_END
