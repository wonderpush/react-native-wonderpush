#import "WonderPushLib.h"
#import <WonderPush/WonderPush.h>
@interface WonderPushLib()

@end
@implementation WonderPushLib

+ (void)initialize
{
    [WonderPush setIntegrator:@"ReactNative"];
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

//Initialization
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

// Subscribing users
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


// Segmentation
RCT_EXPORT_METHOD(trackEvent:(NSString *)type attributes:(NSDictionary *)attributes resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush trackEvent:type attributes:attributes];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(addTag:(NSArray *)tags resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush addTags:tags];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeTag:(NSArray *)tags resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush removeTags:tags];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeAllTags:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush removeAllTags];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(hasTag:(NSString *)tag resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        if([WonderPush hasTag:tag]){
            resolve(@TRUE);
        }else{
            resolve(@FALSE);
        }
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getTags:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSOrderedSet<NSString*> *tags = [WonderPush getTags];
        resolve((NSArray *) tags);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getCountry:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         NSString *country = [WonderPush country];
        resolve(country);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setCountry:(NSString *)country resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setCountry:country];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getCurrency:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         NSString *currency = [WonderPush currency];
        resolve(currency);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setCurrency:(NSString *)currency resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setCurrency:currency];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getLocale:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSString *locale = [WonderPush locale];
        resolve(locale);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setLocale:(NSString *)locale resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setLocale:locale];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getTimeZone:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSString *timeZone = [WonderPush timeZone];
        resolve(timeZone);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setTimeZone:(NSString *)timeZone resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
     @try{
        [WonderPush setTimeZone:timeZone];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

// User IDs
RCT_EXPORT_METHOD(getUserId:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSString *userId = [WonderPush userId];
        resolve(userId);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setUserId:(NSString *)userId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setUserId:userId];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

// Installation info
RCT_EXPORT_METHOD(getInstallationId:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSString *installationId = [WonderPush installationId];
        resolve(InstallationId);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPushToken:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
         NSString *pushToken = [WonderPush pushToken];
        resolve(pushToken);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

//Privacy
RCT_EXPORT_METHOD(disableGeolocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush disableGeolocation];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(enableGeolocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush enableGeolocation];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearEventsHistory:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush clearEventsHistory];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush clearPreferences];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearAllData:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush clearAllData];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

@end
