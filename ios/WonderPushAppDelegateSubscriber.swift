import ExpoModulesCore
import WonderPush

public class WonderPushAppDelegateSubscriber: ExpoAppDelegateSubscriber {

    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // TODO Fetch CLIENT_ID and CLIENT_SECRET and initialize the WonderPush SDK

        // Avoid WonderPush.setupDelegateForApplication(application) and
        // manually forward the other methods, so that the class of
        // UIApplication.delegate is left untouched, as the WonderPush iOS SDK
        // does not use method swizzling at the moment.
        //WonderPush.setupDelegateForApplication(application)

        WonderPush.setupDelegateForUserNotificationCenter()

        return true
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WonderPush.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        WonderPush.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        WonderPush.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        WonderPush.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        WonderPush.applicationDidBecomeActive(application)
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        WonderPush.applicationDidEnterBackground(application)
    }

    public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        WonderPush.application(application, didRegister: notificationSettings)
    }

}
