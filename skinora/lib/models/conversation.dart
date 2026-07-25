import 'chat_message.dart';

class Conversation {
  final String id;
  String title;
  List<ChatMessage> messages;
  DateTime updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    return messages.last.text;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}