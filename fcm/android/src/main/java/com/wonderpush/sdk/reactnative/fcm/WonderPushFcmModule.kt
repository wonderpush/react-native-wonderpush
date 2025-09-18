package com.wonderpush.sdk.reactnative.fcm

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = WonderPushFcmModule.NAME)
class WonderPushFcmModule(reactContext: ReactApplicationContext) :
  NativeWonderPushFcmSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  companion object {
    const val NAME = "WonderPushFcm"
  }
}
