//
//  WonderPushConcreteAPI.m
//  WonderPush
//
//  Created by Stéphane JAIS on 07/02/2019.
//

#import "WonderPushConcreteAPI.h"
#import "WPConfiguration.h"
#import "WPJsonSyncInstallation.h"
#import "WPLog.h"
#import "WonderPush.h"
#import "WPAPIClient.h"
#import "WPAction.h"
#import "WonderPush_private.h"
#import "WPUtil.h"
#import <UIKit/UIKit.h>
#import "WPInstallationCoreProperties.h"
#import "WPDataManager.h"

@interface WonderPushConcreteAPI (private)
@end

@implementation WonderPushConcreteAPI
- (void) activate {}
- (void) deactivate {}
- (instancetype) init
{
    if (self = [super init]) {
        self.locationManager = [CLLocationManager new];
    }
    return self;
}
/**
 Makes sure we have an up-to-date device token, and send it to WonderPush servers if necessary.
 */
- (void) refreshDeviceTokenIfPossible
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    });
}

- (void) trackInternalEvent:(NSString *)type eventData:(NSDictionary *)data customData:(NSDictionary *)customData
{
    if ([type characterAtIndex:0] != '@') {
        @throw [NSException exceptionWithName:@"illegal argument"
                                       reason:@"This method must only be called for internal events, starting with an '@'"
                                     userInfo:nil];
    }
    
    [self trackEvent:type eventData:data customData:customData];
}
- (void) trackEvent:(NSString *)type eventData:(NSDictionary *)data customData:(NSDictionary *)customData
{
    
    if (![type isKindOfClass:[NSString class]]) return;
    @synchronized (self) {
        NSString *eventEndPoint = @"/events";
        long long date = [WPUtil getServerDate];
        NSMutableDictionary *params = [[NSMutableDictionary alloc]
                                       initWithDictionary:@{@"type": type,
                                                            @"actionDate": [NSNumber numberWithLongLong:date]}];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in data) {
                [params setValue:[data objectForKey:key] forKey:key];
            }
        }
        
        if ([customData isKindOfClass:[NSDictionary class]]) {
            [params setValue:customData forKey:@"custom"];
        }
        
        CLLocation *location = [WonderPush location];
        if (location != nil) {
            params[@"location"] = @{@"lat": [NSNumber numberWithDouble:location.coordinate.latitude],
                                    @"lon": [NSNumber numberWithDouble:location.coordinate.longitude]};
        }
        
        [WonderPush postEventually:eventEndPoint params:@{@"body":params}];
    }
}
- (void) executeAction:(NSDictionary *)action onNotification:(NSDictionary *)notification
{
    WPLogDebug(@"Running action %@", action);
    @synchronized (self) {
        NSString *type = [WPUtil stringForKey:@"type" inDictionary:action];
        
        if ([WP_ACTION_TRACK isEqualToString:type]) {
            
            NSDictionary *event = [WPUtil dictionaryForKey:@"event" inDictionary:action] ?: @{};
            NSString *type = [WPUtil stringForKey:@"type" inDictionary:event];
            if (!type) return;
            NSDictionary *custom = [WPUtil dictionaryForKey:@"custom" inDictionary:event];
            [self trackEvent:type
                   eventData:@{@"campaignId": notification[@"c"] ?: [NSNull null],
                               @"notificationId": notification[@"n"] ?: [NSNull null]}
                  customData:custom];
            
        } else if ([WP_ACTION_UPDATE_INSTALLATION isEqualToString:type]) {
            
            NSNumber *appliedServerSide = [WPUtil numberForKey:@"appliedServerSide" inDictionary:action];
            NSDictionary *installation = [WPUtil dictionaryForKey:@"installation" inDictionary:action];
            NSDictionary *directCustom = [WPUtil dictionaryForKey:@"custom" inDictionary:action];
            if (installation == nil && directCustom != nil) {
                installation = @{@"custom":directCustom};
            }
            if (installation) {
                if ([appliedServerSide isEqual:@YES]) {
                    WPLogDebug(@"Received server installation diff: %@", installation);
                    [[WPJsonSyncInstallation forCurrentUser] receiveDiff:installation];
                } else {
                    WPLogDebug(@"Putting installation diff: %@", installation);
                    [[WPJsonSyncInstallation forCurrentUser] put:installation];
                }
            }
            
        } else if ([WP_ACTION_ADD_PROPERTY isEqualToString:type]) {
            
            NSDictionary *custom = [WPUtil dictionaryForKey:@"custom" inDictionary:([WPUtil dictionaryForKey:@"installation" inDictionary:action] ?: action)];
            if (custom) {
                for (id field in custom) {
                    [WonderPush addProperty:field value:custom[field]];
                }
            }
            
        } else if ([WP_ACTION_REMOVE_PROPERTY isEqualToString:type]) {
            
            NSDictionary *custom = [WPUtil dictionaryForKey:@"custom" inDictionary:([WPUtil dictionaryForKey:@"installation" inDictionary:action] ?: action)];
            if (custom) {
                for (id field in custom) {
                    [WonderPush removeProperty:field value:custom[field]];
                }
            }
            
        } else if ([WP_ACTION_ADD_TAG isEqualToString:type]) {
            
            NSArray *tags = [WPUtil arrayForKey:@"tags" inDictionary:action];
            [WonderPush addTags:tags];
            
        } else if ([WP_ACTION_REMOVE_TAG isEqualToString:type]) {
            
            NSArray *tags = [WPUtil arrayForKey:@"tags" inDictionary:action];
            [WonderPush removeTags:tags];
            
        } else if ([WP_ACTION_REMOVE_ALL_TAGS isEqualToString:type]) {
            
            [WonderPush removeAllTags];
            
        } else if ([WP_ACTION_CLOSE_NOTIFICATIONS isEqualToString:type]) {

            // NOTE: Unlike on Android, this is asynchronous, and almost always resolves after the current notification is displayed
            //       so until we have a completion handler in this method (and many levels up the call hierarchy,
            //       it's not possible to remove all notifications and then display a new one.
            if (@available(iOS 10.0, *)) {
                [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
                    NSMutableArray<NSString *> *ids = [NSMutableArray new];
                    for (UNNotification *notification in notifications) {
                        // Filter tag (notification.request.identifier is never nil, so code is simpler by skipping [NSNull null] handling)
                        NSString *tag = [WPUtil stringForKey:@"tag" inDictionary:action];
                        if (tag != nil && ![tag isEqualToString:notification.request.identifier]) {
                            continue;
                        }
                        // Filter threadId
                        id threadId = action[@"threadId"];
                        if (threadId != nil) {
                            if ((threadId == [NSNull null] || [@"" isEqualToString:threadId]) && !(notification.request.content.threadIdentifier == nil || [@"" isEqualToString:notification.request.content.threadIdentifier])) {
                                continue;
                            } else if ([threadId isKindOfClass:[NSString class]] && ![threadId isEqualToString:notification.request.content.threadIdentifier]) {
                                continue;
                            }
                        }
                        // Filter category
                        id category = action[@"category"];
                        if (category != nil) {
                            if ((category == [NSNull null] || [@"" isEqualToString:category]) && !(notification.request.content.categoryIdentifier == nil || [@"" isEqualToString:notification.request.content.categoryIdentifier])) {
                                continue;
                            } else if ([category isKindOfClass:[NSString class]] && ![category isEqualToString:notification.request.content.categoryIdentifier]) {
                                continue;
                            }
                        }
                        // Filter targetContentId
                        if (@available(iOS 13.0, *)) {
                            id targetContentId = action[@"targetContentId"];
                            if (targetContentId != nil) {
                                if ((targetContentId == [NSNull null] || [@"" isEqualToString:targetContentId]) && !(notification.request.content.targetContentIdentifier == nil || [@"" isEqualToString:notification.request.content.targetContentIdentifier])) {
                                    continue;
                                } else if ([targetContentId isKindOfClass:[NSString class]] && ![targetContentId isEqualToString:notification.request.content.targetContentIdentifier]) {
                                    continue;
                                }
                            }
                        }

                        [ids addObject:notification.request.identifier];
                    }
                    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:ids];
                }];
            }

        } else if ([WP_ACTION_RESYNC_INSTALLATION isEqualToString:type]) {
            
            void (^cont)(NSDictionary *action) = ^(NSDictionary *action){
                WPLogDebug(@"Running enriched action %@", action);
                NSDictionary *installation = [WPUtil dictionaryForKey:@"installation" inDictionary:action] ?: @{};
                NSNumber *reset = [WPUtil numberForKey:@"reset" inDictionary:action];
                NSNumber *force = [WPUtil numberForKey:@"force" inDictionary:action];
                
                // Take or reset custom
                if ([reset isEqual:@YES]) {
                    [[WPJsonSyncInstallation forCurrentUser] receiveState:installation
                                                            resetSdkState:[force isEqual:@YES]];
                } else {
                    [[WPJsonSyncInstallation forCurrentUser] receiveServerState:installation];
                }
                
                [WonderPush refreshPreferencesAndConfiguration];
            };
            
            NSDictionary *installation = [WPUtil dictionaryForKey:@"installation" inDictionary:action];
            if (installation) {
                cont(action);
            } else {
                
                WPLogDebug(@"Fetching installation for action %@", type);
                [WonderPush get:@"/installation" params:nil handler:^(WPResponse *response, NSError *error) {
                    if (error) {
                        WPLog(@"Failed to fetch installation for running action %@: %@", action, error);
                        return;
                    }
                    if (![response.object isKindOfClass:[NSDictionary class]]) {
                        WPLog(@"Failed to fetch installation for running action %@, got: %@", action, response.object);
                        return;
                    }
                    NSMutableDictionary *installation = [(NSDictionary *)response.object mutableCopy];
                    // Filter other fields starting with _ like _serverTime and _serverTook
                    [installation removeObjectsForKeys:[installation.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        return [evaluatedObject isKindOfClass:[NSString class]] && [(NSString*)evaluatedObject hasPrefix:@"_"];
                    }]]];
                    NSMutableDictionary *actionFilled = [[NSMutableDictionary alloc] initWithDictionary:action];
                    actionFilled[@"installation"] = [NSDictionary dictionaryWithDictionary:installation];
                    cont(actionFilled);
                    // We added async processing, we need to ensure that we flush it too, especially in case we're running receiveActions in the background
                    [WPJsonSyncInstallation flush];
                }];
                
            }
            
        } else if ([WP_ACTION_RATING isEqualToString:type]) {
            
            NSString *itunesAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:WP_ITUNES_APP_ID];
            if (itunesAppId != nil) {
                [WonderPush openURL:[NSURL URLWithString:[NSString stringWithFormat:ITUNES_APP_URL_FORMAT, itunesAppId]]];
            }
            
        } else  if ([WP_ACTION_METHOD_CALL isEqualToString:type]) {
            
            NSString *methodName = [WPUtil stringForKey:@"method" inDictionary:action];
            id methodParameter = [WPUtil nullsafeObjectForKey:@"methodArg" inDictionary:action];
            NSDictionary *parameters = @{
                                         WP_REGISTERED_CALLBACK_METHOD_KEY: methodName ?: [NSNull null],
                                         WP_REGISTERED_CALLBACK_PARAMETER_KEY: methodParameter ?: [NSNull null],
                                         };
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:methodName object:self userInfo:parameters]; // @FIXME Deprecated, remove in v4.0.0
                [[NSNotificationCenter defaultCenter] postNotificationName:WP_NOTIFICATION_REGISTERED_CALLBACK object:self userInfo:parameters];
            });
            
        } else if ([WP_ACTION_LINK isEqualToString:type]) {
            
            NSString *url = [WPUtil stringForKey:@"url" inDictionary:action];
            [WonderPush openURL:[NSURL URLWithString:url]];
            
        } else if ([WP_ACTION_MAP_OPEN isEqualToString:type]) {
            
            NSDictionary *mapData = [WPUtil dictionaryForKey:@"map" inDictionary:notification] ?: @{};
            NSDictionary *place = [WPUtil dictionaryForKey:@"place" inDictionary:mapData] ?: @{};
            NSDictionary *point = [WPUtil dictionaryForKey:@"point" inDictionary:place] ?: @{};
            NSNumber *lat = [WPUtil numberForKey:@"lat" inDictionary:point];
            NSNumber *lon = [WPUtil numberForKey:@"lon" inDictionary:point];
            if (!lat || !lon) return;
            NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f", [lat doubleValue], [lon doubleValue]];
            WPLogDebug(@"url: %@", url);
            [WonderPush openURL:[NSURL URLWithString:url]];
            
        } else if ([WP_ACTION__DUMP_STATE isEqualToString:type]) {
            
            NSDictionary *stateDump = [[WPConfiguration sharedConfiguration] dumpState] ?: @{};
            WPLog(@"STATE DUMP: %@", stateDump);
            [self trackInternalEvent:@"@DEBUG_DUMP_STATE"
                           eventData:nil
                          customData:@{@"ignore_sdkStateDump": stateDump}];
            
        } else if ([WP_ACTION__OVERRIDE_SET_LOGGING isEqualToString:type]) {
            
            NSNumber *force = [WPUtil numberForKey:@"force" inDictionary:action];
            WPLog(@"OVERRIDE setLogging: %@", force);
            [WPConfiguration sharedConfiguration].overrideSetLogging = force;
            if (force != nil) {
                WPLogEnable([force boolValue]);
            }
            
        } else if ([WP_ACTION__OVERRIDE_NOTIFICATION_RECEIPT isEqualToString:type]) {
            
            NSNumber *force = [WPUtil numberForKey:@"force" inDictionary:action];
            WPLog(@"OVERRIDE notification receipt: %@", force);
            [WPConfiguration sharedConfiguration].overrideNotificationReceipt = force;
            
        } else {
            WPLogDebug(@"Unhandled action type %@", type);
        }
    }
}

- (CLLocation *)location
{
    CLLocation *location = self.locationManager.location;
    if (   !location // skip if unavailable
        || [location.timestamp timeIntervalSinceNow] < -300 // skip if older than 5 minutes
        || location.horizontalAccuracy < 0 // skip invalid locations
        || location.horizontalAccuracy > 10000 // skip if less precise then 10 km
        ) {
        return nil;
    }
    return location;

}
- (void) updateInstallationCoreProperties
{
    @synchronized (self) {
        NSNull *null = [NSNull null];
        NSDictionary *apple = @{@"apsEnvironment": [WPUtil getEntitlement:@"aps-environment"] ?: null,
                                @"appId": [WPUtil getEntitlement:@"application-identifier"] ?: null,
                                @"backgroundModes": [WPUtil getBackgroundModes] ?: null
                                };
        NSDictionary *application = @{@"version" : [WPInstallationCoreProperties getVersionString] ?: null,
                                      @"sdkVersion": [WPInstallationCoreProperties getSDKVersionNumber] ?: null,
                                      @"integrator": [WonderPush getIntegrator] ?: null,
                                      @"apple": apple ?: null
                                      };
        
        NSDictionary *configuration = @{@"timeZone": [WPInstallationCoreProperties getTimezone] ?: null,
                                        @"carrier": [WPInstallationCoreProperties getCarrierName] ?: null,
                                        @"country": [WPInstallationCoreProperties getCountry] ?: null,
                                        @"currency": [WPInstallationCoreProperties getCurrency] ?: null,
                                        @"locale": [WPInstallationCoreProperties getLocale] ?: null};
        
        CGRect screenSize = [WPInstallationCoreProperties getScreenSize];
        NSDictionary *device = @{@"id": [WPUtil deviceIdentifier] ?: null,
                                 @"platform": @"iOS",
                                 @"osVersion": [WPInstallationCoreProperties getOsVersion] ?: null,
                                 @"brand": @"Apple",
                                 @"model": [WPInstallationCoreProperties getDeviceModel] ?: null,
                                 @"screenWidth": [NSNumber numberWithInt:(int)screenSize.size.width] ?: null,
                                 @"screenHeight": [NSNumber numberWithInt:(int)screenSize.size.height] ?: null,
                                 @"screenDensity": [NSNumber numberWithInt:(int)[WPInstallationCoreProperties getScreenDensity]] ?: null,
                                 @"configuration": configuration,
                                 };
        
        NSDictionary *properties = @{@"application": application,
                                     @"device": device
                                     };
        
        WPConfiguration *sharedConfiguration = [WPConfiguration sharedConfiguration];
        [sharedConfiguration setCachedInstallationCoreProperties:properties];
        [sharedConfiguration setCachedInstallationCorePropertiesDate: [NSDate date]];
        [sharedConfiguration setCachedInstallationCorePropertiesAccessToken:sharedConfiguration.accessToken];
        [[WPJsonSyncInstallation forCurrentUser] put:properties];
    }
}

- (void) setNotificationEnabled:(BOOL)enabled
{
    [WPConfiguration sharedConfiguration].notificationEnabled = enabled;
    [WonderPush refreshPreferencesAndConfiguration];

    // Register to push notifications if enabled
    if (enabled) {
        [WPUtil askUserPermission];
    }
}

- (void) sendPreferences
{
    [WonderPush hasAcceptedVisibleNotificationsWithCompletionHandler:^(BOOL osNotificationsEnabled) {
        WPConfiguration *sharedConfiguration = [WPConfiguration sharedConfiguration];
        BOOL enabled = sharedConfiguration.notificationEnabled;
        NSString *value = enabled && osNotificationsEnabled ? @"optIn" : @"optOut";

        sharedConfiguration.cachedOsNotificationEnabled = osNotificationsEnabled;
        sharedConfiguration.cachedOsNotificationEnabledDate = [NSDate date];

        [[WPJsonSyncInstallation forCurrentUser] put:@{@"preferences": @{
                                                               @"subscriptionStatus": value,
                                                               @"subscribedToNotifications": enabled ? @YES : @NO,
                                                               @"osNotificationsVisible": osNotificationsEnabled ? @YES : @NO,
                                                               }}];
    }];
}

- (BOOL) getNotificationEnabled
{
    WPConfiguration *sharedConfiguration = [WPConfiguration sharedConfiguration];
    return sharedConfiguration.notificationEnabled;
}
- (void) setDeviceToken:(NSString *)deviceToken
{
    @synchronized (self) {
        WPConfiguration *sharedConfiguration = [WPConfiguration sharedConfiguration];
        [sharedConfiguration setDeviceToken:deviceToken];
        [sharedConfiguration setDeviceTokenAssociatedToUserId:sharedConfiguration.userId];
        [sharedConfiguration setCachedDeviceTokenDate:[NSDate date]];
        [sharedConfiguration setCachedDeviceTokenAccessToken:sharedConfiguration.accessToken];
        [[WPJsonSyncInstallation forCurrentUser] put:@{@"pushToken": @{@"data": deviceToken ?: [NSNull null]}}];
    }
}

- (NSString *)accessToken {
    WPConfiguration *configuration = [WPConfiguration sharedConfiguration];
    return configuration.accessToken;
}


- (NSString *)deviceId {
    return [WPUtil deviceIdentifier];
}


- (NSDictionary *)getInstallationCustomProperties {
    @synchronized (self) {
        NSDictionary *customProperties = [([WPUtil dictionaryForKey:@"custom" inDictionary:[WPJsonSyncInstallation forCurrentUser].sdkState] ?: @{}) copy];
        NSMutableDictionary *rtn = [NSMutableDictionary new];
        for (id key in customProperties) {
            if ([key isKindOfClass:[NSString class]] && [(NSString *)key containsString:@"_"]) {
                rtn[key] = customProperties[key];
            }
        }
        return [NSDictionary dictionaryWithDictionary:rtn];
    }
}


- (NSString *)installationId {
    WPConfiguration *configuration = [WPConfiguration sharedConfiguration];
    return configuration.installationId;
}


- (NSString *)pushToken {
    WPConfiguration *configuration = [WPConfiguration sharedConfiguration];
    return configuration.deviceToken;
}


- (void)putInstallationCustomProperties:(NSDictionary *)customProperties {
    @synchronized (self) {
        NSMutableDictionary *diff = [NSMutableDictionary new];
        for (id key in customProperties ?: @{}) {
            if ([key isKindOfClass:[NSString class]] && [(NSString *)key containsString:@"_"]) {
                diff[key] = customProperties[key];
            } else {
                WPLog(@"Dropping an installation property with no prefix: %@", key);
            }
        }
        [[WPJsonSyncInstallation forCurrentUser] put:@{@"custom":diff}];
    }
}


- (void)trackEvent:(NSString *)type {
    [self trackEvent:type eventData:nil customData:nil];
}


- (void)trackEvent:(NSString *)type withData:(NSDictionary *)data {
    [self trackEvent:type eventData:nil customData:data];
}

- (void)clearAllData {
    [[WPDataManager sharedInstance] clearAllData];
}


- (void)clearEventsHistory {
    [[WPDataManager sharedInstance] clearEventsHistory];
}


- (void)clearPreferences {
    [[WPDataManager sharedInstance] clearPreferences];
}


- (void)downloadAllData:(void (^)(NSData *, NSError *))completion {
    [[WPDataManager sharedInstance] downloadAllData:completion];
}


- (NSDictionary *)getProperties {
    return [self getInstallationCustomProperties];
}


- (void) setProperty:(NSString *)field value:(id)value {
    if (field == nil) return;
    [self putProperties:@{field: value ?: [NSNull null]}];
}


- (void) unsetProperty:(NSString *)field {
    if (field == nil) return;
    [self putProperties:@{field: [NSNull null]}];
}


- (void) addProperty:(NSString *)field value:(id)value {
    if (field == nil || value == nil || value == [NSNull null]) return;
    @synchronized (self) {
        // The contract is to actually append new values only, not shuffle or deduplicate everything,
        // hence the array and the set.
        NSMutableArray *values = [NSMutableArray arrayWithArray:[self getPropertyValues:field]];
        NSMutableSet *set = [NSMutableSet setWithArray:values];
        NSArray *inputs = [value isKindOfClass:[NSArray class]] ? value : @[value];
        for (id input in inputs) {
            if (input == nil || input == [NSNull null]) continue;
            if ([set containsObject:input]) continue;
            [values addObject:input];
            [set addObject:input];
        }
        [self setProperty:field value:values];
    }
}


- (void) removeProperty:(NSString *)field value:(id)value {
    if (field == nil || value == nil) return; // Note: We accept removing NSNull.
    @synchronized (self) {
        // The contract is to actually remove every listed values (all duplicated appearences), not shuffle or deduplicate everything else
        NSMutableArray *values = [NSMutableArray arrayWithArray:[self getPropertyValues:field]];
        NSArray *inputs = [value isKindOfClass:[NSArray class]] ? value : @[value];
        [values removeObjectsInArray:inputs];
        [self setProperty:field value:values];
    }
}


- (id) getPropertyValue:(NSString *)field {
    if (field == nil) return [NSNull null];
    @synchronized (self) {
        NSDictionary *properties = [self getProperties];
        id rtn = properties[field];
        if ([rtn isKindOfClass:[NSArray class]]) {
            rtn = [rtn count] > 0 ? [rtn objectAtIndex:0] : nil;
        }
        if (rtn == nil) rtn = [NSNull null];
        return rtn;
    }
}


- (NSArray *) getPropertyValues:(NSString *)field {
    if (field == nil) return @[];
    @synchronized (self) {
        NSDictionary *properties = [self getProperties];
        id rtn = properties[field];
        if (rtn == nil || rtn == [NSNull null]) rtn = @[];
        if (![rtn isKindOfClass:[NSArray class]]) {
            rtn = @[rtn];
        }
        return rtn;
    }
}


- (BOOL)isSubscribedToNotifications {
    return [self getNotificationEnabled];
}


- (void)putProperties:(NSDictionary *)properties {
    return [self putInstallationCustomProperties:properties];
}


- (void)subscribeToNotifications {
    return [self setNotificationEnabled:YES];
}


- (void)trackEvent:(NSString *)eventType attributes:(NSDictionary *)attributes {
    return [self trackEvent:eventType eventData:nil customData:attributes];
}


- (void)unsubscribeFromNotifications {
    return [self setNotificationEnabled:NO];
}

- (void) addTag:(NSString *)tag {
    [self addTags:@[tag]];
}

- (void) addTags:(NSArray<NSString *> *)newTags {
    if (newTags == nil || [newTags count] == 0) return;
    @synchronized(self) {
        NSMutableOrderedSet<NSString *> *tags = [NSMutableOrderedSet orderedSetWithOrderedSet:[self getTags]];
        for (NSString *tag in newTags) {
            if (![tag isKindOfClass:[NSString class]] || [tag length] == 0) continue;
            [tags addObject:tag];
        }
        [[WPJsonSyncInstallation forCurrentUser] put:@{@"custom":@{@"tags":[tags array]}}];
    }
}

- (void) removeTag:(NSString *)tag {
    [self removeTags:@[tag]];
}

- (void) removeTags:(NSArray<NSString *> *)oldTags {
    if (oldTags == nil || [oldTags count] == 0) return;
    @synchronized(self) {
        NSMutableOrderedSet<NSString *> *tags = [NSMutableOrderedSet orderedSetWithOrderedSet:[self getTags]];
        for (NSString *tag in oldTags) {
            if (![tag isKindOfClass:[NSString class]]) continue;
            [tags removeObject:tag];
        }
        [[WPJsonSyncInstallation forCurrentUser] put:@{@"custom":@{@"tags":[tags array]}}];
    }
}

- (void) removeAllTags {
    [[WPJsonSyncInstallation forCurrentUser] put:@{@"custom":@{@"tags":[NSNull null]}}];
}

- (NSOrderedSet<NSString *> *) getTags {
    @synchronized(self) {
        NSDictionary *custom = [([WPUtil dictionaryForKey:@"custom" inDictionary:[WPJsonSyncInstallation forCurrentUser].sdkState] ?: @{}) copy];
        NSArray *tags = [WPUtil arrayForKey:@"tags" inDictionary:custom];
        if (tags == nil) {
            // Recover from a potential scalar string value
            if ([custom[@"tags"] isKindOfClass:[NSString class]]) {
                tags = @[custom[@"tags"]];
            } else {
                tags = @[];
            }
        }
        
        NSMutableOrderedSet<NSString *> *rtn = [NSMutableOrderedSet new]; // use a sorted implementation to avoid useless diffs later on
        for (id tag in tags) {
            if (![tag isKindOfClass:[NSString class]] || [tag length] == 0) continue;
            [rtn addObject:tag];
        }
        return [NSOrderedSet orderedSetWithOrderedSet:rtn];
    }
}

- (bool) hasTag:(NSString *)tag {
    if (tag == nil) return NO;
    @synchronized (self) {
        return [[self getTags] containsObject:tag];
    }
}


@end
