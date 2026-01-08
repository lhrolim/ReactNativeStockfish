import {
  NativeModules,
  NativeEventEmitter,
  TurboModuleRegistry,
} from 'react-native';

// Try to import the codegen spec (will be available after codegen runs)
let NativeReactNativeStockfishSpec: any = null;
try {
  // This will work after codegen has run
  NativeReactNativeStockfishSpec = require('./NativeReactNativeStockfishSpec').default;
} catch (e) {
  // Codegen spec not available yet, will use legacy module
}

// Check if we should use TurboModule (New Architecture) or Legacy Module
const isTurboModuleEnabled = 
  (typeof global !== 'undefined' && (global as any).__turboModuleProxy != null) ||
  (TurboModuleRegistry != null && TurboModuleRegistry.get != null);

let ReactNativeStockfish: any = null;
let eventEmitter: NativeEventEmitter | null = null;

if (isTurboModuleEnabled && NativeReactNativeStockfishSpec) {
  // New Architecture: Use TurboModule from codegen
  try {
    ReactNativeStockfish = NativeReactNativeStockfishSpec;
    if (ReactNativeStockfish) {
      eventEmitter = new NativeEventEmitter(ReactNativeStockfish);
    }
  } catch (e) {
    console.warn('Failed to load TurboModule, falling back to legacy module', e);
  }
}

// Fallback to legacy module if TurboModule is not available
if (!ReactNativeStockfish) {
  const LegacyModule = NativeModules.ReactNativeStockfish;
  if (!LegacyModule) {
    throw new Error(
      'ReactNativeStockfish native module is not linked. IOS users: ensure that you have run `pod install` and rebuilt the app.'
    );
  }
  ReactNativeStockfish = LegacyModule;
  eventEmitter = new NativeEventEmitter(LegacyModule);
}

if (!eventEmitter) {
  throw new Error('Failed to create event emitter for ReactNativeStockfish');
}

export const _subscribeToStockfishOutput = (
  callback: (output: string) => void
) => {
  const subscription = eventEmitter!.addListener('stockfish-output', (event: any) => {
    // Handle both legacy (string) and new arch (object with output property) formats
    const output = typeof event === 'string' ? event : event?.output || '';
    if (output) {
      callback(output);
    }
  });
  return () => subscription.remove();
};

export const _subscribeToStockfishError = (
  callback: (output: string) => void
) => {
  const subscription = eventEmitter!.addListener('stockfish-error', (event: any) => {
    // Handle both legacy (string) and new arch (object with error property) formats
    const error = typeof event === 'string' ? event : event?.error || '';
    if (error) {
      callback(error);
    }
  });
  return () => subscription.remove();
};

export interface Spec {
  stockfishLoop(): void;
  sendCommandToStockfish(command: string): void;
  stopStockfish(): void;
}

export default ReactNativeStockfish as Spec;
