package com.wonderpush.sdk.reactnative.hcm

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = WonderPushHcmModule.NAME)
class WonderPushHcmModule(reactContext: ReactApplicationContext) :
  NativeWonderPushHcmSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  companion object {
    const val NAME = "WonderPushHcm"
  }
}
