import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
import WonderPush

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  var reactNativeDelegate: ReactNativeDelegate?
  var reactNativeFactory: RCTReactNativeFactory?

  var pendingUserActivity: NSUserActivity?
  var pendingRestorationHandler: (([UIUserActivityRestoring]?) -> Void)?

  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    WonderPush.setLogging(true)
    WonderPush.setRequiresUserConsent(false)
    WonderPush.setClientId("USE_REMEMBERED", secret: "USE_REMEMBERED")
    WonderPush.setupDelegate(for: application)
    WonderPush.setupDelegateForUserNotificationCenter()
    return true
  }

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let delegate = ReactNativeDelegate()
    let factory = RCTReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    reactNativeFactory = factory

    window = UIWindow(frame: UIScreen.main.bounds)

    factory.startReactNative(
      withModuleName: "WonderPushExample",
      in: window,
      launchOptions: launchOptions
    )

    return true
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    NSLog("📱 [AppDelegate] application:open:options: called with URL: %@", url.absoluteString)
    let result = RCTLinkingManager.application(app, open: url, options: options)
    NSLog("📱 [AppDelegate] RCTLinkingManager returned: %@", result ? "true" : "false")

    // Always return true for wonderpush.example URLs to prevent opening in Safari
    if url.host == "wonderpush.example" {
      NSLog("📱 [AppDelegate] Returning true for wonderpush.example URL")
      return true
    }

    return result
  }

  func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    NSLog("📱 [AppDelegate] application:continueUserActivity: called")
    if let url = userActivity.webpageURL {
      NSLog("📱 [AppDelegate] URL: %@", url.absoluteString)

      // Store the activity to process it after React Native is ready
      pendingUserActivity = userActivity
      pendingRestorationHandler = restorationHandler

      // Try to process it with a delay to give React Native time to initialize
      processPendingUserActivity(application: application, attempt: 0)
    }

    // Return true immediately to handle the universal link
    NSLog("📱 [AppDelegate] Returning true for universal link")
    return true
  }

  private func processPendingUserActivity(application: UIApplication, attempt: Int) {
    guard let userActivity = pendingUserActivity,
          let restorationHandler = pendingRestorationHandler else {
      return
    }

    // Try up to 10 times with increasing delays (max 5 seconds total)
    let delay = Double(attempt) * 0.5
    guard attempt < 10 else {
      NSLog("📱 [AppDelegate] Gave up processing pending user activity")
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      NSLog("📱 [AppDelegate] Attempting to process pending user activity (attempt %d)", attempt + 1)
      let result = RCTLinkingManager.application(application, continue: userActivity, restorationHandler: restorationHandler)
      NSLog("📱 [AppDelegate] RCTLinkingManager returned: %@", result ? "true" : "false")

      // Clear the pending activity
      self?.pendingUserActivity = nil
      self?.pendingRestorationHandler = nil
    }
  }
}

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    self.bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
