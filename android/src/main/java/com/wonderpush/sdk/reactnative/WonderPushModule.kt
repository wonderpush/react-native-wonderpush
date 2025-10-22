package com.wonderpush.sdk.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.wonderpush.sdk.reactnative.NativeWonderPushSpec
import com.wonderpush.sdk.WonderPush
import com.wonderpush.sdk.WonderPushDelegate
import com.wonderpush.sdk.DeepLinkEvent
import org.json.JSONArray
import org.json.JSONObject

@ReactModule(name = WonderPushModule.NAME)
class WonderPushModule(reactContext: ReactApplicationContext) :
  NativeWonderPushSpec(reactContext), WonderPushDelegate {

  private val queuedReceivedNotifications = mutableListOf<JSONObject>()
  private val queuedOpenedNotifications = mutableListOf<Pair<JSONObject, Int>>()
  private var isJsReady = false
  private val urlCallbacks = java.util.concurrent.ConcurrentHashMap<String, java.util.concurrent.CompletableFuture<String?>>()
  private val urlCallbacksLock = Any()

  // Required for NativeEventEmitter compatibility
  @ReactMethod
  override fun addListener(eventName: String) {
    // Keep: Required for RN built in Event Emitter Calls.
  }

  @ReactMethod
  override fun removeListeners(count: Double) {
    // Keep: Required for RN built in Event Emitter Calls.
  }

  init {
    // Set this module as the sub-delegate to work with the main Delegate
    Delegate.setSubDelegate(this)
  }

  override fun getName(): String {
    return NAME
  }

  // Initialization
  override fun setLogging(enable: Boolean, promise: Promise) {
    WonderPush.setLogging(enable)
    promise.resolve(null)
  }

  override fun initialize(clientId: String, clientSecret: String, promise: Promise) {
    WonderPush.initialize(reactApplicationContext, clientId, clientSecret)
    promise.resolve(null)
  }

  override fun initializeAndRememberCredentials(clientId: String, clientSecret: String, promise: Promise) {
    WonderPush.initializeAndRememberCredentials(reactApplicationContext, clientId, clientSecret)
    promise.resolve(null)
  }

  override fun getRememberedClientId(promise: Promise) {
    val clientId = WonderPush.getRememberedClientId(reactApplicationContext)
    promise.resolve(clientId)
  }

  override fun isInitialized(promise: Promise) {
    val initialized = WonderPush.isInitialized()
    promise.resolve(initialized)
  }

  // Subscribing users
  override fun subscribeToNotifications(fallbackToSettings: Boolean, promise: Promise) {
    WonderPush.subscribeToNotifications(fallbackToSettings)
    promise.resolve(null)
  }

  override fun unsubscribeFromNotifications(promise: Promise) {
    WonderPush.unsubscribeFromNotifications()
    promise.resolve(null)
  }

  override fun isSubscribedToNotifications(promise: Promise) {
    val subscribed = WonderPush.isSubscribedToNotifications()
    promise.resolve(subscribed)
  }

  // Segmentation
  override fun trackEvent(type: String, attributes: ReadableMap, promise: Promise) {
    val jsonAttributes = convertReadableMapToJson(attributes)
    WonderPush.trackEvent(type, jsonAttributes)
    promise.resolve(null)
  }

  // Tags
  override fun addTag(tags: ReadableArray, promise: Promise) {
    val tagArray = convertReadableArrayToStringArray(tags)
    WonderPush.addTag(*tagArray)
    promise.resolve(null)
  }

  override fun removeTag(tags: ReadableArray, promise: Promise) {
    val tagArray = convertReadableArrayToStringArray(tags)
    WonderPush.removeTag(*tagArray)
    promise.resolve(null)
  }

  override fun removeAllTags(promise: Promise) {
    WonderPush.removeAllTags()
    promise.resolve(null)
  }

  override fun hasTag(tag: String, promise: Promise) {
    val hasTag = WonderPush.hasTag(tag)
    promise.resolve(hasTag)
  }

  override fun getTags(promise: Promise) {
    val tags = WonderPush.getTags()
    val writableArray = Arguments.createArray()
    tags.forEach { tag -> writableArray.pushString(tag) }
    promise.resolve(writableArray)
  }

  // Properties
  override fun getPropertyValue(property: String, promise: Promise) {
    val value = WonderPush.getPropertyValue(property)
    promise.resolve(value)
  }

  override fun getPropertyValues(property: String, promise: Promise) {
    val values = WonderPush.getPropertyValues(property)
    val writableArray = Arguments.createArray()
    values?.forEach { value -> writableArray.pushString(value?.toString()) }
    promise.resolve(writableArray)
  }

  override fun addProperty(str: String, property: ReadableArray, promise: Promise) {
    val propertyArray = convertReadableArrayToObjectArray(property)
    for (value in propertyArray) {
      WonderPush.addProperty(str, value)
    }
    promise.resolve(null)
  }

  override fun removeProperty(str: String, property: ReadableArray, promise: Promise) {
    val propertyArray = convertReadableArrayToObjectArray(property)
    for (value in propertyArray) {
      WonderPush.removeProperty(str, value)
    }
    promise.resolve(null)
  }

  override fun setProperty(str: String, property: ReadableArray, promise: Promise) {
    val propertyArray = convertReadableArrayToObjectArray(property)
    WonderPush.setProperty(str, propertyArray)
    promise.resolve(null)
  }

  override fun unsetProperty(property: String, promise: Promise) {
    WonderPush.unsetProperty(property)
    promise.resolve(null)
  }

  override fun putProperties(properties: ReadableMap, promise: Promise) {
    val jsonProperties = convertReadableMapToJson(properties)
    WonderPush.putProperties(jsonProperties)
    promise.resolve(null)
  }

  override fun getProperties(promise: Promise) {
    val properties = WonderPush.getProperties()
    val writableMap = convertJsonToWritableMap(properties)
    promise.resolve(writableMap)
  }

  // Localization
  override fun getCountry(promise: Promise) {
    val country = WonderPush.getCountry()
    promise.resolve(country)
  }

  override fun setCountry(country: String?, promise: Promise) {
    WonderPush.setCountry(country)
    promise.resolve(null)
  }

  override fun getCurrency(promise: Promise) {
    val currency = WonderPush.getCurrency()
    promise.resolve(currency)
  }

  override fun setCurrency(currency: String?, promise: Promise) {
    WonderPush.setCurrency(currency)
    promise.resolve(null)
  }

  override fun getLocale(promise: Promise) {
    val locale = WonderPush.getLocale()
    promise.resolve(locale)
  }

  override fun setLocale(locale: String?, promise: Promise) {
    WonderPush.setLocale(locale)
    promise.resolve(null)
  }

  override fun getTimeZone(promise: Promise) {
    val timeZone = WonderPush.getTimeZone()
    promise.resolve(timeZone)
  }

  override fun setTimeZone(timeZone: String?, promise: Promise) {
    WonderPush.setTimeZone(timeZone)
    promise.resolve(null)
  }

  // User IDs
  override fun getUserId(promise: Promise) {
    val userId = WonderPush.getUserId()
    promise.resolve(userId)
  }

  override fun setUserId(userId: String, promise: Promise) {
    WonderPush.setUserId(userId)
    promise.resolve(null)
  }

  // Installation info
  override fun getDeviceId(promise: Promise) {
    val deviceId = WonderPush.getDeviceId()
    promise.resolve(deviceId)
  }

  override fun getInstallationId(promise: Promise) {
    val installationId = WonderPush.getInstallationId()
    promise.resolve(installationId)
  }

  override fun getPushToken(promise: Promise) {
    val pushToken = WonderPush.getPushToken()
    promise.resolve(pushToken)
  }

  override fun getAccessToken(promise: Promise) {
    val accessToken = WonderPush.getAccessToken()
    promise.resolve(accessToken)
  }

  // Privacy
  override fun setRequiresUserConsent(isConsent: Boolean, promise: Promise) {
    WonderPush.setRequiresUserConsent(isConsent)
    promise.resolve(null)
  }

  override fun getUserConsent(promise: Promise) {
    val consent = WonderPush.getUserConsent()
    promise.resolve(consent)
  }

  override fun setUserConsent(isConsent: Boolean, promise: Promise) {
    WonderPush.setUserConsent(isConsent)
    promise.resolve(null)
  }

  override fun disableGeolocation(promise: Promise) {
    WonderPush.disableGeolocation()
    promise.resolve(null)
  }

  override fun enableGeolocation(promise: Promise) {
    WonderPush.enableGeolocation()
    promise.resolve(null)
  }

  override fun setGeolocation(lat: Double, lon: Double, promise: Promise) {
    val location = android.location.Location("")
    location.latitude = lat
    location.longitude = lon
    WonderPush.setGeolocation(location)
    promise.resolve(null)
  }

  override fun clearEventsHistory(promise: Promise) {
    WonderPush.clearEventsHistory()
    promise.resolve(null)
  }

  override fun clearPreferences(promise: Promise) {
    WonderPush.clearPreferences()
    promise.resolve(null)
  }

  override fun clearAllData(promise: Promise) {
    WonderPush.clearAllData()
    promise.resolve(null)
  }

  override fun downloadAllData(promise: Promise) {
    Thread {
      try {
        WonderPush.downloadAllData()
        promise.resolve(null)
      } catch (error: Exception) {
        promise.reject("DOWNLOAD_ERROR", "Failed to download data: ${error.message}", error)
      }
    }.start()
  }

  // Event emission
  override fun flushDelegateEvents(promise: Promise) {
    synchronized(this) {
      isJsReady = true

      // Process any pending DeepLinkEvent first
      Delegate.processPendingDeepLinkEvent()

      // Flush internal queue first
      for (notification in queuedReceivedNotifications) {
        val notificationJson = notification.toString()
        emitEvent("onNotificationReceived", notificationJson)
      }
      queuedReceivedNotifications.clear()

      for ((notification, buttonIndex) in queuedOpenedNotifications) {
        val notificationJson = notification.toString()
        val eventData = Arguments.createMap().apply {
          putString("notification", notificationJson)
          putInt("buttonIndex", buttonIndex)
        }
        emitEvent("onNotificationOpened", eventData)
      }
      queuedOpenedNotifications.clear()

      // Also flush any saved notifications from the main Delegate (cold boot scenarios)
      var savedNotification = Delegate.consumeSavedReceivedNotification()
      while (savedNotification != null) {
        val notificationJson = savedNotification.toString()
        emitEvent("onNotificationReceived", notificationJson)
        savedNotification = Delegate.consumeSavedReceivedNotification()
      }

      var savedOpenedInfo = Delegate.consumeSavedOpenedNotification()
      while (savedOpenedInfo != null) {
        val notificationJson = savedOpenedInfo.notification.toString()
        val eventData = Arguments.createMap().apply {
          putString("notification", notificationJson)
          putInt("buttonIndex", savedOpenedInfo.buttonIndex)
        }
        emitEvent("onNotificationOpened", eventData)
        savedOpenedInfo = Delegate.consumeSavedOpenedNotification()
      }

      promise.resolve(null)
    }
  }

  // Deep linking
  override fun getInitialURL(promise: Promise) {
    // This method isn't implemented in Android, as Linking.getInitialURL works perfectly on that platform
    promise.resolve(null)
  }

  // Delegate callback for URL deep link handling
  @ReactMethod
  override fun urlForDeeplinkCallback(callbackId: String, url: String?) {
    android.util.Log.d("WonderPushModule", "urlForDeeplinkCallback called with: " + callbackId + " and url: " + url)
    android.util.Log.d("WonderPushModule", "urlForDeeplinkCallback entering synchronized section")
    synchronized(urlCallbacksLock) {
      val future = urlCallbacks.remove(callbackId)
    android.util.Log.d("WonderPushModule", "urlForDeeplinkCallback in synchronized section, future: " + future)
      future?.complete(url)
    }
  }

  // Helper methods
  private fun convertReadableMapToJson(readableMap: ReadableMap): JSONObject {
    val jsonObject = JSONObject()
    val iterator = readableMap.keySetIterator()
    while (iterator.hasNextKey()) {
      val key = iterator.nextKey()
      val value = when (readableMap.getType(key)) {
        com.facebook.react.bridge.ReadableType.Null -> null
        com.facebook.react.bridge.ReadableType.Boolean -> readableMap.getBoolean(key)
        com.facebook.react.bridge.ReadableType.Number -> readableMap.getDouble(key)
        com.facebook.react.bridge.ReadableType.String -> readableMap.getString(key)
        com.facebook.react.bridge.ReadableType.Map -> readableMap.getMap(key)?.let { convertReadableMapToJson(it) }
        com.facebook.react.bridge.ReadableType.Array -> readableMap.getArray(key)?.let { convertReadableArrayToJson(it) }
      }
      jsonObject.put(key, value)
    }
    return jsonObject
  }

  private fun convertReadableArrayToJson(readableArray: ReadableArray): JSONArray {
    val jsonArray = JSONArray()
    for (i in 0 until readableArray.size()) {
      val value = when (readableArray.getType(i)) {
        com.facebook.react.bridge.ReadableType.Null -> null
        com.facebook.react.bridge.ReadableType.Boolean -> readableArray.getBoolean(i)
        com.facebook.react.bridge.ReadableType.Number -> readableArray.getDouble(i)
        com.facebook.react.bridge.ReadableType.String -> readableArray.getString(i)
        com.facebook.react.bridge.ReadableType.Map -> readableArray.getMap(i)?.let { convertReadableMapToJson(it) }
        com.facebook.react.bridge.ReadableType.Array -> readableArray.getArray(i)?.let { convertReadableArrayToJson(it) }
      }
      jsonArray.put(value)
    }
    return jsonArray
  }

  private fun convertReadableArrayToStringArray(readableArray: ReadableArray): Array<String> {
    val stringArray = Array(readableArray.size()) { "" }
    for (i in 0 until readableArray.size()) {
      stringArray[i] = readableArray.getString(i) ?: ""
    }
    return stringArray
  }

  private fun convertReadableArrayToObjectArray(readableArray: ReadableArray): Array<Any?> {
    val objectArray = Array<Any?>(readableArray.size()) { null }
    for (i in 0 until readableArray.size()) {
      objectArray[i] = when (readableArray.getType(i)) {
        com.facebook.react.bridge.ReadableType.Null -> null
        com.facebook.react.bridge.ReadableType.Boolean -> readableArray.getBoolean(i)
        com.facebook.react.bridge.ReadableType.Number -> readableArray.getDouble(i)
        com.facebook.react.bridge.ReadableType.String -> readableArray.getString(i)
        else -> readableArray.getString(i)
      }
    }
    return objectArray
  }

  private fun convertJsonToWritableMap(jsonObject: JSONObject): WritableMap {
    val writableMap = Arguments.createMap()
    val iterator = jsonObject.keys()
    while (iterator.hasNext()) {
      val key = iterator.next()
      val value = jsonObject.get(key)
      when (value) {
        is JSONObject -> writableMap.putMap(key, convertJsonToWritableMap(value))
        is JSONArray -> writableMap.putArray(key, convertJsonToWritableArray(value))
        is String -> writableMap.putString(key, value)
        is Int -> writableMap.putInt(key, value)
        is Double -> writableMap.putDouble(key, value)
        is Boolean -> writableMap.putBoolean(key, value)
        else -> writableMap.putNull(key)
      }
    }
    return writableMap
  }

  private fun convertJsonToWritableArray(jsonArray: JSONArray): WritableArray {
    val writableArray = Arguments.createArray()
    for (i in 0 until jsonArray.length()) {
      val value = jsonArray.get(i)
      when (value) {
        is JSONObject -> writableArray.pushMap(convertJsonToWritableMap(value))
        is JSONArray -> writableArray.pushArray(convertJsonToWritableArray(value))
        is String -> writableArray.pushString(value)
        is Int -> writableArray.pushInt(value)
        is Double -> writableArray.pushDouble(value)
        is Boolean -> writableArray.pushBoolean(value)
        else -> writableArray.pushNull()
      }
    }
    return writableArray
  }

  // WonderPushDelegate implementation
  override fun urlForDeepLink(event: DeepLinkEvent): String? {
    android.util.Log.d("WonderPushModule", "urlForDeepLink:" + event)
    val originalUrl = event.url

    // Generate a unique callback ID
    val callbackId = java.util.UUID.randomUUID().toString()
    val future = java.util.concurrent.CompletableFuture<String?>()

    synchronized(urlCallbacksLock) {
      urlCallbacks[callbackId] = future
    }

    android.util.Log.d("WonderPushModule", "will run on UI thread to send event")
    // Send event to JavaScript on UI thread
    UiThreadUtil.runOnUiThread {
      try {
        val eventData = Arguments.createMap().apply {
          putString("url", originalUrl)
          putString("callbackId", callbackId)
        }
    android.util.Log.d("WonderPushModule", "on UI thread: sending event")
        emitEvent("urlForDeeplink", eventData)
      } catch (e: Exception) {
        android.util.Log.e(NAME, "Error emitting urlForDeeplink event", e)
        // Clean up and return original URL
        synchronized(urlCallbacksLock) {
          urlCallbacks.remove(callbackId)
        }
        future.complete(originalUrl)
      }
    }

    // Wait for the callback with a timeout
    return try {
    android.util.Log.d("WonderPushModule", "waiting 3s for the callback future to be resolved")
      val result = future.get(3, java.util.concurrent.TimeUnit.SECONDS)
    android.util.Log.d("WonderPushModule", "future resolved to " + result)
      result
    } catch (e: java.util.concurrent.TimeoutException) {
      android.util.Log.w(NAME, "urlForDeeplink callback timed out, using original URL")
      synchronized(urlCallbacksLock) {
        urlCallbacks.remove(callbackId)
      }
      originalUrl
    } catch (e: Exception) {
      android.util.Log.e(NAME, "Error waiting for urlForDeeplink callback", e)
      synchronized(urlCallbacksLock) {
        urlCallbacks.remove(callbackId)
      }
      originalUrl
    }
  }

  override fun onNotificationReceived(notif: JSONObject) {
    UiThreadUtil.runOnUiThread {
      try {
        synchronized(this) {
          if (isJsReady) {
            val notificationJson = notif.toString()
            emitEvent("onNotificationReceived", notificationJson)
          } else {
            queuedReceivedNotifications.add(notif)
          }
        }
      } catch (e: Exception) {
        android.util.Log.e(NAME, "Error handling notification received", e)
      }
    }
  }

  override fun onNotificationOpened(notif: JSONObject, buttonIndex: Int) {
    UiThreadUtil.runOnUiThread {
      try {
        synchronized(this) {
          if (isJsReady) {
            val notificationJson = notif.toString()
            val eventData = Arguments.createMap().apply {
              putString("notification", notificationJson)
              putInt("buttonIndex", buttonIndex)
            }
            emitEvent("onNotificationOpened", eventData)
          } else {
            queuedOpenedNotifications.add(Pair(notif, buttonIndex))
          }
        }
      } catch (e: Exception) {
        android.util.Log.e(NAME, "Error handling notification opened", e)
      }
    }
  }

  private fun emitEvent(eventName: String, data: Any) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, data)
  }

  companion object {
    const val NAME = "RNWonderPush"
  }
}
