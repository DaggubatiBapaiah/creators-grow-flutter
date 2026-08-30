import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/monetization/domain/models/brand_deal.dart';
import 'package:creators_grow/features/monetization/domain/models/mediakit_config.dart';
import 'package:creators_grow/features/monetization/data/repositories/monetization_repository.dart';
import 'package:creators_grow/features/monetization/presentation/notifiers/brand_deals_notifier.dart';
import 'package:creators_grow/features/monetization/presentation/notifiers/mediakit_notifier.dart';
import 'package:creators_grow/features/monetization/presentation/screens/crm_pipeline_screen.dart';
import 'package:creators_grow/features/monetization/presentation/screens/mediakit_settings_screen.dart';
import 'package:creators_grow/features/billing/data/repositories/billing_repository.dart';
import 'package:creators_grow/features/billing/domain/models/billing_status.dart';

class MockMonetizationRepository implements MonetizationRepository {
  List<BrandDeal> deals = [
    BrandDeal(
      id: 'deal1',
      userId: 'user1',
      brandName: 'Nike Collab',
      dealValue: 1200.0,
      stage: 'negotiating',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    BrandDeal(
      id: 'deal2',
      userId: 'user1',
      brandName: 'Adidas post',
      dealValue: 800.0,
      stage: 'paid',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  MediaKitConfig config = const MediaKitConfig(
    id: 'config1',
    userId: 'user1',
    customBio: 'Old Bio',
    contactEmail: 'old@email.com',
    showInstagram: true,
    showTiktok: true,
    rates: [RateItem(service: 'Reel', rate: 300.0)],
    viewsCount: 15,
  );

  @override
  Future<List<BrandDeal>> getDeals() async => List.from(deals);

  @override
  Future<BrandDeal> createDeal({
    required String brandName,
    required double dealValue,
    required String stage,
    String? contactPerson,
    String? contactEmail,
    String? notes,
    String? associatedPostId,
  }) async {
    final d = BrandDeal(
      id: 'new_deal',
      userId: 'user1',
      brandName: brandName,
      dealValue: dealValue,
      stage: stage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    deals.add(d);
    return d;
  }

  @override
  Future<BrandDeal> updateDealStage(String id, String stage) async {
    final i = deals.indexWhere((x) => x.id == id);
    deals[i] = BrandDeal(
      id: deals[i].id,
      userId: deals[i].userId,
      brandName: deals[i].brandName,
      dealValue: deals[i].dealValue,
      stage: stage,
      createdAt: deals[i].createdAt,
      updatedAt: DateTime.now(),
    );
    return deals[i];
  }

  @override
  Future<MediaKitConfig> getConfig() async => config;

  @override
  Future<MediaKitConfig> saveConfig(MediaKitConfig configData) async {
    config = configData;
    return config;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBillingRepository implements BillingRepository {
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
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CRM and Media Kit Widget Screen Tests', () {
    late MockMonetizationRepository mockRepo;

    setUp(() {
      mockRepo = MockMonetizationRepository();
    });

    testWidgets('CrmPipelineScreen renders financial cards and list details', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(mockRepo),
            billingRepositoryProvider.overrideWithValue(MockBillingRepository()),
          ],
          child: const MaterialApp(
            home: CrmPipelineScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Active Pipeline'), findsOneWidget);
      expect(find.text('\$1200.00'), findsNWidgets(2));
      expect(find.text('Paid Earnings'), findsOneWidget);
      expect(find.text('\$800.00'), findsNWidgets(2));

      expect(find.text('Nike Collab'), findsOneWidget);
      expect(find.text('Adidas post'), findsOneWidget);
    });

    testWidgets('MediaKitSettingsScreen renders link and config input fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(mockRepo),
            billingRepositoryProvider.overrideWithValue(MockBillingRepository()),
          ],
          child: const MaterialApp(
            home: MediaKitSettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Shareable Public Link'), findsOneWidget);
      expect(find.text('Total Kit Page Views'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      final bioFinder = find.byKey(const Key('bioField'));
      expect(bioFinder, findsOneWidget);
      expect(tester.widget<TextField>(bioFinder).controller?.text, 'Old Bio');

      final emailFinder = find.byKey(const Key('contactEmailField'));
      expect(emailFinder, findsOneWidget);
      expect(tester.widget<TextField>(emailFinder).controller?.text, 'old@email.com');
    });
  });
}
