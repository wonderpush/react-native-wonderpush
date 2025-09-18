package com.wonderpush

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.wonderpush.sdk.reactnative.NativeWonderPushSpec
import com.wonderpush.sdk.WonderPush

@ReactModule(name = WonderPushModule.NAME)
class WonderPushModule(reactContext: ReactApplicationContext) :
  NativeWonderPushSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  override fun subscribeToNotifications(fallbackToSettings: Boolean): Unit {
    WonderPush.subscribeToNotifications(fallbackToSettings)
  }

  companion object {
    const val NAME = "WonderPush"
  }
}
