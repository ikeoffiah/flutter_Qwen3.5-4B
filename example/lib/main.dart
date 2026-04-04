import 'package:flutter/material.dart';
import 'package:flutter_qwen/flutter_qwen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qwen3.5-4B Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Qwen _qwen = Qwen();
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isInitializing = true;
  double _initProgress = 0.0;
  String _status = 'Starting...';
  bool _isGenerating = false;
  bool _isReasoningMode = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _qwen.initialize(
        onProgress: (p, s) {
          setState(() {
            _initProgress = p;
            _status = s;
          });
        },
      );
      setState(() {
        _isInitializing = false;
        _messages.add({
          'role': 'assistant',
          'content': 'Model loaded and ready! Ask me anything.'
        });
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messages.add({'role': 'assistant', 'content': ''});
      _isGenerating = true;
      _msgController.clear();
    });

    _scrollToBottom();

    try {
      final assistIdx = _messages.length - 1;
      if (_isReasoningMode) {
        _qwen.reasonStream(
          text,
          onToken: (token) {
            setState(() {
              _messages[assistIdx]['content'] =
                  (_messages[assistIdx]['content'] ?? '') + token;
            });
            _scrollToBottom();
          },
        );
      } else {
        _qwen.generateStream(
          text,
          onToken: (token) {
            setState(() {
              _messages[assistIdx]['content'] =
                  (_messages[assistIdx]['content'] ?? '') + token;
            });
            _scrollToBottom();
          },
        );
      }
    } catch (e) {
      final assistIdx = _messages.length - 1;
      setState(() {
        _messages[assistIdx]['content'] = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _qwen.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(_status),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(value: _initProgress),
              ),
              const SizedBox(height: 10),
              Text('${(_initProgress * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qwen3.5-4B Chat'),
        actions: [
          Row(
            children: [
              const Text('Reasoning'),
              Switch(
                value: _isReasoningMode,
                onChanged: (val) => setState(() => _isReasoningMode = val),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _qwen.reset();
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[700] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Text(
                      m['content'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isGenerating) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Enter prompt...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
