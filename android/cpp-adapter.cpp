#include <jni.h>
#include <string>
#include "loloof64-react-native-stockfish.h"

#define STR_SIZE 1024
char conv_buffer[STR_SIZE + 1];

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_loloof64_reactnativestockfish_ReactNativeStockfishModule_main(JNIEnv *env, jclass type) {
    return loloof64_reactnativestockfish::stockfish_main();
}

extern "C"
JNIEXPORT jboolean JNICALL
Java_com_loloof64_reactnativestockfish_ReactNativeStockfishModule_stdinWrite(JNIEnv *env, jclass type, jstring command) {
    ssize_t result;

    jboolean isCopy;
    const char * str = env->GetStringUTFChars(command, &isCopy);

    result = loloof64_reactnativestockfish::stockfish_stdin_write(str);
    env->ReleaseStringUTFChars(command, str);

    if (result < 0) {
        return JNI_FALSE;
    }

    return JNI_TRUE;
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_loloof64_reactnativestockfish_ReactNativeStockfishModule_stdoutRead(JNIEnv *env, jclass type) {
    char *output = loloof64_reactnativestockfish::stockfish_stdout_read();
    // An error occured
    if (output == NULL) {
        return NULL;
    }

    std::strncpy(conv_buffer, output, STR_SIZE);

    return env->NewStringUTF(conv_buffer);
}
