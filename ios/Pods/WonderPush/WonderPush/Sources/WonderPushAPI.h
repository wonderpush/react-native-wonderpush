//
//  WonderPushAPI.h
//  Pods
//
//  Created by Stéphane JAIS on 07/02/2019.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol WonderPushAPI
// Public API
- (void) subscribeToNotifications;
- (void) unsubscribeFromNotifications;
- (BOOL) isSubscribedToNotifications;
- (void) trackEvent:(NSString*)eventType;
- (void) trackEvent:(NSString *)eventType attributes:(NSDictionary *)attributes;
- (void) putProperties:(NSDictionary *)properties;
- (NSDictionary *) getProperties;
- (void) setProperty:(NSString *)field value:(id)value;
- (void) unsetProperty:(NSString *)field;
- (void) addProperty:(NSString *)field value:(id)value;
- (void) removeProperty:(NSString *)field value:(id)value;
- (id) getPropertyValue:(NSString *)field;
- (NSArray *) getPropertyValues:(NSString *)field;
- (void) addTag:(NSString *)tag;
- (void) addTags:(NSArray<NSString *> *)tags;
- (void) removeTag:(NSString *)tag;
- (void) removeTags:(NSArray<NSString *> *)tags;
- (void) removeAllTags;
- (NSOrderedSet<NSString *> *) getTags;
- (bool) hasTag:(NSString *)tag;
- (void) clearEventsHistory;
- (void) clearPreferences;
- (void) clearAllData;
- (void) downloadAllData:(void(^)(NSData *data, NSError *error))completion;


// Old / private API
- (void) activate;
- (void) deactivate;
- (NSString *) installationId;
- (NSString *) deviceId;
- (NSString *) pushToken;
- (NSString *) accessToken;
- (BOOL) getNotificationEnabled;
- (void) setNotificationEnabled:(BOOL)enabled;
- (void) sendPreferences;
- (void) updateInstallationCoreProperties;
- (NSDictionary *) getInstallationCustomProperties;
- (void) putInstallationCustomProperties:(NSDictionary *)customProperties;
- (void) trackEvent:(NSString*)type withData:(NSDictionary *)data;
- (void) trackInternalEvent:(NSString *)type eventData:(NSDictionary *)data customData:(NSDictionary *)customData;
- (void) refreshDeviceTokenIfPossible;
- (void) executeAction:(NSDictionary *)action onNotification:(NSDictionary *)notification;
- (CLLocation *) location;
- (void) setDeviceToken:(NSString *)deviceToken;
@end
