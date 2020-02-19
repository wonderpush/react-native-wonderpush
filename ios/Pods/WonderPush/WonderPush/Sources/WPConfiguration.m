/*
 Copyright 2014 WonderPush

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "WPConfiguration.h"
#import "WonderPush_private.h"
#import "WPLog.h"
#import "WPJsonUtil.h"
#import "WPRequestVault.h"
#import "WPUtil.h"

static WPConfiguration *sharedConfiguration = nil;

@interface WPConfiguration ()

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSNumber *_notificationEnabled;

@end


@implementation WPConfiguration

@synthesize accessToken = _accessToken;
@synthesize deviceToken = _deviceToken;
@synthesize sid = _sid;
@synthesize userId = _userId;
@synthesize installationId = _installationId;
@synthesize _notificationEnabled = __notificationEnabled;
@synthesize timeOffset = _timeOffset;
@synthesize timeOffsetPrecision = _timeOffsetPrecision;
@synthesize justOpenedNotification = _justOpenedNotification;


+ (void) initialize
{
    sharedConfiguration = [[self alloc] init];
}

+ (WPConfiguration *) sharedConfiguration
{
    return sharedConfiguration;
}


#pragma mark - Utilities

- (NSDictionary *) _getNSDictionaryFromJSONForKey:(NSString *)key
{
    id rawValue = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (!rawValue) return nil;
    if ([rawValue isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)rawValue;
    } else if ([rawValue isKindOfClass:[NSData class]]) {
        NSError *error = NULL;
        NSDictionary *value = [NSJSONSerialization JSONObjectWithData:(NSData *)rawValue options:kNilOptions error:&error];
        if (error) WPLog(@"WPConfiguration: Error while deserializing %@: %@", key, error);
        return value;
    }
    WPLog(@"WPConfiguration: Expected an NSDictionary of JSON NSData but got: (%@) %@, for key %@", [rawValue class], rawValue, key);
    return nil;
}

- (void) _setNSDictionaryAsJSON:(NSDictionary *)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (value) {
        NSError *error = NULL;
        NSData *data = [NSJSONSerialization dataWithJSONObject:value options:kNilOptions error:&error];
        if (error) WPLog(@"WPConfiguration: Error while serializing %@: %@", key, error);
        [defaults setValue:data forKeyPath:key];
    } else {
        [defaults removeObjectForKey:key];
    }

    [defaults synchronize];
}

- (NSDate *) _getNSDateForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void) _setNSDate:(NSDate *)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (value) {
        [defaults setValue:value forKeyPath:key];
    } else {
        [defaults removeObjectForKey:key];
    }

    [defaults synchronize];
}

- (NSString *) _getNSStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void) _setNSString:(NSString *)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (value) {
        [defaults setValue:value forKeyPath:key];
    } else {
        [defaults removeObjectForKey:key];
    }

    [defaults synchronize];
}

- (NSNumber *) _getNSNumberForKey:(NSString *)key
{
    id value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (![value isKindOfClass:[NSNumber class]]) value = nil;
    return (NSNumber *)value;
}

- (void) _setNSNumber:(NSNumber *)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (value) {
        [defaults setValue:value forKeyPath:key];
    } else {
        [defaults removeObjectForKey:key];
    }

    [defaults synchronize];
}

- (NSDictionary *) dumpState
{
    NSMutableDictionary *rtn = [NSMutableDictionary new];
    [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([USER_DEFAULTS_REQUEST_VAULT_QUEUE isEqualToString:key]) {
            NSArray *requests = [WPRequestVault savedRequests];
            NSMutableArray *value = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)obj count]];
            [requests enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WPRequest class]]) {
                    [value addObject:[(WPRequest *)obj toJSON]];
                }
            }];
            obj = [[NSArray alloc] initWithArray:value];
        }
        if ([key hasPrefix:@"_wonderpush"] || [key hasPrefix:@"__wonderpush"]) {
            rtn[key] = [WPJsonUtil ensureJSONEncodable:obj];
        }
    }];
    return [NSDictionary dictionaryWithDictionary:rtn];
}


#pragma mark - JSON utilities

- (id) _NSDateToJSON:(NSDate *)date
{
    if (!date) return [NSNull null];
    return [NSNumber numberWithLongLong:(long long)([date timeIntervalSince1970] * 1000)];
}

- (NSDate *) _JSONToNSDate:(id)value
{
    if ([value isKindOfClass:[NSNumber class]]) {
        if ([value longLongValue] == INT_MAX) {
            WPLogDebug(@"Returning nil date instead of 2038-01-19T03:14:07Z (INT_MAX)");
            // Previous version of -[WPConfiguration _NSDateToJSON:] gave INT_MAX for any reasonable dates
            return nil;
        }
        return [NSDate dateWithTimeIntervalSince1970:([(NSNumber *)value longLongValue]/1000)];
    }
    return nil;
}

- (NSNumber *) _BOOLToJSON:(BOOL)value
{
    return value == YES ? @YES : @NO;
}

- (BOOL) _JSONToBOOL:(id)value withDefault:(BOOL)defaultValue
{
    if (!value || value == [NSNull null]) return defaultValue;
    if ([value isEqual:@YES]) return YES;
    return NO;
}

- (id) _NSStringToJSON:(NSString *)value
{
    return value ?: [NSNull null];
}

- (NSString *) _JSONToNSString:(id)value
{
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

- (id) _NSDictionaryToJSON:(NSDictionary *)value
{
    return value ?: [NSNull null];
}

- (NSDictionary *) _JSONToNSDictionary:(id)value
{
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

#pragma mark - User consent
- (BOOL) userConsent
{
    return [[self _getNSNumberForKey:USER_DEFAULTS_USER_CONSENT_KEY] boolValue];
}
- (void) setUserConsent:(BOOL)userConsent
{
    [self _setNSNumber:[NSNumber numberWithBool:userConsent] forKey:USER_DEFAULTS_USER_CONSENT_KEY];
}
#pragma mark - Change user id

- (void) changeUserId:(NSString *)newUserId
{
    if ([@"" isEqualToString:newUserId]) newUserId = nil;
    if ((newUserId == nil && self.userId == nil)
        || (newUserId != nil && [newUserId isEqualToString:self.userId])) {
        // No userId change
        return;
    }
    // Save current user preferences
    NSDictionary *currentUserArchive = @{
                                         USER_DEFAULTS_ACCESS_TOKEN_KEY: [self _NSStringToJSON:self.accessToken],
                                         USER_DEFAULTS_SID_KEY: [self _NSStringToJSON:self.sid],
                                         USER_DEFAULTS_INSTALLATION_ID: [self _NSStringToJSON:self.installationId],
                                         USER_DEFAULTS_USER_ID_KEY: [self _NSStringToJSON:self.userId],
                                         USER_DEFAULTS_NOTIFICATION_ENABLED_KEY: [self _BOOLToJSON:self.notificationEnabled],
                                         USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_KEY: [self _BOOLToJSON:self.cachedOsNotificationEnabled],
                                         USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_DATE_KEY: [self _NSDateToJSON:self.cachedOsNotificationEnabledDate],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES: [self _NSDictionaryToJSON:self.cachedInstallationCoreProperties],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_DATE: [self _NSDateToJSON:self.cachedInstallationCorePropertiesDate],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_ACCESS_TOKEN: [self _NSStringToJSON:self.cachedInstallationCorePropertiesAccessToken],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN: [self _NSDictionaryToJSON:self.cachedInstallationCustomPropertiesWritten],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN_DATE: [self _NSDateToJSON:self.cachedInstallationCustomPropertiesWrittenDate],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED: [self _NSDictionaryToJSON:self.cachedInstallationCustomPropertiesUpdated],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED_DATE: [self _NSDateToJSON:self.cachedInstallationCustomPropertiesUpdatedDate],
                                         USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_FIRST_DELAYED_WRITE_DATE: [self _NSDateToJSON:self.cachedInstallationCustomPropertiesFirstDelayedWriteDate],
                                         USER_DEFAULTS_LAST_INTERACTION_DATE: [self _NSDateToJSON:self.lastInteractionDate],
                                         USER_DEFAULTS_LAST_APP_OPEN_DATE: [self _NSDateToJSON:self.lastAppOpenDate],
                                         USER_DEFAULTS_LAST_APP_OPEN_INFO: [self _NSDictionaryToJSON:self.lastAppOpenInfo],
                                         USER_DEFAULTS_LAST_APP_CLOSE_DATE: [self _NSDateToJSON:self.lastAppCloseDate],
                                         USER_DEFAULTS_COUNTRY: [self _NSStringToJSON:self.country],
                                         USER_DEFAULTS_CURRENCY: [self _NSStringToJSON:self.currency],
                                         USER_DEFAULTS_LOCALE: [self _NSStringToJSON:self.locale],
                                         USER_DEFAULTS_TIME_ZONE: [self _NSStringToJSON:self.timeZone],
                                         };
    NSMutableDictionary *usersArchive = [([self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_PER_USER_ARCHIVE_KEY] ?: @{}) mutableCopy];
    usersArchive[self.userId ?: @""] = currentUserArchive;
    [self _setNSDictionaryAsJSON:usersArchive forKey:USER_DEFAULTS_PER_USER_ARCHIVE_KEY];

    // Load new user preferences
    NSDictionary *newUserArchive = usersArchive[newUserId ?: @""] ?: @{};
    self.userId              = newUserId;
    self.accessToken         = [self _JSONToNSString:newUserArchive[USER_DEFAULTS_ACCESS_TOKEN_KEY]];
    self.sid                 = [self _JSONToNSString:newUserArchive[USER_DEFAULTS_SID_KEY]];
    self.installationId      = [self _JSONToNSString:newUserArchive[USER_DEFAULTS_INSTALLATION_ID]];
    self.notificationEnabled = [self _JSONToBOOL:    newUserArchive[USER_DEFAULTS_NOTIFICATION_ENABLED_KEY] withDefault:YES];
    self.cachedOsNotificationEnabled                             = [self _JSONToBOOL:        newUserArchive[USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_KEY] withDefault:NO];
    self.cachedOsNotificationEnabledDate                         = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_DATE_KEY]];
    self.cachedInstallationCoreProperties                        = [self _JSONToNSDictionary:newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES]];
    self.cachedInstallationCorePropertiesDate                    = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_DATE]];
    self.cachedInstallationCorePropertiesAccessToken             = [self _JSONToNSString:    newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_ACCESS_TOKEN]];
    self.cachedInstallationCustomPropertiesWritten               = [self _JSONToNSDictionary:newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN]];
    self.cachedInstallationCustomPropertiesWrittenDate           = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN_DATE]];
    self.cachedInstallationCustomPropertiesUpdated               = [self _JSONToNSDictionary:newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED]];
    self.cachedInstallationCustomPropertiesUpdatedDate           = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED_DATE]];
    self.cachedInstallationCustomPropertiesFirstDelayedWriteDate = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_FIRST_DELAYED_WRITE_DATE]];
    self.lastInteractionDate = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_LAST_INTERACTION_DATE]];
    self.lastAppOpenDate     = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_LAST_APP_OPEN_DATE]];
    self.lastAppOpenInfo     = [self _JSONToNSDictionary:newUserArchive[USER_DEFAULTS_LAST_APP_OPEN_INFO]];
    self.lastAppCloseDate    = [self _JSONToNSDate:      newUserArchive[USER_DEFAULTS_LAST_APP_CLOSE_DATE]];
    self.country             = [self _JSONToNSString:    newUserArchive[USER_DEFAULTS_COUNTRY]];
    self.currency            = [self _JSONToNSString:    newUserArchive[USER_DEFAULTS_CURRENCY]];
    self.locale              = [self _JSONToNSString:    newUserArchive[USER_DEFAULTS_LOCALE]];
    self.timeZone            = [self _JSONToNSString:    newUserArchive[USER_DEFAULTS_TIME_ZONE]];
}

// Uses @"" for nil userId
- (NSArray *) listKnownUserIds
{
    NSDictionary *usersArchive = [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_PER_USER_ARCHIVE_KEY] ?: @{};
    NSMutableArray *mutable = [[NSMutableArray alloc] initWithArray:[usersArchive allKeys]];
    if (![mutable containsObject:self.userId ?: @""]) {
        [mutable addObject:self.userId ?: @""];
    }
    return [[NSArray alloc] initWithArray:mutable];
}


#pragma mark - Access token

- (NSURL *) baseURL
{
    return [NSURL URLWithString:PRODUCTION_API_URL];
}

- (NSString *) accessToken
{
    if (_accessToken)
        return _accessToken;

    _accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_ACCESS_TOKEN_KEY];
    return _accessToken;
}

- (NSString *) deviceToken
{
    if (_deviceToken)
        return _deviceToken;

    _deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_DEVICE_TOKEN_KEY];
    return _deviceToken;
}

- (void) setDeviceToken:(NSString *)deviceToken
{
    _deviceToken = deviceToken;
    WPLogDebug(@"Setting device token: %@", deviceToken);
    [self _setNSString:deviceToken forKey:USER_DEFAULTS_DEVICE_TOKEN_KEY];
}

- (NSDate *) cachedDeviceTokenDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_DEVICE_TOKEN_DATE];
}

- (void) setCachedDeviceTokenDate:(NSDate *)cachedDeviceTokenDate
{
    [self _setNSDate:cachedDeviceTokenDate forKey:USER_DEFAULTS_CACHED_DEVICE_TOKEN_DATE];
}

- (NSString *) deviceTokenAssociatedToUserId
{
    return [self _getNSStringForKey:USER_DEFAULTS_DEVICE_TOKEN_ASSOCIATED_TO_USER_ID_KEY];
}

- (void) setDeviceTokenAssociatedToUserId:(NSString *)userId
{
    [self _setNSString:userId forKey:USER_DEFAULTS_DEVICE_TOKEN_ASSOCIATED_TO_USER_ID_KEY];
}

- (NSString *) cachedDeviceTokenAccessToken
{
    return [self _getNSStringForKey:USER_DEFAULTS_CACHED_DEVICE_TOKEN_ACCESS_TOKEN_KEY];
}

- (void) setCachedDeviceTokenAccessToken:(NSString *)cachedDeviceTokenAccessToken
{
    [self _setNSString:cachedDeviceTokenAccessToken forKey:USER_DEFAULTS_CACHED_DEVICE_TOKEN_ACCESS_TOKEN_KEY];
}


- (void) setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    WPLogDebug(@"Setting access token: %@", accessToken);
    [self _setNSString:accessToken forKey:USER_DEFAULTS_ACCESS_TOKEN_KEY];
}

- (void) setStoredClientId:(NSString *)clientId
{
    if (clientId) {
        [self _setNSString:clientId forKey:USER_DEFAULTS_CLIENT_ID_KEY];
    }
}

- (NSString *) getStoredClientId
{
    return [self _getNSStringForKey:USER_DEFAULTS_CLIENT_ID_KEY];
}

- (NSString *) getAccessTokenForUserId:(NSString *)userId
{
    if (((userId == nil || [userId isEqualToString:@""]) && self.userId == nil)
        || (userId != nil && [userId isEqualToString:self.userId])) {
        return self.accessToken;
    } else {
        NSDictionary *usersArchive = [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_PER_USER_ARCHIVE_KEY] ?: @{};
        NSDictionary *userArchive = usersArchive[userId ?: @""] ?: @{};
        return [self _JSONToNSString:userArchive[USER_DEFAULTS_ACCESS_TOKEN_KEY]];
    }
}


#pragma mark - DEVICE ID

- (NSString *) deviceId
{
    return [self _getNSStringForKey:USER_DEFAULTS_DEVICE_ID_KEY];
}

- (void) setDeviceId:(NSString *)deviceId
{
    [self _setNSString:deviceId forKey:USER_DEFAULTS_DEVICE_ID_KEY];
}


#pragma mark - INSTALLATION ID

- (NSString *) installationId
{
    if (_installationId)
        return _installationId;

    _installationId = [self _getNSStringForKey:USER_DEFAULTS_INSTALLATION_ID];
    return _installationId;
}

- (void) setInstallationId:(NSString *)installationId
{
    _installationId = installationId;
    WPLogDebug(@"Setting installationId: %@", installationId);
    [self _setNSString:installationId forKey:USER_DEFAULTS_INSTALLATION_ID];
}


#pragma mark - USER ID

- (NSString *) userId
{
    if (_userId)
        return _userId;

    _userId = [self _getNSStringForKey:USER_DEFAULTS_USER_ID_KEY];
    return _userId;
}

- (void) setUserId:(NSString *)userId
{
    if ([@"" isEqualToString:userId]) {
        userId = nil;
    }
    _userId = userId;

    WPLogDebug(@"Setting userId: %@", userId);
    [self _setNSString:userId forKey:USER_DEFAULTS_USER_ID_KEY];
}


#pragma mark - SID

- (NSString *)sid
{
    if (_sid)
        return _sid;

    _sid = [self _getNSStringForKey:USER_DEFAULTS_SID_KEY];
    return _sid;
}

- (void) setSid:(NSString *)sid
{
    _sid = sid;
    WPLogDebug(@"Setting sid: %@", sid);
    [self _setNSString:sid forKey:USER_DEFAULTS_SID_KEY];
}

- (BOOL) usesSandbox
{
    return [[self.baseURL absoluteString] rangeOfString:PRODUCTION_API_URL].location == NSNotFound;
}


#pragma mark - NOTIFICATION ENABLED

- (BOOL) notificationEnabled
{
    if (!__notificationEnabled) {
        __notificationEnabled = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_NOTIFICATION_ENABLED_KEY];
        if (__notificationEnabled == nil) {
            return YES;
        }
    }

    return [__notificationEnabled boolValue];
}

- (void) setNotificationEnabled:(BOOL)notificationEnabled
{
    __notificationEnabled = [NSNumber numberWithBool:notificationEnabled];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:__notificationEnabled forKey:USER_DEFAULTS_NOTIFICATION_ENABLED_KEY];
    [defaults synchronize];
}

- (BOOL) cachedOsNotificationEnabled
{
    NSNumber *value = [self _getNSNumberForKey:USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_KEY];
    if (value == nil) return YES; // although it's not opt-in by default on iOS, that's how the related installation field works
    return [value boolValue];
}

- (void) setCachedOsNotificationEnabled:(BOOL)cachedOsNotificationEnabled
{
    [self _setNSNumber:[NSNumber numberWithBool:cachedOsNotificationEnabled] forKey:USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_KEY];
}

- (NSDate *) cachedOsNotificationEnabledDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_DATE_KEY];
}

- (void) setCachedOsNotificationEnabledDate:(NSDate *)cachedOsNotificationEnabledDate
{
    [self _setNSDate:cachedOsNotificationEnabledDate forKey:USER_DEFAULTS_CACHED_OS_NOTIFICATION_ENABLED_DATE_KEY];
}


#pragma mark - OVERRIDE SET LOGGING

- (NSNumber *) overrideSetLogging
{
    return [self _getNSNumberForKey:USER_DEFAULTS_OVERRIDE_SET_LOGGING_KEY];
}

- (void) setOverrideSetLogging:(NSNumber *)overrideSetLogging
{
    [self _setNSNumber:overrideSetLogging forKey:USER_DEFAULTS_OVERRIDE_SET_LOGGING_KEY];
}


#pragma mark - OVERRIDE NOTIFICATION RECEIPT

- (NSNumber *) overrideNotificationReceipt
{
    return [self _getNSNumberForKey:USER_DEFAULTS_OVERRIDE_NOTIFICATION_RECEIPT_KEY];
}

- (void) setOverrideNotificationReceipt:(NSNumber *)overrideNotificationReceipt
{
    [self _setNSNumber:overrideNotificationReceipt forKey:USER_DEFAULTS_OVERRIDE_NOTIFICATION_RECEIPT_KEY];
}


#pragma mark - QUEUED NOTIFICATIONS

- (void) addToQueuedNotifications:(NSDictionary *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *queuedNotifications = [self getQueuedNotifications];
    [queuedNotifications addObject:notification];
    NSError *error = NULL;
    NSData *queuedNotificationsData = [NSJSONSerialization dataWithJSONObject:queuedNotifications options:0 error:&error];
    if (error) {
        WPLogDebug(@"Error while serializing queued notifications: %@", error);
        return;
    }
    NSString *queuedNotificationsJson = [[NSString alloc] initWithData:queuedNotificationsData encoding:NSUTF8StringEncoding];

    [defaults setObject:queuedNotificationsJson forKey:USER_DEFAULTS_QUEUED_NOTIFICATIONS];
    [defaults synchronize];
}

- (NSMutableArray *) getQueuedNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *queuedNotificationsJson = [defaults stringForKey:USER_DEFAULTS_QUEUED_NOTIFICATIONS];
    if (queuedNotificationsJson != nil) {
        NSData *queuedNotificationsData = [queuedNotificationsJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = NULL;
        id queuedNotifications = [NSJSONSerialization JSONObjectWithData:queuedNotificationsData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            WPLogDebug(@"Error while reading queued notifications: %@", error);
        }
        if (queuedNotifications) {
            return queuedNotifications;
        }
    }
    return [NSMutableArray new];
}

- (void) clearQueuedNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USER_DEFAULTS_QUEUED_NOTIFICATIONS];
    [defaults synchronize];
}


#pragma mark - CACHED INSTALLATION CORE PROPERTIES

- (NSDictionary *) cachedInstallationCoreProperties
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES];
}

- (void) setCachedInstallationCoreProperties:(NSDictionary *)cachedInstallationCoreProperties
{
    [self _setNSDictionaryAsJSON:cachedInstallationCoreProperties forKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES];
}

- (NSDate *) cachedInstallationCorePropertiesDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_DATE];
}

- (void) setCachedInstallationCorePropertiesDate:(NSDate *)cachedInstallationCorePropertiesDate
{
    [self _setNSDate:cachedInstallationCorePropertiesDate forKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_DATE];
}

- (NSString *) cachedInstallationCorePropertiesAccessToken
{
    return [self _getNSStringForKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_ACCESS_TOKEN];
}

- (void) setCachedInstallationCorePropertiesAccessToken:(NSString *)cachedInstallationCorePropertiesAccessToken
{
    [self _setNSString:cachedInstallationCorePropertiesAccessToken forKey:USER_DEFAULTS_CACHED_INSTALLATION_CORE_PROPERTIES_ACCESS_TOKEN];
}


#pragma mark - CACHED INSTALLATION CUSTOM PROPERTIES

- (NSDictionary *) cachedInstallationCustomPropertiesWritten
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN];
}

- (void) setCachedInstallationCustomPropertiesWritten:(NSDictionary *)cachedInstallationCustomPropertiesWritten
{
    [self _setNSDictionaryAsJSON:cachedInstallationCustomPropertiesWritten forKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN];
}

- (NSDate *) cachedInstallationCustomPropertiesWrittenDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN_DATE];
}

- (void) setCachedInstallationCustomPropertiesWrittenDate:(NSDate *)cachedInstallationCustomPropertiesWrittenDate
{
    [self _setNSDate:cachedInstallationCustomPropertiesWrittenDate forKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_WRITTEN_DATE];
}

- (NSDictionary *) cachedInstallationCustomPropertiesUpdated
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED];
}

- (void) setCachedInstallationCustomPropertiesUpdated:(NSDictionary *)cachedInstallationCustomPropertiesUpdated
{
    [self _setNSDictionaryAsJSON:cachedInstallationCustomPropertiesUpdated forKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED];
}

- (NSDate *) cachedInstallationCustomPropertiesUpdatedDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED_DATE];
}

- (void) setCachedInstallationCustomPropertiesUpdatedDate:(NSDate *)cachedInstallationCustomPropertiesUpdatedDate
{
    [self _setNSDate:cachedInstallationCustomPropertiesUpdatedDate forKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_UPDATED_DATE];
}

- (NSDate *) cachedInstallationCustomPropertiesFirstDelayedWriteDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_FIRST_DELAYED_WRITE_DATE];
}

- (void) setCachedInstallationCustomPropertiesFirstDelayedWriteDate:(NSDate *)cachedInstallationCustomPropertiesFirstDelayedWriteDate
{
    [self _setNSDate:cachedInstallationCustomPropertiesFirstDelayedWriteDate forKey:USER_DEFAULTS_CACHED_INSTALLATION_CUSTOM_PROPERTIES_FIRST_DELAYED_WRITE_DATE];
}

- (NSDate *) lastReceivedNotificationDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_LAST_RECEIVED_NOTIFICATION_DATE];
}

- (void) setLastReceivedNotificationDate:(NSDate *)lastReceivedNotificationDate
{
    [self _setNSDate:lastReceivedNotificationDate forKey:USER_DEFAULTS_LAST_RECEIVED_NOTIFICATION_DATE];
}

- (NSDictionary *) lastReceivedNotification
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_LAST_RECEIVED_NOTIFICATION];
}

- (void) setLastReceivedNotification:(NSDictionary *)lastReceivedNotification
{
    [self _setNSDictionaryAsJSON:lastReceivedNotification forKey:USER_DEFAULTS_LAST_RECEIVED_NOTIFICATION];
}

- (NSDate *) lastOpenedNotificationDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_LAST_OPENED_NOTIFICATION_DATE];
}

- (void) setLastOpenedNotificationDate:(NSDate *)lastOpenedNotificationDate
{
    [self _setNSDate:lastOpenedNotificationDate forKey:USER_DEFAULTS_LAST_OPENED_NOTIFICATION_DATE];
}

- (NSDictionary *) lastOpenedNotification
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_LAST_OPENED_NOTIFICATION];
}

- (void) setLastOpenedNotification:(NSDictionary *)lastOpenedNotification
{
    [self _setNSDictionaryAsJSON:lastOpenedNotification forKey:USER_DEFAULTS_LAST_OPENED_NOTIFICATION];
}

- (NSDate *) lastInteractionDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_LAST_INTERACTION_DATE];
}

- (void) setLastInteractionDate:(NSDate *)lastInteractionDate
{
    [self _setNSDate:lastInteractionDate forKey:USER_DEFAULTS_LAST_INTERACTION_DATE];
}

- (NSDictionary *) lastAppOpenInfo
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_LAST_APP_OPEN_INFO];
}

- (void) setLastAppOpenInfo:(NSDictionary *)lastAppOpenInfo
{
    [self _setNSDictionaryAsJSON:lastAppOpenInfo forKey:USER_DEFAULTS_LAST_APP_OPEN_INFO];
}

- (NSDate *) lastAppOpenDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_LAST_APP_OPEN_DATE];
}

- (void) setLastAppOpenDate:(NSDate *)lastAppOpenDate
{
    [self _setNSDate:lastAppOpenDate forKey:USER_DEFAULTS_LAST_APP_OPEN_DATE];
}

- (NSDate *) lastAppCloseDate
{
    return [self _getNSDateForKey:USER_DEFAULTS_LAST_APP_CLOSE_DATE];
}

- (void) setLastAppCloseDate:(NSDate *)lastAppCloseDate
{
    [self _setNSDate:lastAppCloseDate forKey:USER_DEFAULTS_LAST_APP_CLOSE_DATE];
}

- (NSString *) country
{
    return [self _getNSStringForKey:USER_DEFAULTS_COUNTRY];
}

- (void) setCountry:(NSString *)country
{
    [self _setNSString:country forKey:USER_DEFAULTS_COUNTRY];
}

- (NSString *) currency
{
    return [self _getNSStringForKey:USER_DEFAULTS_CURRENCY];
}

- (void) setCurrency:(NSString *)currency
{
    [self _setNSString:currency forKey:USER_DEFAULTS_CURRENCY];
}

- (NSString *) locale
{
    return [self _getNSStringForKey:USER_DEFAULTS_LOCALE];
}

- (void) setLocale:(NSString *)locale
{
    [self _setNSString:locale forKey:USER_DEFAULTS_LOCALE];
}

- (NSString *) timeZone
{
    return [self _getNSStringForKey:USER_DEFAULTS_TIME_ZONE];
}

- (void) setTimeZone:(NSString *)timeZone
{
    [self _setNSString:timeZone forKey:USER_DEFAULTS_TIME_ZONE];
}

- (NSDictionary *) installationCustomSyncStatePerUserId
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_INSTALLATION_CUSTOM_SYNC_STATE_PER_USER_ID_KEY];
}

- (void) setInstallationCustomSyncStatePerUserId:(NSDictionary *)installationCustomSyncStatePerUserId
{
    [self _setNSDictionaryAsJSON:installationCustomSyncStatePerUserId forKey:USER_DEFAULTS_INSTALLATION_CUSTOM_SYNC_STATE_PER_USER_ID_KEY];
}

- (NSDictionary *) installationCoreSyncStatePerUserId
{
    return [self _getNSDictionaryFromJSONForKey:USER_DEFAULTS_INSTALLATION_CORE_SYNC_STATE_PER_USER_ID_KEY];
}

- (void) setInstallationCoreSyncStatePerUserId:(NSDictionary *)installationCoreSyncStatePerUserId
{
    [self _setNSDictionaryAsJSON:installationCoreSyncStatePerUserId forKey:USER_DEFAULTS_INSTALLATION_CORE_SYNC_STATE_PER_USER_ID_KEY];
}

- (void) clearStorageKeepUserConsent:(BOOL)keepUserConsent keepDeviceId:(BOOL)keepDeviceId
{
    NSArray *prefixes = @[@"_wonderpush", @"__wonderpush"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[defaults dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL hasPrefix = NO;
        for (NSString *prefix in prefixes) {
            hasPrefix = [key hasPrefix:prefix];
            if (hasPrefix) break;
        }
        if (!hasPrefix) return;
        
        if (keepUserConsent && [key isEqualToString:USER_DEFAULTS_USER_CONSENT_KEY]) return;
        if (keepDeviceId && [key isEqualToString:USER_DEFAULTS_DEVICE_ID_KEY]) return;
        [defaults removeObjectForKey:key];
    }];
    [defaults synchronize];
    
    _accessToken = nil;
    _deviceToken = nil;
    _sid = nil;
    _userId = nil;
    _installationId = nil;
    __notificationEnabled = nil;
    _timeOffset = 0;
    _timeOffsetPrecision = 0;
    _justOpenedNotification = nil;
}



@end
