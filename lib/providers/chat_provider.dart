import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/ai_provider.dart';
import 'settings_provider.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  String _summary = '';
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

  List<Map<String, String>> _buildChatMessages(String currentMessage) {
    List<Map<String, String>> chatMessages = [];
    chatMessages.add({'role': 'system', 'content': _systemPrompt});

    if (_summary.isNotEmpty) {
      chatMessages.add({
        'role': 'system',
        'content': 'Summary of previous conversation: $_summary'
      });
    }

    int start = _messages.length > 11 ? _messages.length - 11 : 0;
    List<Message> recentMessages = _messages.sublist(start, _messages.isNotEmpty ? _messages.length - 1 : 0);

    for (final msg in recentMessages) {
      chatMessages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    chatMessages.add({'role': 'user', 'content': currentMessage});
    return chatMessages;
  }

  Future<void> sendMessage(String userMessage, SettingsProvider settings) async {
    final userMsg = Message(text: userMessage, isUser: true, timestamp: DateTime.now());
    _messages.add(userMsg);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    final aiMsg = Message(text: '', isUser: false, timestamp: DateTime.now());
    _messages.add(aiMsg);
    int aiMsgIndex = _messages.length - 1;

    try {
      switch (settings.provider) {
        case AiProvider.ollama:
          await _sendOllamaRequest(userMessage, settings, aiMsgIndex);
          break;
        case AiProvider.gemini:
          await _sendGeminiRequest(userMessage, settings, aiMsgIndex);
          break;
        case AiProvider.openai:
          await _sendOpenAIRequest(userMessage, settings, aiMsgIndex);
          break;
        case AiProvider.anthropic:
          await _sendAnthropicRequest(userMessage, settings, aiMsgIndex);
          break;
      }

      if (_messages.length % 15 == 0) {
        _generateSummary(settings);
      }
    } catch (e) {
      _messages[aiMsgIndex] = Message(
        text: '❌ Error: ${e.toString()}',
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

  Future<void> _sendOllamaRequest(String userMessage, SettingsProvider settings, int aiMsgIndex) async {
    final chatMessages = _buildChatMessages(userMessage);
    final response = await http.Client().send(http.Request('POST', Uri.parse("${settings.ollamaBaseUrl}/api/chat"))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': settings.ollamaModel,
        'messages': chatMessages,
        'stream': true,
      }));

    if (response.statusCode == 200) {
      _isLoading = false;
      notifyListeners();
      StringBuffer accumulatedText = StringBuffer();
      await response.stream.transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
        if (line.isNotEmpty) {
          final data = jsonDecode(line);
          final chunk = data['message']?['content'] ?? '';
          accumulatedText.write(chunk);
          _messages[aiMsgIndex] = Message(text: accumulatedText.toString(), isUser: false, timestamp: DateTime.now());
          notifyListeners();
        }
      });
    } else {
      throw Exception('Ollama error: ${response.statusCode}');
    }
  }

  Future<void> _sendGeminiRequest(String userMessage, SettingsProvider settings, int aiMsgIndex) async {
    final url = "https://generativelanguage.googleapis.com/v1beta/models/${settings.geminiModel}:streamGenerateContent?key=${settings.geminiKey}";
    
    // Gemini uses a different message structure
    final contents = _messages.take(_messages.length - 1).map((m) => {
      'role': m.isUser ? 'user' : 'model',
      'parts': [{'text': m.text}]
    }).toList();

    final response = await http.post(Uri.parse(url), body: jsonEncode({'contents': contents}));

    if (response.statusCode == 200) {
      _isLoading = false;
      final List<dynamic> data = jsonDecode(response.body);
      String fullText = "";
      for (var part in data) {
        fullText += part['candidates'][0]['content']['parts'][0]['text'];
      }
      _messages[aiMsgIndex] = Message(text: fullText, isUser: false, timestamp: DateTime.now());
      notifyListeners();
    } else {
      throw Exception('Gemini error: ${response.body}');
    }
  }

  Future<void> _sendOpenAIRequest(String userMessage, SettingsProvider settings, int aiMsgIndex) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.openAIKey}',
      },
      body: jsonEncode({
        'model': settings.openAIModel,
        'messages': _buildChatMessages(userMessage),
      }),
    );

    if (response.statusCode == 200) {
      _isLoading = false;
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      _messages[aiMsgIndex] = Message(text: content, isUser: false, timestamp: DateTime.now());
      notifyListeners();
    } else {
      throw Exception('OpenAI error: ${response.body}');
    }
  }

  Future<void> _sendAnthropicRequest(String userMessage, SettingsProvider settings, int aiMsgIndex) async {
    // Implement Anthropic API call here (similar to OpenAI)
    _isLoading = false;
    _messages[aiMsgIndex] = Message(text: "Claude support coming soon!", isUser: false, timestamp: DateTime.now());
    notifyListeners();
  }

  Future<void> _generateSummary(SettingsProvider settings) async {
    // Summary logic remains similar, ideally using the current active provider
  }

  void clearMessages() {
    _messages.clear();
    _summary = '';
    notifyListeners();
  }
}
