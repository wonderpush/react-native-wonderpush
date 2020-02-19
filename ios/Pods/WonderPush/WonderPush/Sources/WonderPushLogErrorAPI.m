//
//  WonderPushLogErrorAPI.m
//  WonderPush
//
//  Created by Stéphane JAIS on 08/02/2019.
//  Copyright © 2019 WonderPush. All rights reserved.
//

#import "WonderPushLogErrorAPI.h"
#import "WPLog.h"
#import "WPUtil.h"

@implementation WonderPushLogErrorAPI
- (void) activate {}
- (void) deactivate {}
- (void) log:(NSString *)method
{
    WPLog(@"Cannot call WonderPush.%@", method);
}

- (NSString *)accessToken
{
    [self log:@"accessToken"];
    return nil;
}

- (NSString *)deviceId
{
    [self log:@"deviceId"];
    return nil;
}

- (void)executeAction:(NSDictionary *)action onNotification:(NSDictionary *)notification
{
    [self log:@"executeAction:onNotification:"];
}

- (NSDictionary *)getInstallationCustomProperties
{
    [self log:@"getInstallationCustomProperties"];
    return @{};
}

- (BOOL)getNotificationEnabled
{
    return NO;
}

- (NSString *)installationId
{
    [self log:@"installationId"];
    return nil;
}

- (CLLocation *)location
{
    [self log:@"location"];
    return nil;
}

- (NSString *)pushToken
{
    [self log:@"pushToken"];
    return nil;
}

- (void)putInstallationCustomProperties:(NSDictionary *)customProperties
{
    [self log:@"putInstallationCustomProperties:"];
}

- (void)refreshDeviceTokenIfPossible
{
    [self log:@"refreshDeviceTokenIfPossible"];
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    [self log:@"setDeviceToken:"];
}

- (void)setNotificationEnabled:(BOOL)enabled
{
    [self log:@"setNotificationEnabled:"];
}

- (void) sendPreferences
{
    [self log:@"sendPreferences"];
}

- (void)trackEvent:(NSString *)type
{
    [self log:@"trackEvent:"];
}

- (void)trackEvent:(NSString *)type withData:(NSDictionary *)data
{
    [self log:@"trackEvent:withData:"];
}

- (void)trackInternalEvent:(NSString *)type eventData:(NSDictionary *)data customData:(NSDictionary *)customData
{
    [self log:@"trackInternalEvent:eventData:customData:"];
}

- (void)updateInstallationCoreProperties
{
    [self log:@"updateInstallationCoreProperties"];
}

- (void)clearAllData {
    [self log:@"clearAllData"];
}


- (void)clearEventsHistory {
    [self log:@"clearEventsHistory"];
}


- (void)clearPreferences {
    [self log:@"clearPreferences"];
}


- (void)downloadAllData:(void (^)(NSData *, NSError *))completion {
    [self log:@"downloadAllData:"];
    completion(nil, [NSError errorWithDomain:WPErrorDomain code:WPErrorMissingUserConsent userInfo:nil]);
}


- (NSDictionary *)getProperties {
    [self log:@"getProperties"];
    return @{};
}


- (void) setProperty:(NSString *)field value:(id)value {
    [self log:@"setProperty"];
}


- (void) unsetProperty:(NSString *)field {
    [self log:@"unsetProperty"];
}


- (void) addProperty:(NSString *)field value:(id)value {
    [self log:@"addProperty"];
}


- (void) removeProperty:(NSString *)field value:(id)value {
    [self log:@"removeProperty"];
}


- (id) getPropertyValue:(NSString *)field {
    [self log:@"getPropertyValue"];
    return [NSNull null];
}


- (NSArray *) getPropertyValues:(NSString *)field {
    [self log:@"getPropertyValues"];
    return [NSArray new];
}


- (BOOL)isSubscribedToNotifications {
    return NO;
}


- (void)putProperties:(NSDictionary *)properties {
    [self log:@"putProperties:"];
}


- (void)subscribeToNotifications {
    [self log:@"subscribeToNotifications"];
}


- (void)trackEvent:(NSString *)eventType attributes:(NSDictionary *)attributes {
    [self log:@"trackEvent:attributes:"];
}


- (void)unsubscribeFromNotifications {
    [self log:@"unsubscribeFromNotifications"];
}

- (void) addTag:(NSString *)tag {
    [self log:@"addTag"];
}

- (void) addTags:(NSArray<NSString *> *)tags {
    [self log:@"addTags"];
}

- (void) removeTag:(NSString *)tag {
    [self log:@"removeTag"];
}

- (void) removeTags:(NSArray<NSString *> *)tags {
    [self log:@"removeTags"];
}

- (void) removeAllTags {
    [self log:@"removeAllTag"];
}

- (NSOrderedSet<NSString *> *) getTags {
    [self log:@"getTags"];
    return [NSOrderedSet new];
}

- (bool) hasTag:(NSString *)tag {
    [self log:@"hasTag"];
    return NO;
}

@end

@implementation WonderPushNotInitializedAPI
- (void) log:(NSString *)method
{
    WPLog(@"Cannot call WonderPush.%@ before initialization. Please call WonderPush.setClientId(:secret) first.", method);
}
@end

@implementation WonderPushNoConsentAPI
- (void) log:(NSString *)method
{
    WPLog(@"Cannot call WonderPush.%@ without user consent. Consider calling WonderPush.setUserConsent(true) after prompting the user.", method);
}
@end
