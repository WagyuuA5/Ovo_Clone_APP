enum MessageStatus { sending, sent, read }

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.status,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? time,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}
