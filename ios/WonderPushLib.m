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

RCT_EXPORT_METHOD(setClientId:(NSString *)clientId secret:(NSString *)clientSecret resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
           [WonderPush setClientId:clientId secret:clientSecret];
           [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
           if (@available(iOS 10.0, *)) {
                 [WonderPush setupDelegateForUserNotificationCenter];
            }
            resolve(@"WonderPush: initialized successfully.");
        });
    }
    @catch (NSError *e) {
        reject(@"WonderPush", @"Error occured in calling setClientId:secretId.", e);
    }
 }

RCT_EXPORT_METHOD(setLogging:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         [WonderPush setLogging:enable];
         if(enable){
            resolve(@"WonderPush: logging enabled successfully.");
         }else{
            resolve(@"WonderPush: logging disabled successfully.");
         }
     }
     @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in calling setLogging.", e);
     }
 }

RCT_EXPORT_METHOD(isReady:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        if([WonderPush isReady]){
            resolve(@TRUE);
        }else{
            resolve(@FALSE);
        }
     }
     @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in calling isReady.", e);
     }
 }

RCT_EXPORT_METHOD(isInitialized:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        if([WonderPush isInitialized]){
            resolve(@TRUE);
        }else{
            resolve(@FALSE);
        }
     }
     @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in calling isInitialized.", e);
     }
 }

RCT_EXPORT_METHOD(setupDelegateForApplication:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        resolve(@"WonderPush: Application delegate setup successfully.");
    }
    @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in setupDelegateForApplication.", e);
    }
 }

RCT_EXPORT_METHOD(setupDelegateForUserNotificationCenter:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
     @try{
        if (@available(iOS 10.0, *)) {
             [WonderPush setupDelegateForUserNotificationCenter];
         }
         resolve(@[@"WonderPush: UserNotificationCenter delegate setup successfully."]);
    }
    @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in setupDelegateForUserNotificationCenter.", e);
    }
 }

// WonderPush: Subscribing users methods
RCT_EXPORT_METHOD(subscribeToNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush subscribeToNotifications];
        resolve(@"WonderPush: subscribed to notification successfully.");
    }
    @catch(NSError *e){
       reject(@"WonderPush", @"Error occured in calling subscribeToNotifications.", e);
    }
 }

RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush unsubscribeFromNotifications];
        resolve(@"WonderPush: unsubscribed to notification successfully.");
    }
    @catch(NSError *e){
       reject(@"WonderPush", @"Error occured in calling unsubscribeFromNotifications.", e);
    }
 }

RCT_EXPORT_METHOD(isSubscribedToNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        if([WonderPush isSubscribedToNotifications]){
            resolve(@TRUE);
        }else{
            resolve(@FALSE);
        }
     }
     @catch(NSError *e){
        reject(@"WonderPush", @"Error occured in calling isSubscribedToNotifications.", e);
     }
 }

@end
