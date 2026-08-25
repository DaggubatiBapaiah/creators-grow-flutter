import 'package:flutter_test/flutter_test.dart';
import 'package:creators_grow/core/storage/secure_storage.dart';
import 'package:creators_grow/features/onboarding/domain/notifiers/onboarding_notifier.dart';

class FakeSecureStorage implements SecureStorage {
  bool completed = false;
  String displayName = '';
  String category = '';
  List<String> goals = [];
  List<String> platforms = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> saveOnboardingCompleted(bool value) async {
    completed = value;
  }

  @override
  Future<bool> isOnboardingCompleted() async => completed;

  @override
  Future<void> saveProfileData({
    required String displayName,
    required String creatorCategory,
    required List<String> goals,
    required List<String> platforms,
  }) async {
    this.displayName = displayName;
    category = creatorCategory;
    this.goals = goals;
    this.platforms = platforms;
  }

  @override
  Future<Map<String, dynamic>> getOnboardingData() async {
    return {
      'completed': completed,
      'displayName': displayName,
      'creatorCategory': category,
      'goals': goals,
      'platforms': platforms,
    };
  }
}

void main() {
  late FakeSecureStorage fakeSecureStorage;
  late OnboardingNotifier onboardingNotifier;

  setUp(() {
    fakeSecureStorage = FakeSecureStorage();
    onboardingNotifier = OnboardingNotifier(fakeSecureStorage);
  });

  group('OnboardingNotifier Tests', () {
    test('initial state is empty/uncompleted', () {
      expect(onboardingNotifier.state.completed, isFalse);
      expect(onboardingNotifier.state.displayName, isEmpty);
    });

    test('updateProfile updates local state correctly', () {
      onboardingNotifier.updateProfile('Tech Creator', 'Technology');
      expect(onboardingNotifier.state.displayName, 'Tech Creator');
      expect(onboardingNotifier.state.creatorCategory, 'Technology');
    });

    test('completeOnboarding saves details and sets completed status', () async {
      onboardingNotifier.updateProfile('Tech Creator', 'Technology');
      onboardingNotifier.updateGoals(['Grow followers']);
      onboardingNotifier.updatePlatforms(['Instagram']);

      await onboardingNotifier.completeOnboarding();

      expect(onboardingNotifier.state.completed, isTrue);
      expect(fakeSecureStorage.completed, isTrue);
      expect(fakeSecureStorage.displayName, 'Tech Creator');
    });

    test('resetOnboarding clears state and storage', () async {
      onboardingNotifier.updateProfile('Tech Creator', 'Technology');
      await onboardingNotifier.completeOnboarding();
      expect(onboardingNotifier.state.completed, isTrue);

      await onboardingNotifier.resetOnboarding();
      expect(onboardingNotifier.state.completed, isFalse);
      expect(onboardingNotifier.state.displayName, isEmpty);
      expect(fakeSecureStorage.completed, isFalse);
      expect(fakeSecureStorage.displayName, isEmpty);
    });
  });
}
