import 'package:dio/dio.dart';
import '../../../../core/errors/app_error.dart';

class AnalyticsRepository {
  final Dio _dio;

  AnalyticsRepository(this._dio);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/api/v1/analytics/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>> getTopPosts() async {
    try {
      final response = await _dio.get('/api/v1/analytics/top-posts');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }
}
