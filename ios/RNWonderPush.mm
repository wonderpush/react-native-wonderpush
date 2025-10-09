#import "RNWonderPush.h"
#import <WonderPush/WonderPush.h>
#import <React/RCTEventEmitter.h>

// Singleton delegate to handle WonderPush events before RNWonderPush module is initialized
@interface RNWonderPushDelegate : NSObject <WonderPushDelegate>
+ (instancetype)sharedInstance;
@property (nonatomic, weak) RNWonderPush *reactModule;
@property (nonatomic, strong) NSMutableArray *queuedReceivedNotifications;
@property (nonatomic, strong) NSMutableArray *queuedOpenedNotifications;
- (void)flushDelegateEvents;
@end

// Singleton delegate implementation
@implementation RNWonderPushDelegate

+ (instancetype)sharedInstance {
    static RNWonderPushDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _queuedReceivedNotifications = [NSMutableArray array];
        _queuedOpenedNotifications = [NSMutableArray array];
    }
    return self;
}

// Notification event emission methods (called by WonderPush delegate)
- (void)onNotificationReceived:(NSDictionary *)notification {
  if (self.reactModule) {
    NSString *notificationJson = [self dictionaryToJSONString:notification];
    [self.reactModule sendEventWithName:@"onNotificationReceived" body:notificationJson];
  } else {
    @synchronized(self) {
      [self.queuedReceivedNotifications addObject:notification];
    }
  }
}

- (void)onNotificationOpened:(NSDictionary *)notification withButton:(NSInteger)buttonIndex {
  if (self.reactModule) {
    NSString *notificationJson = [self dictionaryToJSONString:notification];
    NSDictionary *eventData = @{
      @"notification": notificationJson,
      @"buttonIndex": @(buttonIndex)
    };
    [self.reactModule sendEventWithName:@"onNotificationOpened" body:eventData];
  } else {
    @synchronized(self) {
      [self.queuedOpenedNotifications addObject:@{
        @"notification": notification,
        @"buttonIndex": @(buttonIndex)
      }];
    }
  }
}

- (void)flushDelegateEvents {
  @synchronized(self) {
    // Flush received notifications first
    for (NSDictionary *notification in self.queuedReceivedNotifications) {
      NSString *notificationJson = [self dictionaryToJSONString:notification];
      [self.reactModule sendEventWithName:@"onNotificationReceived" body:notificationJson];
    }
    [self.queuedReceivedNotifications removeAllObjects];

    // Then flush opened notifications
    for (NSDictionary *queuedItem in self.queuedOpenedNotifications) {
      NSDictionary *notification = queuedItem[@"notification"];
      NSInteger buttonIndex = [queuedItem[@"buttonIndex"] integerValue];
      NSString *notificationJson = [self dictionaryToJSONString:notification];
      NSDictionary *eventData = @{
        @"notification": notificationJson,
        @"buttonIndex": @(buttonIndex)
      };
      [self.reactModule sendEventWithName:@"onNotificationOpened" body:eventData];
    }
    [self.queuedOpenedNotifications removeAllObjects];
  }
}

- (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary {
    if (!dictionary) return @"{}";

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error || !jsonData) return @"{}";

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation RNWonderPush

RCT_EXPORT_MODULE(WonderPush)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WonderPush setIntegrator:@"react-native-wonderpush-3.0.0"];
        [WonderPush setDelegate:[RNWonderPushDelegate sharedInstance]];
    });
}

- (instancetype)init {
    if (self = [super init]) {
        // Register this module with the singleton delegate
        [RNWonderPushDelegate sharedInstance].reactModule = self;
    }
    return self;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeWonderPushSpecJSI>(params);
}

// Required for RCTEventEmitter
- (NSArray<NSString *> *)supportedEvents {
    return @[@"onNotificationReceived", @"onNotificationOpened"];
}

// Initialization
- (void)setLogging:(BOOL)enable resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setLogging:enable];
    resolve(nil);
}

- (void)initialize:(NSString *)clientId clientSecret:(NSString *)clientSecret resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setClientId:clientId secret:clientSecret];
    resolve(nil);
}

- (void)initializeAndRememberCredentials:(NSString *)clientId clientSecret:(NSString *)clientSecret resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setAndRememberClientId:clientId secret:clientSecret];
    resolve(nil);
}

- (void)getRememberedClientId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *clientId = [WonderPush getRememberedClientId];
    resolve(clientId);
}

- (void)isInitialized:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    BOOL initialized = [WonderPush isInitialized];
    resolve(@(initialized));
}

// Subscribing users
- (void)subscribeToNotifications:(BOOL)fallbackToSettings resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush subscribeToNotifications];
    resolve(nil);
}

- (void)unsubscribeFromNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush unsubscribeFromNotifications];
    resolve(nil);
}

- (void)isSubscribedToNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    BOOL subscribed = [WonderPush isSubscribedToNotifications];
    resolve(@(subscribed));
}

// Segmentation
- (void)trackEvent:(NSString *)type attributes:(NSDictionary *)attributes resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush trackEvent:type attributes:attributes];
    resolve(nil);
}

// Tags
- (void)addTag:(NSArray<NSString *> *)tags resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush addTags:tags];
    resolve(nil);
}

- (void)removeTag:(NSArray<NSString *> *)tags resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush removeTags:tags];
    resolve(nil);
}

- (void)removeAllTags:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush removeAllTags];
    resolve(nil);
}

- (void)hasTag:(NSString *)tag resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    BOOL hasTag = [WonderPush hasTag:tag];
    resolve(@(hasTag));
}

- (void)getTags:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSArray *tags = [[WonderPush getTags] array];
    resolve(tags ?: @[]);
}

// Properties
- (void)getPropertyValue:(NSString *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    id value = [WonderPush getPropertyValue:property];
    resolve(value);
}

- (void)getPropertyValues:(NSString *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSArray *values = [WonderPush getPropertyValues:property];
    resolve(values ?: @[]);
}

- (void)addProperty:(NSString *)str property:(NSArray *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush addProperty:str value:property];
    resolve(nil);
}

- (void)removeProperty:(NSString *)str property:(NSArray *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush removeProperty:str value:property];
    resolve(nil);
}

- (void)setProperty:(NSString *)str property:(NSArray *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setProperty:str value:property];
    resolve(nil);
}

- (void)unsetProperty:(NSString *)property resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush unsetProperty:property];
    resolve(nil);
}

- (void)putProperties:(NSDictionary *)properties resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush putProperties:properties];
    resolve(nil);
}

- (void)getProperties:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSDictionary *properties = [WonderPush getProperties];
    resolve(properties ?: @{});
}

// Localization
- (void)getCountry:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *country = [WonderPush country];
    resolve(country);
}

- (void)setCountry:(NSString *)country resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setCountry:country];
    resolve(nil);
}

- (void)getCurrency:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *currency = [WonderPush currency];
    resolve(currency);
}

- (void)setCurrency:(NSString *)currency resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setCurrency:currency];
    resolve(nil);
}

- (void)getLocale:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *locale = [WonderPush locale];
    resolve(locale);
}

- (void)setLocale:(NSString *)locale resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setLocale:locale];
    resolve(nil);
}

- (void)getTimeZone:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *timeZone = [WonderPush timeZone];
    resolve(timeZone);
}

- (void)setTimeZone:(NSString *)timeZone resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setTimeZone:timeZone];
    resolve(nil);
}

// User IDs
- (void)getUserId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *userId = [WonderPush userId];
    resolve(userId);
}

- (void)setUserId:(NSString *)userId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setUserId:userId];
    resolve(nil);
}

// Installation info
- (void)getDeviceId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *deviceId = [WonderPush deviceId];
    resolve(deviceId);
}

- (void)getInstallationId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *installationId = [WonderPush installationId];
    resolve(installationId);
}

- (void)getPushToken:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *pushToken = [WonderPush pushToken];
    resolve(pushToken);
}

- (void)getAccessToken:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    NSString *accessToken = [WonderPush accessToken];
    resolve(accessToken);
}

// Privacy
- (void)setRequiresUserConsent:(BOOL)isConsent resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setRequiresUserConsent:isConsent];
    resolve(nil);
}

- (void)getUserConsent:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    BOOL consent = [WonderPush getUserConsent];
    resolve(@(consent));
}

- (void)setUserConsent:(BOOL)isConsent resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setUserConsent:isConsent];
    resolve(nil);
}

- (void)disableGeolocation:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush disableGeolocation];
    resolve(nil);
}

- (void)enableGeolocation:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush enableGeolocation];
    resolve(nil);
}

- (void)setGeolocation:(double)lat lon:(double)lon resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush setGeolocation:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
    resolve(nil);
}

- (void)clearEventsHistory:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush clearEventsHistory];
    resolve(nil);
}

- (void)clearPreferences:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush clearPreferences];
    resolve(nil);
}

- (void)clearAllData:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush clearAllData];
    resolve(nil);
}

- (void)downloadAllData:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [WonderPush downloadAllData:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            reject(@"DOWNLOAD_ERROR", [NSString stringWithFormat:@"Failed to download data: %@", error.localizedDescription], error);
        } else if (data) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resolve(jsonString ?: [NSNull null]);
        } else {
            resolve([NSNull null]);
        }
    }];
}

// Event emission
- (void)flushDelegateEvents:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    [[RNWonderPushDelegate sharedInstance] flushDelegateEvents];
    resolve(nil);
}

// Deep linking
- (void)getInitialURL:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    // Stop listening for deeplinks
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WP_DEEPLINK_OPENED object:nil];

    NSDictionary *remoteNotification = self.bridge.launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification && remoteNotification[@"_wp"][@"targetUrl"]) {
        resolve(remoteNotification[@"_wp"][@"targetUrl"]);
        return;
    }
    //if (self.initialDeepLinkURL) {
    //    resolve(self.initialDeepLinkURL.absoluteString);
    //    return;
    //}

    resolve(nil);
}

@end
