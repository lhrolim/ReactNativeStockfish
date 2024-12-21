package com.loloof64.reactnativestockfish

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = ReactNativeStockfishModule.NAME)
class ReactNativeStockfishModule(reactContext: ReactApplicationContext) :
  NativeReactNativeStockfishSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = "ReactNativeStockfish"
  }
}
