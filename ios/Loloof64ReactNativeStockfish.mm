#import <React/RCTLog.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#import "ReactNativeStockfish.h"

@implementation ReactNativeStockfish {
    NSThread *stockfishThread;
    BOOL shouldStopStockfish;

    dispatch_source_t stdoutTimer;
    dispatch_source_t stderrTimer;
}

RCT_EXPORT_MODULE(ReactNativeStockfish);

- (instancetype)init {
    NSLog(@"ReactNativeStockfish module is loading");
    self = [super init];
    return self;
}

// Supported events
- (NSArray<NSString *> *)supportedEvents {
    return @[@"stockfish-output", @"stockfish-error"];
}

// Start Stockfish in a background thread
RCT_EXPORT_METHOD(stockfishLoop) {
    if (stockfishThread && stockfishThread.isExecuting) {
        RCTLogInfo(@"Stockfish is already running. Ignoring start request.");
        return;
    }

    shouldStopStockfish = NO;
    stockfishThread = [[NSThread alloc] initWithTarget:self selector:@selector(runStockfish) object:nil];
    [stockfishThread start];
    [self startTimerForStdoutReading];
    [self startTimerForStderrReading];
}   

// The actual execution of stockfish_main
- (void)runStockfish {
    @autoreleasepool {
        RCTLogInfo(@"Stockfish thread started.");

        reactnativestockfish::stockfish_main();

        RCTLogInfo(@"Stockfish thread ended.");
    }
}

// Send a command to Stockfish
RCT_EXPORT_METHOD(sendCommandToStockfish:(NSString *)command) {
    if (!stockfishThread || !stockfishThread.isExecuting) {
        RCTLogInfo(@"Cannot send command: Stockfish is not running.");
        return;
    }

    const char *nativeCommand = [command UTF8String];
    reactnativestockfish::stockfish_stdin_write(nativeCommand);
}

- (void)startTimerForStdoutReading {
    if (stdoutTimer) {
        RCTLogInfo(@"Stdout reader is already running.");
        return;
    }

    RCTLogInfo(@"Stdout stream reader is starting.");

    // Create dedicated queue for continuous reading
    dispatch_queue_t queue = dispatch_queue_create("com.reactnativestockfish.stdout", DISPATCH_QUEUE_SERIAL);

    // Use a simple flag to track if we should continue reading
    // We store the dispatch source just to keep a reference, but we're using async not timer
    stdoutTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, queue);

    // Stream-based continuous reading - no polling delays
    dispatch_async(queue, ^{
        while (stdoutTimer) { // Check if still active
            const char *output = reactnativestockfish::stockfish_stdout_read(); // Blocking read
            if (output) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendEventWithName:@"stockfish-output" body:@(output)];
                });
                // No delay - immediately read next line
            } else {
                // Stream ended or closed
                break;
            }
        }
        RCTLogInfo(@"Stdout stream reader ended.");
    });

    RCTLogInfo(@"Stdout stream reader started.");
}

- (void)startTimerForStderrReading {
    if (stderrTimer) {
        RCTLogInfo(@"Stderr reader is already running.");
        return;
    }

    RCTLogInfo(@"Stderr stream reader is starting.");

    // Create dedicated queue for continuous reading
    dispatch_queue_t queue = dispatch_queue_create("com.reactnativestockfish.stderr", DISPATCH_QUEUE_SERIAL);

    // Use a simple flag to track if we should continue reading
    // We store the dispatch source just to keep a reference, but we're using async not timer
    stderrTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, queue);

    // Stream-based continuous reading - no polling delays
    dispatch_async(queue, ^{
        while (stderrTimer) { // Check if still active
            const char *error = reactnativestockfish::stockfish_stderr_read(); // Blocking read
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendEventWithName:@"stockfish-error" body:@(error)];
                });
                // No delay - immediately read next line
            } else {
                // Stream ended or closed
                break;
            }
        }
        RCTLogInfo(@"Stderr stream reader ended.");
    });

    RCTLogInfo(@"Stderr stream reader started.");
}

- (void)stopTimers {
    if (stdoutTimer) {
        RCTLogInfo(@"Stdout stream reader is being stopped.");
        dispatch_source_cancel(stdoutTimer);
        stdoutTimer = nil;
        RCTLogInfo(@"Stdout stream reader is stopped.");
    }
    if (stderrTimer) {
        RCTLogInfo(@"Stderr stream reader is being stopped.");
        dispatch_source_cancel(stderrTimer);
        stderrTimer = nil;
        RCTLogInfo(@"Stderr stream reader is stopped.");
    }
}

// Stop the Stockfish thread and timers
RCT_EXPORT_METHOD(stopStockfish) {
    [self stopTimers];
    if (stockfishThread && stockfishThread.isExecuting) {
        shouldStopStockfish = YES;

        reactnativestockfish::stockfish_stdin_write("quit\n");

        [stockfishThread cancel];
        stockfishThread = nil;

        RCTLogInfo(@"Stockfish stopped.");
    } else {
        RCTLogInfo(@"Stockfish is not running.");
    }
}

- (void)dealloc {
    NSLog(@"ReactNativeStockfish module is being removed");
    [self stopStockfish];
}


@end
