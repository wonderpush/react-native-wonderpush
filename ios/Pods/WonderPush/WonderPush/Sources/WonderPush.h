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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

FOUNDATION_EXPORT double WonderPushVersionNumber;
FOUNDATION_EXPORT const unsigned char WonderPushVersionString[];


/**
 Name of the notification that is sent using `NSNotificationCenter` when the SDK is initialized.
 */
#define WP_NOTIFICATION_INITIALIZED @"_wonderpushInitialized"

/**
 Name of the notification that is sent using `NSNotificationCenter` when the user consent changes.
 */
#define WP_NOTIFICATION_HAS_USER_CONSENT_CHANGED @"_wonderpushHasUserConsentChanged"
/**
 Name of the userInfo key that holds a NSNumber whose boolValue is the user consent.
 */
#define WP_NOTIFICATION_HAS_USER_CONSENT_CHANGED_KEY @"hasUserConsent"

/**
 Name of the notification that is sent using `NSNotificationCenter` when a user logs in.
 */
#define WP_NOTIFICATION_USER_LOGED_IN @"_wonderpushUserLoggedIn"

/**
 Key of the SID parameter for `WP_NOTIFICATION_USER_LOGED_IN` notification.
 */
#define WP_NOTIFICATION_USER_LOGED_IN_SID_KEY @"_wonderpushSID"

/**
 Key of the Access Token parameter for `WP_NOTIFICATION_USER_LOGED_IN` notification.
 */
#define WP_NOTIFICATION_USER_LOGED_IN_ACCESS_TOKEN_KEY @"_wonderpushAccessToken"

/**
 Name of the notification that is sent using `NSNotificationCenter` when the a button of type `method` is called.
 */
#define WP_NOTIFICATION_REGISTERED_CALLBACK @"_wonderpushRegisteredCallback"

/**
 Key of the method used when a button of type `method` is called.
 */
#define WP_REGISTERED_CALLBACK_METHOD_KEY @"_wonderpushCallbackMethod"

/**
 Key of the parameter used when a button of type `method` is called.
 */
#define WP_REGISTERED_CALLBACK_PARAMETER_KEY @"_wonderpushCallbackParameter"

/**
 Name of the notification that is sent using `NSNotificationCenter` when a push notification is received.
 */
#define WP_NOTIFICATION_RECEIVED @"_wonderpushNotificationReceived"

/**
 Name of the notification that is sent using `NSNotificationCenter` when a push notification with a "delegate to application code" deep link.
 */
#define WP_NOTIFICATION_OPENED_BROADCAST @"_wonderpushNotificationOpenedBroadcast"

/**
 Name of the notification that is sent using `NSNotificationCenter` when a push notification is being opened.
 */
#define WP_NOTIFICATION_OPENED @"_wonderpushNotificationOpened"

/**
 The `WonderPushDelegate` protocol lets you customize various aspects of the WonderPush behavior at runtime.
 */
@protocol WonderPushDelegate <NSObject>

/**
 Lets you overwrite URLs that WonderPush will open using `UIApplication:openURL:`.
 @param URL The URL that WonderPush is about to open.
 @return A URL to open, or nil to avoid opening anything. Just return the value of the URL parameter to use the default WonderPush behavior.
 @deprecated If `wonderPushWillOpenURL:withCompletionHandler:` is implemented, it will be called instead of this one.
 */
@optional
- ( NSURL * ) wonderPushWillOpenURL:( NSURL * )URL __deprecated_msg("Implement wonderPushWillOpenURL:withCompletionHandler: instead");

/**
 Lets you overwrite URLs that WonderPush will open using `UIApplication:openURL:`.
 This version let's you do some asynchronous processing before returning.
 @param url The URL that WonderPush is about to open.
 @param completionHandler The callback to call with the new URL to open.
 @return A URL to open, or nil to avoid opening anything. Just return the value of the URL parameter to use the default WonderPush behavior.
 */
@optional
- (void) wonderPushWillOpenURL:( NSURL * )url withCompletionHandler:(void (^)(NSURL *url))completionHandler;

@end

/**
 `WonderPush` is your main interface to the WonderPush SDK.

 Make sure you properly installed the WonderPush SDK, as described in [the guide](../index.html).

 You must call `<setClientId:secret:>` before using any other method.

 You must also either call `<setupDelegateForApplication:>`, preferably in the `application:willFinishLaunchingWithOptions:` method of your `AppDelegate` just after calling the previously mentioned method, or override every method listed under [Manual AppDelegate forwarding](#task_Manual AppDelegate forwarding).

 You must also either call `<setupDelegateForUserNotificationCenter>`, preferably along with `<setupDelegateForApplication:>` in the `application:willFinishLaunchingWithOptions:` method of your `AppDelegate`, or override every method listed under [Manual UserNotificationCenter delegate forwarding](#task_Manual UserNotificationCenter delegate forwarding).

 Troubleshooting tip: As the SDK should not interfere with your application other than when a notification is to be shown, make sure to monitor your logs for WonderPush output during development, if things did not went as smoothly as they should have.
 */
@interface WonderPush : NSObject

///---------------------
/// @name Initialization
///---------------------

/**
 Sets whether user consent is required before the SDK is allowed to work.
 Call this method before `setClientId:secret:`
 @param requiresUserConsent Whether user consent is required before the SDK is allowed to work.
 @see setUserConsent:
 */
+ (void) setRequiresUserConsent:(BOOL)requiresUserConsent;

/**
 Provides or withdraws user consent.
 Call this method after `setClientId:secret:`.
 @param userConsent Whether the user provided or withdrew consent.
 @see setRequiresUserConsent:
 */
+ (void) setUserConsent:(BOOL)userConsent;

/**
 Returns whether user has already provided consent.
 Call this method after `setClientId:secret:`.
 */
+ (BOOL) getUserConsent;

/**
 Returns YES whenever user has already provided consent or consent is not necessary.
 Call this method after `setClientId:secret:`.
 */
+ (BOOL) hasUserConsent;

/**
 Initializes the WonderPush SDK.

 Initialization should occur at the earliest possible time, when your application starts.
 A good place is the `application:didFinishLaunchingWithOptions:` method of your `AppDelegate`.

 Please refer to the step entitled *Initialize the SDK* from [the guide](../index.html).

 @param clientId Your WonderPush client id
 @param secret Your WonderPush client secret
 */
+ (void) setClientId:(NSString *)clientId secret:(NSString *)secret;

/**
 Sets the user id, used to identify a single identity across multiple devices, and to correctly identify multiple users on a single device.

 If not called, the last used user id it assumed. Defaulting to `nil` if none is known.

 Prefer calling this method just before calling `<setClientId:secret:>`, rather than just after.
 Upon changing userId, the access token is wiped, so avoid unnecessary calls, like calling with null just before calling with a user id.

 @param userId The user id, unique to your application. Use `nil` for anonymous users.
     You are strongly encouraged to use your own unique internal identifier.
 */
+ (void) setUserId:(NSString *)userId;

/**
 Sets the delegate for the WonderPushSDK. Setting the delegate lets you control various behaviors of the WonderPushSDK at runtime.
 It is advised to set the delegate as early as possible, preferably in application:didFinishLaunchingWithOptions
 @param delegate The delegate.
 */
+ (void) setDelegate:(__weak id<WonderPushDelegate>) delegate;

/**
 Returns whether the WonderPush SDK has been given the clientId and clientSecret.
 Will be `YES` as soon as `[WonderPush setClientId:secret:]` is called.
 No network can be performed before the SDK is initialized.
 Further use of the SDK methods will be dropped until initialized. Such call will be ignored and logged in the device console.
 @return The initialization state as a BOOL
 */
+ (BOOL) isInitialized;

/**
 Returns whether the WonderPush SDK is ready to operate.
 Returns YES when the WP_NOTIFICATION_INITIALIZED is sent.
 @return The initialization state as a BOOL
 */
+ (BOOL) isReady;

/**
 Controls SDK logging.

 @param enable Whether to enable logs.
 */
+ (void) setLogging:(BOOL)enable;


///-----------------------
/// @name Core information
///-----------------------

/**
 Returns the userId currently in use, `nil` by default.
 */
+ (NSString *) userId;

/**
 Returns the installationId identifying your application on a device, bond to a specific userId.
 If you want to store this information on your servers, keep the corresponding userId with it.
 Will return `nil` until the SDK is properly initialized.
 */
+ (NSString *) installationId;

/**
 Returns the unique device identifier.
 */
+ (NSString *) deviceId;

/**
 Returns the push token, or device token in Apple lingo.
 Returns `nil` if the user is not opt-in.
 */
+ (NSString *) pushToken;

/**
 Returns the currently used access token.
 Returns `nil` until the SDK is properly initialized.
 This together with your client secret gives entire control to the current installation and associated user,
 you should not disclose it unnecessarily.
 */
+ (NSString *) accessToken;

/**
 Sets the framework, library or wrapper used for integration.

 This method should not be used by the developer directly,
 only by components that facilitates the native SDK integration.
 @param integrator Expected format is `"some-component-1.2.3"`
 */
+ (void) setIntegrator:(NSString *)integrator;

/**
 Enables the collection of the user's geolocation.
 */
+ (void) enableGeolocation;

/**
 Disables the collection of the user's geolocation.
 */
+ (void) disableGeolocation;

/**
 Overrides the user's geolocation.

 Using this method you can have the user's location be set to wherever you want.
 This may be useful to use a pre-recorded location.

 @param location The location to use as the user's current geolocation.
                 Using `nil` has the same effect as calling `disableGeolocation()`.
 */
+ (void) setGeolocation:(CLLocation *)location;

/**
 Gets the user's country, either as previously stored, or as guessed from the system.

 @return The user's country.
 @see [WonderPush setCountry:]
 */
+ (NSString *) country;

/**
 Overrides the user's country.

 You should use an ISO 3166-1 alpha-2 country code.

 Defaults to getting the country code from the system default locale.

 @param country The country to use as the user's country.
                Use `nil` to disable the override.
 */
+ (void) setCountry:(NSString *)country;

/**
 Gets the user's currency, either as previously stored, or as guessed from the system.

 @return The user's currency.
 @see [WonderPush setCurrency:]
 */
+ (NSString *) currency;

/**
 Overrides the user's currency.

 You should use an ISO 4217 currency code.

 Defaults to getting the currency code from the system default locale.

 @param currency The currency to use as the user's currency.
                 Use `nil` to disable the override.
 */
+ (void) setCurrency:(NSString *)currency;

/**
 Gets the user's locale, either as previously stored, or as guessed from the system.

 @return The user's locale.
 @see [WonderPush setLocale:]
 */
+ (NSString *) locale;

/**
 Overrides the user's locale.

 You should use an `xx-XX` form of RFC 1766, composed of a lowercase ISO 639-1 language code,
 an underscore or a dash, and an uppercase ISO 3166-1 alpha-2 country code.

 Defaults to getting the locale code from the system default locale.

 @param locale The locale to use as the user's locale.
               Use `nil` to disable the override.
 */
+ (void) setLocale:(NSString *)locale;

/**
 Gets the user's time zone, either as previously stored, or as guessed from the system.

 @return The user's time zone.
 @see [WonderPush setTimeZone:]
 */
+ (NSString *) timeZone;

/**
 Overrides the user's timeZone.

 You should use an IANA time zone database codes, `Continent/Country` style preferably,
 abbreviations like `CET`, `PST`, `UTC`, which have the drawback of changing on daylight saving transitions.

 Defaults to getting the time zone code from the system default locale.

 @param timeZone The time zone to use as the user's time zone.
                 Use `nil` to disable the override.
 */
+ (void) setTimeZone:(NSString *)timeZone;

///---------------------------------
/// @name Push Notification handling
///---------------------------------

/**
 Subscribes to push notifications. Triggers the system permission prompt.
 */
+ (void) subscribeToNotifications;

/**
 Unsubscribes from push notifications. Does not affect the push notification permission.
 */
+ (void) unsubscribeFromNotifications;

/**
 Returns a boolean indicating whether the user is subscribed to push notifications.
 */
+ (BOOL) isSubscribedToNotifications;

/**
 Returns whether the notifications are enabled.

 Defaults to NO as notifications are opt-in on iOS.

 @deprecated Use `isSubscribedToNotifications()` instead
 @see [WonderPush isSubscribedToNotifications]
 */
+ (BOOL) getNotificationEnabled __deprecated_msg("Use isSubscribedToNotifications() instead");

/**
 Activates or deactivates the push notification on the device (if the user accepts) and registers the device token with WondePush.

 You **must** call the following method at least once to make the user pushable.

 - You can call this method multiple times. The user is only prompted for permission by iOS once.
 - Calling with `YES` opts the user in, whether he was not opt-in or soft opt-out (by calling with `NO`).
 - There is no need to call this method if the permission has already been granted, but it does not harm either.
   Prior to WonderPush iOS SDK v1.2.1.0, you should call it if the user was already opt-in in a non WonderPush-enabled version of your application.
 - If the permission has been denied, calling this method cannot opt the user back in as iOS leaves the user in control, through the system settings.

 Because you only have *one* chance for prompting the user, you should find a good timing for that.
 For a start, you can systematically call it when the application starts, so that the user will be prompted directly at the first launch.

 @param enabled The new activation state of push notifications.
 @deprecated Use `subscribeToNotifications()` or `unsubscribeFromNotifications()` instead.
 @see [WonderPush subscribeToNotifications]
 @see [WonderPush unsubscribeFromNotifications]
 */
+ (void) setNotificationEnabled:(BOOL)enabled __deprecated_msg("Use subscribeToNotifications() or unsubscribeFromNotifications() instead");

/**
 Returns whether the given notification is to be consumed by the WonderPush SDK.

 @param userInfo The notification dictionary as read from some UIApplicationDelegate method parameters.
 */
+ (BOOL) isNotificationForWonderPush:(NSDictionary *)userInfo;

/**
 Returns whether the notification is a `data` notification sent by WonderPush.

 Data notifications are aimed at providing your application with some data your should consume accordingly.

 @param userInfo The notification dictionary as read from some UIApplicationDelegate method parameters.
 */
+ (BOOL) isDataNotification:(NSDictionary *)userInfo;


///-----------------------------------
/// @name Installation data and events
///-----------------------------------

/**
 Updates the properties attached to the current installation object stored by WonderPush.

 In order to remove a value, don't forget to use `[NSNull null]` as value.

 @param properties The partial object containing only the custom properties to update.

 The keys should be prefixed according to the type of their values.
 You can find the details in the [Property names](https://docs.wonderpush.com/docs/properties#section-property-names) section of the documentation.
 */
+ (void) putProperties:(NSDictionary *)properties;

/**
 Returns the latest known properties attached to the current installation object stored by WonderPush.
 */
+ (NSDictionary *) getProperties;

/**
 Sets the value to a given property attached to the current installation object stored by WonderPush.

 The previous value is replaced entirely.
 The value can be an `NSString`, `NSNumber`, `NSDictionary`, `NSArray`, or `NSNull` (which has the same effect as `<unsetProperty:>`).

 @param field The name of the property to set
 @param value The value to be set, can be an NSArray
 */
+ (void) setProperty:(NSString *)field value:(id)value;

/**
 Removes the value of a given property attached to the current installation object stored by WonderPush.

 The previous value is replaced with `NSNull`.

 @param field The name of the property to set
 */
+ (void) unsetProperty:(NSString *)field;

/**
 Adds the value to a given property attached to the current installation object stored by WonderPush.

 The stored value is made an array if not already one.
 If the given value is an `NSArray`, all its values are added.
 If a value is already present in the stored value, it won't be added.

 @param field The name of the property to add values to
 @param value The value(s) to be added, can be an NSArray
 */
+ (void) addProperty:(NSString *)field value:(id)value;

/**
 Removes the value from a given property attached to the current installation object stored by WonderPush.

 The stored value is made an array if not already one.
 If the given value is an `NSArray`, all its values are removed.
 If a value is present multiple times in the stored value, they will all be removed.

 @param field The name of the property to remove values from
 @param value The value(s) to be removed, can be an NSArray
 */
+ (void) removeProperty:(NSString *)field value:(id)value;

/**
 Returns the value of a given property attached to the current installation object stored by WonderPush.

 If the property stores an array, only the first value is returned.
 This way you don't have to deal with potential arrays if that property is not supposed to hold one.
 Returns `NSNull` instead of `nil` if the property is absent or has an empty array value.

 @param field The name of the property to remove values from
 @return `NSNull` or a single value stored in the property, never an `NSArray` or `nil`
 */
+ (id) getPropertyValue:(NSString *)field;

/**
 Returns an array of the values of a given property attached to the current installation object stored by WonderPush.

 If the property does not store an array, an array is returned nevertheless.
 This way you don't have to deal with potential scalar values if that property is supposed to hold an array.
 Returns an empty array instead of `nil` or `NSNull` if the property is absent or is `NSNull`.
 Returns an array wrapping any scalar value held by the property.

 @param field The name of the property to remove values from
 @return A possibly empty `NSArray` of the values stored in the property, but never `NSNull` or `nil`
 */
+ (NSArray *) getPropertyValues:(NSString *)field;

/**
 Returns the latest known custom properties attached to the current installation object stored by WonderPush.
 @deprecated Use `getProperties()` instead.
 @see [WonderPush getProperties]
 */
+ (NSDictionary *) getInstallationCustomProperties __deprecated_msg("Use getProperties() instead");

/**
 Updates the custom properties attached to the current installation object stored by WonderPush.

 In order to remove a value, don't forget to use `[NSNull null]` as value.

 @param customProperties The partial object containing only the custom properties to update.

 The keys should be prefixed according to the type of their values.
 You can find the details in the [Segmentation > Properties](https://docs.wonderpush.com/docs/properties) section of the documentation.

 @deprecated Use `putProperties()` instead.
 @see [WonderPush putProperties:]
 */
+ (void) putInstallationCustomProperties:(NSDictionary *)customProperties __deprecated_msg("Use putProperties() instead");

/**
 Send an event to be tracked to WonderPush.

 @param type The event type, or name. Event types starting with an `@` character are reserved.
 */
+ (void) trackEvent:(NSString*)type;

/**
 Send an event to be tracked to WonderPush.

 @param eventType The event type, or name. Event types starting with an `@` character are reserved.
 @param attributes A dictionary containing attributes to be attached to the event.

 The keys should be prefixed according to the type of their values.
 You can find the details in the [Property names](https://docs.wonderpush.com/docs/properties#section-property-names) section of the documentation.
 */
+ (void) trackEvent:(NSString *)eventType attributes:(NSDictionary *)attributes;

/**
 Send an event to be tracked to WonderPush.

 @param type The event type, or name. Event types starting with an `@` character are reserved.
 @param data A dictionary containing custom properties to be attached to the event.
 Prefer using a few custom properties over a plethora of event type variants.

 The keys should be prefixed according to the type of their values.
 You can find the details in the [Segmentation > Properties](https://docs.wonderpush.com/docs/properties) section of the documentation.
 @deprecated Use `trackEvent(_:attributes:)` instead.
 @see [WonderPush trackEvent:attributes:]
 */
+ (void) trackEvent:(NSString*)type withData:(NSDictionary *)data __deprecated_msg("Use trackEvent(_:attributes:) instead");

/**
 * Add a tag to the current installation object stored by WonderPush.
 *
 * @param tag The tag to add to the installation.
 */
+ (void) addTag:(NSString *)tag;

/**
 * Add one or more tags to the current installation object stored by WonderPush.
 *
 * @param tags The tags to add to the installation.
 */
+ (void) addTags:(NSArray<NSString *> *)tags;

/**
 * Remove a tag from the current installation object stored by WonderPush.
 *
 * @param tag The tag to remove from the installation.
 */
+ (void) removeTag:(NSString *)tag;

/**
 * Remove one or more tags from the current installation object stored by WonderPush.
 *
 * @param tags The tags to remove from the installation.
 */
+ (void) removeTags:(NSArray<NSString *> *)tags;

/**
 * Remove all tags from the current installation object stored by WonderPush.
 */
+ (void) removeAllTags;

/**
 * Remove all tags from the current installation object stored by WonderPush.
 *
 * @return A copy of the set of tags attached to the installation. Never returns `nil`.
 */
+ (NSOrderedSet<NSString *> *) getTags;

/**
 * Test whether the current installation has the given tag attached to it.
 *
 * @param tag The tag to test.
 * @return `YES` if the given tag is attached to the installation, `NO` otherwise.
 */
+ (bool) hasTag:(NSString *)tag;

///----------------------------------
/// @name Privacy and data management
///----------------------------------

/**
 Instructs to delete any event associated with the all installations present on the device, locally and on WonderPush servers.
 */
+ (void) clearEventsHistory;

/**
 Instructs to delete any custom data (including installation properties) associated with the all installations present on the device, locally and on WonderPush servers.
 */
+ (void) clearPreferences;

/**
 Instructs to delete any event, installation and potential user objects associated with all installations present on the device, locally and on WonderPush servers.
 */
+ (void) clearAllData;

/**
 Initiates the download of all the WonderPush data relative to the current installation, in JSON format.
 @param completion Completion block called upon success or error
 */
+ (void) downloadAllData:(void(^)(NSData *data, NSError *error))completion;


///---------------------------------------
/// @name Automatic AppDelegate forwarding
///---------------------------------------

/**
 Setup UIApplicationDelegate override, so that calls from your UIApplicationDelegate are automatically transmitted to the WonderPush SDK.

 This eases your setup, you can call this from your
 `- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions` method.

 Do not forget to also setup the UserNotificationCenter delegate with `[WonderPush setupDelegateForUserNotificationCenter]`.

 @param application The application parameter from your AppDelegate.
 */
+ (void) setupDelegateForApplication:(UIApplication *)application;


///------------------------------------
/// @name Manual AppDelegate forwarding
///------------------------------------

/**
 Forwards an application delegate to the SDK.

 Method to call in your `application:didFinishLaunchingWithOptions:` method of your `AppDelegate`.

 @param application Same parameter as in the forwarded delegate method.
 @param launchOptions Same parameter as in the forwarded delegate method.
 */
+ (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 Forwards an application delegate to the SDK.

 Method to call in your `application:didReceiveRemoteNotification:` method of your `AppDelegate`.

 @param application Same parameter as in the forwarded delegate method.
 @param userInfo Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 Forwards an application delegate to the SDK.

 Method to call in your `application:didRegisterForRemoteNotificationsWithDeviceToken:` method of your `AppDelegate`.

 @param application Same parameter as in the forwarded delegate method.
 @param deviceToken Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 Forwards an application delegate to the SDK.

 Method to call in your `application:didFailToRegisterForRemoteNotificationsWithError:` method of your `AppDelegate`.

 Any previous device token will be forgotten.

 @param application Same parameter as in the forwarded delegate method.
 @param error Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 Forwards an application delegate to the SDK.

 If your application uses backgroundModes/remote-notification, call this method in your
 `application:didReceiveLocalNotification:` method of your `AppDelegate`.
 Handles a notification and presents the associated dialog.

 @param application Same parameter as in the forwarded delegate method.
 @param notification Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
#pragma clang diagnostic pop

/**
 Forwards an application delegate to the SDK.

 If your application uses backgroundModes/remote-notification, call this method in your
 `application:didReceiveRemoteNotification:fetchCompletionHandler:` method.

 If you implement this application delegate function, you must call `completionHandler` at some point.
 If you do not know what to do, you're probably good with calling it right away.

 @param application Same parameter as in the forwarded delegate method.
 @param userInfo Same parameter as in the forwarded delegate method.
 @param completionHandler Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 Forwards an application delegate to the SDK.

 Method to call in your `applicationDidBecomeActive:` method of your `AppDelegate`.

 @param application Same parameter as in the forwarded delegate method.
 */
+ (void) applicationDidBecomeActive:(UIApplication *)application;

/**
 Forwards an application delegate to the SDK.

 Method to call in your `applicationDidEnterBackground:` method of your `AppDelegate`.

 @param application Same parameter as in the forwarded delegate method.
 */
+ (void) applicationDidEnterBackground:(UIApplication *)application;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 Forwards an application delegate to the SDK.

 @param application Same parameter as in the forwarded delegate method.
 @param notificationSettings Same parameter as in the forwarded delegate method.
 */
+ (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
#pragma clang diagnostic pop


///-----------------------------------------------------------
/// @name Automatic UserNotificationCenter delegate forwarding
///-----------------------------------------------------------

/**
 Setup UNUserNotificationCenterDelegate override, so that calls from the UNUserNotificationCenter are automatically transmitted to the WonderPush SDK.

 You must call this from either `application:willFinishLaunchingWithOptions:` or `application:didFinishLaunchingWithOptions:` of your AppDelegate.
 Simply call it along with `[WonderPush setupDelegateForApplication:]`.
 */
+ (void) setupDelegateForUserNotificationCenter __IOS_AVAILABLE(10.0);


///--------------------------------------------------------
/// @name Manual UserNotificationCenter delegate forwarding
///--------------------------------------------------------

/**
 You must instruct the WonderPush SDK whether you have manually forwarded the UserNotificationCenter delegate.
 The SDK would otherwise not be able to properly handle notifications in some cases.

 @param enabled Use `YES` if you have manually forwarded the UserNotificationCenter delegate methods to the WonderPush SDK.
 */
+ (void) setUserNotificationCenterDelegateInstalled:(BOOL)enabled;

/**
 Forwards a UserNotificationCenter delegate to the SDK.

 Method to call in your `userNotificationCenter:willPresentNotification:withCompletionHandler:` method of your `NotificationCenterDelegate`.

 @param center Same parameter as in the forwarded delegate method.
 @param notification Same parameter as in the forwarded delegate method.
 @param completionHandler Same parameter as in the forwarded delegate method.
 */
+ (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0);

/**
 Forwards a UserNotificationCenter delegate to the SDK.

 Method to call in your `userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:` method of your `NotificationCenterDelegate`.

 @param center Same parameter as in the forwarded delegate method.
 @param response Same parameter as in the forwarded delegate method.
 @param completionHandler Same parameter as in the forwarded delegate method.
 */
+ (void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0);

@end
