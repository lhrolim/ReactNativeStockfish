#import <React/RCTLog.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#import "ReactNativeStockfish.h"

@implementation ReactNativeStockfish {
    void *handle;
    dispatch_queue_t mainQueue;
    BOOL isStockfishInitialized;
    BOOL isStockfishRunning;

    NSTimer *stdoutTimer;
    NSTimer *stderrTimer;
}

RCT_EXPORT_MODULE();

- (instancetype)init {
    if (self = [super init]) {
      mainQueue = dispatch_queue_create("com.reactnativestockfish.main", DISPATCH_QUEUE_SERIAL);
      isStockfishRunning = NO;
    }
    return self;
}

// Supported events
- (NSArray<NSString *> *)supportedEvents {
    return @[@"stockfish-output", @"stockfish-error"];
}

// Starts Stockfish main loop
RCT_EXPORT_METHOD(stockfishLoop) {
    isStockfishRunning = YES;
    dispatch_async(mainQueue, ^{
       loloof64_reactnativestockfish::stockfish_main();
    });

    // Start timers for stdout and stderr reading
    [self startTimerForStdoutReading];
    [self startTimerForStderrReading];
}

// Send a command to Stockfish
RCT_EXPORT_METHOD(sendCommandToStockfish:(NSString *)command) {
    if (!isStockfishRunning) {
        RCTLogError(@"Stockfish is not running. Cannot send command.");
        return;
    }


    const char *nativeCommand = [command UTF8String];
    loloof64_reactnativestockfish::stockfish_stdin_write(nativeCommand);
}

- (void)startTimerForStdoutReading {
    stdoutTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(readStdout)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)startTimerForStderrReading {
    stderrTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(readStderr)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)readStdout {
    const char *output = loloof64_reactnativestockfish::stockfish_stdout_read();
    if (output) {
        [self sendEventWithName:@"stockfish-output" body:@(output)];
    }
}

- (void)readStderr {
    const char *error = loloof64_reactnativestockfish::stockfish_stderr_read();
    if (error) {
        [self sendEventWithName:@"stockfish-error" body:@(error)];
    }
}

- (void)stopTimers {
    if (stdoutTimer) {
        [stdoutTimer invalidate];
        stdoutTimer = nil;
    }
    if (stderrTimer) {
        [stderrTimer invalidate];
        stderrTimer = nil;
    }
}

// Stop Stockfish
RCT_EXPORT_METHOD(stopStockfish) {
    [self stopTimers];
    isStockfishRunning = NO;
    [self sendCommandToStockfish:@"quit\n"];
}

- (void)dealloc {
    [self stopTimers];
    isStockfishRunning = NO;
    [self sendCommandToStockfish:@"quit\n"];

    // closing access to stockfish dynamic library
    if (handle) {
        dlclose(handle);
    }
}


@end
