# Build llama.cpp as a shared library for Android so the Flutter app can load it via FFI.
# Paths are relative to this file (android/); third_party is at ../third_party/llama.cpp.
cmake_minimum_required(VERSION 3.22)
project(flutter_qwen_native C CXX)

set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared lib for Android" FORCE)

# Build only the library; no tests, tools, or examples.
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_COMMON OFF CACHE BOOL "" FORCE)

add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/llama.cpp
  ${CMAKE_BINARY_DIR}/llama.cpp
)

# The llama target produces libllama.so; Gradle packs it into the ABI-specific output.
# No extra target needed unless we had our own JNI wrapper.
