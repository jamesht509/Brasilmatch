import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/onboarding/profile_setup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/swipe/swipe_screen.dart';
import '../../screens/matches/matches_screen.dart';
import '../../screens/chat/chat_list_screen.dart';
import '../../screens/chat/chat_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/credits/credits_store_screen.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isOnboarded = authState.user?.name != null; // Verifica se completou perfil
      
      final isGoingToAuth = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToSplash = state.matchedLocation == '/splash';
      
      // Se não está logado e não vai para auth ou splash, redireciona para login
      if (!isLoggedIn && !isGoingToAuth && !isGoingToSplash) {
        return '/login';
      }
      
      // Se está logado mas não completou onboarding
      if (isLoggedIn && !isOnboarded && !isGoingToOnboarding) {
        return '/onboarding';
      }
      
      // Se está logado, completou onboarding e está indo para auth, redireciona para home
      if (isLoggedIn && isOnboarded && (isGoingToAuth || isGoingToOnboarding)) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'swipe',
            builder: (context, state) => const SwipeScreen(),
          ),
          GoRoute(
            path: 'matches',
            builder: (context, state) => const MatchesScreen(),
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':matchId',
                builder: (context, state) {
                  final matchId = state.pathParameters['matchId']!;
                  return ChatDetailScreen(matchId: matchId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) {
              final userId = state.uri.queryParameters['userId'];
              return ProfileScreen(userId: userId);
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'credits',
            builder: (context, state) => const CreditsStoreScreen(),
          ),
        ],
      ),
    ],
  );
});
