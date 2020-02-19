#import <Foundation/Foundation.h>

/**
 Button of type link (opens the browser)
 */
#define WP_ACTION_LINK @"link"

/**
 Button of type map (opens the map application)
 */
#define WP_ACTION_MAP_OPEN @"mapOpen"

/**
 Button of type method (launch a notification using NSNotification)
 */
#define WP_ACTION_METHOD_CALL @"method"

/**
 Button of type rating (opens the itunes app on the current application)
 */
#define WP_ACTION_RATING @"rating"

/**
 Button of type track event (track a event on button click)
 */
#define WP_ACTION_TRACK @"trackEvent"

/**
 Button of type update installation (update installation custom data on button click)
 */
#define WP_ACTION_UPDATE_INSTALLATION @"updateInstallation"

/**
 Button of type add property
 */
#define WP_ACTION_ADD_PROPERTY @"addProperty"

/**
 Button of type remove property
 */
#define WP_ACTION_REMOVE_PROPERTY @"removeProperty"

/**
 Resynchronize installation
 */
#define WP_ACTION_RESYNC_INSTALLATION @"resyncInstallation"

/**
 Button of type add tag
 */
#define WP_ACTION_ADD_TAG @"addTag"

/**
 Button of type remove tag
 */
#define WP_ACTION_REMOVE_TAG @"removeTag"

/**
 Button of type remove all tags
 */
#define WP_ACTION_REMOVE_ALL_TAGS @"removeAllTags"

/**
 Button of type close notifications
 */
#define WP_ACTION_CLOSE_NOTIFICATIONS @"closeNotifications"

/**
 Dump installation state as an event
 */
#define WP_ACTION__DUMP_STATE @"_dumpState"

/**
 Override [WonderPush setLogging:]
 */
#define WP_ACTION__OVERRIDE_SET_LOGGING @"_overrideSetLogging"

/**
 Override notification receipt
 */
#define WP_ACTION__OVERRIDE_NOTIFICATION_RECEIPT @"_overrideNotificationReceipt"

