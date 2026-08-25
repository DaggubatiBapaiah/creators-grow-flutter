import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/onboarding_state.dart';

final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return OnboardingNotifier(secureStorage);
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final SecureStorage _secureStorage;

  OnboardingNotifier(this._secureStorage) : super(const OnboardingState()) {
    loadOnboardingData();
  }

  Future<void> loadOnboardingData() async {
    final data = await _secureStorage.getOnboardingData();
    state = OnboardingState(
      completed: data['completed'] as bool? ?? false,
      displayName: data['displayName'] as String? ?? '',
      creatorCategory: data['creatorCategory'] as String? ?? '',
      goals: List<String>.from(data['goals'] ?? const []),
      selectedPlatforms: List<String>.from(data['platforms'] ?? const []),
    );
  }

  void updateProfile(String name, String category) {
    state = state.copyWith(
      displayName: name,
      creatorCategory: category,
    );
  }

  void updateGoals(List<String> goals) {
    state = state.copyWith(goals: goals);
  }

  void updatePlatforms(List<String> platforms) {
    state = state.copyWith(selectedPlatforms: platforms);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(completed: true);
    await _secureStorage.saveOnboardingCompleted(true);
    await _secureStorage.saveProfileData(
      displayName: state.displayName,
      creatorCategory: state.creatorCategory,
      goals: state.goals,
      platforms: state.selectedPlatforms,
    );
  }

  Future<void> resetOnboarding() async {
    state = const OnboardingState();
    await _secureStorage.saveOnboardingCompleted(false);
    await _secureStorage.saveProfileData(
      displayName: '',
      creatorCategory: '',
      goals: const [],
      platforms: const [],
    );
  }
}
