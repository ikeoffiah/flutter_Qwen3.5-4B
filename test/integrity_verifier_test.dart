import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_qwen/src/integrity_verifier.dart';

void main() {
  group('IntegrityVerifier', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('integrity_verifier_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('verify throws when file does not exist', () async {
      final path = '${tempDir.path}/nonexistent.bin';

      expect(
        IntegrityVerifier.verify(
          path: path,
          expectedSha256: '0' * 64,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('File not found'),
        )),
      );
    });

    test('verify exception when file not found includes path', () async {
      final path = '${tempDir.path}/missing.bin';
      try {
        await IntegrityVerifier.verify(
          path: path,
          expectedSha256: '0' * 64,
        );
        fail('expected Exception');
      } on Exception catch (e) {
        expect(e.toString(), contains('File not found'));
        expect(e.toString(), contains('missing.bin'));
      }
    });

    test('verify throws when SHA256 does not match', () async {
      final file = File('${tempDir.path}/wrong_hash.bin');
      await file.writeAsString('hello');

      expect(
        IntegrityVerifier.verify(
          path: file.path,
          expectedSha256: '0' * 64,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('SHA256 mismatch'),
        )),
      );
    });

    test('verify deletes file when SHA256 does not match', () async {
      final file = File('${tempDir.path}/wrong_hash_deleted.bin');
      await file.writeAsString('hello');
      final path = file.path;

      try {
        await IntegrityVerifier.verify(
          path: path,
          expectedSha256: '0' * 64,
        );
      } on Exception catch (e) {
        expect(e.toString(), contains('SHA256 mismatch'));
      }
      expect(File(path).existsSync(), isFalse);
    });

    test('verify succeeds when file exists and SHA256 matches', () async {
      const content = 'hello\n';
      final digest = sha256.convert(utf8.encode(content));
      final expectedSha256 = digest.toString();

      final file = File('${tempDir.path}/correct.bin');
      await file.writeAsString(content);

      await IntegrityVerifier.verify(
        path: file.path,
        expectedSha256: expectedSha256,
      );

      expect(file.existsSync(), isTrue);
    });

    test('verify SHA256 mismatch exception includes Expected and Actual', () async {
      final file = File('${tempDir.path}/mismatch.bin');
      await file.writeAsString('x');
      try {
        await IntegrityVerifier.verify(
          path: file.path,
          expectedSha256: 'a' * 64,
        );
        fail('expected Exception');
      } on Exception catch (e) {
        final msg = e.toString();
        expect(msg, contains('SHA256 mismatch'));
        expect(msg, contains('Expected:'));
        expect(msg, contains('Actual:'));
      }
    });
  });
}
