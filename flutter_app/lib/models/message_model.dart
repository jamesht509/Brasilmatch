/// Model de Mensagem no chat
class MessageModel {
  final String id;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type; // 'text', 'image', 'video'
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  
  MessageModel({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'text',
    required this.sentAt,
    this.isRead = false,
    this.readAt,
  });
  
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
    };
  }
  
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }
  
  MessageModel copyWith({
    String? id,
    String? matchId,
    String? senderId,
    String? receiverId,
    String? content,
    String? type,
    DateTime? sentAt,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
