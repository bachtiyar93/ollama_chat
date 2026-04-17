import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../config/ollama_config.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  VoidCallback? _onMessageComplete;

  static const String _systemPrompt = '''You are Jobseeker AI, a professional career assistant created to help job seekers with career guidance, interview preparation, resume optimization, salary negotiation, and professional development.

Your name is Jobseeker AI. You are a specialized career assistant.

Guidelines:
- ALWAYS respond using the same language as the user's input.
- Stay in character as a career assistant.
- Use the provided conversation history to maintain context.''';

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void setOnMessageComplete(VoidCallback callback) {
    _onMessageComplete = callback;
  }

  // Fungsi untuk membangun prompt dengan konteks yang "cerdas" (Ringan tapi tetap ingat tujuan)
  String _buildContextPrompt(String currentMessage) {
    StringBuffer prompt = StringBuffer();
    prompt.writeln("System: $_systemPrompt");
    prompt.writeln("\nConversation History:");
    
    // STRATEGI: Ambil 2 pesan awal (tujuan) + 8 pesan terakhir (aliran diskusi)
    List<Message> contextMessages = [];
    
    if (_messages.length > 10) {
      // Ambil 2 pertama (Penting untuk tahu topik utama diskusi)
      contextMessages.addAll(_messages.take(2));
      prompt.writeln("... (beberapa pesan sebelumnya disederhanakan) ...");
      // Ambil 8 terakhir (Penting untuk alur diskusi saat ini)
      // -1 karena pesan terakhir saat ini adalah placeholder AI yang sedang diproses
      contextMessages.addAll(_messages.sublist(_messages.length - 9, _messages.length - 1));
    } else {
      contextMessages.addAll(_messages.take(_messages.length - 1));
    }

    for (final msg in contextMessages) {
      prompt.writeln("${msg.isUser ? 'User' : 'Jobseeker AI'}: ${msg.text}");
    }

    prompt.writeln("\nCurrent User Question: $currentMessage");
    prompt.writeln("\nJobseeker AI:");

    // Limit context size untuk mencegah overflow (FIX: Minor issue #9)
    final fullPrompt = prompt.toString();
    if (fullPrompt.length > 3000) {
      debugPrint('Context size: ${fullPrompt.length} chars (exceeds recommended 3000)');
    }
    return fullPrompt;
  }

  Future<void> sendMessage(String userMessage) async {
    final userMsg = Message(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    final aiMsg = Message(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    int aiMsgIndex = _messages.length - 1;

    // FIX: Kritis #2 & Minor #8 - HTTP Client cleanup + Request timeout
    final client = http.Client();
    try {
      // Gunakan prompt yang sudah menyertakan riwayat percakapan
      final fullPrompt = _buildContextPrompt(userMessage);

      // FIX: Kritis #1 - Gunakan config untuk host yang fleksibel
      final ollamaUrl = OllamaConfig.getOllamaUrl();

      final request = http.Request(
        'POST',
        Uri.parse(ollamaUrl),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': OllamaConfig.modelName,
        'prompt': fullPrompt,
        'stream': true,
        'options': {
          'num_ctx': OllamaConfig.contextWindowSize,
          'temperature': OllamaConfig.temperature,
        }
      });

      // FIX: Minor #8 - Tambahkan timeout
      final response = await client
          .send(request)
          .timeout(
            Duration(seconds: OllamaConfig.requestTimeoutSeconds),
            onTimeout: () => throw Exception(
              'Ollama request timeout after ${OllamaConfig.requestTimeoutSeconds} seconds. '
              'Please check if Ollama is running.',
            ),
          );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();

        StringBuffer accumulatedText = StringBuffer();
        await response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
          if (line.trim().isNotEmpty) {
            try {
              final data = jsonDecode(line);
              final chunk = data['response'] ?? '';
              accumulatedText.write(chunk);
              
              _messages[aiMsgIndex] = Message(
                text: accumulatedText.toString(),
                isUser: false,
                timestamp: aiMsg.timestamp,
              );
              notifyListeners();
            } catch (e) {
              debugPrint('Error parsing chunk: $e');
            }
          }
        });
      } else {
        throw Exception('HTTP Status code: ${response.statusCode}');
      }
    } catch (e) {
      // FIX: Penting #5 - Better error handling dengan specific messages
      String errorMsg = _getDetailedErrorMessage(e);

      _messages[aiMsgIndex] = Message(
        text: errorMsg,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
    } finally {
      // FIX: Kritis #2 - Selalu tutup HTTP client (resource cleanup)
      client.close();
    }

    if (_onMessageComplete != null) {
      _onMessageComplete?.call();
    }
  }

  /// FIX: Penting #5 - Helper untuk generate detailed error messages
  String _getDetailedErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('timeout') || errorString.contains('Timeout')) {
      return '⏱️ Request timeout.\n\n'
          'Ollama might be busy or not responding.\n'
          'Try:\n'
          '1. Check if Ollama is running\n'
          '2. Run: ollama serve\n'
          '3. Ensure model is loaded: ollama run qwen2.5-coder:3b';
    } else if (error is SocketException) {
      return '🔌 Connection error.\n\n'
          'Cannot reach Ollama server.\n'
          'Try:\n'
          '1. Start Ollama: ollama serve\n'
          '2. Check if running on correct host/port\n'
          '3. Verify network connection';
    } else if (errorString.contains('404')) {
      return '❌ Model not found.\n\n'
          'The model qwen2.5-coder:3b is not available.\n'
          'Pull it first:\n'
          'ollama pull qwen2.5-coder:3b';
    } else if (errorString.contains('500')) {
      return '⚠️ Ollama server error.\n\n'
          'The server encountered an error.\n'
          'Try restarting Ollama:\n'
          '1. Kill the process\n'
          '2. Run: ollama serve again';
    } else if (errorString.contains('Connection refused')) {
      return '❌ Connection refused.\n\n'
          'Ollama is not running or not accessible.\n'
          'Start it with: ollama serve';
    }

    // Generic error (don't expose raw exception)
    return '❌ Error: Unable to get response.\n\n'
        'Please try again or check Ollama connection.\n'
        'Run: ollama serve';
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
