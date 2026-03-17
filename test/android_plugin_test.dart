import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_qwen/flutter_qwen.dart';

/// Tests that run on Android to verify the plugin and package work on the platform.
/// Run with: flutter test test/android_plugin_test.dart --platform=android
void main() {
  if (!Platform.isAndroid) {
    test('Android plugin tests skipped on non-Android platform', () {
      // Skip entire file when not on Android; test run with --platform=android will execute the group below.
    });
    return;
  }

  group('Android plugin', () {
    test('package exports work on Android', () {
      expect(Qwen(), isNotNull);
      expect(const QwenConfig(), isNotNull);
      expect(kDefaultReasoningPrompt, isNotEmpty);
      expect(QwenModelManager(), isNotNull);
      expect(IntegrityVerifier.verify, isNotNull);
    });

    test('QwenConfig Android compatible', () {
      const config = QwenConfig(contextLength: 4096, threads: 4);
      expect(config.contextLength, greaterThanOrEqualTo(512));
      expect(config.threads, greaterThanOrEqualTo(1));
    });

    test('Qwen lifecycle safe on Android (no native load)', () {
      final qwen = Qwen();
      expect(qwen.isInitialized, isFalse);
      qwen.reset();
      qwen.cancel();
      qwen.dispose();
      qwen.dispose();
      expect(() => qwen.generate('hi'), throwsStateError);
    });

    test('custom manager works on Android', () {
      final manager = _EmptyPathModelManager();
      final qwen = Qwen(modelManager: manager);
      expect(qwen.config.threads, 4);
      qwen.dispose();
    });
  });
}

class _EmptyPathModelManager extends QwenModelManager {
  @override
  String get modelDir => '';

  @override
  String get modelPath => '';

  @override
  Future<bool> isReady() async => true;
}
