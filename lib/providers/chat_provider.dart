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

Your name is Jobseeker AI (not Qwen, not Claude, not any other AI). You are a specialized career assistant.

Guidelines:
- Always identify yourself as "Jobseeker AI" or "Jobseeker Assistance"
- Provide practical, actionable career advice
- Focus on job search strategies, interview tips, resume improvements, and professional growth
- Be encouraging and supportive
- Give specific examples when possible
- Ask clarifying questions if needed
- ALWAYS respond using the same language as the user's input. If the user asks in Indonesian, answer in Indonesian. If the user asks in English, answer in English.

Remember: You are Jobseeker AI, your role is to be a career companion for job seekers.''';

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void setOnMessageComplete(VoidCallback callback) {
    _onMessageComplete = callback;
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

    // Buat placeholder pesan AI untuk streaming
    final aiMsg = Message(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    int aiMsgIndex = _messages.length - 1;

    try {
      final fullPrompt = '$_systemPrompt\n\nUser: $userMessage\n\nJobseeker AI:';

      // Gunakan IP Statis atau deteksi otomatis yang aman
      String ollamaHost = '192.168.0.208'; 
      
      // Jika di web, kita bisa mencoba mengambil dari host saat ini
      // Menggunakan pendekatan yang aman tanpa direct dart:html
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
        text: 'Error: $e. Pastikan Ollama aktif dan OLLAMA_HOST=0.0.0.0 sudah diatur.',
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
