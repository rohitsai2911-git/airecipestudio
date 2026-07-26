import '../../../core/api/api_client.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_reply.dart';

class ChatApi {
  final ApiClient _client;
  ChatApi(this._client);

  Future<ChatReply> sendMessage(String sessionId, String message) async {
    final data = await _client.post('/chat', body: {'session_id': sessionId, 'message': message});
    return ChatReply.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> getHistory(String sessionId) async {
    final data = await _client.get('/chat/$sessionId');
    return (data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }
}
