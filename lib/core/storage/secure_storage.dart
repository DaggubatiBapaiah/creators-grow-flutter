import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage(FlutterSecureStorage());
});

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  static const String _tokenKey = 'auth_token';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _displayNameKey = 'onboarding_display_name';
  static const String _creatorCategoryKey = 'onboarding_creator_category';
  static const String _goalsKey = 'onboarding_goals';
  static const String _platformsKey = 'onboarding_platforms';

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _storage.write(key: _onboardingCompletedKey, value: completed.toString());
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: _onboardingCompletedKey);
    return value == 'true';
  }

  Future<void> saveProfileData({
    required String displayName,
    required String creatorCategory,
    required List<String> goals,
    required List<String> platforms,
  }) async {
    await _storage.write(key: _displayNameKey, value: displayName);
    await _storage.write(key: _creatorCategoryKey, value: creatorCategory);
    await _storage.write(key: _goalsKey, value: goals.join(','));
    await _storage.write(key: _platformsKey, value: platforms.join(','));
  }

  Future<Map<String, dynamic>> getOnboardingData() async {
    final displayName = await _storage.read(key: _displayNameKey) ?? '';
    final creatorCategory = await _storage.read(key: _creatorCategoryKey) ?? '';
    final goalsRaw = await _storage.read(key: _goalsKey) ?? '';
    final platformsRaw = await _storage.read(key: _platformsKey) ?? '';
    final completed = await isOnboardingCompleted();

    return {
      'completed': completed,
      'displayName': displayName,
      'creatorCategory': creatorCategory,
      'goals': goalsRaw.isEmpty ? <String>[] : goalsRaw.split(','),
      'platforms': platformsRaw.isEmpty ? <String>[] : platformsRaw.split(','),
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
