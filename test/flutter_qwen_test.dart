import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_qwen/flutter_qwen.dart';
import 'package:flutter_qwen/src/model_manager.dart';

void main() {
  group('QwenConfig', () {
    test('default values', () {
      const config = QwenConfig();
      expect(config.contextLength, 4096);
      expect(config.threads, 4);
    });

    test('custom values', () {
      const config = QwenConfig(
        contextLength: 2048,
        threads: 8,
      );
      expect(config.contextLength, 2048);
      expect(config.threads, 8);
    });
  });

  group('kDefaultReasoningPrompt', () {
    test('is non-empty and contains reasoning hint', () {
      expect(kDefaultReasoningPrompt, isNotEmpty);
      expect(kDefaultReasoningPrompt.toLowerCase(), contains('step'));
    });
  });

  group('Qwen', () {
    test('isInitialized is false before initialize', () {
      final qwen = Qwen();
      expect(qwen.isInitialized, isFalse);
    });

    test('config is stored', () {
      const config = QwenConfig(contextLength: 1024, threads: 2);
      final qwen = Qwen(config: config);
      expect(qwen.config.contextLength, 1024);
      expect(qwen.config.threads, 2);
    });

    test('generate throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.generate('Hello'),
        throwsStateError,
      );
    });

    test('generateStream throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.generateStream('Hi', onToken: (_) {}),
        throwsStateError,
      );
    });

    test('reason throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.reason('Why?'),
        throwsStateError,
      );
    });

    test('reasonStream throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.reasonStream('Why?', onToken: (_) {}),
        throwsStateError,
      );
    });

    test('tokenize throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.tokenize('text'),
        throwsStateError,
      );
    });

    test('getEmbedding throws StateError when not initialized', () {
      final qwen = Qwen();
      expect(
        () => qwen.getEmbedding(),
        throwsStateError,
      );
    });

    test('reset does not throw when not initialized', () {
      final qwen = Qwen();
      expect(() => qwen.reset(), returnsNormally);
    });

    test('cancel does not throw when not initialized', () {
      final qwen = Qwen();
      expect(() => qwen.cancel(), returnsNormally);
    });

    test('dispose does not throw when not initialized', () {
      final qwen = Qwen();
      expect(() => qwen.dispose(), returnsNormally);
    });

    test('initialize throws StateError when model path is empty', () async {
      final manager = _EmptyPathModelManager();
      final qwen = Qwen(modelManager: manager);

      expect(
        qwen.initialize(),
        throwsStateError,
      );
    });
  });
}

/// A fake manager that reports ready but returns an empty path (e.g. broken state).
class _EmptyPathModelManager extends QwenModelManager {
  @override
  String get modelDir => '';

  @override
  String get modelPath => '';

  @override
  Future<bool> isReady() async => true;
}
