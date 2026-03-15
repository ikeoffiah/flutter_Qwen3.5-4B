# iOS setup for flutter_qwen

This package uses **Dart FFI** and loads the native llama.cpp library via `DynamicLibrary.process()` on iOS. The **host app** must link the llama library into the app so that its symbols are available at runtime.

## Option 1: Link a pre-built framework (recommended)

1. Build llama.cpp for iOS (e.g. as an **xcframework** or **.framework**) from the package’s `third_party/llama.cpp` (or use a pre-built binary).
2. In Xcode, open your app’s `ios/Runner.xcworkspace`.
3. Drag the framework into the project (or add it via **File → Add Files**).
4. In **Target → Runner → General → Frameworks, Libraries, and Embedded Content**, add the framework and set it to **Embed & Sign** (for a dynamic framework) or ensure it is linked (for a static library linked into the app).
5. Ensure **Minimum Deployments** is at least **iOS 12.0** (or whatever your app uses).

## Option 2: Build from source in Xcode

1. Build the llama.cpp static or dynamic library for iOS (e.g. using the project’s `third_party/llama.cpp` and its CMake/Makefile with an iOS toolchain).
2. Add the resulting library (e.g. `libllama.a` or `libllama.dylib` inside a `.framework`) to the Runner target’s **Link Binary With Libraries** and, if dynamic, **Embed Frameworks**.

## Deployment target

The plugin’s iOS deployment target is **12.0**. Your app’s minimum iOS version should be at least 12.0.

## Troubleshooting

- **Undefined symbols for llama_…**  
  The app is not linking the llama library. Add the framework or library as above.

- **DynamicLibrary.process() fails**  
  The native library must be linked into the app (statically or dynamically) so that its symbols are in the process. A separate `.framework` must be in **Embedded Binaries** so it is loaded at startup.
