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
        [WonderPush setClientId:clientId secret:clientSecret];
        resolve(nil);
    }
    @catch (NSError *e) {
        reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(setLogging:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         [WonderPush setLogging:enable];
         resolve(nil);
     }
     @catch(NSError *e){
        reject(nil, nil, e);
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
        reject(nil, nil, e);
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
        reject(nil, nil, e);
     }
 }

RCT_EXPORT_METHOD(setupDelegateForApplication:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush setupDelegateForApplication:[UIApplication sharedApplication]];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(setupDelegateForUserNotificationCenter:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
     @try{
         if (@available(iOS 10.0, *)) {
             [WonderPush setupDelegateForUserNotificationCenter];
         }
         resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
 }

// WonderPush: Subscribing users methods
RCT_EXPORT_METHOD(subscribeToNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush subscribeToNotifications];
        resolve(nil);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [WonderPush unsubscribeFromNotifications];
        resolve(nil);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
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
        reject(nil, nil, e);
     }
 }

@end
