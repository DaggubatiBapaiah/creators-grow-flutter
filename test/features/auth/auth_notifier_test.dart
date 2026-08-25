import 'package:flutter_test/flutter_test.dart';
import 'package:creators_grow/core/storage/secure_storage.dart';
import 'package:creators_grow/core/errors/app_error.dart';
import 'package:creators_grow/features/auth/data/repositories/auth_repository.dart';
import 'package:creators_grow/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:creators_grow/features/auth/domain/models/auth_state.dart';
import 'package:creators_grow/features/auth/domain/models/user.dart';

// Manual Fake for SecureStorage
class FakeSecureStorage implements SecureStorage {
  String? token;

  @override
  Future<String?> getAuthToken() async => token;

  @override
  Future<void> saveAuthToken(String value) async {
    token = value;
  }

  @override
  Future<void> deleteAuthToken() async {
    token = null;
  }

  @override
  Future<void> clearAll() async {
    token = null;
  }
}

// Manual Fake for AuthRepository
class FakeAuthRepository implements AuthRepository {
  final User testUser = const User(id: '123', email: 'test@example.com', displayName: 'Test Name');
  bool shouldThrowError = false;
  bool logoutCalled = false;

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldThrowError) {
      throw const ServerError('A user with this email address already exists.', statusCode: 409);
    }
    return {
      'token': 'jwt_token_abc',
      'user': testUser.toJson(),
    };
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrowError) {
      throw const UnauthorizedError(message: 'Invalid email or password.');
    }
    return {
      'token': 'jwt_token_abc',
      'user': testUser.toJson(),
    };
  }

  @override
  Future<User> getMe() async {
    if (shouldThrowError) {
      throw const UnauthorizedError(message: 'Invalid token');
    }
    return testUser;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeSecureStorage fakeSecureStorage;
  late AuthNotifier authNotifier;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeSecureStorage = FakeSecureStorage();
    authNotifier = AuthNotifier(fakeAuthRepository, fakeSecureStorage);
  });

  group('AuthNotifier Tests', () {
    test('checkAuthStatus - unauthenticated when token is null', () async {
      await authNotifier.checkAuthStatus();
      expect(authNotifier.state, isA<Unauthenticated>());
    });

    test('checkAuthStatus - authenticated when token is valid', () async {
      fakeSecureStorage.token = 'valid_token';
      await authNotifier.checkAuthStatus();

      expect(authNotifier.state, isA<Authenticated>());
      final authState = authNotifier.state as Authenticated;
      expect(authState.user.email, 'test@example.com');
    });

    test('register - success updates state and saves token', () async {
      await authNotifier.register(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test Name',
      );

      expect(authNotifier.state, isA<Authenticated>());
      final authState = authNotifier.state as Authenticated;
      expect(authState.user.id, '123');
      expect(fakeSecureStorage.token, 'jwt_token_abc');
    });

    test('login - success updates state and saves token', () async {
      await authNotifier.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(authNotifier.state, isA<Authenticated>());
      final authState = authNotifier.state as Authenticated;
      expect(authState.user.displayName, 'Test Name');
      expect(fakeSecureStorage.token, 'jwt_token_abc');
    });

    test('login - failure sets AuthError state', () async {
      fakeAuthRepository.shouldThrowError = true;

      await authNotifier.login(
        email: 'test@example.com',
        password: 'wrong_password',
      );

      expect(authNotifier.state, isA<AuthError>());
      final authState = authNotifier.state as AuthError;
      expect(authState.message, 'Invalid email or password.');
    });

    test('logout - clears token and sets state to unauthenticated', () async {
      fakeSecureStorage.token = 'jwt_token_abc';
      await authNotifier.logout();

      expect(authNotifier.state, isA<Unauthenticated>());
      expect(fakeSecureStorage.token, isNull);
      expect(fakeAuthRepository.logoutCalled, isTrue);
    });
  });
}
