import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

// Current auth user provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});

// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return SupabaseService.isLoggedIn;
});

// Auth notifier for sign out functionality
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncData(null));

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await SupabaseService.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      return AuthNotifier();
    });
