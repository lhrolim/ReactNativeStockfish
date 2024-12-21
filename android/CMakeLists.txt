cmake_minimum_required(VERSION 3.4.1)
project(ReactNativeStockfish)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 14)

add_library(loloof64-react-native-stockfish            SHARED
            ../cpp/loloof64-react-native-stockfish.cpp
            cpp-adapter.cpp
)

# Specifies a path to native header files.
include_directories(
            ../cpp
)
