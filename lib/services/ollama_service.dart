import 'dart:io';
import 'package:flutter/foundation.dart';

class OllamaService {
  static final OllamaService _instance = OllamaService._internal();

  OllamaService._internal();

  factory OllamaService() {
    return _instance;
  }

  // Gunakan dynamic untuk menghindari error type Process di Web
  dynamic _process;
  bool _initialized = false;

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

      // Check if ollama is already running
      final checkResponse = await _checkOllamaStatus();
      if (checkResponse) {
        debugPrint('Ollama is already running');
        _initialized = true;
        return;
      }

      // Start ollama if not running
      debugPrint('Starting Ollama...');
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
      debugPrint('Ollama initialization complete');
    } catch (e) {
      debugPrint('Error initializing Ollama: $e');
      _initialized = true;
    }
  }

  Future<bool> _checkOllamaStatus() async {
    if (kIsWeb) return true;
    try {
      final result = await Process.run('curl', ['-s', 'http://localhost:11434/api/tags'])
          .timeout(const Duration(seconds: 5));
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> dispose() async {
    if (!kIsWeb && _process != null) {
      (_process as Process).kill();
    }
  }
}
