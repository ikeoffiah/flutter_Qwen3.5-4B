# Android

This plugin builds **libllama.so** for Android (arm64-v8a, armeabi-v7a, x86_64) via CMake and packs it into the app. The Dart code loads it with `DynamicLibrary.open('libllama.so')`; the Kotlin plugin calls `System.loadLibrary("llama")` so the library is available.

When you build a Flutter app that depends on `flutter_qwen` for Android, the native library is compiled and included automatically. No extra steps are required on your part.

**Requirements:** Android NDK (e.g. 26.x) and CMake 3.22+ (installed via Android Studio SDK Manager or `sdkmanager "ndk;26.1.10909125" "cmake;3.22.1"`).
