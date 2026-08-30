import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/models/notification_preference.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationItem> notifications;
  final List<NotificationPreference> preferences;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.preferences = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    List<NotificationPreference>? preferences,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(NotificationState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifs = await _repository.getNotifications();
      final prefs = await _repository.getPreferences();
      state = state.copyWith(
        notifications: notifs,
        preferences: prefs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markRead(id);
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == id) {
            return NotificationItem(
              id: n.id,
              userId: n.userId,
              category: n.category,
              title: n.title,
              body: n.body,
              metadata: n.metadata,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark read: $e');
    }
  }

  Future<void> updatePref({
    required String category,
    required bool emailEnabled,
    required bool pushEnabled,
    required bool inAppEnabled,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.updatePreference(
        category: category,
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        inAppEnabled: inAppEnabled,
      );

      final exists = state.preferences.any((p) => p.category == category);
      List<NotificationPreference> newPrefs;
      if (exists) {
        newPrefs = state.preferences.map((p) {
          return p.category == category ? updated : p;
        }).toList();
      } else {
        newPrefs = [...state.preferences, updated];
      }

      state = state.copyWith(
        preferences: newPrefs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update preferences: $e',
      );
    }
  }
}

final notificationNotifierProvider = StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider));
});
