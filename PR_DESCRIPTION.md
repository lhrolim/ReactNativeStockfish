# Fix: Metro Reload Support for Android Native Module

## Problem

When Metro reloads the JavaScript bundle (hot reload/fast refresh), React Native creates a new instance of the native module while the old instance's coroutines are still running. This causes several issues:

1. **Timeout on initialization**: The native module fails to respond to UCI commands, causing `Timeout waiting for: uciok` errors
2. **Event emission failures**: Old coroutines try to emit events to an invalid React context
3. **Resource conflicts**: Multiple coroutines reading from the same global C++ streams (`stdout`/`stderr`) cause conflicts
4. **Memory leaks**: Old coroutines and threads continue running indefinitely

## Root Cause

- React Native modules can be recreated on Metro reload, but the old instance's coroutines persist
- The C++ streams (`fakeout`, `fakein`, `fakeerr`) are global and shared across all module instances
- Coroutines were checking `currentActivity == null` and skipping reads, preventing event emission during reload
- No mechanism to stop old instances when new ones are created

## Solution

Implemented global state management using a companion object to ensure only one Stockfish instance runs at a time across all module instances:

### Key Changes

1. **Global State Management**:
   - Added companion object with `@Volatile` global state variables
   - Tracks running state, coroutine scopes, thread, and React context globally
   - Ensures only one instance runs at a time

2. **Automatic Cleanup on Module Creation**:
   - Added cleanup logic in `init` block to stop any existing global instance
   - Prevents old coroutines from interfering with new ones

3. **Improved Coroutine Logic**:
   - Removed `currentActivity == null` check that was preventing reads during Metro reload
   - Always read from stdout/stderr (prevents buffer overflow)
   - Always attempt to emit events (works even when activity is temporarily null)
   - Use global React context that can be updated on Metro reload

4. **Enhanced Stop Logic**:
   - `stopStockfish()` now stops both local and global instances
   - Properly cancels all coroutines and interrupts threads
   - Added `onCatalystInstanceDestroy()` for cleanup

5. **Thread Management**:
   - Track Stockfish thread locally and globally
   - Properly interrupt threads on stop
   - Set `isRunning` flag to false when thread completes

## Changes Made

### `ReactNativeStockfishModule.kt`

- **Added companion object** with global state management
- **Changed coroutine scopes** from `val` to `var` to allow recreation
- **Added `isRunning` flag** to track local instance state
- **Added `stockfishThread` tracking** for proper thread management
- **Removed activity check** in coroutines - always read and try to emit
- **Added cleanup in `init`** to stop old instances
- **Enhanced `stopStockfish()`** to clean up both local and global state
- **Added `onCatalystInstanceDestroy()`** lifecycle hook

## Testing

- ✅ Stockfish initializes successfully on app startup
- ✅ Stockfish initializes successfully after Metro reload (hot reload)
- ✅ No timeout errors on `uciok` or `readyok` responses
- ✅ Events are properly emitted to JavaScript after reload
- ✅ No memory leaks from orphaned coroutines
- ✅ Proper cleanup when module is destroyed

## Impact

- **Fixes Metro reload timeout issues**: Stockfish now works correctly after hot reload
- **Improves developer experience**: Faster debugging workflow without app restarts
- **Prevents memory leaks**: Proper cleanup of old instances
- **Maintains backward compatibility**: No breaking changes to the API

## Files Changed

- `android/src/main/java/com/loloof64/reactnativestockfish/ReactNativeStockfishModule.kt`

## Related Issues

Fixes timeout errors when Metro reloads the JavaScript bundle, allowing developers to use hot reload without restarting the app.



