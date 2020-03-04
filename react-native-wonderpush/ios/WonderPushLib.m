#import "WonderPushLib.h"
#import <WonderPush/WonderPush.h>
@interface WonderPushLib()


@end
@implementation WonderPushLib

- (instancetype)init {
    self = [super init];
    if (self) {
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

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setClientId:(NSString *)clientId secret:(NSString *)clientSecret callback:(RCTResponseSenderBlock)callback)
{
    [WonderPush setClientId:clientId secret:clientSecret];
    [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
    if (@available(iOS 10.0, *)) {
        [WonderPush setupDelegateForUserNotificationCenter];
    }
    callback(@[@"WonderPush <ios> initialized successfully."]);
}

RCT_EXPORT_METHOD(setLogging:(BOOL)enable callback:(RCTResponseSenderBlock)callback)
{
    [WonderPush setLogging:enable];
    if(enable){
       callback(@[@"WonderPush <ios> logging status enabled successfully."]);
    }else{
        callback(@[@"WonderPush <ios> logging status disabled successfully."]);
    }
}

RCT_EXPORT_METHOD(isReady:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isReady]){
        callback(@[@TRUE]);
    }else{
        callback(@[@FALSE]);
    }
}

RCT_EXPORT_METHOD(isInitialized:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isReady]){
        callback(@[@TRUE]);
    }else{
        callback(@[@FALSE]);
    }
}

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setupDelegateForApplication:(RCTResponseSenderBlock)callback)
{
    [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
    callback(@[@"WonderPush <ios> notification delegete setup succesfully."]);
}

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setupDelegateForUserNotificationCenter:(RCTResponseSenderBlock)callback)
{
    if (@available(iOS 10.0, *)) {
        [WonderPush setupDelegateForUserNotificationCenter];
    }
    callback(@[@"WonderPush <ios> notification center delegete setup succesfully."]);
}

// WonderPush: Subscribing users methods
RCT_EXPORT_METHOD(subscribeToNotifications:(RCTResponseSenderBlock)callback)
{
    [WonderPush subscribeToNotifications];
    callback(@[@"WonderPush: <ios> subscribed to notification successfully."]);
}
RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTResponseSenderBlock)callback)
{
    [WonderPush unsubscribeFromNotifications];
    callback(@[@"WonderPush: <ios> unsubscribed to notification successfully."]);
}

RCT_EXPORT_METHOD(isSubscribedToNotifications:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isSubscribedToNotifications]){
        callback(@[@TRUE]);
    }else{
        callback(@[@FALSE]);
    }
}
// 

@end
