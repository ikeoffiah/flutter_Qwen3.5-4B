# Third-party code

## llama.cpp

This directory contains a **vendored** copy of [llama.cpp](https://github.com/ggerganov/llama.cpp) used only to build the **libllama** shared library (e.g. `libllama.dylib`, `libllama.so`, `llama.dll`) that the Flutter app loads via FFI.

- **Not a Git submodule** — the code is part of this repo, not a separate clone from GitHub.
- **Trimmed** — the `examples/`, `tools/`, `tests/`, and `pocs/` directories have been removed; only the core library (ggml + llama) and the minimal build glue are kept.
- **Build output** — the built binaries live under `llama.cpp/build/bin/` and are ignored by Git (see root `.gitignore`).

### Building the library

From the project root:

```bash
mkdir -p third_party/llama.cpp/build
cd third_party/llama.cpp/build
cmake .. -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_TOOLS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_SERVER=OFF -DLLAMA_BUILD_COMMON=OFF
cmake --build . --config Release
```

The Flutter app expects the shared library at e.g. `third_party/llama.cpp/build/bin/libllama.dylib` (macOS) or the equivalent for your platform.
