import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
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
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
              ),
            ),
            child: isUser 
              ? SelectableText(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15),
                )
              : MarkdownBody(
                  data: message.text,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: textColor, fontSize: 15),
                    listBullet: TextStyle(color: textColor, fontSize: 15),
                    code: TextStyle(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.transparent, // Kita handle di CodeElementBuilder
                    ),
                  ),
                  builders: {
                    'code': CodeElementBuilder(),
                  },
                ),
          ),
          // Global copy button (for entire message)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: InkWell(
              onTap: () => FlutterClipboard.copy(message.text).then(
                (value) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message copied to clipboard'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_all_rounded, size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      'Copy All', 
                      style: TextStyle(
                        fontSize: 10, 
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w500,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Builder kustom untuk menangani blok kode di Markdown
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Ambil konten kode
    final String language = element.attributes['class']?.replaceAll('language-', '') ?? 'text';
    final String code = element.textContent.trim();

    // Jika ini adalah blok kode (bukan inline code)
    if (element.tag == 'code' && element.textContent.contains('\n') || element.attributes.containsKey('class')) {
      return CodeWrapper(
        code: code,
        language: language,
      );
    }
    
    // Untuk inline code, biarkan default
    return null;
  }
}
