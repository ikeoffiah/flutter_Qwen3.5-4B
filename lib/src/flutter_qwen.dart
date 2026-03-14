import 'dart:typed_data';

import 'llama_ffi.dart';
import 'model_manager.dart';

/// Configuration for the Qwen model (context size, threads).
class QwenConfig {
  const QwenConfig({
    this.contextLength = 4096,
    this.threads = 4,
  });

  /// Maximum context length (n_ctx).
  final int contextLength;

  /// Number of threads for inference.
  final int threads;
}

/// Default system prompt used for [reason] to encourage step-by-step reasoning.
const String kDefaultReasoningPrompt =
    'Think through this step by step. Show your reasoning, then give a clear answer.';

/// High-level API for the Qwen3.5-4B model: initialization, generation, reasoning, embeddings.
///
/// Example:
/// ```dart
/// final qwen = Qwen();
/// await qwen.initialize(onProgress: (p, s) => print('$s ${(p * 100).round()}%'));
/// final answer = qwen.generate('What is 2+2?');
/// qwen.dispose();
/// ```
class Qwen {
  Qwen({QwenModelManager? modelManager, this.config = const QwenConfig()})
      : _manager = modelManager ?? QwenModelManager();

  final QwenModelManager _manager;
  final QwenConfig config;

  LlamaEngine? _engine;
  bool _backendInitialized = false;

  /// Whether the model is loaded and ready for [generate], [reason], etc.
  bool get isInitialized => _engine != null;

  /// Ensures the model is downloaded (if needed), initializes the backend, and loads the model.
  ///
  /// Call this before [generate], [generateStream], [reason], or [getEmbedding].
  /// [onProgress] is called during download with (progress 0..1, status string).
  Future<void> initialize({
    void Function(double progress, String status)? onProgress,
  }) async {
    if (_engine != null) return;

    final ready = await _manager.isReady();
    if (!ready) await _manager.download(onProgress: onProgress);

    final path = _manager.modelPath;
    if (path.isEmpty) throw StateError('Model path is empty after download');

    _engine = LlamaEngine();
    _engine!.initBackend();
    _backendInitialized = true;

    final loaded = _engine!.loadModel(
      path,
      config.contextLength,
      config.threads,
    );
    if (!loaded) {
      _engine!.freeBackend();
      _engine = null;
      _backendInitialized = false;
      throw StateError('Failed to load model from $path');
    }
  }

  /// Generates a completion for [prompt].
  ///
  /// Optional [onToken] streams each token as it is produced.
  String generate(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    void Function(String token)? onToken,
  }) {
    _ensureInitialized();
    return _engine!.generate(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      onToken: onToken,
    );
  }

  /// Streams the completion token-by-token via [onToken].
  void generateStream(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    required void Function(String token) onToken,
  }) {
    _ensureInitialized();
    _engine!.generateStream(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      onToken: onToken,
    );
  }

  /// Runs a reasoning-style completion: encourages step-by-step thinking then an answer.
  ///
  /// Uses [systemPrompt] (default [kDefaultReasoningPrompt]) to guide the model.
  /// You can pass a custom prompt, e.g. "You are a math tutor. Explain each step."
  String reason(
    String userPrompt, {
    String? systemPrompt,
    int maxTokens = 1024,
    double temperature = 0.6,
    double topP = 0.9,
    void Function(String token)? onToken,
  }) {
    _ensureInitialized();
    final system = systemPrompt ?? kDefaultReasoningPrompt;
    final prompt = '<|im_start|>system\n$system<|im_end|>\n<|im_start|>user\n$userPrompt<|im_end|>\n<|im_start|>assistant\n';
    return _engine!.generate(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      onToken: onToken,
    );
  }

  /// Streams a reasoning-style completion token-by-token.
  void reasonStream(
    String userPrompt, {
    String? systemPrompt,
    int maxTokens = 1024,
    double temperature = 0.6,
    double topP = 0.9,
    required void Function(String token) onToken,
  }) {
    _ensureInitialized();
    final system = systemPrompt ?? kDefaultReasoningPrompt;
    final prompt = '<|im_start|>system\n$system<|im_end|>\n<|im_start|>user\n$userPrompt<|im_end|>\n<|im_start|>assistant\n';
    _engine!.generateStream(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      onToken: onToken,
    );
  }

  /// Tokenizes [text] with the model vocabulary.
  List<int> tokenize(String text, {int maxTokens = 4096}) {
    _ensureInitialized();
    return _engine!.tokenize(text, maxTokens: maxTokens);
  }

  /// Returns the embedding vector from the last decode (e.g. after [generate] or a prompt-only decode).
  Float32List getEmbedding() {
    _ensureInitialized();
    return _engine!.getEmbedding();
  }

  /// Clears the KV cache for a new conversation turn.
  void reset() {
    _engine?.reset();
  }

  /// Cancels any in-progress [generate] / [generateStream] / [reason] / [reasonStream].
  void cancel() {
    _engine?.cancel();
  }

  /// Releases the model and backend. Call when done using this instance.
  void dispose() {
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      engine.free();
      if (_backendInitialized) engine.freeBackend();
    }
    _backendInitialized = false;
  }

  void _ensureInitialized() {
    if (_engine == null) {
      throw StateError(
        'Qwen is not initialized. Call initialize() before generate/reason/tokenize/getEmbedding.',
      );
    }
  }
}
