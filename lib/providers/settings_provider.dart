import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';

class SettingsProvider with ChangeNotifier {
  // Current Active Provider
  AiProvider _provider = AiProvider.ollama;

  // Ollama Settings
  String _ollamaHost = 'localhost';
  int _ollamaPort = 11434;
  String _ollamaModel = 'qwen2.5-coder:3b';

  // API Keys & Models
  String _geminiKey = '';
  String _geminiModel = 'gemini-1.5-flash';
  
  String _openAIKey = '';
  String _openAIModel = 'gpt-4o-mini';

  String _anthropicKey = '';
  String _anthropicModel = 'claude-3-5-sonnet-20240620';

  bool _isCheckingConnection = false;
  bool? _lastConnectionStatus;

  // Getters
  AiProvider get provider => _provider;
  String get ollamaHost => _ollamaHost;
  int get ollamaPort => _ollamaPort;
  String get ollamaModel => _ollamaModel;
  
  String get geminiKey => _geminiKey;
  String get geminiModel => _geminiModel;
  
  String get openAIKey => _openAIKey;
  String get openAIModel => _openAIModel;
  
  String get anthropicKey => _anthropicKey;
  String get anthropicModel => _anthropicModel;

  bool get isCheckingConnection => _isCheckingConnection;
  bool? get lastConnectionStatus => _lastConnectionStatus;

  // Helper Getters for Active Config
  String get activeModel {
    switch (_provider) {
      case AiProvider.ollama: return _ollamaModel;
      case AiProvider.gemini: return _geminiModel;
      case AiProvider.openai: return _openAIModel;
      case AiProvider.anthropic: return _anthropicModel;
    }
  }

  String get ollamaBaseUrl => 'http://$_ollamaHost:$_ollamaPort';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _provider = AiProvider.values[prefs.getInt('ai_provider') ?? 0];
    
    _ollamaHost = prefs.getString('ollama_host') ?? 'localhost';
    _ollamaPort = prefs.getInt('ollama_port') ?? 11434;
    _ollamaModel = prefs.getString('ollama_model') ?? 'qwen2.5-coder:3b';

    _geminiKey = prefs.getString('gemini_key') ?? '';
    _geminiModel = prefs.getString('gemini_model') ?? 'gemini-1.5-flash';

    _openAIKey = prefs.getString('openai_key') ?? '';
    _openAIModel = prefs.getString('openai_model') ?? 'gpt-4o-mini';

    _anthropicKey = prefs.getString('anthropic_key') ?? '';
    _anthropicModel = prefs.getString('anthropic_model') ?? 'claude-3-5-sonnet-20240620';
    
    notifyListeners();
  }

  Future<void> setProvider(AiProvider provider) async {
    _provider = provider;
    _lastConnectionStatus = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ai_provider', provider.index);
    notifyListeners();
  }

  // Setters with persistence
  Future<void> updateOllama(String host, int port, String model) async {
    _ollamaHost = host;
    _ollamaPort = port;
    _ollamaModel = model;
    _lastConnectionStatus = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ollama_host', host);
    await prefs.setInt('ollama_port', port);
    await prefs.setString('ollama_model', model);
    notifyListeners();
  }

  Future<void> updateGemini(String key, String model) async {
    _geminiKey = key;
    _geminiModel = model;
    _lastConnectionStatus = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_key', key);
    await prefs.setString('gemini_model', model);
    notifyListeners();
  }

  Future<void> updateOpenAI(String key, String model) async {
    _openAIKey = key;
    _openAIModel = model;
    _lastConnectionStatus = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_key', key);
    await prefs.setString('openai_model', model);
    notifyListeners();
  }

  Future<void> updateAnthropic(String key, String model) async {
    _anthropicKey = key;
    _anthropicModel = model;
    _lastConnectionStatus = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anthropic_key', key);
    await prefs.setString('anthropic_model', model);
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    _isCheckingConnection = true;
    _lastConnectionStatus = null;
    notifyListeners();

    try {
      bool success = false;
      switch (_provider) {
        case AiProvider.ollama:
          final response = await http.get(Uri.parse('$ollamaBaseUrl/api/tags')).timeout(const Duration(seconds: 5));
          success = response.statusCode == 200;
          break;
        case AiProvider.gemini:
          // Simple check for Gemini (usually needs a valid key to even hit the models endpoint)
          final response = await http.get(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_geminiKey'));
          success = response.statusCode == 200;
          break;
        case AiProvider.openai:
          final response = await http.get(
            Uri.parse('https://api.openai.com/v1/models'),
            headers: {'Authorization': 'Bearer $_openAIKey'},
          );
          success = response.statusCode == 200;
          break;
        case AiProvider.anthropic:
          // Anthropic doesn't have a simple public "check" without a full request or specific headers
          success = _anthropicKey.isNotEmpty; 
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
