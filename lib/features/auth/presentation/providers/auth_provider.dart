import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';

// State for Authentication
class AuthState {
  final bool isLoading;
  final String? token;
  final String? error;

  AuthState({this.isLoading = false, this.token, this.error});

  bool get isAuthenticated => token != null;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _repository.getToken();
    if (token != null) {
      state = AuthState(token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final token = await _repository.login(email, password);
      state = AuthState(token: token);
      _ref.invalidate(userProvider);
      _ref.invalidate(eventsProvider);
      router.go('/');
    } catch (e) {
      state = AuthState(error: _mapError(e));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = AuthState(isLoading: true);
    try {
      final result = await _repository.register(data);

      if (result == 'pending') {
        state = AuthState();
        router.go('/pending-approval');
      } else {
        state = AuthState(error: 'Unexpected response from server');
      }
    } catch (e) {
      state = AuthState(error: _mapError(e));
    }
  }

  Future<void> registerGuest({
    required String name,
    required String email,
    required String password,
    required String phone,
    File? profilePhoto,
  }) async {
    state = AuthState(isLoading: true);
    try {
      final token = await _repository.registerGuest(
        name: name,
        email: email,
        password: password,
        phone: phone,
        profilePhoto: profilePhoto,
      );

      if (token != null) {
        // Guest registration returns token, auto-login like normal login
        state = AuthState(token: token);
        _ref.invalidate(userProvider);
        _ref.invalidate(eventsProvider);
        router.go('/guest-welcome');
      } else {
        state = AuthState(error: 'Unexpected response from server');
      }
    } catch (e) {
      state = AuthState(error: _mapError(e));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
    _ref.invalidate(userProvider);
    _ref.invalidate(eventsProvider);
    router.go('/login');
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? bio,
    File? profilePhoto,
  }) async {
    state = AuthState(isLoading: true, token: state.token);
    try {
      await _repository.updateProfile(
        name: name,
        phone: phone,
        company: company,
        bio: bio,
        profilePhoto: profilePhoto,
      );
      state = AuthState(token: state.token);
      _ref.invalidate(userProvider);
    } catch (e) {
      state = AuthState(token: state.token, error: _mapError(e));
      rethrow;
    }
  }

  String _mapError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : message;
  }
}

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Riverpod Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
