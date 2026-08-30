import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:creators_grow/features/social_accounts/data/repositories/social_accounts_repository.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_account.dart';
import 'package:creators_grow/features/content/data/repositories/content_repository.dart';
import 'package:creators_grow/features/content/domain/models/content_post.dart';
import 'package:creators_grow/features/analytics/data/repositories/analytics_repository.dart';
import 'package:creators_grow/features/analytics/presentation/notifiers/analytics_notifier.dart';
import 'package:creators_grow/features/growth/data/repositories/growth_repository.dart';
import 'package:creators_grow/features/growth/domain/models/growth_models.dart';
import 'package:creators_grow/features/billing/data/repositories/billing_repository.dart';
import 'package:creators_grow/features/billing/domain/models/billing_status.dart';
import 'package:creators_grow/features/inbox/data/repositories/inbox_repository.dart';
import 'package:creators_grow/features/inbox/domain/models/engagement_item.dart';

class MockGrowthRepository implements GrowthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<GrowthScore> getGrowthScore() async => GrowthScore(score: 0, change: 0, trend: 'flat', factors: []);
  @override
  Future<List<BestTimeScore>> getBestTimes() async => [];
  @override
  Future<ContentAnalysis> getContentAnalysis() async => ContentAnalysis(formats: [], overallAverageEngagement: 0, overallAverageReach: 0);
  @override
  Future<List<GrowthRecommendation>> getRecommendations() async => [];
}

class MockSocialAccountsRepository implements SocialAccountsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<List<SocialAccount>> getConnectedAccounts() async => [];
}

class MockContentRepository implements ContentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<List<ContentPost>> getPosts() async => [];
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<Map<String, dynamic>> getDashboardStats() async => {
        'followers': 0,
        'engagementRate': 0,
        'reach': 0,
        'history': [],
        'draftsCount': 0,
        'scheduledCount': 0,
        'publishedCount': 0,
        'failedCount': 0,
        'topPosts': [],
      };
}

class MockInboxRepository implements InboxRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<List<EngagementItem>> getItems({String? platform, String? status, String? search, int limit = 20, int offset = 0}) async => [];
}

class MockBillingRepository implements BillingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Future<BillingStatus> getStatus() async => BillingStatus(
        planCode: 'pro',
        status: 'active',
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
        cancelAtPeriodEnd: false,
        connectedAccounts: 1,
        maxSocialAccounts: 10,
        scheduledPostsUsed: 0,
        maxScheduledPosts: 100,
        aiGenerationsUsed: 0,
        maxAiGenerations: 100,
        hasCrmAccess: true,
        hasGrowthIntelligence: true,
        hasMediaKitCustomization: true,
      );
}

void main() {
  testWidgets('Dashboard renders and has 5 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          socialAccountsRepositoryProvider.overrideWithValue(MockSocialAccountsRepository()),
          contentRepositoryProvider.overrideWithValue(MockContentRepository()),
          analyticsRepositoryProvider.overrideWithValue(MockAnalyticsRepository()),
          growthRepositoryProvider.overrideWithValue(MockGrowthRepository()),
          inboxRepositoryProvider.overrideWithValue(MockInboxRepository()),
          billingRepositoryProvider.overrideWithValue(MockBillingRepository()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify bottom navigation items are present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
