#include <jni.h>
#include "loloof64-react-native-stockfish.h"

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_loloof64_reactnativestockfish_ReactNativeStockfishModule_nativeMultiply(JNIEnv *env, jclass type, jdouble a, jdouble b) {
    return loloof64_reactnativestockfish::multiply(a, b);
}
