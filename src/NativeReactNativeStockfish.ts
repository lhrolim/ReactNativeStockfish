import type { TurboModule } from 'react-native';
import {
  TurboModuleRegistry,
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

const { ReactNativeStockfish } = NativeModules;

const eventEmitter = new NativeEventEmitter(ReactNativeStockfish);

export const _subscribeToStockfishOutput = (
  callback: (output: string) => void
) => {
  const subscription = eventEmitter.addListener('stockfish-output', callback);
  return () => subscription.remove();
};

export interface Spec extends TurboModule {
  stockfishLoop(): void;
  sendCommandToStockfish(command: string): void;
  stopStockfish(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('ReactNativeStockfish');
