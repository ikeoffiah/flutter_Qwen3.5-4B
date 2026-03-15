#
# To use this plugin on iOS, the host app must link the llama.cpp native library
# into the app (statically or as a dynamic framework). See ios/README.md.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_qwen'
  s.version          = '0.0.1'
  s.summary          = 'Qwen model inference for Flutter (FFI).'
  s.description      = 'Flutter package for Qwen3.5-4B GGUF model: download, load, generate, reason. Native via llama.cpp; iOS requires host app to link the library.'
  s.homepage         = 'https://github.com/your-org/flutter_qwen'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.swift_version = '5.0'
end
