package com.loloof64.reactnativestockfish

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule

import kotlinx.coroutines.*

@ReactModule(name = ReactNativeStockfishModule.NAME)
class ReactNativeStockfishModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private val mainCoroutineScope = CoroutineScope(Dispatchers.Default)
  private val outputReaderCoroutineScope = CoroutineScope(Dispatchers.Default)
  private val errorReaderCoroutineScope = CoroutineScope(Dispatchers.Default)

  external fun main()
  external fun stdoutRead(): String?
  external fun stderrRead(): String?
  external fun stdinWrite(command: String)


  override fun getName(): String {
    return NAME
  }

  init {
    System.loadLibrary("react-native-stockfish")
  }

  @ReactMethod
  fun stockfishLoop() {
    // Run main() in a separate thread, not in a coroutine
    Thread {
      main()
    }.start()
    // Stream-based approach: blocking reads without polling delays
    // stdoutRead() and stderrRead() will block until data is available
    outputReaderCoroutineScope.launch {
      while (true) {
        val reactIsNotReady = reactApplicationContext.currentActivity == null
        if (reactIsNotReady) {
          delay(50L) // Only delay when React isn't ready
          continue
        }
        val output = stdoutRead() // Blocking call - no polling needed
        if (output == null) {
          // Only happens when stream is closed/ended
          break
        }
        reactApplicationContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit("stockfish-output", output)
        // No delay here - immediately read next line
      }
    }
    errorReaderCoroutineScope.launch {
      while (true) {
        val reactIsNotReady = reactApplicationContext.currentActivity == null
        if (reactIsNotReady) {
          delay(50L) // Only delay when React isn't ready
          continue
        }
        val output = stderrRead() // Blocking call - no polling needed
        if (output == null) {
          // Only happens when stream is closed/ended
          break
        }
        reactApplicationContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit("stockfish-error", output)
        // No delay here - immediately read next line
      }
    }
  }

  @ReactMethod
  fun sendCommandToStockfish(command: String) {
    stdinWrite(command)
  }

  @ReactMethod
  fun stopStockfish() {
    outputReaderCoroutineScope.cancel()
    errorReaderCoroutineScope.cancel()
    sendCommandToStockfish("quit\n")
  }

  companion object {
    const val NAME = "ReactNativeStockfish"
  }
}
