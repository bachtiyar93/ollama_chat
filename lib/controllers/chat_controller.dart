import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';

class ChatController {
  final ChatProvider chatProvider;

  ChatController(this.chatProvider);

  void sendMessage(String message, SettingsProvider settings) {
    final trimmed = message.trim();

    if (trimmed.isEmpty) {
      debugPrint('Message is empty');
      return;
    }

    // You might want to move maxMessageLength to settings or keep it as a constant
    if (trimmed.length > 10000) {
      debugPrint('Message too long');
      return;
    }

    chatProvider.sendMessage(trimmed, settings);
  }
}
