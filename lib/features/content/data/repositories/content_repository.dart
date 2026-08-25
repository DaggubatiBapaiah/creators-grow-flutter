import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/content_post.dart';

class ContentRepository {
  final Dio _dio;

  ContentRepository(this._dio);

  Future<ContentPost> createPost({
    required String socialAccountId,
    required String platform,
    String? caption,
    List<String>? mediaIds,
    String status = 'draft',
    DateTime? scheduledAt,
  }) async {
    final response = await _dio.post('/api/v1/content', data: {
      'socialAccountId': socialAccountId,
      'platform': platform,
      'caption': caption,
      'mediaIds': mediaIds ?? [],
      'status': status,
      'scheduledAt': scheduledAt?.toIso8601String(),
    });
    return ContentPost.fromJson(response.data['post']);
  }

  Future<ContentPost> updatePost({
    required String id,
    String? caption,
    List<String>? mediaIds,
    String? status,
    DateTime? scheduledAt,
  }) async {
    final data = <String, dynamic>{};
    if (caption != null) data['caption'] = caption;
    if (mediaIds != null) data['mediaIds'] = mediaIds;
    if (status != null) data['status'] = status;
    if (scheduledAt != null) data['scheduledAt'] = scheduledAt.toIso8601String();

    final response = await _dio.put('/api/v1/content/$id', data: data);
    return ContentPost.fromJson(response.data['post']);
  }

  Future<List<ContentPost>> getPosts() async {
    final response = await _dio.get('/api/v1/content');
    final posts = response.data['posts'] as List;
    return posts.map((p) => ContentPost.fromJson(p)).toList();
  }

  Future<void> deletePost(String id) async {
    await _dio.delete('/api/v1/content/$id');
  }

  Future<ContentPost> cancelPost(String id) async {
    final response = await _dio.post('/api/v1/content/$id/cancel');
    return ContentPost.fromJson(response.data['post']);
  }
}

final contentRepositoryProvider = Provider((ref) {
  return ContentRepository(ref.watch(dioProvider));
});
