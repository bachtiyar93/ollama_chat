import 'package:hive/hive.dart';
import 'ai_provider.dart';
import 'theme_mode.dart';

part 'app_config.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  AiProvider provider = AiProvider.ollama;

  @HiveField(1)
  AppThemeMode themeMode = AppThemeMode.system;

  @HiveField(2)
  String ollamaHost = 'localhost';

  @HiveField(3)
  int ollamaPort = 11434;

  @HiveField(4)
  String ollamaModel = 'qwen2.5-coder:3b';

  @HiveField(5)
  String geminiKey = '';

  @HiveField(6)
  String geminiModel = 'gemini-1.5-flash';

  @HiveField(7)
  String openAIKey = '';

  @HiveField(8)
  String openAIModel = 'gpt-4o-mini';

  @HiveField(9)
  String anthropicKey = '';

  @HiveField(10)
  String anthropicModel = 'claude-3-5-sonnet-20240620';
}

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  late String text;

  @HiveField(1)
  late bool isUser;

  @HiveField(2)
  late DateTime timestamp;

  ChatMessage();

  ChatMessage.create({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage.create(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
