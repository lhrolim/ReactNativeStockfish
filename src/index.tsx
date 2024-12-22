import ReactNativeStockfish, {
  _subscribeToStockfishOutput,
  _subscribeToStockfishError,
} from './NativeReactNativeStockfish';

/**
 * Runs the main stockfish loop
 */
export function stockfishLoop(): void {
  return ReactNativeStockfish.stockfishLoop();
}

/**
 * Registers a callback for processing stockfish output
 * @param callback {function} a callback that takes a string as argument for the output to be processed
 * @returns {function} a function that unsubscribes the callback
 */
export function subscribeToStockfishOutput(
  callback: (output: string) => void
): Function {
  return _subscribeToStockfishOutput(callback);
}

/**
 * Registers a callback for processing stockfish error
 * @param callback {function} a callback that takes a string as argument for the error to be processed
 * @returns {function} a function that unsubscribes the callback
 */
export function subscribeToStockfishError(
  callback: (error: string) => void
): Function {
  return _subscribeToStockfishError(callback);
}

/**
 * Sends a command to stockfish
 * @param command {string} the command to send (without the newline at the end)
 */
export function sendCommandToStockfish(command: string): void {
  return ReactNativeStockfish.sendCommandToStockfish(`${command}\n`);
}

/**
 * Releases the resources used by stockfish
 * @returns {void} nothing
 */
export function stopStockfish(): void {
  return ReactNativeStockfish.stopStockfish();
}
