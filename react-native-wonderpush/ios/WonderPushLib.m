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
    if(![WonderPush isInitialized]){
        [WonderPush setClientId:clientId secret:clientSecret];
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        if (@available(iOS 10.0, *)) {
            [WonderPush setupDelegateForUserNotificationCenter];
        }
        callback(@[@"WonderPush <ios> initialized successfully."]);
    }else{
        callback(@[@"WonderPush <ios> already initialized."]);
    }
}

RCT_EXPORT_METHOD(setLogging:(BOOL)enable callback:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        [WonderPush setLogging:enable];
        if(enable){
           callback(@[@"WonderPush <ios> logging status enabled successfully."]);
        }else{
           callback(@[@"WonderPush <ios> logging status disabled successfully."]);
        }
    }else{
        callback(@[@"WonderPush <ios> already initialized."]);
    }
}

RCT_EXPORT_METHOD(isReady:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if([WonderPush isReady]){
            callback(@[@TRUE]);
        }else{
            callback(@[@FALSE]);
        }
    }else{
        callback(@[@FALSE]);
    }
}

RCT_EXPORT_METHOD(isInitialized:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if([WonderPush isReady]){
            callback(@[@TRUE]);
        }else{
            callback(@[@FALSE]);
        }
    }else{
        callback(@[@FALSE]);
    }
}

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setupDelegateForApplication:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        callback(@[@"WonderPush <ios> notification delegete setup succesfully."]);
    }else{
        callback(@[@"WonderPush <ios> already initialized."]);
    }
}

// WonderPush: Initialization methods
RCT_EXPORT_METHOD(setupDelegateForUserNotificationCenter:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if (@available(iOS 10.0, *)) {
            [WonderPush setupDelegateForUserNotificationCenter];
        }
        callback(@[@"WonderPush <ios> notification center delegete setup succesfully."]);
    }else{
        callback(@[@"WonderPush <ios> not initialized."]);
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

RCT_EXPORT_METHOD(isSubscribedToNotifications:(RCTResponseSenderBlock)callback)
{
    if([WonderPush isInitialized]){
        if([WonderPush isSubscribedToNotifications]){
            callback(@[@TRUE]);
        }else{
            callback(@[@FALSE]);
        }
    }else{
        callback(@[@FALSE]);
    }
}
// 

@end
