import '../providers/chat_provider.dart';

class ChatController {
  final ChatProvider chatProvider;

  ChatController(this.chatProvider);

  void sendMessage(String message) {
    if (message.trim().isNotEmpty) {
      chatProvider.sendMessage(message.trim());
    }
  }
}
