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
import 'package:creators_grow/features/growth/presentation/notifiers/growth_notifier.dart';

class MockGrowthRepository implements GrowthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<GrowthScore> getGrowthScore() async {
    return GrowthScore(score: 0, change: 0, trend: 'flat', factors: []);
  }
  @override
  Future<List<BestTimeScore>> getBestTimes() async { return []; }
  @override
  Future<ContentAnalysis> getContentAnalysis() async { return ContentAnalysis(formats: [], overallAverageEngagement: 0, overallAverageReach: 0); }
  @override
  Future<List<GrowthRecommendation>> getRecommendations() async { return []; }
}

class MockSocialAccountsRepository implements SocialAccountsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<SocialAccount>> getConnectedAccounts() async {
    return [];
  }
}

class MockContentRepository implements ContentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<ContentPost>> getPosts() async {
    return [];
  }
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
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
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify bottom navigation items are present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
