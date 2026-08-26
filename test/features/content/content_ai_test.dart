import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/content/presentation/screens/content_composer_screen.dart';
import 'package:creators_grow/features/content/presentation/widgets/ai_prompt_bottom_sheet.dart';
import 'package:creators_grow/features/content/data/repositories/content_repository.dart';
import 'package:creators_grow/features/content/domain/models/content_post.dart';
import 'package:creators_grow/features/content/domain/models/ai_variation.dart';
import 'package:creators_grow/features/content/data/ai_copilot_service.dart';
import 'package:creators_grow/features/content/presentation/notifiers/ai_copilot_notifier.dart';
import 'package:creators_grow/features/social_accounts/data/repositories/social_accounts_repository.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_account.dart';
import 'package:creators_grow/features/social_accounts/domain/models/social_platform.dart';
import 'package:creators_grow/features/social_accounts/presentation/notifiers/social_accounts_notifier.dart';
import 'package:dio/dio.dart';

class FakeAICopilotService implements AICopilotService {
  List<AIVariation> variationsResult = [];
  bool shouldThrow = false;
  String throwMessage = 'AI error';

  @override
  Dio get _dio => throw UnimplementedError();

  @override
  Future<List<AIVariation>> generateCaption({
    required String prompt,
    required String platform,
    String? tone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldThrow) {
      throw Exception(throwMessage);
    }
    return variationsResult;
  }
}

class FakeSocialAccountsRepository implements SocialAccountsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<SocialAccount>> getConnectedAccounts() async {
    return [
      const SocialAccount(
        id: 'acc_1',
        platform: SocialPlatform.instagram,
        accountName: 'test_instagram',
        platformAccountId: 'ig_1',
        status: 'connected',
      )
    ];
  }
}

class FakeContentRepository implements ContentRepository {
  List<ContentPost> posts = [];
  bool createPostCalled = false;
  bool lastCreatePostAiGenerated = false;
  String? lastCreatePostCaption;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<ContentPost>> getPosts() async {
    return posts;
  }

  @override
  Future<ContentPost> createPost({
    required String socialAccountId,
    required String platform,
    String? caption,
    List<String>? mediaIds,
    bool aiGenerated = false,
    String status = 'draft',
    DateTime? scheduledAt,
  }) async {
    createPostCalled = true;
    lastCreatePostAiGenerated = aiGenerated;
    lastCreatePostCaption = caption;

    final newPost = ContentPost(
      id: 'post_123',
      userId: 'u_1',
      socialAccountId: socialAccountId,
      platform: platform,
      caption: caption,
      mediaIds: mediaIds ?? [],
      status: status,
      scheduledAt: scheduledAt,
      aiGenerated: aiGenerated,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    posts.add(newPost);
    return newPost;
  }
}

void main() {
  late FakeAICopilotService fakeAI;
  late FakeContentRepository fakeContent;
  late FakeSocialAccountsRepository fakeSocial;

  setUp(() {
    fakeAI = FakeAICopilotService();
    fakeContent = FakeContentRepository();
    fakeSocial = FakeSocialAccountsRepository();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        aiCopilotServiceProvider.overrideWithValue(fakeAI),
        contentRepositoryProvider.overrideWithValue(fakeContent),
        socialAccountsRepositoryProvider.overrideWithValue(fakeSocial),
      ],
      child: const MaterialApp(
        home: ContentComposerScreen(),
      ),
    );
  }

  group('ContentComposerScreen AI Copilot Integration Tests', () {
    testWidgets('1. Spark AI button opens the bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      
      final item = find.text('@test_instagram').last;
      await tester.tap(item);
      await tester.pumpAndSettle();

      final sparkButton = find.byKey(const Key('sparkAIButton'));
      expect(sparkButton, findsOneWidget);

      await tester.tap(sparkButton);
      await tester.pumpAndSettle();

      expect(find.byType(AIPromptBottomSheet), findsOneWidget);
    });

    testWidgets('2. Empty caption + generated variation inserts content directly', (WidgetTester tester) async {
      fakeAI.variationsResult = [
        const AIVariation(
          hook: 'Awesome Hook',
          body: 'Great Body Content',
          hashtags: ['#test'],
          fullText: 'Awesome Hook\n\nGreat Body Content\n\n#test',
        )
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'My Morning Routine');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Awesome Hook'), findsOneWidget);

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.byType(AIPromptBottomSheet), findsNothing);
      
      final composerTextField = tester.widget<TextField>(find.byKey(const Key('composerCaptionField')));
      expect(composerTextField.controller?.text, 'Awesome Hook\n\nGreat Body Content\n\n#test');
    });

    testWidgets('3. AI generation error state is shown', (WidgetTester tester) async {
      fakeAI.shouldThrow = true;
      fakeAI.throwMessage = 'Gemini quota exceeded';

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Workout');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pumpAndSettle();

      expect(find.text('Gemini quota exceeded'), findsOneWidget);
    });

    testWidgets('4. Existing caption + Cancel leaves caption unchanged', (WidgetTester tester) async {
      fakeAI.variationsResult = [
        const AIVariation(
          hook: 'AI Hook',
          body: 'AI Body',
          hashtags: [],
          fullText: 'AI Full Text',
        )
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('composerCaptionField')), 'Original Human Caption');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Routine');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('captionSafetyDialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pumpAndSettle();

      final composerTextField = tester.widget<TextField>(find.byKey(const Key('composerCaptionField')));
      expect(composerTextField.controller?.text, 'Original Human Caption');
    });

    testWidgets('5. Existing caption + Replace intentionally overwrites caption', (WidgetTester tester) async {
      fakeAI.variationsResult = [
        const AIVariation(
          hook: 'AI Hook',
          body: 'AI Body',
          hashtags: [],
          fullText: 'AI Full Text',
        )
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('composerCaptionField')), 'Original Human Caption');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Routine');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('replaceButton')));
      await tester.pumpAndSettle();

      final composerTextField = tester.widget<TextField>(find.byKey(const Key('composerCaptionField')));
      expect(composerTextField.controller?.text, 'AI Full Text');
    });

    testWidgets('6. Existing caption + Append appends AI text correctly', (WidgetTester tester) async {
      fakeAI.variationsResult = [
        const AIVariation(
          hook: 'AI Hook',
          body: 'AI Body',
          hashtags: [],
          fullText: 'AI Full Text',
        )
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('composerCaptionField')), 'Original Human Caption');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Routine');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('appendButton')));
      await tester.pumpAndSettle();

      final composerTextField = tester.widget<TextField>(find.byKey(const Key('composerCaptionField')));
      expect(composerTextField.controller?.text, 'Original Human Caption\n\nAI Full Text');
    });

    testWidgets('7. Saved AI-generated content sends aiGenerated=true', (WidgetTester tester) async {
      fakeAI.variationsResult = [
        const AIVariation(
          hook: 'AI Hook',
          body: 'AI Body',
          hashtags: [],
          fullText: 'AI Full Text',
        )
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sparkAIButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Routine');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Variations'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE DRAFT'));
      await tester.pumpAndSettle();

      expect(fakeContent.createPostCalled, isTrue);
      expect(fakeContent.lastCreatePostAiGenerated, isTrue);
      expect(fakeContent.lastCreatePostCaption, 'AI Full Text');
    });

    testWidgets('8. Saved manual content sends aiGenerated=false', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('@test_instagram').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('composerCaptionField')), 'Manual text');
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE DRAFT'));
      await tester.pumpAndSettle();

      expect(fakeContent.createPostCalled, isTrue);
      expect(fakeContent.lastCreatePostAiGenerated, isFalse);
      expect(fakeContent.lastCreatePostCaption, 'Manual text');
    });
  });
}
