#import "WPNotificationCenterDelegate.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "WonderPush.h"
#import "WPLog.h"


const char * const WPNOTIFICATIONCENTERDELEGATE_ASSOCIATION_KEY = "com.wonderpush.sdk.WPNotificationCenterDelegate";

static BOOL _WPNotificationCenterDelegateAlreadyRunning = NO;


@implementation WPNotificationCenterDelegate

@synthesize nextDelegate;

#pragma mark - Setup and chaining

+ (void)setupDelegateForNotificationCenter:(UNUserNotificationCenter *)center {
    if (!center) {
        // `[UNUserNotificationCenter currentNotificationCenter]` returns `nil` on pre iOS 10 devices
        return;
    }

    WPNotificationCenterDelegate *delegate = [WPNotificationCenterDelegate new];

    // Retain the delegate as long as the UIApplication lives
    objc_setAssociatedObject(center, WPNOTIFICATIONCENTERDELEGATE_ASSOCIATION_KEY, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // Note: the association is not breakable, like the created delegate chain

    // Setup the delegate chain
    delegate.nextDelegate = center.delegate;
    center.delegate = delegate;

    // Tell the SDK that setup is complete
    [WonderPush setUserNotificationCenterDelegateInstalled:YES];
}

+ (BOOL)isAlreadyRunning {
    return _WPNotificationCenterDelegateAlreadyRunning;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.nextDelegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.nextDelegate respondsToSelector:aSelector];
}


#pragma mark - Overriding useful methods

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0) {
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPNotificationCenterDelegateAlreadyRunning = YES;
        [self.nextDelegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
        _WPNotificationCenterDelegateAlreadyRunning = NO;
    }
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) {
    WPLogDebug(@"%@", NSStringFromSelector(_cmd));
    [WonderPush userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    if ([self.nextDelegate respondsToSelector:_cmd]) {
        _WPNotificationCenterDelegateAlreadyRunning = YES;
        [self.nextDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
        _WPNotificationCenterDelegateAlreadyRunning = NO;
    }
}


@end
