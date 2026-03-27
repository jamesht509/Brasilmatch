import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sign in with Google (OAuth)
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'brasilmatch://callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Sign in with Apple (OAuth)
  Future<bool> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'brasilmatch://callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
  
  /// Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      if (response == null) return null;
      
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  /// Create user profile in database
  Future<UserModel> createUserProfile(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('No user logged in');
      
      // Delete user profile (cascade deletes all related data)
      await _supabase.from('users').delete().eq('id', userId);
      
      // Sign out
      await signOut();
    } catch (e) {
      rethrow;
    }
  }
}
