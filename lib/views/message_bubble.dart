import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../models/message.dart';
import '../views/code_wrapper.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  message.text,
                  style: TextStyle(color: textColor),
                ),
                if (_isCodeBlock(message.text)) ...[
                  const SizedBox(height: 8),
                  CodeWrapper(text: message.text),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => FlutterClipboard.copy(message.text).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCodeBlock(String text) {
    // Simple check for code blocks (e.g., contains ``` or starts with code-like patterns)
    return text.contains('```') ||
           text.contains('import ') ||
           text.contains('class ') ||
           text.contains('function ') ||
           text.contains('{') && text.contains('}');
  }
}
