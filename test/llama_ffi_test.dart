import 'package:flutter_qwen/src/llama_ffi.dart';

void main() {
  print('Init Llama Engine Object (checks missing symbols)...');
  final engine = LlamaEngine();
  
  print('Initializing Backend natively...');
  engine.initBackend();
  
  print('Loading vocabulary defaults...');
  // Testing simple functions like checking vocab size when model is not loaded yet
  try {
    print('Vocab size before model load: ${engine.vocabSize()}');
  } catch(e) {
    print('Error caught (expected): $e');
  }

  print('Freeing backend...');
  engine.freeBackend();

  print('LlamaEngine FFI wrapper tests completed successfully!');
}
