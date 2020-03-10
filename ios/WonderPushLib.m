#import "WonderPushLib.h"
#import <WonderPush/WonderPush.h>
#import "RCTWonderPush.h"
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
        [[RCTWonderPush sharedInstance] setClientId:clientId secret:clientSecret];
        resolve(nil);
    }
    @catch (NSError *e) {
        reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(setLogging:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         [[RCTWonderPush sharedInstance] setLogging:enable];
         resolve(nil);
     }
     @catch(NSError *e){
        reject(nil, nil, e);
     }
 }

RCT_EXPORT_METHOD(isReady:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        if([[RCTWonderPush sharedInstance] isReady]){
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
        if([[RCTWonderPush sharedInstance] isInitialized]){
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
        [[RCTWonderPush sharedInstance] setupDelegateForApplication];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(setupDelegateForUserNotificationCenter:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
     @try{
         [[RCTWonderPush sharedInstance] setupDelegateForUserNotificationCenter];
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
        [[RCTWonderPush sharedInstance] subscribeToNotifications];
        resolve(nil);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        [[RCTWonderPush sharedInstance] unsubscribeFromNotifications];
        resolve(nil);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
    }
 }

RCT_EXPORT_METHOD(isSubscribedToNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
 {
    @try{
        if([[RCTWonderPush sharedInstance] isSubscribedToNotifications]){
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
