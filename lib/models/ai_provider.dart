enum AiProvider {
  ollama,
  gemini,
  openai,
  anthropic,
}

extension AiProviderExtension on AiProvider {
  String get displayName {
    switch (this) {
      case AiProvider.ollama: return 'Ollama (Local)';
      case AiProvider.gemini: return 'Google Gemini';
      case AiProvider.openai: return 'OpenAI (ChatGPT)';
      case AiProvider.anthropic: return 'Anthropic (Claude)';
    }
  }
}
