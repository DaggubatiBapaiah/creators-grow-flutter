import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:creators_grow/features/social_accounts/data/repositories/social_accounts_repository.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_account.dart';

class MockSocialAccountsRepository implements SocialAccountsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<SocialAccount>> getConnectedAccounts() async {
    return [];
  }

  @override
  Future<void> disconnectAccount(String id) async {}

  @override
  Future<String> getMetaConnectUrl() async => '';
}

void main() {
  testWidgets('Dashboard renders and has 5 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          socialAccountsRepositoryProvider.overrideWithValue(MockSocialAccountsRepository()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Verify bottom navigation items are present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
