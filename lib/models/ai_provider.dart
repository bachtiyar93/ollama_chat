import 'package:hive/hive.dart';

part 'ai_provider.g.dart';

@HiveType(typeId: 2)
enum AiProvider {
  @HiveField(0)
  ollama,
  @HiveField(1)
  gemini,
  @HiveField(2)
  openai,
  @HiveField(3)
  anthropic;

  String get displayName {
    switch (this) {
      case AiProvider.ollama: return 'Ollama';
      case AiProvider.gemini: return 'Google Gemini';
      case AiProvider.openai: return 'OpenAI';
      case AiProvider.anthropic: return 'Anthropic Claude';
    }
  }
}
