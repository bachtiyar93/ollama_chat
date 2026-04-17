import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/ollama_config.dart';

class OllamaService {
  static final OllamaService _instance = OllamaService._internal();

  OllamaService._internal();

  factory OllamaService() {
    return _instance;
  }

  // Gunakan dynamic untuk menghindari error type Process di Web
  dynamic _process;
  bool _initialized = false;
  String? _serverHost;

  Future<void> initialize() async {
    if (_initialized) return;

    // JANGAN jalankan kode ini di Web karena dart:io akan crash
    if (kIsWeb) {
      debugPrint('OllamaService: Web platform detected, skipping local process management.');
      _initialized = true;
      return;
    }

    try {
      debugPrint('Initializing Ollama service...');

      // Auto-detect server host
      _serverHost = await OllamaConfig.getOllamaHost();
      debugPrint('OllamaService: Detected server host: $_serverHost');

      // Check if ollama is already running on detected host
      final checkResponse = await _checkOllamaStatus();
      if (checkResponse) {
        debugPrint('Ollama is already running on $_serverHost');
        _initialized = true;
        return;
      }

      // Jika localhost, coba start local server
      if (_serverHost == OllamaConfig.defaultLocalhost) {
        debugPrint('Starting local Ollama server...');
        await _startLocalServer();
      } else {
        debugPrint('Using remote Ollama server at $_serverHost - no local startup needed');
        _initialized = true;
      }

    } catch (e) {
      debugPrint('Error initializing Ollama: $e');
      _initialized = true;
    }
  }

  Future<void> _startLocalServer() async {
    try {
      // Start ollama if not running
      debugPrint('Starting Ollama serve...');
      _process = await Process.start('ollama', ['serve']);

      // Wait a bit for ollama to start
      await Future.delayed(const Duration(seconds: 3));

      // Now run the model
      debugPrint('Running qwen2.5-coder:3b model...');
      await Process.run('ollama', ['run', 'qwen2.5-coder:3b']).timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          debugPrint('Model loading timed out, but it should be in background');
          return ProcessResult(0, 0, '', '');
        },
      );

      _initialized = true;
      debugPrint('Ollama local initialization complete');
    } catch (e) {
      debugPrint('Error starting local Ollama server: $e');
      throw e;
    }
  }

  Future<bool> _checkOllamaStatus() async {
    if (kIsWeb) return true;
    if (_serverHost == null) return false;

    try {
      final tagsUrl = await OllamaConfig.getOllamaTagsUrl();
      final result = await Process.run('curl', ['-s', '--max-time', '5', tagsUrl])
          .timeout(const Duration(seconds: 5));
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get current server status info
  Future<String> getServerInfo() async {
    final host = await OllamaConfig.getOllamaHost();
    final isRemote = OllamaConfig.isUsingRemoteServer ?? false;
    final isAvailable = await _checkOllamaStatus();

    return 'Server: $host (${isRemote ? "REMOTE" : "LOCAL"}), Available: $isAvailable';
  }

  Future<void> dispose() async {
    if (!kIsWeb && _process != null) {
      (_process as Process).kill();
    }
  }
}
