package com.loloof64.reactnativestockfish

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.HashMap

class ReactNativeStockfishPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return if (name == ReactNativeStockfishModule.NAME) {
      // For New Architecture, React Native will automatically use the TurboModule implementation
      // via codegen. For old architecture, use the legacy module.
      ReactNativeStockfishModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      moduleInfos[ReactNativeStockfishModule.NAME] = ReactModuleInfo(
        ReactNativeStockfishModule.NAME,
        ReactNativeStockfishModule.NAME,
        false,  // canOverrideExistingModule
        false,  // needsEagerInit
        false,  // isCxxModule
        true // isTurboModule - enables TurboModule support
      )
      moduleInfos
    }
  }
}
