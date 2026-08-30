import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/models/notification_preference.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationItem>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get('/api/v1/notifications', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final List data = response.data['data']['notifications'] ?? [];
    return data.map((x) => NotificationItem.fromJson(x)).toList();
  }

  Future<void> markRead(String id) async {
    await _dio.post('/api/v1/notifications/$id/read');
  }

  Future<List<NotificationPreference>> getPreferences() async {
    final response = await _dio.get('/api/v1/notifications/preferences');
    final List data = response.data['data']['preferences'] ?? [];
    return data.map((x) => NotificationPreference.fromJson(x)).toList();
  }

  Future<NotificationPreference> updatePreference({
    required String category,
    required bool emailEnabled,
    required bool pushEnabled,
    required bool inAppEnabled,
  }) async {
    final response = await _dio.put('/api/v1/notifications/preferences', data: {
      'category': category,
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'inAppEnabled': inAppEnabled,
    });
    return NotificationPreference.fromJson(response.data['data']['preference']);
  }
}

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});
