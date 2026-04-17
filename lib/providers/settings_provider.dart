import 'package:flutter/material.dart';
import '../models/ai_provider.dart';
import '../models/theme_mode.dart';
import '../models/app_config.dart';
import '../services/hive_service.dart';
import 'package:http/http.dart' as http;

class SettingsProvider with ChangeNotifier {
  final HiveService _hiveService;
  AppSettings _config = AppSettings();
  
  bool _isCheckingConnection = false;
  bool? _lastConnectionStatus;

  SettingsProvider(this._hiveService);

  AiProvider get provider => _config.provider;
  AppThemeMode get themeMode => _config.themeMode;
  
  String get ollamaHost => _config.ollamaHost;
  int get ollamaPort => _config.ollamaPort;
  String get ollamaModel => _config.ollamaModel;
  
  String get geminiKey => _config.geminiKey;
  String get geminiModel => _config.geminiModel;
  
  String get openAIKey => _config.openAIKey;
  String get openAIModel => _config.openAIModel;
  
  String get anthropicKey => _config.anthropicKey;
  String get anthropicModel => _config.anthropicModel;

  bool get isCheckingConnection => _isCheckingConnection;
  bool? get lastConnectionStatus => _lastConnectionStatus;

  String get activeModel {
    switch (provider) {
      case AiProvider.ollama: return ollamaModel;
      case AiProvider.gemini: return geminiModel;
      case AiProvider.openai: return openAIModel;
      case AiProvider.anthropic: return anthropicModel;
    }
  }

  String get ollamaBaseUrl => 'http://$ollamaHost:$ollamaPort';

  Future<void> loadSettings() async {
    _config = await _hiveService.getConfig();
    notifyListeners();
  }

  Future<void> setProvider(AiProvider provider) async {
    _config.provider = provider;
    _lastConnectionStatus = null;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _config.themeMode = mode;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<void> updateOllama(String host, int port, String model) async {
    _config.ollamaHost = host;
    _config.ollamaPort = port;
    _config.ollamaModel = model;
    _lastConnectionStatus = null;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<void> updateGemini(String key, String model) async {
    _config.geminiKey = key;
    _config.geminiModel = model;
    _lastConnectionStatus = null;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<void> updateOpenAI(String key, String model) async {
    _config.openAIKey = key;
    _config.openAIModel = model;
    _lastConnectionStatus = null;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<void> updateAnthropic(String key, String model) async {
    _config.anthropicKey = key;
    _config.anthropicModel = model;
    _lastConnectionStatus = null;
    await _hiveService.saveConfig(_config);
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    _isCheckingConnection = true;
    _lastConnectionStatus = null;
    notifyListeners();

    try {
      bool success = false;
      switch (provider) {
        case AiProvider.ollama:
          final response = await http.get(Uri.parse('$ollamaBaseUrl/api/tags')).timeout(const Duration(seconds: 5));
          success = response.statusCode == 200;
          break;
        case AiProvider.gemini:
          final response = await http.get(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$geminiKey'));
          success = response.statusCode == 200;
          break;
        case AiProvider.openai:
          final response = await http.get(
            Uri.parse('https://api.openai.com/v1/models'),
            headers: {'Authorization': 'Bearer $openAIKey'},
          );
          success = response.statusCode == 200;
          break;
        case AiProvider.anthropic:
          success = anthropicKey.isNotEmpty;
          break;
      }
      
      _lastConnectionStatus = success;
      _isCheckingConnection = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastConnectionStatus = false;
      _isCheckingConnection = false;
      notifyListeners();
      return false;
    }
  }
}
