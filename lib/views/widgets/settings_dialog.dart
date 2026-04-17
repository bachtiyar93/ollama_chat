import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/ai_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _ollamaHost;
  late TextEditingController _ollamaPort;
  late TextEditingController _ollamaModel;
  
  late TextEditingController _geminiKey;
  late TextEditingController _geminiModel;

  late TextEditingController _openaiKey;
  late TextEditingController _openaiModel;

  late TextEditingController _anthropicKey;
  late TextEditingController _anthropicModel;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _ollamaHost = TextEditingController(text: settings.ollamaHost);
    _ollamaPort = TextEditingController(text: settings.ollamaPort.toString());
    _ollamaModel = TextEditingController(text: settings.ollamaModel);

    _geminiKey = TextEditingController(text: settings.geminiKey);
    _geminiModel = TextEditingController(text: settings.geminiModel);

    _openaiKey = TextEditingController(text: settings.openAIKey);
    _openaiModel = TextEditingController(text: settings.openAIModel);

    _anthropicKey = TextEditingController(text: settings.anthropicKey);
    _anthropicModel = TextEditingController(text: settings.anthropicModel);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings, size: 24),
          SizedBox(width: 12),
          Text('Settings'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Section
              const _SectionHeader(title: 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              const Divider(),

              // Provider Selection
              const _SectionHeader(title: 'AI Provider'),
              DropdownButtonFormField<AiProvider>(
                value: settings.provider,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: AiProvider.values.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.displayName));
                }).toList(),
                onChanged: (val) {
                  if (val != null) settings.setProvider(val);
                },
              ),
              const SizedBox(height: 16),

              // Conditional Forms
              if (settings.provider == AiProvider.ollama) _buildOllamaForm(),
              if (settings.provider == AiProvider.gemini) _buildGeminiForm(),
              if (settings.provider == AiProvider.openai) _buildOpenAIForm(),
              if (settings.provider == AiProvider.anthropic) _buildAnthropicForm(),

              const SizedBox(height: 20),
              
              // Connection Test Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: settings.isCheckingConnection ? null : () async {
                    _saveSpecificSettings(settings);
                    final success = await settings.checkConnection();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '✅ Connection Successful!' : '❌ Connection Failed!'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  icon: settings.isCheckingConnection 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bolt),
                  label: const Text('Test & Save'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  void _saveSpecificSettings(SettingsProvider settings) {
    switch (settings.provider) {
      case AiProvider.ollama:
        settings.updateOllama(_ollamaHost.text, int.tryParse(_ollamaPort.text) ?? 11434, _ollamaModel.text);
        break;
      case AiProvider.gemini:
        settings.updateGemini(_geminiKey.text, _geminiModel.text);
        break;
      case AiProvider.openai:
        settings.updateOpenAI(_openaiKey.text, _openaiModel.text);
        break;
      case AiProvider.anthropic:
        settings.updateAnthropic(_anthropicKey.text, _anthropicModel.text);
        break;
    }
  }

  Widget _buildOllamaForm() {
    return Column(
      children: [
        TextField(controller: _ollamaHost, decoration: const InputDecoration(labelText: 'Host (e.g. 192.168.1.5)')),
        TextField(controller: _ollamaPort, decoration: const InputDecoration(labelText: 'Port (default 11434)')),
        TextField(controller: _ollamaModel, decoration: const InputDecoration(labelText: 'Model Name')),
      ],
    );
  }

  Widget _buildGeminiForm() {
    return Column(
      children: [
        TextField(controller: _geminiKey, decoration: const InputDecoration(labelText: 'Google API Key'), obscureText: true),
        TextField(controller: _geminiModel, decoration: const InputDecoration(labelText: 'Model (gemini-1.5-flash)')),
      ],
    );
  }

  Widget _buildOpenAIForm() {
    return Column(
      children: [
        TextField(controller: _openaiKey, decoration: const InputDecoration(labelText: 'OpenAI API Key'), obscureText: true),
        TextField(controller: _openaiModel, decoration: const InputDecoration(labelText: 'Model (gpt-4o-mini)')),
      ],
    );
  }

  Widget _buildAnthropicForm() {
    return Column(
      children: [
        TextField(controller: _anthropicKey, decoration: const InputDecoration(labelText: 'Anthropic API Key'), obscureText: true),
        TextField(controller: _anthropicModel, decoration: const InputDecoration(labelText: 'Model (claude-3-5-sonnet)')),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
      ),
    );
  }
}
