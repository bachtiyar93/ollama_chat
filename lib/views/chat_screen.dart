import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../controllers/chat_controller.dart';
import '../models/theme_mode.dart';
import 'message_bubble.dart';
import 'welcome_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late ChatController _chatController;
  bool _conversationStarted = false;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(context.read<ChatProvider>());
    _setupFocusCallback();
  }

  void _setupFocusCallback() {
    // Set callback to focus input after message complete
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setOnMessageComplete(() {
      // Use Future.delayed to ensure the UI has updated
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: SvgPicture.asset(
                'assets/logo.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jobseeker AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Career Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<AppThemeMode>(
            onSelected: (mode) => themeProvider.setThemeMode(mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppThemeMode.system,
                child: Text('System Theme'),
              ),
              const PopupMenuItem(
                value: AppThemeMode.light,
                child: Text('Light Theme'),
              ),
              const PopupMenuItem(
                value: AppThemeMode.dark,
                child: Text('Dark Theme'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty && !_conversationStarted
                ? WelcomeScreen(
                    onStartChat: () {
                      setState(() {
                        _conversationStarted = true;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _focusNode.requestFocus();
                      });
                    },
                  )
                : ListView.builder(
                    itemCount: chatProvider.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[chatProvider.messages.length - 1 - index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (_conversationStarted || chatProvider.messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _chatController.sendMessage(value);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final message = _controller.text;
                      if (message.isNotEmpty) {
                        _chatController.sendMessage(message);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
