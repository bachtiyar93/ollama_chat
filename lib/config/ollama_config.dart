import 'package:flutter/foundation.dart';

class OllamaConfig {
  /// Default hosts untuk berbagai environment
  static const String defaultLocalhost = 'localhost';
  static const String fallbackHost = '192.168.0.208';
  static const int defaultPort = 11434;
  static const String modelName = 'qwen2.5-coder:3b';
  static const int requestTimeoutSeconds = 300; // 5 menit
  static const int maxMessageLength = 10000; // 10KB
  static const int contextWindowSize = 4096;
  static const double temperature = 0.7;

  /// Get the Ollama host address berdasarkan platform
  static String getOllamaHost() {
    if (kIsWeb) {
      // Web: gunakan current host atau fallback
      final currentHost = Uri.base.host;
      if (currentHost.isNotEmpty && currentHost != 'localhost') {
        return currentHost;
      }
      return fallbackHost;
    }

    // Desktop: gunakan localhost sebagai prioritas
    // (asumsi Ollama berjalan di local machine)
    return defaultLocalhost;
  }

  /// Get full Ollama URL
  static String getOllamaUrl() {
    final host = getOllamaHost();
    return 'http://$host:$defaultPort/api/generate';
  }

  /// Get Ollama tags check URL
  static String getOllamaTagsUrl() {
    final host = getOllamaHost();
    return 'http://$host:$defaultPort/api/tags';
  }
}

