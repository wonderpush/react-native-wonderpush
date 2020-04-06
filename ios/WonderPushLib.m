#import "WonderPushLib.h"
#import <WonderPush/WonderPush.h>
@interface WonderPushLib()

@end
@implementation WonderPushLib

- (NSArray<NSString *> *)supportedEvents {
  return @[
    @"wonderpushNotificationWillOpen",
  ];
}


+ (void)initialize
{
    [WonderPush setIntegrator:@"react-native-wonderpush-1.0.0"];
     __block WonderPushLib *blocksafeSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:WP_NOTIFICATION_OPENED_BROADCAST object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *notification = note.userInfo;
        [blocksafeSelf sendEventWithName:@"wonderpushNotificationWillOpen" body:notification];
    }];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(RNWonderPush)

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
        NSArray *arrTags = [NSArray arrayWithArray:[tags array]];
        resolve(arrTags);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPropertyValue:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
       id value = [WonderPush getPropertyValue:property];
       resolve(value);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPropertyValues:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSArray *values = [WonderPush getPropertyValues:property];
        resolve(values);
    }
    @catch(NSError *e){
       reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(addProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush addProperty:str value:properties];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush removeProperty:str value:properties];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setProperty:str value:properties];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(unsetProperty:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush unsetProperty:property];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(putProperties:(NSDictionary *)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush putProperties:properties];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getProperties:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        NSDictionary *properties = [WonderPush getProperties];
        resolve(properties);
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
        resolve(installationId);
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

RCT_EXPORT_METHOD(setRequiresUserConsent:(BOOL)isConsent resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setRequiresUserConsent:isConsent];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setUserConsent:(BOOL)isConsent resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        [WonderPush setUserConsent:isConsent];
        resolve(nil);
    }
    @catch(NSError *e){
        reject(nil, nil, e);
    }
}


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

RCT_EXPORT_METHOD(setGeolocation:(double)lat lon:(double)lon resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        CLLocation *location =  [[CLLocation alloc] initWithLatitude:lat longitude:lon];        
        [WonderPush setGeolocation:location];
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
RCT_EXPORT_METHOD(downloadAllData:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [WonderPush downloadAllData:^(NSData *data, NSError *error) {
        if (error) {
            reject(nil, nil, error);
        }
        resolve(data);
    }];
}
@end
