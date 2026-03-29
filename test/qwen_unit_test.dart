import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_qwen/flutter_qwen.dart';
import 'package:flutter_qwen/src/llama_ffi.dart';

// Generate mocks using: flutter pub run build_runner build
// For simplicity in this environment, I'll use manual mocks if I can't run build_runner.
// Using manual mocks here.

class MockModelManager extends Mock implements QwenModelManager {
  @override
  Future<bool> isReady() async =>
      super.noSuchMethod(Invocation.method(#isReady, []), returnValue: Future.value(false));

  @override
  Future<void> download({void Function(double, String)? onProgress}) async =>
      super.noSuchMethod(Invocation.method(#download, [], {#onProgress: onProgress}),
          returnValue: Future.value());

  @override
  String get modelPath =>
      super.noSuchMethod(Invocation.getter(#modelPath), returnValue: '');
}

class MockLlamaEngine extends Mock implements LlamaEngine {
  @override
  void initBackend() => super.noSuchMethod(Invocation.method(#initBackend, []));

  @override
  void freeBackend() => super.noSuchMethod(Invocation.method(#freeBackend, []));

  @override
  bool loadModel(String? path, int? nCtx, int? nThreads) => super.noSuchMethod(
      Invocation.method(#loadModel, [path, nCtx, nThreads]),
      returnValue: false);

  @override
  String generate(String? prompt,
          {int? maxTokens,
          double? temperature,
          double? topP,
          void Function(String)? onToken}) =>
      super.noSuchMethod(
          Invocation.method(#generate, [prompt], {
            #maxTokens: maxTokens,
            #temperature: temperature,
            #topP: topP,
            #onToken: onToken
          }),
          returnValue: '');

  @override
  void free() => super.noSuchMethod(Invocation.method(#free, []));
}

void main() {
  group('Qwen Unit Tests with Mocks', () {
    late MockModelManager mockManager;
    late MockLlamaEngine mockEngine;

    setUp(() {
      mockManager = MockModelManager();
      mockEngine = MockLlamaEngine();
    });

    test('initialize calls download if not ready', () async {
      when(mockManager.isReady()).thenAnswer((_) async => false);
      when(mockManager.download(onProgress: anyNamed('onProgress')))
          .thenAnswer((_) async {});
      when(mockManager.modelPath).thenReturn('/path/to/model');
      when(mockEngine.loadModel(any, any, any)).thenReturn(true);

      final qwen = Qwen(modelManager: mockManager, engine: mockEngine);
      await qwen.initialize();

      verify(mockManager.download(onProgress: anyNamed('onProgress'))).called(1);
      verify(mockEngine.loadModel('/path/to/model', 4096, 4)).called(1);
      expect(qwen.isInitialized, isTrue);
    });

    test('initialize skips download if ready', () async {
      when(mockManager.isReady()).thenAnswer((_) async => true);
      when(mockManager.modelPath).thenReturn('/path/to/model');
      when(mockEngine.loadModel(any, any, any)).thenReturn(true);

      final qwen = Qwen(modelManager: mockManager, engine: mockEngine);
      await qwen.initialize();

      verifyNever(mockManager.download(onProgress: anyNamed('onProgress')));
      verify(mockEngine.loadModel('/path/to/model', 4096, 4)).called(1);
    });

    test('generate calls engine.generate', () async {
      when(mockManager.isReady()).thenAnswer((_) async => true);
      when(mockManager.modelPath).thenReturn('/path/to/model');
      when(mockEngine.loadModel(any, any, any)).thenReturn(true);
      when(mockEngine.generate(any,
              maxTokens: anyNamed('maxTokens'),
              temperature: anyNamed('temperature'),
              topP: anyNamed('topP'),
              onToken: anyNamed('onToken')))
          .thenReturn('Response');

      final qwen = Qwen(modelManager: mockManager, engine: mockEngine);
      await qwen.initialize();

      final result = qwen.generate('Hello', maxTokens: 100);

      expect(result, 'Response');
      verify(mockEngine.generate('Hello',
              maxTokens: 100,
              temperature: 0.7,
              topP: 0.9,
              onToken: anyNamed('onToken')))
          .called(1);
    });

    test('reason uses correct formatting', () async {
      when(mockManager.isReady()).thenAnswer((_) async => true);
      when(mockManager.modelPath).thenReturn('/path/to/model');
      when(mockEngine.loadModel(any, any, any)).thenReturn(true);
      when(mockEngine.generate(any,
              maxTokens: anyNamed('maxTokens'),
              temperature: anyNamed('temperature'),
              topP: anyNamed('topP'),
              onToken: anyNamed('onToken')))
          .thenReturn('Reasoned');

      final qwen = Qwen(modelManager: mockManager, engine: mockEngine);
      await qwen.initialize();

      qwen.reason('Problem');

      final captured = verify(mockEngine.generate(captureAny,
              maxTokens: anyNamed('maxTokens'),
              temperature: anyNamed('temperature'),
              topP: anyNamed('topP'),
              onToken: anyNamed('onToken')))
          .captured;
      
      expect(captured.single, contains('<|im_start|>system'));
      expect(captured.single, contains('Problem'));
    });

    test('dispose frees engine and backend', () async {
      when(mockManager.isReady()).thenAnswer((_) async => true);
      when(mockManager.modelPath).thenReturn('/path/to/model');
      when(mockEngine.loadModel(any, any, any)).thenReturn(true);

      final qwen = Qwen(modelManager: mockManager, engine: mockEngine);
      await qwen.initialize();
      qwen.dispose();

      verify(mockEngine.free()).called(1);
      verify(mockEngine.freeBackend()).called(1);
      expect(qwen.isInitialized, isFalse);
    });
  });
}
