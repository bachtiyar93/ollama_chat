import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/hive_service.dart';
import '../services/ollama_service.dart';
import '../services/gemini_service.dart';
import '../services/openai_service.dart';
import '../models/ai_provider.dart';
import 'settings_provider.dart';

class ChatProvider with ChangeNotifier {
  final HiveService _hiveService;
  final OllamaService _ollamaService;
  final GeminiService _geminiService;
  final OpenAIService _openAIService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider(
    this._hiveService,
    this._ollamaService,
    this._geminiService,
    this._openAIService,
  );

  Future<void> loadHistory() async {
    _messages = await _hiveService.getChatHistory();
    notifyListeners();
  }

  Future<void> sendMessage(String text, SettingsProvider settings) async {
    if (text.trim().isEmpty) return;

    // 1. Simpan & Tampilkan pesan User
    final userMsg = ChatMessage.create(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    await _hiveService.saveChatMessage(text, true);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      String responseText = '';
      ChatMessage? streamingMessage;

      // 2. Kirim ke Provider yang sesuai dengan streaming support
      switch (settings.provider) {
        case AiProvider.ollama:
          // Create initial empty AI message for streaming
          streamingMessage = ChatMessage.create(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(streamingMessage);

          await _ollamaService.generateStreamingResponse(
            text,
            settings.ollamaBaseUrl,
            settings.ollamaModel,
            (chunk) {
              responseText += chunk;
              // Update the streaming message in real-time
              if (streamingMessage != null) {
                final updatedMessage = streamingMessage.copyWith(text: responseText);
                final index = _messages.indexOf(streamingMessage);
                if (index != -1) {
                  _messages[index] = updatedMessage;
                  notifyListeners();
                }
              }
            },
          );
          break;
        case AiProvider.gemini:
          responseText = await _geminiService.generateResponse(
            text,
            settings.geminiKey,
            settings.geminiModel,
          );
          break;
        case AiProvider.openai:
          responseText = await _openAIService.generateResponse(
            text,
            settings.openAIKey,
            settings.openAIModel,
          );
          break;
        case AiProvider.anthropic:
          responseText = "Anthropic support coming soon...";
          break;
      }

      // For non-streaming providers, add the message after completion
      if (settings.provider != AiProvider.ollama) {
        final aiMsg = ChatMessage.create(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMsg);
      }
      
      // Save the final response
      await _hiveService.saveChatMessage(responseText, false);
      
    } catch (e) {
      final errorMsg = ChatMessage.create(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMsg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    await _hiveService.clearHistory();
    _messages.clear();
    notifyListeners();
  }
}
