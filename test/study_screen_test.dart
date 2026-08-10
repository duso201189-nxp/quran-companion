import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 7.2 (Foundation-First Session Default) — GoRouter TỐI GIẢN,
/// chỉ có đúng 3 route cần cho test này (StudyScreen + 2 đích điều
/// hướng, mỗi đích chỉ là 1 Text đánh dấu) — không dựng cả app
/// (QuranCompanionApp/makeApp) vì ReadingScreen/LearningSessionScreen
/// thật kéo theo nhiều provider không liên quan tới sprint này (audio
/// player, Quiz, Scheduler...). Cùng mẫu wrap() cục bộ đã dùng ở
/// quiz_session_screen_test.dart/revision_queue_screen_test.dart.
Future<Widget> _wrap({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const StudyScreen()),
      GoRoute(
        path: '/quran/surah/:id',
        builder: (_, __) => const Scaffold(body: Text('READING_SCREEN')),
      ),
      GoRoute(
        path: AppRoutes.learningSession,
        builder: (_, __) => const Scaffold(body: Text('LEARNING_SESSION')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets(
      'chưa từng đọc (lastSurahId == null) -> bấm "Start Learning '
      'Session" điều hướng tới Reading (Surah 1), KHÔNG tới Learning '
      'Session', (tester) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    expect(find.text('READING_SCREEN'), findsOneWidget);
    expect(find.text('LEARNING_SESSION'), findsNothing);
  });

  testWidgets(
      'đã từng đọc (lastSurahId != null) -> bấm "Start Learning Session" '
      'điều hướng tới Learning Session như trước Sprint 7.2, KHÔNG đổi',
      (tester) async {
    await tester.pumpWidget(
      await _wrap(
        prefs: {
          ReadingPositionStore.kLastSurah: 1,
          ReadingPositionStore.posKey(1): 0,
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    expect(find.text('LEARNING_SESSION'), findsOneWidget);
    expect(find.text('READING_SCREEN'), findsNothing);
  });

  testWidgets(
      'màn hình Học vẫn hiện đủ tiêu đề + nút bắt đầu + các công cụ có '
      'sẵn — hành vi hiện có không đổi bởi Sprint 7.2', (tester) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Start Learning Session'), findsOneWidget);
    expect(find.text('Flashcards'), findsOneWidget);
  });
}
