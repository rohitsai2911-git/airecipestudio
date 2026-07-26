import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import '../../../core/models/chat_message.dart';

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, List<ChatMessage>>((ref) {
  return MessagesNotifier(ref);
});

class MessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  MessagesNotifier(this._ref) : super([]);

  void setHistory(List<ChatMessage> messages) {
    state = messages;
  }

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
  }

  Future<void> sendMessage(String content) async {
    addMessage(ChatMessage(role: 'user', content: content));
    try {
      final api = _ref.read(chatApiProvider);
      final reply = await api.sendMessage('default-session', content);
      addMessage(ChatMessage(role: 'assistant', content: reply.reply));
    } catch (e) {
      addMessage(ChatMessage(role: 'assistant', content: 'Sorry, I had trouble responding. Please try again.'));
    }
  }
}
