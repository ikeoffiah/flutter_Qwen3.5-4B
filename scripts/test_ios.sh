#!/usr/bin/env bash
# Validate the iOS plugin (podspec and Dart tests).
# Run from repo root: bash scripts/test_ios.sh
set -e
cd "$(dirname "$0")/.."

echo "=== Validating ios/flutter_qwen.podspec ==="
cd ios
pod lib lint flutter_qwen.podspec --allow-warnings --quick
cd ..
echo "=== Podspec OK ==="

echo ""
echo "=== Running Dart tests (including iOS-specific when on iOS) ==="
flutter test test/ios_plugin_test.dart
echo "=== Dart tests OK ==="

echo ""
echo "To run all tests: flutter test"
echo "To build for iOS (from an app that depends on this package): flutter build ios --no-codesign"
