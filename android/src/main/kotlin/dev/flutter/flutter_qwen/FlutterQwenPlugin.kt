package dev.flutter.flutter_qwen

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Stub for Flutter Android plugin registration.
 * This package uses Dart FFI and loads libllama.so on Android;
 * the native library is built by this module's CMake and packed into the app.
 */
class FlutterQwenPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Load libllama.so so Dart's DynamicLibrary.open("libllama.so") can find it.
        System.loadLibrary("llama")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
