/**
 * TurboModule Spec for ReactNativeStockfish
 * 
 * This file defines the TypeScript interface for the TurboModule.
 * React Native's codegen will generate the native implementation.
 * 
 * The codegen will create:
 * - Android: android/generated/java/com/loloof64/reactnativestockfish/NativeReactNativeStockfishSpec.java
 * - iOS: ios/generated/RCTRNReactNativeStockfishSpec.h and .mm
 */

import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  stockfishLoop(): void;
  sendCommandToStockfish(command: string): void;
  stopStockfish(): void;
}

// This will be used by React Native's codegen to generate the native implementation
export default TurboModuleRegistry.getEnforcing<Spec>('RNReactNativeStockfishSpec');

