import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../services/supabase/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State
class AuthState {
  final supabase.User? authUser;
  final UserModel? user;
  final bool isLoading;
  final String? error;
  
  AuthState({
    this.authUser,
    this.user,
    this.isLoading = false,
    this.error,
  });
  
  bool get isAuthenticated => authUser != null;
  bool get hasProfile => user != null;
  
  AuthState copyWith({
    supabase.User? authUser,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState()) {
    _initialize();
  }
  
  void _initialize() async {
    // Check if user is already logged in
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserProfile(currentUser.id);
    }
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((authState) {
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        _loadUserProfile(authState.session!.user.id);
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        state = AuthState();
      }
    });
  }
  
  Future<void> _loadUserProfile(String userId) async {
    try {
      final user = await _authService.getUserProfile(userId);
      state = state.copyWith(
        authUser: _authService.currentUser,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        state = state.copyWith(isLoading: false);
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        state = state.copyWith(
          authUser: response.user,
          isLoading: false,
        );
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Signup failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final success = await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final success = await _authService.signInWithApple();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> createProfile(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final createdUser = await _authService.createUserProfile(user);
      
      state = state.copyWith(
        user: createdUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<void> updateProfile(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedUser = await _authService.updateUserProfile(user);
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
