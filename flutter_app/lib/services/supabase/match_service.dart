import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/match_model.dart';
import '../../models/user_model.dart';

class MatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all matches for a user
  Future<List<MatchModel>> getMatches(String userId) async {
    try {
      final response = await _supabase
          .from('matches')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .eq('status', 'active')
          .order('matched_at', ascending: false);

      return (response as List)
          .map((match) => MatchModel.fromJson(match))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a specific user
  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Unmatch with a user
  Future<bool> unmatch(String matchId) async {
    try {
      await _supabase
          .from('matches')
          .update({'status': 'unmatched'})
          .eq('id', matchId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Block a user
  Future<bool> blockUser(String blockerId, String blockedId) async {
    try {
      await _supabase.from('blocked_users').insert({
        'blocker_id': blockerId,
        'blocked_id': blockedId,
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
