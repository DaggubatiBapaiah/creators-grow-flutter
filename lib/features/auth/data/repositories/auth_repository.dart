import 'package:dio/dio.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/models/user.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _dio.get('/api/v1/auth/me');
      final data = response.data as Map<String, dynamic>;
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/v1/auth/logout');
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }
}
