import 'ai_message.dart';

class AiConversation {
  final String id;
  final String userId;
  final String title;
  final List<AiMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  AiConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  AiConversation copyWith({
    String? id,
    String? userId,
    String? title,
    List<AiMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AiConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    return AiConversation(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => AiMessage.fromMap(m))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  // Helper methods
  AiMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get messageCount => messages.length;
  bool get hasUnreadMessages => false; // Could be implemented with read status
}
