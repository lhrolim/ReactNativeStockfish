cmake_minimum_required(VERSION 3.4.1)
project(ReactNativeStockfish)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 17)

# Include stockfish NNUE
set (NNUE_NAME_BIG nn-1111cefa1111.nnue)
set (NNUE_NAME_SMALL nn-37f18f62d772.nnue)
## Download big NNUE
file(DOWNLOAD https://tests.stockfishchess.org/api/nn/${NNUE_NAME_BIG} ../cpp/${NNUE_NAME_BIG} SHOW_PROGRESS)
file(COPY ../cpp/${NNUE_NAME_BIG} DESTINATION ${CMAKE_BINARY_DIR})
## Download small NNUE
file(DOWNLOAD https://tests.stockfishchess.org/api/nn/${NNUE_NAME_SMALL} ../cpp/${NNUE_NAME_SMALL} SHOW_PROGRESS)
file(COPY ../cpp/${NNUE_NAME_SMALL} DESTINATION ${CMAKE_BINARY_DIR})

# Include stockfish sources and fixes
file(GLOB_RECURSE stockfishCppPaths "../cpp/stockfish/src/*.cpp")
file(GLOB_RECURSE stockfishFixesPaths "../cpp/fixes/*.cpp")


add_library(loloof64-react-native-stockfish            SHARED
            ../cpp/loloof64-react-native-stockfish.cpp
            cpp-adapter.cpp
            ${stockfishCppPaths}
            ${stockfishFixesPaths}
)

# Specifies a path to native header files.
include_directories(
            ../cpp
            ../cpp/fixes
            ../cpp/stockfish/src
            ../cpp/stockfish/src/incbin
            ../cpp/stockfish/src/nnue
            ../cpp/stockfish/src/nnue/features
            ../cpp/stockfish/src/nnue/layers
            ../cpp/stockfish/src/syzygy
)