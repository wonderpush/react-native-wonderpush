#import "WonderPushLib.h"
#import <WonderPush/WonderPush.h>

@interface SavedNotification: NSObject
@property (nonatomic, strong) NSString *json;
@property (nonatomic, assign) NSInteger buttonIndex;
@end

@implementation SavedNotification
- (instancetype) initWithJson:(NSString *)json buttonIndex:(NSInteger) buttonIndex {
    if (self = [super init]) {
        self.json = json;
        self.buttonIndex = buttonIndex;
    }
    return self;
}
@end

@interface WonderPushLibDelegate : NSObject <WonderPushDelegate>
+ (instancetype) instance;
@property (nonatomic, strong) NSMutableArray<SavedNotification *> *savedReceivedNotifications;
@property (nonatomic, strong) NSMutableArray<SavedNotification *> *savedOpenedNotifications;
@property (nonatomic, strong) RCTResponseSenderBlock notificationOpenedCallback;
@property (nonatomic, strong) RCTResponseSenderBlock notificationReceivedCallback;
- (void) saveOpenedNotification:(SavedNotification *) notification;
- (void) saveReceivedNotification:(SavedNotification *) notification;
- (SavedNotification *) consumeSavedReceivedNotification;
- (SavedNotification *) consumeSavedOpenedNotification;
@end

@interface WonderPushLib()
@property (nonatomic, strong) NSURL *initialDeepLinkURL;
@end


@implementation WonderPushLibDelegate

- (instancetype)init {
    if (self = [super init]) {
        self.savedOpenedNotifications = [NSMutableArray new];
        self.savedReceivedNotifications = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    static WonderPushLibDelegate *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [WonderPushLibDelegate new];
    });
    return _instance;
}


- (void)saveOpenedNotification:(SavedNotification *)notification {
    @synchronized (self) {
        [self.savedOpenedNotifications addObject:notification];
    }
}

- (void)saveReceivedNotification:(SavedNotification *)notification {
    @synchronized (self) {
        [self.savedReceivedNotifications addObject:notification];
    }
}

- (SavedNotification *)consumeSavedOpenedNotification {
    @synchronized (self) {
        if (self.savedOpenedNotifications.count) {

            SavedNotification *notification = self.savedOpenedNotifications[0];
            [self.savedOpenedNotifications removeObjectAtIndex:0];
            return notification;
        }
        return nil;
    }
}

- (SavedNotification *)consumeSavedReceivedNotification {
    @synchronized (self) {
        if (self.savedReceivedNotifications.count) {

            SavedNotification *notification = self.savedReceivedNotifications[0];
            [self.savedReceivedNotifications removeObjectAtIndex:0];
            return notification;
        }
        return nil;
    }
}

- (void) onNotificationReceived:(NSDictionary *)notification {
#if DEBUG
    NSLog(@"[WonderPush] onNotificationReceived: %@", notification);
#endif
    NSError *error = nil;
    NSData *notificationJsonData = [NSJSONSerialization dataWithJSONObject:notification options:0 error:&error];
    if (error) {
        NSLog(@"[WonderPush] error serializing notification: %@", error);
        return;
    }
    NSString *notificationJson = [[NSString alloc] initWithData:notificationJsonData encoding:NSUTF8StringEncoding];
    if (self.notificationReceivedCallback) {
        RCTResponseSenderBlock cb = self.notificationReceivedCallback;
        self.notificationReceivedCallback = nil; // Single use
        dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG
            NSLog(@"[WonderPush] callback React with received notification %@", notificationJson);
#endif
            cb(@[notificationJson]);
        });
    } else {
#if DEBUG
        NSLog(@"[WonderPush] save received notification for later %@", notificationJson);
#endif
        [self saveReceivedNotification:[[SavedNotification alloc] initWithJson:notificationJson buttonIndex:0]];
    }

}

- (void) onNotificationOpened:(NSDictionary *)notification withButton:(NSInteger)buttonIndex {
#if DEBUG
    NSLog(@"[WonderPush] onNotificationOpened: %@", notification);
#endif
    NSError *error = nil;
    NSData *notificationJsonData = [NSJSONSerialization dataWithJSONObject:notification options:0 error:&error];
    if (error) {
        NSLog(@"[WonderPush] error serializing notification: %@", error);
        return;
    }
    NSString *notificationJson = [[NSString alloc] initWithData:notificationJsonData encoding:NSUTF8StringEncoding];
    if (self.notificationOpenedCallback) {
        RCTResponseSenderBlock cb = self.notificationOpenedCallback;
        self.notificationOpenedCallback = nil; // Single use
        dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG
        NSLog(@"[WonderPush] callback React with opened notification %@", notificationJson);
#endif
            cb(@[notificationJson, [NSNumber numberWithInteger:buttonIndex]]);
        });
    } else {
#if DEBUG
        NSLog(@"[WonderPush] Save opened notification for later: %@", notificationJson);
#endif
        [self saveOpenedNotification:[[SavedNotification alloc] initWithJson:notificationJson buttonIndex:buttonIndex]];
    }
}

@end


@implementation WonderPushLib
- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"wonderpushNotificationWillOpen",
    ];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WonderPush setIntegrator:@"react-native-wonderpush-2.2.6"];
        [WonderPush setDelegate:[WonderPushLibDelegate instance]];
    });
}

- (instancetype) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:WP_NOTIFICATION_OPENED_BROADCAST object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary *notification = note.userInfo;
            [self sendEventWithName:@"wonderpushNotificationWillOpen" body:notification];
        }];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deeplinkOpened:) name:WP_DEEPLINK_OPENED object:nil];
        // Stop listening after 10 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:WP_DEEPLINK_OPENED object:nil];
        });
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) deeplinkOpened:(NSNotification *) notification {
    if (!self.initialDeepLinkURL) {
        self.initialDeepLinkURL = notification.userInfo[WP_DEEPLINK_OPENED_URL_USERINFO_KEY];
    }
}


+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(RNWonderPush)

#pragma mark - Initialization

RCT_EXPORT_METHOD(setLogging:(BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setLogging:enable];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

#pragma mark - Subscribing users

RCT_EXPORT_METHOD(subscribeToNotifications:(BOOL)fallbackToSettings resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush subscribeToNotifications];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(unsubscribeFromNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush unsubscribeFromNotifications];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(isSubscribedToNotifications:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        if ([WonderPush isSubscribedToNotifications]) {
            resolve(@YES);
        } else {
            resolve(@NO);
        }
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

#pragma mark - Segmentation

RCT_EXPORT_METHOD(trackEvent:(NSString *)type attributes:(NSDictionary *)attributes resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush trackEvent:type attributes:attributes];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(addTag:(NSArray *)tags resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush addTags:tags];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeTag:(NSArray *)tags resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush removeTags:tags];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeAllTags:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush removeAllTags];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(hasTag:(NSString *)tag resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        if ([WonderPush hasTag:tag]) {
            resolve(@YES);
        } else {
            resolve(@NO);
        }
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getTags:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSOrderedSet<NSString*> *tags = [WonderPush getTags];
        NSArray *arrTags = [NSArray arrayWithArray:[tags array]];
        resolve(arrTags);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPropertyValue:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
       id value = [WonderPush getPropertyValue:property];
       resolve(value);
    } @catch (NSError *e) {
       reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPropertyValues:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSArray *values = [WonderPush getPropertyValues:property];
        resolve(values);
    } @catch (NSError *e) {
       reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(addProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush addProperty:str value:properties];
        resolve(nil);
    }  @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(removeProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush removeProperty:str value:properties];
        resolve(nil);
    }  @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setProperty:(NSString *)str properties:(id)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setProperty:str value:properties];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(unsetProperty:(NSString *)property resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush unsetProperty:property];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(putProperties:(NSDictionary *)properties resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush putProperties:properties];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getProperties:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSDictionary *properties = [WonderPush getProperties];
        resolve(properties);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getCountry:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *country = [WonderPush country];
        resolve(country);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setCountry:(NSString *)country resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setCountry:country];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getCurrency:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *currency = [WonderPush currency];
        resolve(currency);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setCurrency:(NSString *)currency resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setCurrency:currency];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getLocale:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *locale = [WonderPush locale];
        resolve(locale);
    } @catch(NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setLocale:(NSString *)locale resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setLocale:locale];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getTimeZone:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *timeZone = [WonderPush timeZone];
        resolve(timeZone);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setTimeZone:(NSString *)timeZone resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
     @try {
        [WonderPush setTimeZone:timeZone];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

#pragma mark - User IDs

RCT_EXPORT_METHOD(getUserId:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *userId = [WonderPush userId];
        resolve(userId);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setUserId:(NSString *)userId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setUserId:userId];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

#pragma mark - Installation info

RCT_EXPORT_METHOD(getDeviceId:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *deviceId = [WonderPush deviceId];
        resolve(deviceId);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getInstallationId:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *installationId = [WonderPush installationId];
        resolve(installationId);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getPushToken:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *pushToken = [WonderPush pushToken];
        resolve(pushToken);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getAccessToken:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSString *accessToken = [WonderPush accessToken];
        resolve(accessToken);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

#pragma mark - Privacy

RCT_EXPORT_METHOD(setRequiresUserConsent:(BOOL)isConsent resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setRequiresUserConsent:isConsent];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(getUserConsent:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL userConsent = [WonderPush getUserConsent];
        resolve([NSNumber numberWithBool:userConsent]);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setUserConsent:(BOOL)isConsent resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush setUserConsent:isConsent];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(disableGeolocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush disableGeolocation];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(enableGeolocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush enableGeolocation];
        resolve(nil);
    } @catch(NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(setGeolocation:(double)lat lon:(double)lon resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        [WonderPush setGeolocation:location];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearEventsHistory:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush clearEventsHistory];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearPreferences:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush clearPreferences];
        resolve(nil);
    } @catch(NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(clearAllData:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        [WonderPush clearAllData];
        resolve(nil);
    } @catch (NSError *e) {
        reject(nil, nil, e);
    }
}

RCT_EXPORT_METHOD(downloadAllData:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [WonderPush downloadAllData:^(NSData *data, NSError *error) {
        if (error) {
            reject(nil, nil, error);
        }
        resolve(data);
    }];
}

RCT_EXPORT_METHOD(getInitialURL:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    // Stop listening for deeplinks
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WP_DEEPLINK_OPENED object:nil];

    NSDictionary *remoteNotification = self.bridge.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification && remoteNotification[@"_wp"][@"targetUrl"]) {
        resolve(remoteNotification[@"_wp"][@"targetUrl"]);
        return;
    }
    if (self.initialDeepLinkURL) {
        resolve(self.initialDeepLinkURL.absoluteString);
        return;
    }

    resolve(nil);
}


RCT_EXPORT_METHOD(setNotificationOpenedCallback:(RCTResponseSenderBlock)callback) {

    // Since we're repeatedly called, let's consume saved notifications one by one
    SavedNotification *notification = [WonderPushLibDelegate.instance consumeSavedOpenedNotification];
    if (notification && callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG
            NSLog(@"[WonderPush] Passing saved opened notification to React: %@", notification.json);
#endif
            callback(@[notification.json, [NSNumber numberWithInteger:notification.buttonIndex]]);
        });
        // Note: we're not keeping a reference on the callback, since it's consumed already
        return;
    }
    WonderPushLibDelegate.instance.notificationOpenedCallback = callback;
}

RCT_EXPORT_METHOD(setNotificationReceivedCallback:(RCTResponseSenderBlock)callback) {

    // Since we're repeatedly called, let's consume saved notifications one by one
    SavedNotification *notification = [WonderPushLibDelegate.instance consumeSavedReceivedNotification];
    if (notification && callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG
            NSLog(@"[WonderPush] Passing saved received notification to React: %@", notification.json);
#endif
            callback(@[notification.json]);
        });

        // Note: we're not keeping a reference on the callback, since it's consumed already
        return;
    }
    WonderPushLibDelegate.instance.notificationReceivedCallback = callback;
}
@end
