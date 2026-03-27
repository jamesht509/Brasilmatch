/// Model de Match entre dois usuários
class MatchModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime matchedAt;
  final String status; // 'active', 'unmatched', 'blocked'
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int? unreadCount; // Mensagens não lidas
  
  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.matchedAt,
    this.status = 'active',
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount,
  });
  
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      matchedAt: DateTime.parse(json['matched_at'] as String),
      status: json['status'] as String? ?? 'active',
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'matched_at': matchedAt.toIso8601String(),
      'status': status,
      'last_message_preview': lastMessagePreview,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
  
  /// Retorna o ID do outro usuário no match
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
  
  MatchModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? matchedAt,
    String? status,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return MatchModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      matchedAt: matchedAt ?? this.matchedAt,
      status: status ?? this.status,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
