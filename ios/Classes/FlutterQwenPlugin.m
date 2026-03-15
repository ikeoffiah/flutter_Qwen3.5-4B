// Stub for Flutter iOS plugin registration.
// This package uses Dart FFI and DynamicLibrary.process() on iOS;
// the host app must link the llama.cpp library (see ios/README.md).
#import <Flutter/Flutter.h>

@interface FlutterQwenPlugin : NSObject <FlutterPlugin>
@end

@implementation FlutterQwenPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  // No method channel; FFI is used from Dart.
}
@end
