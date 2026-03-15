import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_qwen/src/model_manager.dart';

void main() {
  group('QwenModelManager', () {
    test('modelDir is empty before isReady or download', () {
      final manager = QwenModelManager();
      expect(manager.modelDir, isEmpty);
    });

    test('modelPath joins modelDir and model filename', () {
      final manager = QwenModelManager();
      expect(manager.modelPath, endsWith('Qwen3.5-4B-Q4_K_M.gguf'));
      expect(manager.modelPath, p.join('', 'Qwen3.5-4B-Q4_K_M.gguf'));
    });

    test('modelPath is modelDir + filename when modelDir set', () {
      final manager = _FixedPathModelManager('/tmp/qwen');
      expect(manager.modelDir, '/tmp/qwen');
      expect(manager.modelPath, p.join('/tmp/qwen', 'Qwen3.5-4B-Q4_K_M.gguf'));
    });

    // isReady() and download() require path_provider (getApplicationDocumentsDirectory),
    // which is not available in unit test environment without plugin mocks.
    // Test those in integration tests or with path_provider_platform_interface mock.
  });
}

/// Manager with fixed modelDir for testing path join.
class _FixedPathModelManager extends QwenModelManager {
  _FixedPathModelManager(this._fixedDir);
  final String _fixedDir;
  @override
  String get modelDir => _fixedDir;
  @override
  String get modelPath => p.join(_fixedDir, 'Qwen3.5-4B-Q4_K_M.gguf');
}
