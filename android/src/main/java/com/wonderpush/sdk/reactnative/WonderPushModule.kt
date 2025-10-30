package com.wonderpush.sdk.reactnative

import android.util.Log
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
import com.wonderpush.sdk.WonderPushUserPreferences
import com.wonderpush.sdk.WonderPushChannel
import com.wonderpush.sdk.WonderPushChannelGroup
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

  init {
    WonderPush.setIntegrator("react-native-wonderpush-3.0.0")
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
        val eventData = Arguments.createMap().apply {
          putMap("notification", convertJsonToWritableMap(notification))
        }
        emitOnNotificationReceived(eventData)
      }
      queuedReceivedNotifications.clear()

      for ((notification, buttonIndex) in queuedOpenedNotifications) {
        val eventData = Arguments.createMap().apply {
          putMap("notification", convertJsonToWritableMap(notification))
          putInt("buttonIndex", buttonIndex)
        }
        emitOnNotificationOpened(eventData)
      }
      queuedOpenedNotifications.clear()

      // Also flush any saved notifications from the main Delegate (cold boot scenarios)
      var savedNotification = Delegate.consumeSavedReceivedNotification()
      while (savedNotification != null) {
        val eventData = Arguments.createMap().apply {
          putMap("notification", convertJsonToWritableMap(savedNotification))
        }
        emitOnNotificationReceived(eventData)
        savedNotification = Delegate.consumeSavedReceivedNotification()
      }

      var savedOpenedInfo = Delegate.consumeSavedOpenedNotification()
      while (savedOpenedInfo != null) {
        val eventData = Arguments.createMap().apply {
          putMap("notification", convertJsonToWritableMap(savedOpenedInfo.notification))
          putInt("buttonIndex", savedOpenedInfo.buttonIndex)
        }
        emitOnNotificationOpened(eventData)
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
    synchronized(urlCallbacksLock) {
      val future = urlCallbacks.remove(callbackId)
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
    val originalUrl = event.url

    // Generate a unique callback ID
    val callbackId = java.util.UUID.randomUUID().toString()
    val future = java.util.concurrent.CompletableFuture<String?>()

    synchronized(urlCallbacksLock) {
      urlCallbacks[callbackId] = future
    }

    // Send event to JavaScript on UI thread
    UiThreadUtil.runOnUiThread {
      try {
        val eventData = Arguments.createMap().apply {
          putString("url", originalUrl)
          putString("callbackId", callbackId)
        }
        emitOnUrlForDeeplink(eventData)
      } catch (e: Exception) {
        Log.e(TAG, "urlForDeepLink(): Error emitting urlForDeeplink event", e)
        // Clean up and return original URL
        synchronized(urlCallbacksLock) {
          urlCallbacks.remove(callbackId)
        }
        future.complete(originalUrl)
      }
    }

    // Wait for the callback with a timeout
    return try {
      if (WonderPush.getLogging()) Log.d(TAG, "waiting 3s for the callback future to be resolved")
      val result = future.get(3, java.util.concurrent.TimeUnit.SECONDS)
      if (WonderPush.getLogging()) Log.d(TAG, "future resolved to " + result)
      result
    } catch (e: java.util.concurrent.TimeoutException) {
      Log.w(TAG, "urlForDeeplink callback timed out, using original URL")
      synchronized(urlCallbacksLock) {
        urlCallbacks.remove(callbackId)
      }
      originalUrl
    } catch (e: Exception) {
      Log.e(TAG, "Error waiting for urlForDeeplink callback", e)
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
            val eventData = Arguments.createMap().apply {
              putMap("notification", convertJsonToWritableMap(notif))
            }
            emitOnNotificationReceived(eventData)
          } else {
            queuedReceivedNotifications.add(notif)
          }
        }
      } catch (e: Exception) {
        Log.e(TAG, "Error handling notification received", e)
      }
    }
  }

  override fun onNotificationOpened(notif: JSONObject, buttonIndex: Int) {
    UiThreadUtil.runOnUiThread {
      try {
        synchronized(this) {
          if (isJsReady) {
            val eventData = Arguments.createMap().apply {
              putMap("notification", convertJsonToWritableMap(notif))
              putInt("buttonIndex", buttonIndex)
            }
            emitOnNotificationOpened(eventData)
          } else {
            queuedOpenedNotifications.add(Pair(notif, buttonIndex))
          }
        }
      } catch (e: Exception) {
        Log.e(TAG, "Error handling notification opened", e)
      }
    }
  }


  // Helper methods for WonderPush Channel/ChannelGroup conversion
  private fun channelGroupToWritableMap(group: WonderPushChannelGroup): WritableMap {
    val map = Arguments.createMap()
    map.putString("id", group.id)
    map.putString("name", group.name)
    return map
  }

  private fun writableMapToChannelGroup(map: ReadableMap): WonderPushChannelGroup? {
    val id = map.getString("id") ?: return null
    val group = WonderPushChannelGroup(id)
    if (map.hasKey("name")) {
      group.name = map.getString("name")
    }
    return group
  }

  private fun channelToWritableMap(channel: WonderPushChannel): WritableMap {
    val map = Arguments.createMap()
    map.putString("id", channel.id)
    if (channel.groupId != null) map.putString("groupId", channel.groupId)
    if (channel.name != null) map.putString("name", channel.name)
    if (channel.description != null) map.putString("description", channel.description)
    if (channel.bypassDnd != null) map.putBoolean("bypassDnd", channel.bypassDnd)
    if (channel.showBadge != null) map.putBoolean("showBadge", channel.showBadge)
    if (channel.importance != null) map.putInt("importance", channel.importance)
    if (channel.lights != null) map.putBoolean("lights", channel.lights)
    if (channel.lightColor != null) map.putInt("lightColor", channel.lightColor)
    if (channel.vibrate != null) map.putBoolean("vibrate", channel.vibrate)
    if (channel.vibrationPattern != null) {
      val pattern = Arguments.createArray()
      for (value in channel.vibrationPattern) {
        pattern.pushDouble(value.toDouble())
      }
      map.putArray("vibrationPattern", pattern)
    }
    if (channel.sound != null) map.putBoolean("sound", channel.sound)
    if (channel.soundUri != null) map.putString("soundUri", channel.soundUri.toString())
    if (channel.lockscreenVisibility != null) map.putInt("lockscreenVisibility", channel.lockscreenVisibility)
    if (channel.vibrateInSilentMode != null) map.putBoolean("vibrateInSilentMode", channel.vibrateInSilentMode)
    if (channel.color != null) map.putInt("color", channel.color)
    if (channel.localOnly != null) map.putBoolean("localOnly", channel.localOnly)
    return map
  }

  private fun writableMapToChannel(map: ReadableMap): WonderPushChannel? {
    val id = map.getString("id") ?: return null
    val groupId = if (map.hasKey("groupId")) map.getString("groupId") else null
    val channel = WonderPushChannel(id, groupId)

    if (map.hasKey("name")) channel.name = map.getString("name")
    if (map.hasKey("description")) channel.description = map.getString("description")
    if (map.hasKey("bypassDnd")) channel.bypassDnd = map.getBoolean("bypassDnd")
    if (map.hasKey("showBadge")) channel.showBadge = map.getBoolean("showBadge")
    if (map.hasKey("importance")) channel.importance = map.getInt("importance")
    if (map.hasKey("lights")) channel.lights = map.getBoolean("lights")
    if (map.hasKey("lightColor")) channel.lightColor = map.getInt("lightColor")
    if (map.hasKey("vibrate")) channel.vibrate = map.getBoolean("vibrate")
    if (map.hasKey("vibrationPattern")) {
      val patternArray = map.getArray("vibrationPattern")
      if (patternArray != null) {
        val pattern = LongArray(patternArray.size())
        for (i in 0 until patternArray.size()) {
          pattern[i] = patternArray.getDouble(i).toLong()
        }
        channel.vibrationPattern = pattern
      }
    }
    if (map.hasKey("sound")) channel.sound = map.getBoolean("sound")
    if (map.hasKey("soundUri")) {
      val uriString = map.getString("soundUri")
      if (uriString != null) {
        channel.soundUri = android.net.Uri.parse(uriString)
      }
    }
    if (map.hasKey("lockscreenVisibility")) channel.lockscreenVisibility = map.getInt("lockscreenVisibility")
    if (map.hasKey("vibrateInSilentMode")) channel.vibrateInSilentMode = map.getBoolean("vibrateInSilentMode")
    if (map.hasKey("color")) channel.color = map.getInt("color")
    if (map.hasKey("localOnly")) channel.localOnly = map.getBoolean("localOnly")

    return channel
  }

  // User Preferences - Notification Channels
  override fun getDefaultChannelId(promise: Promise) {
    val channelId = WonderPushUserPreferences.getDefaultChannelId()
    promise.resolve(channelId)
  }

  override fun setDefaultChannelId(id: String, promise: Promise) {
    WonderPushUserPreferences.setDefaultChannelId(id)
    promise.resolve(null)
  }

  override fun getChannelGroup(groupId: String, promise: Promise) {
    val channelGroup = WonderPushUserPreferences.getChannelGroup(groupId)
    if (channelGroup != null) {
      val writableMap = channelGroupToWritableMap(channelGroup)
      promise.resolve(writableMap)
    } else {
      promise.resolve(null)
    }
  }

  override fun getChannel(channelId: String, promise: Promise) {
    val channel = WonderPushUserPreferences.getChannel(channelId)
    if (channel != null) {
      val writableMap = channelToWritableMap(channel)
      promise.resolve(writableMap)
    } else {
      promise.resolve(null)
    }
  }

  override fun setChannelGroups(channelGroups: ReadableArray, promise: Promise) {
    try {
      val groups = mutableListOf<WonderPushChannelGroup>()
      for (i in 0 until channelGroups.size()) {
        val groupMap = channelGroups.getMap(i)
        if (groupMap != null) {
          val group = writableMapToChannelGroup(groupMap)
          if (group != null) {
            groups.add(group)
          }
        }
      }
      WonderPushUserPreferences.setChannelGroups(groups)
      promise.resolve(null)
    } catch (error: Exception) {
      promise.reject("SET_CHANNEL_GROUPS_ERROR", "Failed to set channel groups: ${error.message}", error)
    }
  }

  override fun setChannels(channels: ReadableArray, promise: Promise) {
    try {
      val channelList = mutableListOf<WonderPushChannel>()
      for (i in 0 until channels.size()) {
        val channelMap = channels.getMap(i)
        if (channelMap != null) {
          val channel = writableMapToChannel(channelMap)
          if (channel != null) {
            channelList.add(channel)
          }
        }
      }
      WonderPushUserPreferences.setChannels(channelList)
      promise.resolve(null)
    } catch (error: Exception) {
      promise.reject("SET_CHANNELS_ERROR", "Failed to set channels: ${error.message}", error)
    }
  }

  override fun putChannelGroup(channelGroup: ReadableMap, promise: Promise) {
    try {
      val group = writableMapToChannelGroup(channelGroup)
      if (group != null) {
        WonderPushUserPreferences.putChannelGroup(group)
        promise.resolve(null)
      } else {
        promise.reject("PUT_CHANNEL_GROUP_ERROR", "Invalid channel group data")
      }
    } catch (error: Exception) {
      promise.reject("PUT_CHANNEL_GROUP_ERROR", "Failed to put channel group: ${error.message}", error)
    }
  }

  override fun putChannel(channel: ReadableMap, promise: Promise) {
    try {
      val wpChannel = writableMapToChannel(channel)
      if (wpChannel != null) {
        WonderPushUserPreferences.putChannel(wpChannel)
        promise.resolve(null)
      } else {
        promise.reject("PUT_CHANNEL_ERROR", "Invalid channel data")
      }
    } catch (error: Exception) {
      promise.reject("PUT_CHANNEL_ERROR", "Failed to put channel: ${error.message}", error)
    }
  }

  override fun removeChannelGroup(groupId: String, promise: Promise) {
    WonderPushUserPreferences.removeChannelGroup(groupId)
    promise.resolve(null)
  }

  override fun removeChannel(channelId: String, promise: Promise) {
    WonderPushUserPreferences.removeChannel(channelId)
    promise.resolve(null)
  }

  companion object {
    const val NAME = "RNWonderPush"
    const val TAG = NAME + ".Module"
  }
}
