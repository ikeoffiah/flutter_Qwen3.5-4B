# flutter_qwen

A high-performance Flutter plugin for running Qwen3.5-4B models locally using GGUF and FFI.

## Features

- **Local Inference**: Run LLMs directly on-device without an internet connection.
- **Streaming Support**: Real-time token generation for a responsive UI.
- **Reasoning Mode**: Dedicated API for step-by-step thinking/CoT (Chain of Thought).
- **Automated Model Management**: Handles download from Hugging Face and integrity verification (SHA256).
- **Embeddings**: Extract vector embeddings from text for RAG or similarity search.
- **Cross-Platform**: Designed for Android and iOS (via llama.cpp/FFI).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_qwen: ^0.0.1
```

## Usage

### Minimal Example

```dart
final qwen = Qwen();

// Download (if needed) and load the model
await qwen.initialize(
  onProgress: (progress, status) => print('$status: ${(progress * 100).round()}%'),
);

// Batch generation
final response = qwen.generate('What is the capital of France?');
print(response);

// Streaming generation
qwen.generateStream(
  'Write a short poem about coding.',
  onToken: (token) => print(token),
);

qwen.dispose();
```

### Reasoning Mode

To use the model's reasoning capabilities:

```dart
qwen.reasonStream(
  'Solve for x: 2x + 5 = 15',
  onToken: (token) {
    // Process "thinking" tokens and final answer
  },
);
```

### Tokenization & Embeddings

```dart
final tokens = qwen.tokenize('Hello world');
final embedding = qwen.getEmbedding();
```

## Example App

Check out the [example](example/lib/main.dart) folder for a full-featured Chat UI implementation including:
- Download progress tracking
- Real-time streaming
- Reasoning mode toggle
- Reset and memory management

## Additional information

This package uses `llama.cpp` under the hood via FFI. Ensure your target device has sufficient RAM (at least 4GB recommended for Qwen3.5-4B).

