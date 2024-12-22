#import "ReactNativeStockfish.h"
#import <React/RCTEventEmitter.h>
#import <thread>
#import <atomic>

@implementation ReactNativeStockfish {
    std::thread stockfishMainThread;
    std::thread stockfishOutputThread;
    std::atomic<bool> stopStockfishLoop;
}

// Declare React Native module
RCT_EXPORT_MODULE();

// Load stockfish library
+ (void)initialize {
    [super initialize];
    dlopen("loloof64-react-native-stockfish.dylib", RTLD_NOW | RTLD_GLOBAL);
}

// Define native methods exposed by the module
// Define native methods exposed by the module
extern "C" {
    void main();
    const char* stdoutRead();
    void stdinWrite(const char* command);
}

// Start stockfish threads
RCT_EXPORT_METHOD(stockfishLoop) {
    stopStockfishLoop.store(false);

    // main function thread
    stockfishMainThread = std::thread([]() {
        main();
    });

    // stockfish output thread
    stockfishOutputThread = std::thread([this]() {
        while (!stopStockfishLoop.load()) {
            const char* output = stdoutRead();
            if (output && strlen(output) > 0) {
                NSString *outputString = [NSString stringWithUTF8String:output];
                [self sendEventWithName:@"stockfish-output" body:outputString];
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    });
}

// send command to stockfish
RCT_EXPORT_METHOD(sendCommandToStockfish:(NSString *)command) {
    const char *commandCStr = [command UTF8String];
    stdinWrite(commandCStr);
}

// stop stockfish and clean threads
RCT_EXPORT_METHOD(stopStockfish) {
    stopStockfishLoop.store(true);

    // stop stockfish properly
    const char *quitCommand = "quit\n";
    stdinWrite(quitCommand);

    // wait for threads to finish
    if (stockfishMainThread.joinable()) {
        stockfishMainThread.join();
    }
    if (stockfishOutputThread.joinable()) {
        stockfishOutputThread.join();
    }
}

// list supported events for javascript
- (NSArray<NSString *> *)supportedEvents {
    return @[@"stockfish-output"];
}

@end
