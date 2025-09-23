import Loloof64ReactNativeStockfish, {
  _subscribeToStockfishOutput,
  _subscribeToStockfishError,
} from './NativeReactNativeStockfish';

import { useRef, useCallback, useEffect } from 'react';

type UseStockfishOptions = {
  onOutput?: (output: string) => void;
  onError?: (error: string) => void;
};

/**
 * Hook for using Stockfish
 * @param onOutput - an optional function for reading Stockfish output - callback of (string) => void
 * @param onError - an optional function for reading Stockfish error - callback of (string) => void
 * @returns an array with three functions :
 * --------
 * stockfishLoop
 * Starts Stockfish
 * --------
 * stopStockfish
 * Stops Stockfish
 * --------
 * sendCommandToStockfish
 * Sends a command to stockfish, if stockfish is running
 * @param command {string} the command to send (without the newline at the end)
 * --------
 */
export function useStockfish({ onOutput, onError }: UseStockfishOptions) {
  const isStockfishRunning = useRef(false);

  const stockfishLoop = useCallback(() => {
    if (!isStockfishRunning.current) {
      isStockfishRunning.current = true;
      Loloof64ReactNativeStockfish.stockfishLoop();
    }
  }, []);

  const stopStockfish = useCallback(() => {
    if (isStockfishRunning.current) {
      Loloof64ReactNativeStockfish.stopStockfish();
      isStockfishRunning.current = false;
    }
  }, []);

  const sendCommandToStockfish = useCallback((command: string) => {
    if (isStockfishRunning.current) {
      Loloof64ReactNativeStockfish.sendCommandToStockfish(command);
    } else {
      console.warn('Stockfish is not running. Cannot send command.');
    }
  }, []);

  useEffect(() => {
    const cancelOutputSubscription = _subscribeToStockfishOutput(
      (output: string) => {
        if (isStockfishRunning.current && onOutput) {
          onOutput(output);
        }
      }
    );

    const cancelErrorSubscription = _subscribeToStockfishError(
      (error: string) => {
        if (isStockfishRunning.current && onError) {
          onError(error);
        }
      }
    );

    return () => {
      // Clean up subscriptions and stop Stockfish
      cancelOutputSubscription();
      cancelErrorSubscription();
      stopStockfish();
    };
  }, [onOutput, onError, stopStockfish]);

  return { stockfishLoop, stopStockfish, sendCommandToStockfish };
}
