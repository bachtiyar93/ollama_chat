import 'package:flutter/foundation.dart';
import 'dart:io';

class OllamaConfig {
  /// Default hosts untuk berbagai environment
  static const String defaultLocalhost = 'localhost';
  static const String remoteServerHost = '192.168.0.208'; // Server PC Anda
  static const int defaultPort = 11434;
  static const String modelName = 'qwen2.5-coder:3b';
  static const int requestTimeoutSeconds = 300; // 5 menit
  static const int maxMessageLength = 10000; // 10KB
  static const int contextWindowSize = 4096;
  static const double temperature = 0.7;

  /// Cache untuk host yang terdeteksi
  static String? _detectedHost;
  static bool? _isRemoteServer;

  /// Reset cache (untuk testing atau force re-detection)
  static void resetCache() {
    _detectedHost = null;
    _isRemoteServer = null;
  }

  /// Check apakah server Ollama tersedia di host tertentu
  static Future<bool> _isServerAvailable(String host) async {
    if (kIsWeb) return true; // Web selalu anggap available

    try {
      final url = 'http://$host:$defaultPort/api/tags';
      final result = await Process.run('curl', ['-s', '--max-time', '5', url]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get the Ollama host address dengan auto-detection
  /// Prioritas: localhost -> remote server (192.168.0.208)
  static Future<String> getOllamaHost() async {
    // Return cached result jika sudah dideteksi
    if (_detectedHost != null) {
      return _detectedHost!;
    }

    if (kIsWeb) {
      // Web: gunakan current host atau fallback
      final currentHost = Uri.base.host;
      if (currentHost.isNotEmpty && currentHost != 'localhost') {
        _detectedHost = currentHost;
        _isRemoteServer = true;
        return currentHost;
      }
      _detectedHost = remoteServerHost;
      _isRemoteServer = true;
      return remoteServerHost;
    }

    // Desktop/Mobile: Coba localhost dulu
    if (await _isServerAvailable(defaultLocalhost)) {
      _detectedHost = defaultLocalhost;
      _isRemoteServer = false;
      return defaultLocalhost;
    }

    // Jika localhost tidak available, coba remote server
    if (await _isServerAvailable(remoteServerHost)) {
      _detectedHost = remoteServerHost;
      _isRemoteServer = true;
      return remoteServerHost;
    }

    // Fallback ke remote server jika tidak ada yang available
    // (untuk kasus dimana server belum start tapi kita tetap coba)
    _detectedHost = remoteServerHost;
    _isRemoteServer = true;
    return remoteServerHost;
  }

  /// Get full Ollama URL dengan auto-detection
  static Future<String> getOllamaUrl() async {
    final host = await getOllamaHost();
    return 'http://$host:$defaultPort/api/generate';
  }

  /// Get Ollama tags check URL dengan auto-detection
  static Future<String> getOllamaTagsUrl() async {
    final host = await getOllamaHost();
    return 'http://$host:$defaultPort/api/tags';
  }

  /// Check apakah menggunakan remote server
  static bool? get isUsingRemoteServer => _isRemoteServer;

  /// Get status server untuk debugging
  static Future<String> getServerStatus() async {
    final host = await getOllamaHost();
    final isAvailable = await _isServerAvailable(host);

    return 'Host: $host, Available: $isAvailable, Remote: ${_isRemoteServer ?? false}';
  }
}
