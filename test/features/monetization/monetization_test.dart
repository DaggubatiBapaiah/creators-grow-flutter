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
      contactPerson: contactPerson,
      contactEmail: contactEmail,
      notes: notes,
      associatedPostId: associatedPostId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    deals.add(d);
    return d;
  }

  @override
  Future<BrandDeal> updateDeal(String id, Map<String, dynamic> updates) async {
    final idx = deals.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final old = deals[idx];
      final updated = old.copyWith(
        brandName: updates['brandName'] as String?,
        dealValue: updates['dealValue'] != null ? double.parse(updates['dealValue'].toString()) : null,
        stage: updates['stage'] as String?,
        contactPerson: updates['contactPerson'] as String?,
        contactEmail: updates['contactEmail'] as String?,
        notes: updates['notes'] as String?,
        associatedPostId: updates['associatedPostId'] as String?,
        updatedAt: DateTime.now(),
      );
      deals[idx] = updated;
      return updated;
    }
    throw Exception('Not found');
  }

  @override
  Future<void> deleteDeal(String id) async {
    deals.removeWhere((d) => d.id == id);
  }

  @override
  Future<MediaKitConfig> getConfig() async => config;

  @override
  Future<MediaKitConfig> saveConfig(MediaKitConfig newConfig) async {
    config = newConfig;
    return config;
  }
}

void main() {
  late MockMonetizationRepository mockRepo;

  setUp(() {
    mockRepo = MockMonetizationRepository();
  });

  group('Monetization Notifiers Tests', () {
    test('BrandDealsNotifier fetches deals correctly', () async {
      final container = ProviderContainer(
        overrides: [
          monetizationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(brandDealsNotifierProvider.notifier);
      await notifier.fetchDeals();

      final state = container.read(brandDealsNotifierProvider);
      expect(state.isLoading, false);
      expect(state.deals.length, 2);
      expect(state.deals[0].brandName, 'Nike Collab');
    });

    test('BrandDealsNotifier creates brand deal correctly', () async {
      final container = ProviderContainer(
        overrides: [
          monetizationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(brandDealsNotifierProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.createDeal(
        brandName: 'Puma Post',
        dealValue: 500.0,
        stage: 'pitching',
      );

      final state = container.read(brandDealsNotifierProvider);
      expect(state.deals.length, 3);
      expect(state.deals.first.brandName, 'Puma Post');
    });

    test('MediaKitNotifier fetches and saves configuration config correctly', () async {
      final container = ProviderContainer(
        overrides: [
          monetizationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(mediaKitNotifierProvider.notifier);
      await notifier.fetchConfig();

      final stateBefore = container.read(mediaKitNotifierProvider);
      expect(stateBefore.config?.customBio, 'Old Bio');

      await notifier.updateConfig(
        customBio: 'New Bio Details',
        contactEmail: 'new@email.com',
        rates: [const RateItem(service: 'Post', rate: 200.0)],
      );

      final stateAfter = container.read(mediaKitNotifierProvider);
      expect(stateAfter.config?.customBio, 'New Bio Details');
      expect(stateAfter.config?.contactEmail, 'new@email.com');
      expect(stateAfter.config?.rates[0].service, 'Post');
    });
  });

  group('CRM and Media Kit Widget Screen Tests', () {
    testWidgets('CrmPipelineScreen renders financial cards and list details', (tester) async {
      mockRepo.deals = [
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monetizationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: CrmPipelineScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

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
          ],
          child: const MaterialApp(
            home: MediaKitSettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Shareable Public Link'), findsOneWidget);
      expect(find.text('Total Kit Page Views'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      // Verify input values are synchronized
      final bioFinder = find.byKey(const Key('bioField'));
      expect(bioFinder, findsOneWidget);
      expect(tester.widget<TextField>(bioFinder).controller?.text, 'Old Bio');

      final emailFinder = find.byKey(const Key('contactEmailField'));
      expect(emailFinder, findsOneWidget);
      expect(tester.widget<TextField>(emailFinder).controller?.text, 'old@email.com');
    });
  });
}