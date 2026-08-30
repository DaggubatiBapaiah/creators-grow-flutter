import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/engagement_item.dart';

class InboxRepository {
  final Dio _dio;

  InboxRepository(this._dio);

  Future<List<EngagementItem>> getItems({
    String? platform,
    String? status, // 'unread' | 'replied'
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get('/api/v1/inbox', queryParameters: {
      if (platform != null && platform.toLowerCase() != 'all') 'platform': platform,
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      'limit': limit,
      'offset': offset,
    });
    
    final List data = response.data['data']['items'] ?? [];
    return data.map((x) => EngagementItem.fromJson(x)).toList();
  }

  Future<void> postReply(String itemId, String text) async {
    await _dio.post('/api/v1/inbox/$itemId/reply', data: {
      'text': text,
    });
  }

  Future<void> markRead(String itemId) async {
    await _dio.post('/api/v1/inbox/$itemId/read');
  }

  Future<void> toggleLike(String itemId, bool like) async {
    await _dio.post('/api/v1/inbox/$itemId/like', data: {
      'like': like,
    });
  }

  Future<void> toggleHide(String itemId, bool hide) async {
    await _dio.post('/api/v1/inbox/$itemId/hide', data: {
      'hide': hide,
    });
  }

  Future<void> deleteItem(String itemId) async {
    await _dio.delete('/api/v1/inbox/$itemId');
  }
}

final inboxRepositoryProvider = Provider((ref) {
  return InboxRepository(ref.watch(dioProvider));
});
