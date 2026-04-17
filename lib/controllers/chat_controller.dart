import 'package:flutter/material.dart';
import '../config/ollama_config.dart';
import '../providers/chat_provider.dart';

class ChatController {
  final ChatProvider chatProvider;

  ChatController(this.chatProvider);

  // FIX: Penting #6 - Input validation dengan limits
  void sendMessage(String message) {
    final trimmed = message.trim();

    // Validasi 1: Empty check
    if (trimmed.isEmpty) {
      debugPrint('Message is empty');
      return;
    }

    // Validasi 2: Length check (prevent DoS / memory issues)
    if (trimmed.length > OllamaConfig.maxMessageLength) {
      debugPrint('Message too long (${trimmed.length} > ${OllamaConfig.maxMessageLength} chars)');
      return;
    }

    // Validasi 3: Basic content check (optional - prevent spam)
    if (_isSpam(trimmed)) {
      debugPrint('Message appears to be spam (excessive repetition)');
      return;
    }

    chatProvider.sendMessage(trimmed);
  }

  /// Check jika message kemungkinan spam
  bool _isSpam(String message) {
    // Deteksi repetisi ekstrim (lebih dari 80% karakter sama)
    if (message.length < 5) return false;

    final charCounts = <String, int>{};
    for (final char in message.split('')) {
      charCounts[char] = (charCounts[char] ?? 0) + 1;
    }

    final maxCount = charCounts.values.fold<int>(0, (a, b) => a > b ? a : b);
    final spamRatio = maxCount / message.length;

    return spamRatio > 0.8; // 80% repetisi = spam
  }
}