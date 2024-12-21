package com.loloof64.reactnativestockfish

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlinx.coroutines.*

@ReactModule(name = ReactNativeStockfishModule.NAME)
class ReactNativeStockfishModule(reactContext: ReactApplicationContext) :
        NativeReactNativeStockfishSpec(reactContext) {

  private val coroutineScope = CoroutineScope(Dispatchers.Default)

  external fun main()
  external fun stdoutRead(): String
  external fun stdinWrite(command: String)

  init {
    System.loadLibrary("loloof64-react-native-stockfish")
  }

  override fun getName(): String {
    return NAME
  }

  override fun stockfishLoop() {
    coroutineScope.launch { main() }
    coroutineScope.launch {
      while (true) {
        val output = stdoutRead()
        if (output.isNotEmpty()) {
          reactApplicationContext
                  .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                  .emit("stockfish-output", output)
        }
        delay(100)
      }
    }
  }

  override fun sendCommandToStockfish(command: String) {
    stdinWrite(command)
  }

  override fun stopStockfish() {
    super.invalidate()
    sendCommandToStockfish("quit\n")
    coroutineScope.cancel()
  }

  companion object {
    const val NAME = "ReactNativeStockfish"
  }
}
