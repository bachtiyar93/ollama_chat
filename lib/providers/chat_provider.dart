import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/message.dart';

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
    return prompt.toString();
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

    try {
      // Gunakan prompt yang sudah menyertakan riwayat percakapan
      final fullPrompt = _buildContextPrompt(userMessage);

      String ollamaHost = '192.168.0.208'; 
      if (kIsWeb) {
        ollamaHost = Uri.base.host.isNotEmpty && Uri.base.host != 'localhost' 
            ? Uri.base.host 
            : '192.168.0.208';
      }

      final client = http.Client();
      final request = http.Request(
        'POST',
        Uri.parse('http://$ollamaHost:11434/api/generate'),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'qwen2.5-coder:3b',
        'prompt': fullPrompt,
        'stream': true,
        'options': {
          'num_ctx': 4096, // Memperbesar context window
          'temperature': 0.7,
        }
      });

      final response = await client.send(request);

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
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      _messages[aiMsgIndex] = Message(
        text: 'Error: $e. Pastikan Ollama aktif.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
    }

    if (_onMessageComplete != null) {
      _onMessageComplete?.call();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
