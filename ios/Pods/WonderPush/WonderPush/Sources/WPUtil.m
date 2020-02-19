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

#import "WPUtil.h"
#import "WPConfiguration.h"
#import "WPLog.h"
#import "WonderPush_private.h"
#import "WPMobileProvision.h"
#import <sys/utsname.h>
#import <UIKit/UIApplication.h>
#import <UserNotifications/UserNotifications.h>


NSString * const WPErrorDomain = @"WPErrorDomain";
NSInteger const WPErrorInvalidCredentials = 11000;
NSInteger const WPErrorInvalidAccessToken = 11003;
NSInteger const WPErrorMissingUserConsent = 11011;
NSInteger const WPErrorHTTPFailure = 11012;
NSCharacterSet *PercentEncodedAllowedCharacterSet = nil;
@implementation WPUtil
+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *allowed = [NSMutableCharacterSet new];
        // Allow anything that's valid in a query
        [allowed formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
        // Allow -._~
        [allowed formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"-._~"]];
        // Escape :/?#[]@!$&'()*+,;=
        [allowed formIntersectionWithCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@":/?#[]@!$&'()*+,;="] invertedSet]];
        PercentEncodedAllowedCharacterSet = allowed;
    });
}
+ (NSString*)base64forData:(NSData*)theData
{

    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
    if (!encodedString) {
        return nil;
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *pairs = [encodedString componentsSeparatedByString:@"&"];

    for (NSString *kvp in pairs) {
        if ([kvp length] == 0) {
            continue;
        }

        NSRange pos = [kvp rangeOfString:@"="];
        NSString *key;
        NSString *val;

        if (pos.location == NSNotFound) {
            key = [kvp stringByRemovingPercentEncoding];
            val = @"";
        } else {
            key = [[kvp substringToIndex:pos.location] stringByRemovingPercentEncoding];
            val = [[kvp substringFromIndex:pos.location + pos.length] stringByRemovingPercentEncoding];
        }

        if (!key || !val) {
            continue; // I'm sure this will bite my arse one day
        }

        [result setObject:val forKey:key];
    }
    return result;
}

+ (NSString *)percentEncodedString:(NSString *)string
{
    return [string stringByAddingPercentEncodingWithAllowedCharacters:PercentEncodedAllowedCharacterSet];
}


#pragma mark - Device

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)deviceIdentifier
{
    WPConfiguration *conf = [WPConfiguration sharedConfiguration];
    NSString *deviceId = conf.deviceId;
    if (deviceId == nil) {
        // Read from local OpenUDID storage to keep a smooth transition off using OpenUDID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id localDict = [defaults objectForKey:@"OpenUDID"];
        if ([localDict isKindOfClass:[NSDictionary class]]) {
            id optedOutDate = [localDict objectForKey:@"OpenUDID_optOutTS"];
            if (optedOutDate == nil) {
                deviceId = [localDict objectForKey:@"OpenUDID"];
            }
        }
        if (deviceId == nil) {
            // Generate an UUIDv4
            deviceId = [[NSUUID UUID] UUIDString];
        }
        // Store device id
        conf.deviceId = deviceId;
    }
    return deviceId;
}


#pragma mark - URL Checking

+ (NSDictionary *) paramsForWonderPushURL:(NSURL *)URL
{
    if (!URL.query)
        return @{};

    return [self dictionaryWithFormEncodedString:URL.query];

}


#pragma mark - ERROR

+ (NSError *)errorFromJSON:(id)json
{
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSArray *errorArray = [WPUtil arrayForKey:@"error" inDictionary:json];
        NSDictionary *errorDict = [WPUtil dictionaryForKey:@"error" inDictionary:json];
        if (errorDict) {
            errorArray = @[errorDict];
        }
        if (errorArray) {
            for (NSDictionary *detailedError in errorArray) {
                if (![detailedError isKindOfClass:[NSDictionary class]]) continue;
                return [[NSError alloc] initWithDomain:WPErrorDomain
                                                  code:[[WPUtil numberForKey:@"code" inDictionary:detailedError] integerValue]
                                              userInfo:@{NSLocalizedDescriptionKey : [WPUtil stringForKey:@"message" inDictionary:detailedError] ?: [NSNull null]}];
            }
        }
    }
    return nil;
}


#pragma mark - Application utils

+ (BOOL) currentApplicationIsInForeground
{
    return [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
}

static NSArray *backgroundModes = nil;
+ (NSArray *) getBackgroundModes
{
    if (!backgroundModes) {
        NSBundle *bundle = [NSBundle mainBundle];
        backgroundModes = [bundle objectForInfoDictionaryKey:@"UIBackgroundModes"];
    }
    return backgroundModes;
}

static NSNumber *hasBackgroundMode = nil;
+ (BOOL) hasBackgroundModeRemoteNotification
{
    if (hasBackgroundMode == nil) {
        hasBackgroundMode = [NSNumber numberWithBool:NO];
        NSArray *backgroundModes = [WPUtil getBackgroundModes];
        if (backgroundModes != nil) {
            for (NSString *value in backgroundModes) {
                if ([value isEqual:@"remote-notification"]) {
                    WPLogDebug(@"Has background mode remote-notification");
                    hasBackgroundMode = [NSNumber numberWithBool:YES];
                    break;
                }
            }
        }
    }
    return [hasBackgroundMode boolValue];
}

static NSDictionary *entitlements = nil;
+ (NSString *) getEntitlement:(NSString *)key
{
    if (!entitlements) {
        NSDictionary *dict = [WPMobileProvision getMobileProvision];
        entitlements = dict[@"Entitlements"];
    }
    return entitlements[key];
}

static NSNumber *hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler = nil;
+ (BOOL) hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler
{
    if (hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler == nil) {
        hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler =
        [NSNumber numberWithBool:[[UIApplication sharedApplication].delegate
                                  respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]];
        WPLogDebug(@"Has implemented [application:didReceiveRemoteNotification:fetchCompletionHandler:] = %@", hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler);
    }
    return [hasImplementedDidReceiveRemoteNotificationWithFetchCompletionHandler boolValue];
}

#pragma mark - SERVER TIME

+ (long long) getServerDate
{
    WPConfiguration *configuration = [WPConfiguration sharedConfiguration];

    if (configuration.timeOffset == 0) {
        // Not synced, use device time
        return (long long) ([[NSDate date] timeIntervalSince1970] * 1000);
    }
    return (long long) (([[NSProcessInfo processInfo] systemUptime] + configuration.timeOffset) * 1000);
}


# pragma mark - LOCALIZATION

+ (NSString *) localizedStringIfPossible:(NSString *)string
{
    return NSLocalizedStringWithDefaultValue(string, nil, [NSBundle mainBundle], string, nil);
}

+ (NSString *) wpLocalizedString:(NSString *)key withDefault:(NSString *)defaultValue
{
    return [[WonderPush resourceBundle] localizedStringForKey:key value:defaultValue table:@"WonderPushLocalizable"];
}

+ (void) askUserPermission
{
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error != nil) {
                WPLog(@"[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:] returned an error: %@", error.localizedDescription);
            }
            WPLogDebug(@"[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:] granted: %@", granted ? @"YES" : @"NO");
            [WonderPush refreshPreferencesAndConfiguration];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
#pragma clang diagnostic pop
        });
    }
}


+ (id) typesafeObjectForKey:(id)key expectClass:(Class)expectedClass inDictionary:(NSDictionary *)dictionary
{
    id value = dictionary[key];
    if ([value isKindOfClass:expectedClass]) {
        return value;
    }
    return nil;
}

+ (id) nullsafeObjectForKey:(id)key inDictionary:(NSDictionary *)dictionary
{
    id value = dictionary[key];
    if (value != [NSNull null]) {
        return value;
    }
    return nil;
}


+ (NSDictionary *) dictionaryForKey:(id)key inDictionary:(NSDictionary *)dictionary
{
    return [self typesafeObjectForKey:key expectClass:[NSDictionary class] inDictionary:dictionary];
}

+ (NSArray *) arrayForKey:(id)key inDictionary:(NSDictionary *)dictionary
{
    return [self typesafeObjectForKey:key expectClass:[NSArray class] inDictionary:dictionary];
}

+ (NSString *) stringForKey:(id)key inDictionary:(NSDictionary *)dictionary
{
    return [self typesafeObjectForKey:key expectClass:[NSString class] inDictionary:dictionary];
}

+ (NSNumber *) numberForKey:(id)key inDictionary:(NSDictionary *)dictionary
{
    return [self typesafeObjectForKey:key expectClass:[NSNumber class] inDictionary:dictionary];
}

+ (NSDictionary *)dictionaryByFilteringNulls:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (id key in [dictionary allKeys]) {
        id value = [dictionary valueForKey:key];
        if (value == [NSNull null]) continue;
        if ([value isKindOfClass:[NSDictionary class]]) {
            [result setValue:[self dictionaryByFilteringNulls:value] forKey:key];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [result setValue:[self arrayByFilteringNulls:value] forKey:key];
        } else {
            [result setValue:value forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:result];
}
+ (NSArray *)arrayByFilteringNulls:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray new];
    for (id value in array) {
        if (value == [NSNull null]) continue;
        if ([value isKindOfClass:[NSDictionary class]]) {
            [result addObject:[self dictionaryByFilteringNulls:value]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [result addObject:[self arrayByFilteringNulls:value]];
        } else {
            [result addObject:value];
        }
    }
    return [NSArray arrayWithArray:result];
}

+ (NSString *) hexForData:(NSData *)data
{
    char const * const alphabet = "0123456789abcdef";
    unsigned char const *readCursor = data.bytes;
    char *hexCString = malloc(sizeof(char) * (2 * data.length + 1));
    if (hexCString == NULL) {
        [NSException raise:@"NSInternalInconsistencyException" format:@"Failed to allocate more memory" arguments:nil];
        return nil;
    }
    char *writeCursor = hexCString;
    for (unsigned i = 0; i < data.length; ++i) {
        *(writeCursor++) = alphabet[((*readCursor & 0xF0) >> 4)];
        *(writeCursor++) = alphabet[(*readCursor & 0x0F)];
        readCursor++;
    }
    *writeCursor = '\0';
    NSString *hexString = [NSString stringWithUTF8String:hexCString];
    free(hexCString);
    return hexString;
}

@end
