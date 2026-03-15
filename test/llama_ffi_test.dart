import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_qwen/src/llama_ffi.dart';

void main() {
  group('LlamaEngine', () {
    late LlamaEngine engine;

    setUpAll(() {
      try {
        engine = LlamaEngine();
      } catch (e) {
        throw TestFailure(
          'LlamaEngine() failed (native lib may be missing): $e. '
          'Build the llama.cpp library for your platform to run these tests.',
        );
      }
    });

    test('initBackend and freeBackend do not throw', () {
      engine.initBackend();
      engine.freeBackend();
    });

    test('vocabSize returns 0 when model not loaded', () {
      engine.initBackend();
      addTearDown(engine.freeBackend);
      expect(engine.vocabSize(), 0);
    });

    test('cancel does not throw when no generation in progress', () {
      engine.initBackend();
      addTearDown(engine.freeBackend);
      expect(() => engine.cancel(), returnsNormally);
    });

    test('reset does not throw when context not loaded', () {
      engine.initBackend();
      addTearDown(engine.freeBackend);
      expect(() => engine.reset(), returnsNormally);
    });

    test('free does not throw when model not loaded', () {
      engine.initBackend();
      engine.free();
      expect(() => engine.freeBackend(), returnsNormally);
    });
  });
}
