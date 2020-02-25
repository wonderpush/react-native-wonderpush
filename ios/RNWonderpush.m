
#import "RNWonderpush.h"
#import <WonderPush/WonderPush.h>
@implementation RNWonderpush

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret)
{
    [WonderPush setClientId:clientId secret:clientSecret];
    [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
    [WonderPush setupDelegateForUserNotificationCenter];
}
RCT_EXPORT_METHOD(subscribeToNotifications)
{
    [WonderPush subscribeToNotifications];
}
RCT_EXPORT_METHOD(unsubscribeFromNotifications)
{
    [WonderPush unsubscribeFromNotifications];
}

@end
  
