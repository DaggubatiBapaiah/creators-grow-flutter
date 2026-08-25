import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/errors/app_error.dart';
import '../../data/repositories/auth_repository.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(authRepository, secureStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;

  AuthNotifier(this._authRepository, this._secureStorage) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getAuthToken();
    if (token == null) {
      state = const Unauthenticated();
      return;
    }

    try {
      final user = await _authRepository.getMe();
      state = Authenticated(user);
    } catch (e) {
      // If token is invalid/expired, clear storage and log out
      await _secureStorage.deleteAuthToken();
      state = const Unauthenticated();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthLoading();
    try {
      final data = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      await _secureStorage.saveAuthToken(token);
      state = Authenticated(user);
    } on AppError catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('An unexpected registration error occurred: ${e.toString()}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final data = await _authRepository.login(
        email: email,
        password: password,
      );
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      await _secureStorage.saveAuthToken(token);
      state = Authenticated(user);
    } on AppError catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('An unexpected sign-in error occurred: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      // Call stateless backend logout
      await _authRepository.logout();
    } catch (_) {
      // Discard errors, since backend logout is stateless
    } finally {
      await _secureStorage.deleteAuthToken();
      state = const Unauthenticated();
    }
  }

  void clearErrors() {
    if (state is AuthError) {
      state = const Unauthenticated();
    }
  }
}
