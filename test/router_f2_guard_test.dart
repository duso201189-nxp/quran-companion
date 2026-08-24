import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session 98 — kiểm chứng guard cấp router chặn 5 route F2
/// (Flashcards, `DR-2026-0030` — hoãn khỏi v1.0) khỏi điều hướng trực
/// tiếp/deep-link, mà không xoá route/màn hình nào. Dùng GoRouter TỐI
/// GIẢN với [deferredFeatureRedirect] thật lấy từ `lib/app/router.dart`
/// (không viết lại logic guard trong test) + màn hình đánh dấu bằng
/// Text riêng cho mỗi đích, cùng mẫu `study_screen_test.dart`/
/// `flashcard_ux_test.dart` — tránh dựng cả app vì các màn hình F2
/// thật kéo theo AppDatabase không liên quan tới việc kiểm guard.
void main() {
  Widget wrapMinimalRouter({required String initialLocation}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      redirect: deferredFeatureRedirect,
      routes: [
        GoRoute(
          path: AppRoutes.study,
          builder: (_, __) => const Scaffold(body: Text('STUDY_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.library,
          builder: (_, __) => const Scaffold(body: Text('LIBRARY_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.flashcards,
          builder: (_, __) => const Scaffold(body: Text('FLASHCARDS_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.addFlashcard,
          builder: (_, __) =>
              const Scaffold(body: Text('ADD_FLASHCARD_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.flashcardDecks,
          builder: (_, __) =>
              const Scaffold(body: Text('FLASHCARD_DECKS_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.smartDeck,
          builder: (_, __) => const Scaffold(body: Text('SMART_DECK_MARKER')),
        ),
        GoRoute(
          path: AppRoutes.flashcardReview,
          builder: (_, __) =>
              const Scaffold(body: Text('FLASHCARD_REVIEW_MARKER')),
        ),
      ],
    );
    return MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  const deferredF2Cases = {
    AppRoutes.flashcards: 'FLASHCARDS_MARKER',
    AppRoutes.addFlashcard: 'ADD_FLASHCARD_MARKER',
    AppRoutes.flashcardDecks: 'FLASHCARD_DECKS_MARKER',
    AppRoutes.smartDeck: 'SMART_DECK_MARKER',
    AppRoutes.flashcardReview: 'FLASHCARD_REVIEW_MARKER',
  };

  for (final entry in deferredF2Cases.entries) {
    testWidgets(
        'deep-link ${entry.key} -> redirect về Study, KHÔNG dựng '
        '${entry.value}', (tester) async {
      await tester.pumpWidget(wrapMinimalRouter(initialLocation: entry.key));
      await tester.pumpAndSettle();

      expect(find.text('STUDY_MARKER'), findsOneWidget);
      expect(find.text(entry.value), findsNothing);
    });
  }

  testWidgets(
    'route con giả định dưới /flashcards/ (chưa đăng ký) vẫn bị chặn qua '
    'prefix-match, không rơi vào lỗi "route not found"',
    (tester) async {
      await tester.pumpWidget(
        wrapMinimalRouter(initialLocation: '/flashcards/some-future-child'),
      );
      await tester.pumpAndSettle();

      expect(find.text('STUDY_MARKER'), findsOneWidget);
    },
  );

  testWidgets(
      'route ngoài F2 (Thư viện của tôi) KHÔNG bị guard chặn, vẫn điều '
      'hướng thẳng như cũ', (tester) async {
    await tester.pumpWidget(
      wrapMinimalRouter(initialLocation: AppRoutes.library),
    );
    await tester.pumpAndSettle();

    expect(find.text('LIBRARY_MARKER'), findsOneWidget);
    expect(find.text('STUDY_MARKER'), findsNothing);
  });

  testWidgets(
    'StudyScreen thật + router thật có guard: chạm thẻ Flashcard KHÔNG '
    'bao giờ dựng FlashcardBrowseScreen (chặn ở tầng router, độc lập '
    'với trạng thái onTap của thẻ)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final router = GoRouter(
        initialLocation: AppRoutes.study,
        redirect: deferredFeatureRedirect,
        routes: [
          GoRoute(
            path: AppRoutes.study,
            builder: (_, __) => const StudyScreen(),
          ),
          GoRoute(
            path: AppRoutes.flashcards,
            builder: (_, __) => const Scaffold(body: Text('FLASHCARDS_MARKER')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Flashcards'));
      await tester.pumpAndSettle();

      expect(find.text('FLASHCARDS_MARKER'), findsNothing);
    },
  );
}
