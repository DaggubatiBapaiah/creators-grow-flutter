import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/engagement_item.dart';
import '../../data/repositories/inbox_repository.dart';

class InboxState {
  final List<EngagementItem> items;
  final bool isLoading;
  final String? error;
  final String activePlatform; // 'all' | 'instagram' | 'facebook' | 'youtube' | 'x'
  final String? activeStatus; // null | 'unread' | 'replied'
  final String searchKeyword;

  InboxState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.activePlatform = 'all',
    this.activeStatus,
    this.searchKeyword = '',
  });

  InboxState copyWith({
    List<EngagementItem>? items,
    bool? isLoading,
    String? error,
    String? activePlatform,
    String? activeStatus,
    bool clearStatus = false,
    String? searchKeyword,
  }) {
    return InboxState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activePlatform: activePlatform ?? this.activePlatform,
      activeStatus: clearStatus ? null : (activeStatus ?? this.activeStatus),
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

class InboxNotifier extends StateNotifier<InboxState> {
  final InboxRepository _repository;

  InboxNotifier(this._repository) : super(InboxState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.getItems(
        platform: state.activePlatform,
        status: state.activeStatus,
        search: state.searchKeyword,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setPlatformFilter(String platform) {
    state = state.copyWith(activePlatform: platform);
    loadItems();
  }

  void setStatusFilter(String? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(activeStatus: status);
    }
    loadItems();
  }

  void setSearchKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);
    loadItems();
  }

  Future<void> replyToComment(String itemId, String replyText) async {
    try {
      await _repository.postReply(itemId, replyText);
      // Optimistic update
      state = state.copyWith(
        items: state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isReplied: true);
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to reply: $e');
    }
  }

  Future<void> markItemAsRead(String itemId) async {
    try {
      await _repository.markRead(itemId);
      state = state.copyWith(
        items: state.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isRead: true);
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark as read: $e');
    }
  }

  Future<void> toggleLike(String itemId, bool isLiked) async {
    try {
      await _repository.toggleLike(itemId, isLiked);
      state = state.copyWith(
        items: state.items.map((item) {
          if (item.id == itemId) {
            final delta = isLiked ? 1 : -1;
            final updatedMetadata = Map<String, dynamic>.from(item.metadata ?? {});
            updatedMetadata['isLiked'] = isLiked;
            return item.copyWith(
              likeCount: item.likeCount + delta,
              metadata: updatedMetadata,
            );
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> toggleHide(String itemId, bool isHidden) async {
    try {
      await _repository.toggleHide(itemId, isHidden);
      state = state.copyWith(
        items: state.items.map((item) {
          if (item.id == itemId) {
            final updatedMetadata = Map<String, dynamic>.from(item.metadata ?? {});
            updatedMetadata['isHidden'] = isHidden;
            return item.copyWith(metadata: updatedMetadata);
          }
          return item;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to hide comment: $e');
    }
  }

  Future<void> deleteComment(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
      state = state.copyWith(
        items: state.items.where((item) => item.id != itemId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete comment: $e');
    }
  }
}

final inboxNotifierProvider = StateNotifierProvider.autoDispose<InboxNotifier, InboxState>((ref) {
  return InboxNotifier(ref.watch(inboxRepositoryProvider));
});
