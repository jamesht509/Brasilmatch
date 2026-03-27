import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/message_model.dart';
import '../../models/match_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all matches with last message (for chat list)
  Future<List<MatchModel>> getChatList(String userId) async {
    try {
      final response = await _supabase
          .from('matches')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('status', 'active')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((match) => MatchModel.fromJson(match))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get messages for a specific match
  Future<List<MessageModel>> getMessages(String matchId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('match_id', matchId)
          .order('sent_at', ascending: true);

      return (response as List)
          .map((message) => MessageModel.fromJson(message))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Send a message
  Future<MessageModel?> sendMessage({
    required String matchId,
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'match_id': matchId,
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
            'type': type,
          })
          .select()
          .single();

      // Update match last message
      await _supabase
          .from('matches')
          .update({
            'last_message_preview': content.length > 50 
                ? '${content.substring(0, 50)}...' 
                : content,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', matchId);

      return MessageModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Subscribe to new messages in a match (real-time)
  Stream<MessageModel> subscribeToMessages(String matchId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .map((data) => MessageModel.fromJson(data.first));
  }
}
