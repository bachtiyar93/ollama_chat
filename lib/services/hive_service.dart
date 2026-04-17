import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_config.dart';
import '../models/ai_provider.dart';
import '../models/theme_mode.dart';

class HiveService {
  static const String settingsBoxName = 'settingsBox';
  static const String historyBoxName = 'historyBox';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(AiProviderAdapter()); // Kita perlu buat ini di model
    Hive.registerAdapter(AppThemeModeAdapter()); // Kita perlu buat ini di model

    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<ChatMessage>(historyBoxName);
  }

  // Settings
  Future<AppSettings> getConfig() async {
    final box = Hive.box<AppSettings>(settingsBoxName);
    if (box.isEmpty) {
      final config = AppSettings();
      await box.put('current_config', config);
      return config;
    }
    return box.get('current_config')!;
  }

  Future<void> saveConfig(AppSettings config) async {
    final box = Hive.box<AppSettings>(settingsBoxName);
    await box.put('current_config', config);
  }

  // History
  Future<void> saveChatMessage(String text, bool isUser) async {
    final box = Hive.box<ChatMessage>(historyBoxName);
    final message = ChatMessage.create(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    await box.add(message);
  }

  Future<List<ChatMessage>> getChatHistory() async {
    final box = Hive.box<ChatMessage>(historyBoxName);
    return box.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> clearHistory() async {
    final box = Hive.box<ChatMessage>(historyBoxName);
    await box.clear();
  }
}
