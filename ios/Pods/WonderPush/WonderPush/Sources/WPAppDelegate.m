//
//  WPAppDelegate.m
//  WonderPush
//
//  Created by Olivier Favre on 13/01/16.
//  Copyright © 2016 WonderPush. All rights reserved.
//

#import "WPAppDelegate.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "WonderPush.h"
#import "WPLog.h"


const char * const WPAPPDELEGATE_ASSOCIATION_KEY = "com.wonderpush.sdk.WPAppDelegate";

static BOOL _WPAppDelegateAlreadyRunning = NO;


@interface WPAppDelegate ()

@end


@implementation WPAppDelegate

@synthesize nextDelegate;


#pragma mark - Setup and chaining

+ (void) setupDelegateForApplication:(UIApplication *)application
{
    WPAppDelegate *delegate = [WPAppDelegate new];

    // Retain the delegate as long as the UIApplication lives
    objc_setAssociatedObject(application, WPAPPDELEGATE_ASSOCIATION_KEY, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // Note: the association is not breakable, like the created delegate chain

    // Setup the delegate chain
    delegate.nextDelegate = application.delegate;
    application.delegate = delegate;
}

+ (BOOL) isAlreadyRunning
{
    return _WPAppDelegateAlreadyRunning;
}

- (id) forwardingTargetForSelector:(SEL)aSelector
{
    return self.nextDelegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [self.nextDelegate respondsToSelector:aSelector];
}


#pragma mark - Overriding useful methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didFinishLaunchingWithOptions:launchOptions];
    BOOL rtn = YES;
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        rtn = [self.nextDelegate application:application didFinishLaunchingWithOptions:launchOptions];
        _WPAppDelegateAlreadyRunning = NO;
    }
    return rtn;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didReceiveLocalNotification:notification];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didReceiveLocalNotification:notification];
        _WPAppDelegateAlreadyRunning = NO;
    }
}
#pragma clang diagnostic pop

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        _WPAppDelegateAlreadyRunning = NO;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didFailToRegisterForRemoteNotificationsWithError:error];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didFailToRegisterForRemoteNotificationsWithError:error];
        _WPAppDelegateAlreadyRunning = NO;
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didReceiveRemoteNotification:userInfo];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didReceiveRemoteNotification:userInfo];
        _WPAppDelegateAlreadyRunning = NO;
    }
}
#pragma clang diagnostic pop

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        completionHandler = nil;
        _WPAppDelegateAlreadyRunning = NO;
    }
    [WonderPush application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush applicationDidEnterBackground:application];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate applicationDidEnterBackground:application];
        _WPAppDelegateAlreadyRunning = NO;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush applicationDidBecomeActive:application];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate applicationDidBecomeActive:application];
        _WPAppDelegateAlreadyRunning = NO;
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush application:application didRegisterUserNotificationSettings:notificationSettings];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPAppDelegateAlreadyRunning = YES;
        [self.nextDelegate application:application didRegisterUserNotificationSettings:notificationSettings];
        _WPAppDelegateAlreadyRunning = NO;
    }
}


@end
