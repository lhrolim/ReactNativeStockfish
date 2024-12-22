#import "ReactNativeStockfish.h"
#import <React/RCTLog.h>

@implementation ReactNativeStockfish {
    dispatch_queue_t mainQueue;
    dispatch_queue_t readerQueue;
    BOOL isStockfishRunning;
}

// Load stockfish native library
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dlopen("loloof64-react-native-stockfish.dylib", RTLD_NOW | RTLD_GLOBAL);
    });
}

RCT_EXPORT_MODULE();

- (instancetype)init {
    if (self = [super init]) {
        mainQueue = dispatch_queue_create("com.reactnativestockfish.main", DISPATCH_QUEUE_SERIAL);
        readerQueue = dispatch_queue_create("com.reactnativestockfish.reader", DISPATCH_QUEUE_SERIAL);
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
        main();
    });

    // Read stdout
    dispatch_async(readerQueue, ^{
        while (isStockfishRunning) {
            const char *output = stdoutRead();
            if (output) {
                [self sendEventWithName:@"stockfish-output" body:@(output)];
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    });

    // Read stderr
    dispatch_async(readerQueue, ^{
        while (isStockfishRunning) {
            const char *error = stderrRead();
            if (error) {
                [self sendEventWithName:@"stockfish-error" body:@(error)];
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    });
}

// Send a command to Stockfish
RCT_EXPORT_METHOD(sendCommandToStockfish:(NSString *)command) {
    const char *nativeCommand = [command UTF8String];
    stdinWrite(nativeCommand);
}

// Stop Stockfish
RCT_EXPORT_METHOD(stopStockfish) {
    isStockfishRunning = NO;
    [self sendCommandToStockfish:@"quit\n"];
}

@end
