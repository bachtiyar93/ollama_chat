import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:clipboard/clipboard.dart';

class CodeWrapper extends StatelessWidget {
  final String text;

  const CodeWrapper({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Extract code from ``` blocks if present
    String code = text;
    String language = 'dart'; // Default

    final codeBlockRegex = RegExp(r'```(\w+)?\n?(.*?)\n?```', dotAll: true);
    final match = codeBlockRegex.firstMatch(text);
    if (match != null) {
      language = match.group(1) ?? 'dart';
      code = match.group(2) ?? text;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => FlutterClipboard.copy(code).then(
                  (value) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied to clipboard')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          HighlightView(
            code,
            language: language,
            theme: githubTheme,
            padding: const EdgeInsets.all(8),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
