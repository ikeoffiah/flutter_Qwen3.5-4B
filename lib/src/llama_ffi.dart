// ignore_for_file: non_constant_identifier_names
// The snake_case field names in `ffi.Struct` subclasses must mirror the C
// struct layout exactly — renaming them would not break the ABI but would make
// the code much harder to cross-reference with llama.h.

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data'; // Float32List

import 'package:ffi/ffi.dart'; // Utf8, malloc, toNativeUtf8, toDartString

// ─────────────────────────────────────────────────────────────────────────────
// Opaque handle types
// ─────────────────────────────────────────────────────────────────────────────

base class LlamaModel extends ffi.Opaque {}
base class LlamaContext extends ffi.Opaque {}
base class LlamaSampler extends ffi.Opaque {}
base class LlamaVocab extends ffi.Opaque {}

// ─────────────────────────────────────────────────────────────────────────────
// C structs (field names mirror llama.h — lint suppressed at top)
// ─────────────────────────────────────────────────────────────────────────────

final class LlamaModelParams extends ffi.Struct {
  external ffi.Pointer<ffi.Void> devices;
  external ffi.Pointer<ffi.Void> tensor_buft_overrides;
  @ffi.Int32()
  external int n_gpu_layers;
  @ffi.Int32()
  external int split_mode;
  @ffi.Int32()
  external int main_gpu;
  external ffi.Pointer<ffi.Float> tensor_split;
}

final class LlamaContextParams extends ffi.Struct {
  @ffi.Uint32()
  external int n_ctx;
  @ffi.Uint32()
  external int n_batch;
  @ffi.Uint32()
  external int n_ubatch;
  @ffi.Uint32()
  external int n_seq_max;
  @ffi.Int32()
  external int n_threads;
  @ffi.Int32()
  external int n_threads_batch;
  @ffi.Int32()
  external int rope_scaling_type;
  @ffi.Int32()
  external int pooling_type;
  @ffi.Int32()
  external int attention_type;
  @ffi.Int32()
  external int flash_attn_type;
  @ffi.Float()
  external double rope_freq_base;
  @ffi.Float()
  external double rope_freq_scale;
  @ffi.Float()
  external double yarn_ext_factor;
  @ffi.Float()
  external double yarn_attn_factor;
  @ffi.Float()
  external double yarn_beta_fast;
  @ffi.Float()
  external double yarn_beta_slow;
  @ffi.Uint32()
  external int yarn_orig_ctx;
  @ffi.Float()
  external double defrag_thold;
  external ffi.Pointer<ffi.Void> cb_eval;
  external ffi.Pointer<ffi.Void> cb_eval_user_data;
  @ffi.Int32()
  external int type_k;
  @ffi.Int32()
  external int type_v;
  @ffi.Bool()
  external bool logits_all;
  @ffi.Bool()
  external bool embeddings;
  @ffi.Bool()
  external bool offload_kqv;
  @ffi.Bool()
  external bool flash_attn;
  @ffi.Bool()
  external bool no_perf;
  external ffi.Pointer<ffi.Void> abort_callback;
  external ffi.Pointer<ffi.Void> abort_callback_data;
}

final class LlamaBatch extends ffi.Struct {
  @ffi.Int32()
  external int n_tokens;
  external ffi.Pointer<ffi.Int32> token;
  external ffi.Pointer<ffi.Float> embd;
  external ffi.Pointer<ffi.Int32> pos;
  external ffi.Pointer<ffi.Int32> n_seq_id;
  external ffi.Pointer<ffi.Pointer<ffi.Int32>> seq_id;
  external ffi.Pointer<ffi.Int8> logits;
}

final class LlamaSamplerChainParams extends ffi.Struct {
  @ffi.Bool()
  external bool no_perf;
}

// ─────────────────────────────────────────────────────────────────────────────
// Native ↔ Dart function typedefs
// ─────────────────────────────────────────────────────────────────────────────

// 1️⃣ Backend
typedef _BackendInitN = ffi.Void Function();
typedef _BackendInitD = void Function();
typedef _BackendFreeN = ffi.Void Function();
typedef _BackendFreeD = void Function();

// Default params
typedef _ModelDefaultParamsN = LlamaModelParams Function();
typedef _ModelDefaultParamsD = LlamaModelParams Function();
typedef _CtxDefaultParamsN = LlamaContextParams Function();
typedef _CtxDefaultParamsD = LlamaContextParams Function();
typedef _SamplerChainDefaultParamsN = LlamaSamplerChainParams Function();
typedef _SamplerChainDefaultParamsD = LlamaSamplerChainParams Function();

// 2️⃣ Model load / free / context
typedef _ModelLoadN = ffi.Pointer<LlamaModel> Function(
    ffi.Pointer<Utf8> path, LlamaModelParams params);
typedef _ModelLoadD = ffi.Pointer<LlamaModel> Function(
    ffi.Pointer<Utf8> path, LlamaModelParams params);
typedef _ModelFreeN = ffi.Void Function(ffi.Pointer<LlamaModel> m);
typedef _ModelFreeD = void Function(ffi.Pointer<LlamaModel> m);
typedef _InitFromModelN = ffi.Pointer<LlamaContext> Function(
    ffi.Pointer<LlamaModel> m, LlamaContextParams p);
typedef _InitFromModelD = ffi.Pointer<LlamaContext> Function(
    ffi.Pointer<LlamaModel> m, LlamaContextParams p);
typedef _CtxFreeN = ffi.Void Function(ffi.Pointer<LlamaContext> c);
typedef _CtxFreeD = void Function(ffi.Pointer<LlamaContext> c);

// Vocab
typedef _GetVocabN = ffi.Pointer<LlamaVocab> Function(ffi.Pointer<LlamaModel> m);
typedef _GetVocabD = ffi.Pointer<LlamaVocab> Function(ffi.Pointer<LlamaModel> m);
typedef _VocabNTokensN = ffi.Int32 Function(ffi.Pointer<LlamaVocab> v);
typedef _VocabNTokensD = int Function(ffi.Pointer<LlamaVocab> v);

// 3️⃣ Tokenize
typedef _TokenizeN = ffi.Int32 Function(
    ffi.Pointer<LlamaVocab> vocab,
    ffi.Pointer<Utf8> text,
    ffi.Int32 textLen,
    ffi.Pointer<ffi.Int32> tokens,
    ffi.Int32 nTokensMax,
    ffi.Bool addSpecial,
    ffi.Bool parseSpecial);
typedef _TokenizeD = int Function(
    ffi.Pointer<LlamaVocab> vocab,
    ffi.Pointer<Utf8> text,
    int textLen,
    ffi.Pointer<ffi.Int32> tokens,
    int nTokensMax,
    bool addSpecial,
    bool parseSpecial);

// Token to piece
typedef _TokenToPieceN = ffi.Int32 Function(
    ffi.Pointer<LlamaVocab> vocab,
    ffi.Int32 token,
    ffi.Pointer<ffi.Char> buf,
    ffi.Int32 length,
    ffi.Int32 lstrip,
    ffi.Bool special);
typedef _TokenToPieceD = int Function(
    ffi.Pointer<LlamaVocab> vocab,
    int token,
    ffi.Pointer<ffi.Char> buf,
    int length,
    int lstrip,
    bool special);

// EOG check
typedef _VocabIsEogN = ffi.Bool Function(ffi.Pointer<LlamaVocab> vocab, ffi.Int32 token);
typedef _VocabIsEogD = bool Function(ffi.Pointer<LlamaVocab> vocab, int token);

// 4️⃣ Memory clear (formerly llama_kv_cache_clear), batch, decode
typedef _MemoryClearN = ffi.Void Function(ffi.Pointer<LlamaContext> ctx);
typedef _MemoryClearD = void Function(ffi.Pointer<LlamaContext> ctx);
typedef _BatchGetOneN = LlamaBatch Function(ffi.Pointer<ffi.Int32> tokens, ffi.Int32 nTokens);
typedef _BatchGetOneD = LlamaBatch Function(ffi.Pointer<ffi.Int32> tokens, int nTokens);
typedef _DecodeN = ffi.Int32 Function(ffi.Pointer<LlamaContext> ctx, LlamaBatch batch);
typedef _DecodeD = int Function(ffi.Pointer<LlamaContext> ctx, LlamaBatch batch);

// Sampler chain
typedef _SamplerChainInitN = ffi.Pointer<LlamaSampler> Function(LlamaSamplerChainParams p);
typedef _SamplerChainInitD = ffi.Pointer<LlamaSampler> Function(LlamaSamplerChainParams p);
typedef _SamplerInitTopPN = ffi.Pointer<LlamaSampler> Function(ffi.Float p, ffi.Size minKeep);
typedef _SamplerInitTopPD = ffi.Pointer<LlamaSampler> Function(double p, int minKeep);
typedef _SamplerInitTempN = ffi.Pointer<LlamaSampler> Function(ffi.Float t);
typedef _SamplerInitTempD = ffi.Pointer<LlamaSampler> Function(double t);
typedef _SamplerInitDistN = ffi.Pointer<LlamaSampler> Function(ffi.Uint32 seed);
typedef _SamplerInitDistD = ffi.Pointer<LlamaSampler> Function(int seed);
typedef _SamplerChainAddN = ffi.Void Function(
    ffi.Pointer<LlamaSampler> chain, ffi.Pointer<LlamaSampler> smpl);
typedef _SamplerChainAddD = void Function(
    ffi.Pointer<LlamaSampler> chain, ffi.Pointer<LlamaSampler> smpl);
typedef _SamplerSampleN = ffi.Int32 Function(
    ffi.Pointer<LlamaSampler> smpl, ffi.Pointer<LlamaContext> ctx, ffi.Int32 idx);
typedef _SamplerSampleD = int Function(
    ffi.Pointer<LlamaSampler> smpl, ffi.Pointer<LlamaContext> ctx, int idx);
typedef _SamplerAcceptN = ffi.Void Function(ffi.Pointer<LlamaSampler> smpl, ffi.Int32 token);
typedef _SamplerAcceptD = void Function(ffi.Pointer<LlamaSampler> smpl, int token);
typedef _SamplerFreeN = ffi.Void Function(ffi.Pointer<LlamaSampler> smpl);
typedef _SamplerFreeD = void Function(ffi.Pointer<LlamaSampler> smpl);

// 8️⃣ Embeddings
typedef _ModelNEmbdN = ffi.Int32 Function(ffi.Pointer<LlamaModel> model);
typedef _ModelNEmbdD = int Function(ffi.Pointer<LlamaModel> model);
typedef _GetEmbeddingsN = ffi.Pointer<ffi.Float> Function(ffi.Pointer<LlamaContext> ctx);
typedef _GetEmbeddingsD = ffi.Pointer<ffi.Float> Function(ffi.Pointer<LlamaContext> ctx);

// ─────────────────────────────────────────────────────────────────────────────
// LlamaEngine — the public Dart API
// Mirrors the C wrapper API:
//   llm_backend_init / llm_load_model / llm_tokenize /
//   llm_generate / llm_generate_stream / llm_reset /
//   llm_free / llm_vocab_size / llm_get_embedding / llm_cancel
// ─────────────────────────────────────────────────────────────────────────────

class LlamaEngine {
  late final ffi.DynamicLibrary _lib;

  // Bound functions
  late final _BackendInitD _backendInit;
  late final _BackendFreeD _backendFree;
  late final _ModelDefaultParamsD _modelDefaultParams;
  late final _CtxDefaultParamsD _ctxDefaultParams;
  late final _SamplerChainDefaultParamsD _samplerChainDefaultParams;
  late final _ModelLoadD _modelLoad;
  late final _ModelFreeD _modelFree;
  late final _InitFromModelD _initFromModel;
  late final _CtxFreeD _ctxFree;
  late final _GetVocabD _getVocab;
  late final _VocabNTokensD _vocabNTokens;
  late final _TokenizeD _tokenize;
  late final _TokenToPieceD _tokenToPiece;
  late final _VocabIsEogD _vocabIsEog;
  late final _MemoryClearD _memoryClear;
  late final _BatchGetOneD _batchGetOne;
  late final _DecodeD _decode;
  late final _SamplerChainInitD _samplerChainInit;
  late final _SamplerInitTopPD _samplerInitTopP;
  late final _SamplerInitTempD _samplerInitTemp;
  late final _SamplerInitDistD _samplerInitDist;
  late final _SamplerChainAddD _samplerChainAdd;
  late final _SamplerSampleD _samplerSample;
  late final _SamplerAcceptD _samplerAccept;
  late final _SamplerFreeD _samplerFree;
  late final _ModelNEmbdD _modelNEmbd;
  late final _GetEmbeddingsD _getEmbeddings;

  ffi.Pointer<LlamaModel>? _model;
  ffi.Pointer<LlamaContext>? _ctx;
  ffi.Pointer<LlamaVocab>? _vocab;
  bool _isGenerating = false;

  LlamaEngine() {
    _loadLibrary();
    _bindFunctions();
  }

  void _loadLibrary() {
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libllama.so');
    } else if (Platform.isIOS) {
      _lib = ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      _lib = ffi.DynamicLibrary.open(
          'third_party/llama.cpp/build/bin/libllama.dylib');
    } else if (Platform.isWindows) {
      _lib = ffi.DynamicLibrary.open(
          'third_party/llama.cpp/build/bin/llama.dll');
    } else if (Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open(
          'third_party/llama.cpp/build/bin/libllama.so');
    } else {
      throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  void _bindFunctions() {
    _backendInit =
        _lib.lookupFunction<_BackendInitN, _BackendInitD>('llama_backend_init');
    _backendFree =
        _lib.lookupFunction<_BackendFreeN, _BackendFreeD>('llama_backend_free');
    _modelDefaultParams =
        _lib.lookupFunction<_ModelDefaultParamsN, _ModelDefaultParamsD>(
            'llama_model_default_params');
    _ctxDefaultParams =
        _lib.lookupFunction<_CtxDefaultParamsN, _CtxDefaultParamsD>(
            'llama_context_default_params');
    _samplerChainDefaultParams = _lib.lookupFunction<
            _SamplerChainDefaultParamsN, _SamplerChainDefaultParamsD>(
        'llama_sampler_chain_default_params');
    _modelLoad =
        _lib.lookupFunction<_ModelLoadN, _ModelLoadD>('llama_model_load_from_file');
    _modelFree =
        _lib.lookupFunction<_ModelFreeN, _ModelFreeD>('llama_model_free');
    _initFromModel =
        _lib.lookupFunction<_InitFromModelN, _InitFromModelD>('llama_init_from_model');
    _ctxFree = _lib.lookupFunction<_CtxFreeN, _CtxFreeD>('llama_free');
    _getVocab =
        _lib.lookupFunction<_GetVocabN, _GetVocabD>('llama_model_get_vocab');
    _vocabNTokens =
        _lib.lookupFunction<_VocabNTokensN, _VocabNTokensD>('llama_vocab_n_tokens');
    _tokenize = _lib.lookupFunction<_TokenizeN, _TokenizeD>('llama_tokenize');
    _tokenToPiece =
        _lib.lookupFunction<_TokenToPieceN, _TokenToPieceD>('llama_token_to_piece');
    _vocabIsEog =
        _lib.lookupFunction<_VocabIsEogN, _VocabIsEogD>('llama_vocab_is_eog');
    _memoryClear =
        _lib.lookupFunction<_MemoryClearN, _MemoryClearD>('llama_memory_clear');
    _batchGetOne =
        _lib.lookupFunction<_BatchGetOneN, _BatchGetOneD>('llama_batch_get_one');
    _decode = _lib.lookupFunction<_DecodeN, _DecodeD>('llama_decode');
    _samplerChainInit = _lib.lookupFunction<_SamplerChainInitN, _SamplerChainInitD>(
        'llama_sampler_chain_init');
    _samplerInitTopP = _lib.lookupFunction<_SamplerInitTopPN, _SamplerInitTopPD>(
        'llama_sampler_init_top_p');
    _samplerInitTemp = _lib.lookupFunction<_SamplerInitTempN, _SamplerInitTempD>(
        'llama_sampler_init_temp');
    _samplerInitDist = _lib.lookupFunction<_SamplerInitDistN, _SamplerInitDistD>(
        'llama_sampler_init_dist');
    _samplerChainAdd = _lib.lookupFunction<_SamplerChainAddN, _SamplerChainAddD>(
        'llama_sampler_chain_add');
    _samplerSample =
        _lib.lookupFunction<_SamplerSampleN, _SamplerSampleD>('llama_sampler_sample');
    _samplerAccept =
        _lib.lookupFunction<_SamplerAcceptN, _SamplerAcceptD>('llama_sampler_accept');
    _samplerFree =
        _lib.lookupFunction<_SamplerFreeN, _SamplerFreeD>('llama_sampler_free');
    _modelNEmbd =
        _lib.lookupFunction<_ModelNEmbdN, _ModelNEmbdD>('llama_model_n_embd');
    _getEmbeddings =
        _lib.lookupFunction<_GetEmbeddingsN, _GetEmbeddingsD>('llama_get_embeddings');
  }

  // ───────────────────────────────────────────────────────────
  // 1️⃣ Backend Initialization / Free
  // ───────────────────────────────────────────────────────────

  void initBackend() => _backendInit();
  void freeBackend() => _backendFree();

  // ───────────────────────────────────────────────────────────
  // 2️⃣ Load the Model
  // ───────────────────────────────────────────────────────────

  bool loadModel(String modelPath, int nCtx, int nThreads) {
    if (_ctx != null) _ctxFree(_ctx!);
    if (_model != null) _modelFree(_model!);
    _ctx = null;
    _model = null;
    _vocab = null;

    final pathPtr = modelPath.toNativeUtf8();
    final modelParams = _modelDefaultParams();
    _model = _modelLoad(pathPtr, modelParams);
    malloc.free(pathPtr);

    if (_model == null || _model == ffi.nullptr) return false;

    _vocab = _getVocab(_model!);

    final ctxParams = _ctxDefaultParams();
    ctxParams.n_ctx = nCtx;
    ctxParams.n_threads = nThreads;
    ctxParams.n_threads_batch = nThreads;
    ctxParams.embeddings = true;

    _ctx = _initFromModel(_model!, ctxParams);
    return _ctx != null && _ctx != ffi.nullptr;
  }

  // ───────────────────────────────────────────────────────────
  // 3️⃣ Tokenize
  // ───────────────────────────────────────────────────────────

  List<int> tokenize(String text, {int maxTokens = 4096}) {
    if (_vocab == null) return [];
    final textPtr = text.toNativeUtf8();
    final tokensPtr =
        malloc.allocate<ffi.Int32>(maxTokens * ffi.sizeOf<ffi.Int32>());
    final nTokens = _tokenize(
        _vocab!, textPtr, text.length, tokensPtr, maxTokens, true, true);
    malloc.free(textPtr);
    if (nTokens < 0) {
      malloc.free(tokensPtr);
      return [];
    }
    final result = List<int>.generate(nTokens, (i) => tokensPtr[i]);
    malloc.free(tokensPtr);
    return result;
  }

  // ───────────────────────────────────────────────────────────
  // 4️⃣ Generate (returns full string) + 5️⃣ Streaming via onToken
  // ───────────────────────────────────────────────────────────

  /// Returns the full generated response.
  /// If [onToken] is supplied, each token piece is streamed as it is produced.
  String generate(
    String prompt, {
    int maxTokens = 256,
    double temperature = 0.8,
    double topP = 0.95,
    void Function(String token)? onToken,
  }) {
    if (_model == null || _ctx == null || _vocab == null) return '';

    final promptTokens = tokenize(prompt);
    if (promptTokens.isEmpty) return '';

    // Build sampler chain: top-p → temperature → dist (stochastic sampling)
    final sparams = _samplerChainDefaultParams();
    final sampler = _samplerChainInit(sparams);
    _samplerChainAdd(sampler, _samplerInitTopP(topP, 1));
    _samplerChainAdd(sampler, _samplerInitTemp(temperature));
    _samplerChainAdd(sampler, _samplerInitDist(0xFFFFFFFF));

    // Clear memory (KV cache) for a fresh generation
    _memoryClear(_ctx!);

    // Feed prompt tokens
    final promptPtr = malloc.allocate<ffi.Int32>(
        promptTokens.length * ffi.sizeOf<ffi.Int32>());
    for (int i = 0; i < promptTokens.length; i++) {
      promptPtr[i] = promptTokens[i];
    }
    final promptBatch = _batchGetOne(promptPtr, promptTokens.length);
    if (_decode(_ctx!, promptBatch) != 0) {
      malloc.free(promptPtr);
      _samplerFree(sampler);
      return '';
    }
    malloc.free(promptPtr);

    // Generation loop
    final response = StringBuffer();
    _isGenerating = true;
    final singlePtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    final charBuf = malloc.allocate<ffi.Char>(256);

    for (int i = 0; i < maxTokens && _isGenerating; i++) {
      final id = _samplerSample(sampler, _ctx!, -1);
      _samplerAccept(sampler, id);

      if (_vocabIsEog(_vocab!, id)) break;

      final n = _tokenToPiece(_vocab!, id, charBuf, 256, 0, true);
      if (n > 0) {
        final piece = charBuf.cast<Utf8>().toDartString(length: n);
        response.write(piece);
        onToken?.call(piece);
      }

      singlePtr[0] = id;
      final nextBatch = _batchGetOne(singlePtr, 1);
      if (_decode(_ctx!, nextBatch) != 0) break;
    }

    _isGenerating = false;
    malloc.free(singlePtr);
    malloc.free(charBuf);
    _samplerFree(sampler);

    return response.toString();
  }

  /// Convenience streaming wrapper — each token is delivered via [onToken].
  void generateStream(
    String prompt, {
    int maxTokens = 256,
    double temperature = 0.8,
    double topP = 0.95,
    required void Function(String token) onToken,
  }) =>
      generate(prompt,
          maxTokens: maxTokens,
          temperature: temperature,
          topP: topP,
          onToken: onToken);

  // ───────────────────────────────────────────────────────────
  // 6️⃣ Reset Context (clears KV cache for a new chat turn)
  // ───────────────────────────────────────────────────────────

  void reset() {
    if (_ctx != null) _memoryClear(_ctx!);
  }

  // ───────────────────────────────────────────────────────────
  // 7️⃣ Free Memory
  // ───────────────────────────────────────────────────────────

  void free() {
    _isGenerating = false;
    if (_ctx != null) {
      _ctxFree(_ctx!);
      _ctx = null;
    }
    if (_model != null) {
      _modelFree(_model!);
      _model = null;
    }
    _vocab = null;
  }

  // ───────────────────────────────────────────────────────────
  // 8️⃣ Optional helpers
  // ───────────────────────────────────────────────────────────

  /// Returns the vocabulary size of the loaded model.
  int vocabSize() {
    if (_vocab == null) return 0;
    return _vocabNTokens(_vocab!);
  }

  /// Returns the embedding vector from the last decode call as a [Float32List].
  Float32List getEmbedding() {
    if (_ctx == null || _model == null) return Float32List(0);
    final nEmbd = _modelNEmbd(_model!);
    final ptr = _getEmbeddings(_ctx!);
    if (ptr == ffi.nullptr) return Float32List(0);
    return ptr.asTypedList(nEmbd);
  }

  /// Cancels an in-progress [generate] / [generateStream] call.
  void cancel() => _isGenerating = false;
}
