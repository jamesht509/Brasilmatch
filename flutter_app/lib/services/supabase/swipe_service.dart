import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class SwipeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get potential matches for the current user
  Future<List<UserModel>> getPotentialMatches(String currentUserId) async {
    try {
      // Get current user's preferences
      final currentUser = await _supabase
          .from('users')
          .select()
          .eq('id', currentUserId)
          .single();

      final preferences = UserModel.fromJson(currentUser);

      // Get users already swiped (to exclude)
      final swipedIds = await _supabase
          .from('swipes')
          .select('swiped_id')
          .eq('swiper_id', currentUserId);

      final excludeIds = swipedIds.map((s) => s['swiped_id'] as String).toList();
      excludeIds.add(currentUserId); // Don't show self

      // Get users already matched (to exclude)
      final matchedIds = await _supabase
          .from('matches')
          .select('user1_id, user2_id')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId');

      for (final match in matchedIds) {
        final otherId = match['user1_id'] == currentUserId
            ? match['user2_id']
            : match['user1_id'];
        excludeIds.add(otherId as String);
      }

      // Query for potential matches
      var query = _supabase
          .from('users')
          .select()
          .not('id', 'in', '(${excludeIds.join(',')})');

      // Filter by gender preferences
      if (preferences.interestedIn != 'both') {
        query = query.eq('gender', preferences.interestedIn);
      }

      // Filter by age range
      query = query
          .gte('age', preferences.minAge)
          .lte('age', preferences.maxAge);

      // Limit results
      query = query.limit(20);

      final response = await query;

      return (response as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Record a swipe
  Future<bool> recordSwipe({
    required String swiperId,
    required String swipedId,
    required String direction, // 'like', 'nope', 'super_like'
  }) async {
    try {
      await _supabase.from('swipes').insert({
        'swiper_id': swiperId,
        'swiped_id': swipedId,
        'direction': direction,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if two users matched (automatic via trigger)
  Future<bool> checkMatch(String user1Id, String user2Id) async {
    try {
      // Sort IDs alphabetically to match database structure
      final sortedIds = [user1Id, user2Id]..sort();
      
      final response = await _supabase
          .from('matches')
          .select()
          .eq('user1_id', sortedIds[0])
          .eq('user2_id', sortedIds[1])
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
