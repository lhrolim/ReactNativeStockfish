#import <React/RCTLog.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#import "ReactNativeStockfish.h"

typedef const char *(*StdoutReadFunc)();
typedef const char *(*StderrReadFunc)();
typedef void (*MainFunc)();
typedef void (*StdinWriteFunc)(const char *);

@implementation ReactNativeStockfish {
    void *handle;
    dispatch_queue_t mainQueue;
    BOOL isStockfishInitialized;
    BOOL isStockfishRunning;

    StdoutReadFunc stdoutRead;
    StderrReadFunc stderrRead;
    MainFunc main;
    StdinWriteFunc stdinWrite;

    NSTimer *stdoutTimer;
    NSTimer *stderrTimer;
}

RCT_EXPORT_MODULE();

- (void)initializeStockfish {
    handle = dlopen("loloof64-react-native-stockfish.dylib", RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        RCTLogError(@"Failed to load library: %s", dlerror());
        return;
    }

    stdoutRead = (StdoutReadFunc)dlsym(handle, "stdoutRead");
    stderrRead = (StderrReadFunc)dlsym(handle, "stderrRead");
    main = (MainFunc)dlsym(handle, "main");
    stdinWrite = (StdinWriteFunc)dlsym(handle, "stdinWrite");

    if (!stdoutRead) {
        RCTLogError(@"Failed to load stdoutRead function: %s", dlerror());
    }
    if (!stderrRead) {
        RCTLogError(@"Failed to load stderrRead function: %s", dlerror());
    }
    if (!main) {
        RCTLogError(@"Failed to load main function: %s", dlerror());
    }
    if (!stdinWrite) {
        RCTLogError(@"Failed to load stdinWrite function: %s", dlerror());
    }
}

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
    // Intialize Stockfish, if necessary
    if (!isStockfishInitialized) {
        [self initializeStockfish];
        isStockfishInitialized = YES;
    }

    isStockfishRunning = YES;
    dispatch_async(mainQueue, ^{
        main();
    });

    // Start timers for stdout and stderr reading
    [self startTimerForStdoutReading];
    [self startTimerForStderrReading];
}

// Send a command to Stockfish
RCT_EXPORT_METHOD(sendCommandToStockfish:(NSString *)command) {
    if (!stdinWrite) {
        RCTLogError(@"stdinWrite function is not loaded. Cannot send command.");
        return;
    }

    if (!isStockfishRunning) {
        RCTLogError(@"Stockfish is not running. Cannot send command.");
        return;
    }


    const char *nativeCommand = [command UTF8String];
    stdinWrite(nativeCommand);
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
    const char *output = stdoutRead();
    if (output) {
        [self sendEventWithName:@"stockfish-output" body:@(output)];
    }
}

- (void)readStderr {
    const char *error = stderrRead();
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
