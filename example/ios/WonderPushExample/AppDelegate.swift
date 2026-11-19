import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider
import WonderPush

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  // Kept static: WonderPush proxies the application delegate, so `UIApplication.shared.delegate as? AppDelegate` is unreliable.
  static var reactNativeDelegate: ReactNativeDelegate?
  static var reactNativeFactory: RCTReactNativeFactory?
  static weak var mainWindow: UIWindow?

  // React Native still reads `UIApplication.shared.delegate.window` (e.g. RCTDeviceInfo), so expose the scene's window.
  var window: UIWindow? {
    get { AppDelegate.mainWindow }
    set { AppDelegate.mainWindow = newValue }
  }

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

    AppDelegate.reactNativeDelegate = delegate
    AppDelegate.reactNativeFactory = factory

    return true
  }

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    configuration.delegateClass = SceneDelegate.self
    return configuration
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
          let factory = AppDelegate.reactNativeFactory else { return }

    let window = UIWindow(windowScene: windowScene)
    self.window = window
    AppDelegate.mainWindow = window

    factory.startReactNative(
      withModuleName: "WonderPushExample",
      in: window,
      launchOptions: nil
    )

    // Cold launch from a deep link or universal link
    if let urlContext = connectionOptions.urlContexts.first {
      RCTLinkingManager.application(UIApplication.shared, open: urlContext.url, options: [:])
    }
    if let userActivity = connectionOptions.userActivities.first {
      RCTLinkingManager.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
    }
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      RCTLinkingManager.application(UIApplication.shared, open: context.url, options: [:])
    }
  }

  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    RCTLinkingManager.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
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
