#import "WonderPushLib.h"
#import "IOSNativeToast.h"
#import <WonderPush/WonderPush.h>
@interface WonderPushLib()

@property (nonatomic, retain) IOSNativeToast *toast;

@end
@implementation WonderPushLib

- (instancetype)init {
    self = [super init];
    if (self) {
        self.toast = [[IOSNativeToast alloc] init];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

// Sample Methods
RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@", numberArgument, stringArgument]]);
}
RCT_EXPORT_METHOD(show:(NSString *)text)
{
    [self.toast showToast:text];
}

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setClientId:(NSString *)clientId secret:(NSString *)clientSecret callback:(RCTResponseSenderBlock)callback)
{
    if(![WonderPush isInitialized]){
        [WonderPush setClientId:clientId secret:clientSecret];
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        [WonderPush setupDelegateForUserNotificationCenter];
        callback(@[@"WonderPush <ios> initialized successfully."]);
    }else{
        callback(@[@"WonderPush <ios> already initialized."]);
    }
}

// WonderPush: Subscribing users methods
RCT_EXPORT_METHOD(subscribeToNotifications:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if(![WonderPush isSubscribedToNotifications]){
            [WonderPush subscribeToNotifications];
            callback(@[@"WonderPush: <ios> subscribed to notification successfully."]);
        }else{
            callback(@[@"WonderPush: <ios> already subscribed to notifications."]);
        }
    }else{
        callback(@[@"WonderPush <ios> not initialized."]);
    }
}
RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if([WonderPush isSubscribedToNotifications]){
            [WonderPush unsubscribeFromNotifications];
            callback(@[@"WonderPush: <ios> unsubscribed to notification successfully."]);
        }else{
            callback(@[@"WonderPush: <ios> already usubscribed to notifications."]);
        }
    }else{
        callback(@[@"WonderPush <ios> not initialized."]);
    }
}

// 

@end
