import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final host = prefs.getString('ollama_host') ?? 'localhost';
      final model = prefs.getString('ollama_model') ?? 'qwen2.5-coder:3b';
      
      debugPrint('Initializing Ollama service with host: $host');

      // Check if ollama is already running
      final isRunning = await _checkOllamaStatus(host);
      if (isRunning) {
        debugPrint('Ollama is already running on $host');
        _initialized = true;
        return;
      }

      // Jika localhost, coba start local server
      if (host == 'localhost' || host == '127.0.0.1') {
        debugPrint('Starting local Ollama server...');
        await _startLocalServer(model);
      } else {
        debugPrint('Using remote Ollama server at $host - no local startup needed');
        _initialized = true;
      }

    } catch (e) {
      debugPrint('Error initializing Ollama: $e');
      _initialized = true;
    }
  }

  Future<void> _startLocalServer(String model) async {
    try {
      // Start ollama if not running
      debugPrint('Starting Ollama serve...');
      _process = await Process.start('ollama', ['serve']);

      // Wait a bit for ollama to start
      await Future.delayed(const Duration(seconds: 3));

      // Now run the model
      debugPrint('Running $model model...');
      await Process.run('ollama', ['run', model]).timeout(
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
    }
  }

  Future<bool> _checkOllamaStatus(String host) async {
    if (kIsWeb) return true;

    try {
      // Menggunakan Socket.connect lebih reliable daripada curl untuk cek port
      final socket = await Socket.connect(host, 11434, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
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
