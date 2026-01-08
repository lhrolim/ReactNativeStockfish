# 🏗️ New Architecture Support for ReactNativeStockfish

## Changes Made

### 1. TurboModule Implementation
- ✅ Created `ReactNativeStockfishModuleImpl.kt` - TurboModule implementation for New Architecture
- ✅ Updated `ReactNativeStockfishPackage.kt` - Kept `isTurboModule: true` to enable TurboModule support
- ✅ Updated `NativeReactNativeStockfish.ts` - Added TurboModule/legacy module detection and fallback
- ✅ Created `NativeReactNativeStockfishSpec.ts` - TypeScript spec for codegen

### 2. Build Configuration
- ✅ Updated `android/build.gradle` - Added comments about codegen (dependencies handled automatically)
- ✅ Updated `android/CMakeLists.txt` - Removed manual codegen linking (handled by React Native)

### 3. Codegen Configuration
- ✅ `package.json` already has `codegenConfig` properly configured
- ✅ Codegen will run automatically when building with `newArchEnabled=true`

## How It Works

### Old Architecture (Legacy)
- Uses `ReactNativeStockfishModule.kt` (extends `ReactContextBaseJavaModule`)
- Accessed via `NativeModules.ReactNativeStockfish`

### New Architecture (TurboModule)
- React Native's codegen generates `NativeReactNativeStockfishSpec.java` base class
- `ReactNativeStockfishModuleImpl.kt` extends the generated base class
- Accessed via `TurboModuleRegistry.get('RNReactNativeStockfishSpec')`
- JavaScript automatically falls back to legacy if TurboModule not available

## Testing

1. **Enable New Architecture in your app:**
   ```bash
   # In chesswizard/mobile/
   # app.config.js: newArchEnabled: true
   # android/gradle.properties: newArchEnabled=true
   ```

2. **Clean and rebuild:**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   npm run dev:android:incremental
   ```

3. **Verify codegen ran:**
   - Check `android/generated/java/com/loloof64/reactnativestockfish/NativeReactNativeStockfishSpec.java` exists
   - Check build logs for codegen messages

## Important Notes

- The codegen base class (`NativeReactNativeStockfishSpec`) will be generated automatically by React Native's build system
- The implementation (`ReactNativeStockfishModuleImpl`) extends this generated class
- JavaScript code automatically detects and uses TurboModule if available, falls back to legacy otherwise
- Both implementations share the same native C++ code (Stockfish engine)

## Troubleshooting

### Error: "Cannot find class NativeReactNativeStockfishSpec"
- **Cause**: Codegen hasn't run yet
- **Fix**: Ensure `newArchEnabled=true` and rebuild. Codegen runs automatically during build.

### Error: "Cannot specify link libraries for target react_codegen_RNReactNativeStockfishSpec"
- **Cause**: CMake trying to link before codegen runs
- **Fix**: This should be handled automatically by React Native's build system. If it persists, check that `newArchEnabled=true` is set correctly.

### Module not working in New Architecture
- Check logs: `adb logcat | grep ReactNativeStockfish`
- Verify codegen output exists in `android/generated/`
- Ensure `isTurboModule: true` in `ReactNativeStockfishPackage.kt`

