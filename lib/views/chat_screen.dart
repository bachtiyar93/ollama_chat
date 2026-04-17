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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late ChatController _chatController;
  bool _conversationStarted = false;
  bool _showScrollToBottom = false;
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(context.read<ChatProvider>());
    _setupFocusCallback();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Jika user scroll ke atas (offset > 100 dari bawah), munculkan tombol "Scroll to Bottom"
    // Karena ListView reverse: true, offset 0 adalah posisi paling bawah (terbaru)
    if (_scrollController.offset > 100) {
      if (!_showScrollToBottom) {
        setState(() => _showScrollToBottom = true);
      }
      _isAutoScrolling = false;
    } else {
      if (_showScrollToBottom) {
        setState(() => _showScrollToBottom = false);
      }
      _isAutoScrolling = true;
    }
  }

  void _setupFocusCallback() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setOnMessageComplete(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Efek Auto-scroll saat ada pesan baru masuk
    // Hanya jika user sedang berada di posisi paling bawah
    if (_isAutoScrolling && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });
    }

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
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
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
      body: Stack(
        children: [
          Column(
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
                        controller: _scrollController,
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
                  child: LinearProgressIndicator(),
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
                              _isAutoScrolling = true; // Reset auto-scroll saat kirim pesan
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
                            _isAutoScrolling = true; // Reset auto-scroll saat kirim pesan
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Tombol Scroll to Bottom (Floating)
          if (_showScrollToBottom)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
        ],
      ),
    );
  }
}
