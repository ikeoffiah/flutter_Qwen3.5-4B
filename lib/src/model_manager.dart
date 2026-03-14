import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'integrity_verifier.dart';

/// Manages download and integrity of the Qwen3.5-4B GGUF model from Hugging Face.
///
/// Uses the same pattern as KokoroModelManager: download to app documents,
/// verify SHA256 after download, and use a ready marker for idempotency.
class QwenModelManager {
  /// Hugging Face base URL (resolve/main for latest).
  static const _hfBase =
      'https://huggingface.co/unsloth/Qwen3.5-4B-GGUF/resolve/main';

  /// Model file name (from unsloth/Qwen3.5-4B-GGUF). LFS SHA256 from Hugging Face tree API.
  static const _modelFileName = 'Qwen3.5-4B-Q4_K_M.gguf';

  /// SHA256 of the GGUF file (Hugging Face LFS oid from repo tree).
  static const _modelSha256 =
      '00fe7986ff5f6b463e62455821146049db6f9313603938a70800d1fb69ef11a4';

  static const _modelDirName = 'Qwen3.5-4B-GGUF';
  static const _readyMarker = '.ready';

  String? _modelDir;

  String get modelDir => _modelDir ?? '';
  String get modelPath => p.join(modelDir, _modelFileName);

  Future<bool> isReady() async {
    final dir = await _getModelDir();
    final marker = File(p.join(dir.path, _readyMarker));
    final path = p.join(dir.path, _modelFileName);

    if (!marker.existsSync()) return false;

    try {
      await IntegrityVerifier.verify(
        path: path,
        expectedSha256: _modelSha256,
      );
      _modelDir = dir.path;
      return true;
    } catch (_) {
      await marker.delete();
      await _deleteModel(dir.path);
      return false;
    }
  }

  Future<void> _deleteModel(String dirPath) async {
    final modelFile = File(p.join(dirPath, _modelFileName));
    if (await modelFile.exists()) await modelFile.delete();
  }

  Future<void> download({
    void Function(double progress, String status)? onProgress,
  }) async {
    final dir = await _getModelDir();
    _modelDir = dir.path;
    final marker = File(p.join(dir.path, _readyMarker));
    if (marker.existsSync()) {
      onProgress?.call(1.0, 'Ready');
      return;
    }

    final url = '$_hfBase/$_modelFileName';
    await _downloadFile(
      url: url,
      destination: p.join(dir.path, _modelFileName),
      onProgress: (progress) =>
          onProgress?.call(progress, 'Downloading model...'),
    );

    await marker.create();
    onProgress?.call(1.0, 'Ready');
  }

  Future<void> _downloadFile({
    required String url,
    required String destination,
    required void Function(double progress)? onProgress,
  }) async {
    final finalFile = File(destination);
    if (finalFile.existsSync()) return;

    final tempPath = '$destination.part';
    final tempFile = File(tempPath);

    final client = http.Client();

    try {
      final response = await client.send(http.Request('GET', Uri.parse(url)));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      final sink = tempFile.openWrite();

      var received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (total > 0) {
          onProgress?.call(received / total);
        }
      }

      await sink.close();

      if (total > 0 && received != total) {
        throw Exception('Incomplete download');
      }

      await tempFile.rename(destination);

      await IntegrityVerifier.verify(
        path: destination,
        expectedSha256: _modelSha256,
      );
    } catch (e) {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Directory> _getModelDir() async {
    if (_modelDir != null) return Directory(_modelDir!);

    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = p.join(appDir.path, 'qwen', _modelDirName);
    final dir = Directory(modelPath);
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }
}
