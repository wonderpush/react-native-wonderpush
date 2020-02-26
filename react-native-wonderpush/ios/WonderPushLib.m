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

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    // TODO: Implement some actually useful functionality
    callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@", numberArgument, stringArgument]]);
}

RCT_EXPORT_METHOD(show:(NSString *)text)
{
    [self.toast showToast:text];
}
RCT_EXPORT_METHOD(setClientId:(NSString *)clientId secret:(NSString *)clientSecret)
{
    if(![WonderPush isInitialized]){
        [WonderPush setClientId:clientId secret:clientSecret];
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        [WonderPush setupDelegateForUserNotificationCenter];
        [self.toast showToast:[NSString stringWithFormat:@"initWithClientId %@ | %@",clientId,clientSecret]];
    }else{
        [self.toast showToast:[NSString stringWithFormat:@"initialized %@ | %@",clientId,clientSecret]];
    }
}
RCT_EXPORT_METHOD(subscribeToNotifications)
{
    [WonderPush subscribeToNotifications];
    [self.toast showToast:@"subscribeToNotifications called"];
}
RCT_EXPORT_METHOD(unsubscribeFromNotifications)
{
    [WonderPush unsubscribeFromNotifications];
    [self.toast showToast:@"unsubscribeFromNotifications called"];
    
}
@end
