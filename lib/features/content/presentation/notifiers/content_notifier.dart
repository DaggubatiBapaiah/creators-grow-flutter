import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_post.dart';
import '../data/repositories/content_repository.dart';

class ContentState {
  final List<ContentPost> posts;
  final bool isLoading;
  final String? error;

  ContentState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  ContentState copyWith({
    List<ContentPost>? posts,
    bool? isLoading,
    String? error,
  }) {
    return ContentState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ContentNotifier extends StateNotifier<ContentState> {
  final ContentRepository _repository;

  ContentNotifier(this._repository) : super(ContentState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await _repository.getPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPost({
    required String socialAccountId,
    required String platform,
    String? caption,
    List<String>? mediaIds,
    String status = 'draft',
    DateTime? scheduledAt,
  }) async {
    try {
      final newPost = await _repository.createPost(
        socialAccountId: socialAccountId,
        platform: platform,
        caption: caption,
        mediaIds: mediaIds,
        status: status,
        scheduledAt: scheduledAt,
      );
      state = state.copyWith(posts: [newPost, ...state.posts]);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> updatePost({
    required String id,
    String? caption,
    List<String>? mediaIds,
    String? status,
    DateTime? scheduledAt,
  }) async {
    try {
      final updatedPost = await _repository.updatePost(
        id: id,
        caption: caption,
        mediaIds: mediaIds,
        status: status,
        scheduledAt: scheduledAt,
      );
      final index = state.posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newPosts = [...state.posts];
        newPosts[index] = updatedPost;
        state = state.copyWith(posts: newPosts);
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _repository.deletePost(id);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<void> cancelPost(String id) async {
    try {
      final updatedPost = await _repository.cancelPost(id);
      final index = state.posts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newPosts = [...state.posts];
        newPosts[index] = updatedPost;
        state = state.copyWith(posts: newPosts);
      }
    } catch (e) {
      throw Exception('Failed to cancel post: $e');
    }
  }
}

final contentNotifierProvider = StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier(ref.watch(contentRepositoryProvider));
});
