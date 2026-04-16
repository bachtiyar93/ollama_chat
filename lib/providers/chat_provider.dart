import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  VoidCallback? _onMessageComplete;

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

    try {
      final response = await http.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'qwen2.5-coder:3b',
          'prompt': userMessage,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = Message(
          text: data['response'],
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      } else {
        final errorMessage = Message(
          text: 'Error: ${response.statusCode}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
      }
    } catch (e) {
      final errorMessage = Message(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    }

    _isLoading = false;
    notifyListeners();

    // Call callback to focus the input field
    _onMessageComplete?.call();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
