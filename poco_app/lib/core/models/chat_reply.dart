class ChatReply {
  final String sessionId;
  final String reply;
  ChatReply({required this.sessionId, required this.reply});
  factory ChatReply.fromJson(Map<String, dynamic> json) => ChatReply(
    sessionId: json['session_id'] as String,
    reply: json['reply'] as String,
  );
}
