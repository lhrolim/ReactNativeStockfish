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
  private var outputReaderCoroutineScope = CoroutineScope(Dispatchers.Default)
  private var errorReaderCoroutineScope = CoroutineScope(Dispatchers.Default)
  private var stockfishThread: Thread? = null
  private var isRunning = false

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
    // Stop any existing instance before starting a new one (important for Metro reload)
    if (isRunning) {
      stopStockfish()
      // Wait a bit for cleanup to complete
      Thread.sleep(200)
    }
    
    isRunning = true
    val delayTimeMs = 1L  // Reduced from 10ms to 1ms for 10x faster response
    
    // Create new coroutine scopes for fresh start
    outputReaderCoroutineScope = CoroutineScope(Dispatchers.Default)
    errorReaderCoroutineScope = CoroutineScope(Dispatchers.Default)
    
    stockfishThread = Thread {
      Thread.sleep(delayTimeMs)
      main()
      isRunning = false
    }
    stockfishThread?.start()
    
    outputReaderCoroutineScope.launch {
      while (isRunning) {
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
        try {
          reactApplicationContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit("stockfish-output", output)
        } catch (e: Exception) {
          // React context might be invalid during Metro reload, just continue
        }
        delay(delayTimeMs)
      }
    }
    errorReaderCoroutineScope.launch {
      while (isRunning) {
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
        try {
          reactApplicationContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit("stockfish-error", output)
        } catch (e: Exception) {
          // React context might be invalid during Metro reload, just continue
        }
        delay(delayTimeMs)
      }
    }
  }

  @ReactMethod
  fun sendCommandToStockfish(command: String) {
    if (isRunning) {
      stdinWrite(command)
    }
  }

  @ReactMethod
  fun stopStockfish() {
    isRunning = false
    outputReaderCoroutineScope.cancel()
    errorReaderCoroutineScope.cancel()
    sendCommandToStockfish("quit\n")
    stockfishThread?.interrupt()
    stockfishThread = null
  }

  companion object {
    const val NAME = "ReactNativeStockfish"
  }
}
