import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/ai_provider.dart';
import '../../models/theme_mode.dart';
import '../../services/gemini_service.dart';

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

  // State for dynamic Gemini models
  List<String> _geminiAvailableModels = [];
  bool _isLoadingGeminiModels = false;
  String? _geminiModelsError;

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

    // Load Gemini models if provider is Gemini and API key is available
    if (settings.provider == AiProvider.gemini && settings.geminiKey.isNotEmpty) {
      _loadGeminiModels();
    }
  }

  @override
  void dispose() {
    _ollamaHost.dispose();
    _ollamaPort.dispose();
    _ollamaModel.dispose();
    _geminiKey.dispose();
    _geminiModel.dispose();
    _openaiKey.dispose();
    _openaiModel.dispose();
    _anthropicKey.dispose();
    _anthropicModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();

    // Load Gemini models if provider is Gemini, API key is set, and models not loaded yet
    if (settings.provider == AiProvider.gemini && _geminiKey.text.isNotEmpty && _geminiAvailableModels.isEmpty && !_isLoadingGeminiModels) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadGeminiModels());
    }

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
              const SizedBox(height: 8),
              SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: AppThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (Set<AppThemeMode> newSelection) {
                  themeProvider.setThemeMode(newSelection.first);
                },
              ),
              const SizedBox(height: 16),
              const Divider(),

              // Provider Selection
              const _SectionHeader(title: 'AI Provider'),
              DropdownButtonFormField<AiProvider>(
                initialValue: settings.provider,
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

              // Debug button for Gemini (only show when Gemini is selected)
              if (settings.provider == AiProvider.gemini && _geminiKey.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final geminiService = context.read<GeminiService>();
                        final models = await geminiService.getModelsSupportingGenerateContent(_geminiKey.text);
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Available Gemini Models'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Models supporting generateContent:'),
                                    const SizedBox(height: 8),
                                    ...models.map((model) => Text('• $model')),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to list models: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('List Available Models'),
                  ),
                ),
              ],

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
        // Validate and fix invalid Gemini model
        final validModel = _getValidGeminiModel(_geminiModel.text) ?? 'gemini-1.5-flash';
        settings.updateGemini(_geminiKey.text, validModel);
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
        DropdownButtonFormField<String>(
          initialValue: _getValidOllamaModel(_ollamaModel.text),
          decoration: const InputDecoration(labelText: 'Model Name'),
          items: _getOllamaModels().map((model) {
            return DropdownMenuItem(value: model, child: Text(model));
          }).toList(),
          onChanged: (value) {
            if (value != null) _ollamaModel.text = value;
          },
        ),
      ],
    );
  }

  Widget _buildGeminiForm() {
    final availableModels = _geminiAvailableModels.isNotEmpty ? _geminiAvailableModels : _getFallbackGeminiModels();

    return Column(
      children: [
        TextField(controller: _geminiKey, decoration: const InputDecoration(labelText: 'Google API Key'), obscureText: true),
        DropdownButtonFormField<String>(
          initialValue: _getValidGeminiModel(_geminiModel.text),
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Model'),
          items: availableModels.map((model) {
            return DropdownMenuItem(value: model, child: Text(model));
          }).toList(),
          onChanged: (value) {
            if (value != null) _geminiModel.text = value;
          },
        ),
        // Show error message if there's an error loading models
        if (_geminiModelsError != null) ...[
          const SizedBox(height: 8),
          Text(_geminiModelsError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  String? _getValidGeminiModel(String currentModel) {
    final availableModels = _geminiAvailableModels.isNotEmpty ? _geminiAvailableModels : _getFallbackGeminiModels();
    if (availableModels.contains(currentModel)) {
      return currentModel;
    }
    return availableModels.isNotEmpty ? availableModels.first : null;
  }

  List<String> _getFallbackGeminiModels() {
    return [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-pro',
      'gemini-pro-vision',
    ];
  }

  Widget _buildOpenAIForm() {
    return Column(
      children: [
        TextField(controller: _openaiKey, decoration: const InputDecoration(labelText: 'OpenAI API Key'), obscureText: true),
        DropdownButtonFormField<String>(
          initialValue: _getValidOpenAIModel(_openaiModel.text),
          decoration: const InputDecoration(labelText: 'Model'),
          items: _getOpenAIModels().map((model) {
            return DropdownMenuItem(value: model, child: Text(model));
          }).toList(),
          onChanged: (value) {
            if (value != null) _openaiModel.text = value;
          },
        ),
      ],
    );
  }

  Widget _buildAnthropicForm() {
    return Column(
      children: [
        TextField(controller: _anthropicKey, decoration: const InputDecoration(labelText: 'Anthropic API Key'), obscureText: true),
        DropdownButtonFormField<String>(
          initialValue: _getValidAnthropicModel(_anthropicModel.text),
          decoration: const InputDecoration(labelText: 'Model'),
          items: _getAnthropicModels().map((model) {
            return DropdownMenuItem(value: model, child: Text(model));
          }).toList(),
          onChanged: (value) {
            if (value != null) _anthropicModel.text = value;
          },
        ),
      ],
    );
  }

  String? _getValidOllamaModel(String currentModel) {
    final availableModels = _getOllamaModels();
    if (availableModels.contains(currentModel)) {
      return currentModel;
    }
    return availableModels.isNotEmpty ? availableModels.first : null;
  }

  String? _getValidOpenAIModel(String currentModel) {
    final availableModels = _getOpenAIModels();
    if (availableModels.contains(currentModel)) {
      return currentModel;
    }
    return availableModels.isNotEmpty ? availableModels.first : null;
  }

  String? _getValidAnthropicModel(String currentModel) {
    final availableModels = _getAnthropicModels();
    if (availableModels.contains(currentModel)) {
      return currentModel;
    }
    return availableModels.isNotEmpty ? availableModels.first : null;
  }

  List<String> _getOllamaModels() {
    return [
      'qwen2.5-coder:3b',
      'qwen2.5-coder:7b',
      'qwen2.5-coder:14b',
      'llama2:7b',
      'llama2:13b',
      'llama2:70b',
      'mistral:7b',
      'codellama:7b',
      'codellama:13b',
      'codellama:34b',
      'deepseek-coder:6.7b',
      'deepseek-coder:33b',
      'phi3:3.8b',
      'gemma:2b',
      'gemma:7b',
    ];
  }

  List<String> _getOpenAIModels() {
    return [
      'gpt-4o-mini',
      'gpt-4o',
      'gpt-4-turbo',
      'gpt-4',
      'gpt-3.5-turbo',
      'gpt-3.5-turbo-16k',
    ];
  }

  List<String> _getAnthropicModels() {
    return [
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-opus-20240229',
      'claude-3-sonnet-20240229',
      'claude-3-haiku-20240307',
    ];
  }

  void _loadGeminiModels() async {
    setState(() {
      _isLoadingGeminiModels = true;
      _geminiModelsError = null;
    });
    try {
      final geminiService = context.read<GeminiService>();
      final models = await geminiService.getModelsSupportingGenerateContent(_geminiKey.text);
      if (context.mounted) {
        setState(() {
          _geminiAvailableModels = models;
          _geminiModel.text = _getValidGeminiModel(_geminiModel.text) ?? '';
        });
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _geminiModelsError = 'Failed to load models: $e';
        });
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoadingGeminiModels = false;
        });
      }
    }
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
