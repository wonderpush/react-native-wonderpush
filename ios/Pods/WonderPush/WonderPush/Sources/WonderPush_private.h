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

#ifndef WonderPush_WonderPush_private_h
#define WonderPush_WonderPush_private_h

#import "WonderPush.h"
#import "WPResponse.h"


#define SDK_VERSION @"iOS-3.2.0"
#define PRODUCTION_API_DOMAIN @"api.wonderpush.com"
#define PRODUCTION_API_URL @"https://" PRODUCTION_API_DOMAIN @"/v1/"

#define RETRY_INTERVAL 10.0f
#define CACHED_INSTALLATION_CUSTOM_PROPERTIES_MIN_DELAY 5
#define CACHED_INSTALLATION_CUSTOM_PROPERTIES_MAX_DELAY 20
#define CACHED_INSTALLATION_CORE_PROPERTIES_MIN_DELAY 5
#define CACHED_INSTALLATION_CORE_PROPERTIES_MAX_DELAY 20

#define ITUNES_APP_URL_FORMAT @"https://itunes.apple.com/us/app/calcfast/id%@?mt=8"
#define WEB_CALLBACK_RESOURCE @"web/callback"

#define DIFFERENT_SESSION_REGULAR_MIN_TIME_GAP      (30*60*1000)
#define DIFFERENT_SESSION_NOTIFICATION_MIN_TIME_GAP (15*60*1000)

/**
 Key to set in your .plist file to allow rating button action
 */
#define WP_ITUNES_APP_ID @"itunesAppID"


/**
 Key of the WonderPush content in a push notification
 */
#define WP_PUSH_NOTIFICATION_KEY @"_wp"

/**
 Key of the notification type in the WonderPush content of a push notification
 */
#define WP_PUSH_NOTIFICATION_TYPE_KEY @"type"

/**
 Key of the deep link url to open with the notification
 */
#define WP_TARGET_URL_KEY @"targetUrl"
#define WP_TARGET_URL_SDK_PREFIX @"wonderpush://"
#define WP_TARGET_URL_DEFAULT @"wonderpush://notificationOpen/default"
#define WP_TARGET_URL_BROADCAST @"wonderpush://notificationOpen/broadcast"

/**
 Notification of type url
 */
#define WP_PUSH_NOTIFICATION_SHOW_URL @"url"

/**
 Notification of type text
 */
#define WP_PUSH_NOTIFICATION_SHOW_TEXT @"text"

/**
 Notification of type html
 */
#define WP_PUSH_NOTIFICATION_SHOW_HTML @"html"

/**
 Notification of type data
 */
#define WP_PUSH_NOTIFICATION_DATA @"data"


/**
 Default notification button label
 */
#define WP_DEFAULT_BUTTON_LOCALIZED_LABEL [WPUtil wpLocalizedString:@"CLOSE" withDefault:@"Close"]


@interface WonderPush (private)

+ (void) executeAction:(NSDictionary *)action onNotification:(NSDictionary *)notification;

+ (void) updateInstallationCoreProperties;

+ (void) refreshPreferencesAndConfiguration;

+ (void) sendPreferences;

+ (void) setIsReady:(BOOL)isReady;

+ (void) setIsReachable:(BOOL)isReachable;

+ (NSString *) languageCode;

+ (void) setLanguageCode:(NSString *)languageCode;

+ (NSString *) getIntegrator;

+ (NSBundle *) resourceBundle;
/**
 Method returning the rechability state of WonderPush on this phone
 @return the recheability state as a BOOL
 */
+ (BOOL) isReachable;


///---------------------
/// @name Installation data and events
///---------------------

/**
Called when receiving the full state of the installation
 */
+ (void)receivedFullInstallationFromServer:(NSDictionary *)installation updateDate:(NSDate *)installationUpdateDate;

/**
 Tracks an internal event, starting with a @ sign.
 @param data A collection of properties to add directly to the event body.
 @param customData A collection of custom properties to add to the `custom` field of the event.
 */
+ (void) trackInternalEvent:(NSString *)type eventData:(NSDictionary *)data customData:(NSDictionary *)customData;

/**
 Whether the user has already been prompted for permission by the OS.
 This asks the OS itself, so it can detect a situation for an application updating from pre-WonderPush push-enabled version.
 */
+ (void) hasAcceptedVisibleNotificationsWithCompletionHandler:(void(^)(BOOL result))handler;

/**
 Makes sure we have an up-to-date device token, and send it to WonderPush servers if necessary.
 */
+ (void) refreshDeviceTokenIfPossible;
/**
 Opens the given URL
 */
+ (void) openURL:(NSURL *)url;

///---------------------
/// @name REST API
///---------------------

/**
 Perform an authenticated request to the WonderPush API for a specified userId
 @param userId The userId the request should be bound to
 @param method The HTTP method to use
 @param resource The relative resource path, ommiting the first "/"
 @param params a key value dictionary with the parameters for the request
 @param handler the completion callback (optional)
 */
+ (void) requestForUser:(NSString *)userId method:(NSString *)method resource:(NSString *)resource params:(id)params handler:(void(^)(WPResponse *response, NSError *error))handler;

/**
 Perform an authenticated GET request to the WonderPush API
 @param resource The relative resource path, ommiting the first "/"
 @param params a key value dictionary with the parameters for the request
 @param handler the completion callback (optional)
 */
+ (void) get:(NSString *)resource params:(id)params handler:(void(^)(WPResponse *response, NSError *error))handler;

/**
 Perform an authenticated POST request to the WonderPush API
 @param resource The relative resource path, ommiting the first "/"
 @param params A dictionary with parameter names and corresponding values that will constitute the POST request's body.
 @param handler the completion callback (optional)
 */
+ (void) post:(NSString *)resource params:(id)params handler:(void(^)(WPResponse *response, NSError *error))handler;

/**
 Perform an authenticated DELETE request to the WonderPush API
 @param resource The relative resource path, ommiting the first "/"
 @param params a key value dictionary with the parameters for the request
 @param handler the completion callback (optional)
 */
+ (void) delete:(NSString *)resource params:(id)params handler:(void(^)(WPResponse *response, NSError *error))handler;

/**
 Perform an authenticated PUT request to the WonderPush API
 @param resource The relative resource path, ommiting the first "/"
 @param params a key value dictionary with the parameters for the request
 @param handler the completion callback (optional)
 */
+ (void) put:(NSString *)resource params:(id)params handler:(void(^)(WPResponse *response, NSError *error))handler;

/**
 Perform a POST request to the API, retrying later (even after application restarts) in the case of a network error.
 @param resource The relative resource path, ommiting the first "/"
 Example: `scores/best`
 @param params A dictionary with parameter names and corresponding values that will constitute the POST request's body.
 */
+ (void) postEventually:(NSString *)resource params:(id)params;

/**
 The last known location
 @return the last known location
 */
+ (CLLocation *) location;

+ (void) safeDeferWithConsent:(void(^)(void))block;

@end


#endif
