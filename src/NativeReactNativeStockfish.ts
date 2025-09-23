import type { TurboModule } from 'react-native';
import {
  TurboModuleRegistry,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

console.log('NativeModules is defined as :', NativeModules);

const { Loloof64ReactNativeStockfish } = NativeModules;

if (!Loloof64ReactNativeStockfish) {
  throw new Error(
    'Loloof64ReactNativeStockfish native module is not linked. Ensure that you have run `pod install` and rebuilt the app.'
  );
}

const eventEmitter = new NativeEventEmitter(Loloof64ReactNativeStockfish);

export const _subscribeToStockfishOutput = (
  callback: (output: string) => void
) => {
  const subscription = eventEmitter.addListener('stockfish-output', callback);
  return () => subscription.remove();
};

export const _subscribeToStockfishError = (
  callback: (output: string) => void
) => {
  const subscription = eventEmitter.addListener('stockfish-error', callback);
  return () => subscription.remove();
};

export interface Spec extends TurboModule {
  stockfishLoop(): void;
  sendCommandToStockfish(command: string): void;
  stopStockfish(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'Loloof64ReactNativeStockfish'
);
