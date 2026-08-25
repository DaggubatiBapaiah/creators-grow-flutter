import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_platform.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_account.dart';
import 'package:creators_grow/features/social_accounts/data/repositories/social_accounts_repository.dart';
import 'package:creators_grow/features/social_accounts/presentation/notifiers/social_accounts_notifier.dart';
import 'package:creators_grow/core/errors/app_error.dart';

class FakeSocialAccountsRepository implements SocialAccountsRepository {
  List<SocialAccount> mockAccounts = [];
  bool shouldThrowError = false;
  bool disconnectCalled = false;
  String? disconnectedId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<SocialAccount>> getConnectedAccounts() async {
    if (shouldThrowError) {
      throw const ServerError('Failed to fetch accounts', statusCode: 500);
    }
    return mockAccounts;
  }

  @override
  Future<void> disconnectAccount(String id) async {
    if (shouldThrowError) {
      throw const ServerError('Failed to disconnect', statusCode: 500);
    }
    disconnectCalled = true;
    disconnectedId = id;
    mockAccounts.removeWhere((acc) => acc.id == id);
  }

  @override
  Future<String> getMetaConnectUrl() async {
    return 'http://localhost:3000/api/v1/social/meta/connect?state=mockstate';
  }
}

void main() {
  group('SocialAccount Model Tests', () {
    test('fromJson and toJson map correctly', () {
      final json = {
        'id': 'acc_123',
        'platform': 'instagram',
        'accountName': 'test_creator',
        'platformAccountId': '123456789',
        'profileImageUrl': 'http://image.url',
        'status': 'connected',
      };

      final acc = SocialAccount.fromJson(json);
      expect(acc.id, 'acc_123');
      expect(acc.platform, SocialPlatform.instagram);
      expect(acc.accountName, 'test_creator');

      final serialized = acc.toJson();
      expect(serialized['platform'], 'instagram');
      expect(serialized['accountName'], 'test_creator');
    });
  });

  group('SocialAccountsNotifier Tests', () {
    late FakeSocialAccountsRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeSocialAccountsRepository();
      container = ProviderContainer(
        overrides: [
          socialAccountsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading, then updates to dynamic values', () async {
      fakeRepository.mockAccounts = [
        const SocialAccount(
          id: '1',
          platform: SocialPlatform.instagram,
          accountName: 'test_insta',
          platformAccountId: 'ig_123',
          status: 'connected',
        )
      ];

      final stateNotifier = container.read(socialAccountsNotifierProvider.notifier);
      expect(container.read(socialAccountsNotifierProvider), const AsyncValue<List<SocialAccount>>.loading());

      await stateNotifier.fetchAccounts();

      final state = container.read(socialAccountsNotifierProvider);
      expect(state.value?.length, 1);
      expect(state.value?[0].accountName, 'test_insta');
    });
  });
}
