package com.loloof64.reactnativestockfish

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlinx.coroutines.*

@ReactModule(name = ReactNativeStockfishModule.NAME)
class ReactNativeStockfishModule(reactContext: ReactApplicationContext) :
        NativeReactNativeStockfishSpec(reactContext) {

  private val mainCoroutineScope = CoroutineScope(Dispatchers.Default)
  private val readerCoroutineScope = CoroutineScope(Dispatchers.Default)

  external fun main()
  external fun stdoutRead(): String?
  external fun stderrRead(): String?
  external fun stdinWrite(command: String)

  init {
    System.loadLibrary("loloof64-react-native-stockfish")
  }

  override fun getName(): String {
    return NAME
  }

  override fun stockfishLoop() {
    val delayTimeMs = 100L
    mainCoroutineScope.launch { 
      delay(delayTimeMs)
      main()
    }
    readerCoroutineScope.launch {
      while (true) {
        val reactIsNotReady = reactApplicationContext.currentActivity == null
        if (reactIsNotReady) {
          delay(delayTimeMs)
          continue
        }
        val output = stdoutRead()
        if (output == null) {
          delay(delayTimeMs)
          continue
        }
        reactApplicationContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit("stockfish-output", output)
        delay(delayTimeMs)
      }
    }
    readerCoroutineScope.launch {
      while (true) {
        val reactIsNotReady = reactApplicationContext.currentActivity == null
        if (reactIsNotReady) {
          delay(delayTimeMs)
          continue
        }
        val output = stderrRead()
        if (output == null) {
          delay(delayTimeMs)
          continue
        }
        reactApplicationContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit("stockfish-error", output)
        delay(delayTimeMs)
      }
    }
  }

  override fun sendCommandToStockfish(command: String) {
    stdinWrite(command)
  }

  override fun stopStockfish() {
    readerCoroutineScope.cancel()
    sendCommandToStockfish("quit\n")
  }

  companion object {
    const val NAME = "ReactNativeStockfish"
  }
}
