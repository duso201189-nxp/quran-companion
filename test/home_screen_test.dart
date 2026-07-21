import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/home/presentation/home_screen.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_controller.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 20 Phase 2, Task 5 — kiểm chứng home_screen.dart KHÔNG còn
/// "nuốt" trạng thái loading/lỗi trong im lặng (xem
/// accessibility_audit.md mục 3.1/8.5). Không dùng `makeApp()`
/// (fixtures/app_harness.dart) vì cố định `quranRepositoryProvider` —
/// ở đây cần kiểm soát trực tiếp `surahListProvider`/`todaysVerseProvider`
/// để đóng băng ở đúng trạng thái loading/error muốn kiểm tra, nên tự
/// dựng 1 ProviderScope tối giản riêng. HomeScreen không gọi
/// `context.push` trong build() (chỉ trong onTap/onPressed), nên
/// KHÔNG cần bọc GoRouter — miễn không chạm các nút điều hướng.
Future<Widget> _app({required List<Override> overrides}) async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      userDatabaseProvider.overrideWithValue(
        UserDatabase(NativeDatabase.memory()),
      ),
      ...overrides,
    ],
    child: const MaterialApp(
      locale: Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(),
    ),
  );
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('vi'));
  });

  testWidgets(
      'surahListProvider đang tải -> hiện LoadingState với nhãn '
      'accessibility đúng (không còn màn hình trống im lặng)', (tester) async {
    final completer = Completer<List<Surah>>();
    await tester.pumpWidget(
      await _app(
        overrides: [
          surahListProvider.overrideWith((ref) => completer.future),
          // Tránh chạm todaysVerseProvider thật (kéo theo
          // quranRepositoryProvider/appDatabaseProvider thật) khi
          // surahsAsync resolve xong bên dưới — CircularProgressIndicator
          // vô hạn của nó sẽ khiến pumpAndSettle() không bao giờ dừng.
          todaysVerseProvider.overrideWith((ref) async => null),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.homeLoading), findsOneWidget);

    completer.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'surahListProvider lỗi -> hiện lỗi kèm nút Thử lại, KHÔNG còn '
      'render ra khoảng trắng', (tester) async {
    await tester.pumpWidget(
      await _app(
        overrides: [
          surahListProvider.overrideWith(
            (ref) => Future<List<Surah>>.error(Exception('boom')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorLoadData), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);

    // Bấm Thử lại không được ném lỗi (chỉ ref.invalidate).
    await tester.tap(find.text(l10n.retry));
    await tester.pump();
  });

  testWidgets(
      'todaysVerseProvider lỗi -> thẻ Câu hôm nay hiện lỗi kèm nút '
      'Thử lại (trước đây render ra KHÔNG GÌ CẢ)', (tester) async {
    await tester.pumpWidget(
      await _app(
        overrides: [
          surahListProvider.overrideWith((ref) => Future.value(const [])),
          todaysVerseProvider.overrideWith((ref) async {
            throw Exception('boom');
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorLoadData), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);
  });

  testWidgets(
      'todaysVerseProvider đang tải -> hiện LoadingState riêng với '
      'nhãn accessibility đúng', (tester) async {
    final completer = Completer<({Surah surah, AyahContent content})?>();
    await tester.pumpWidget(
      await _app(
        overrides: [
          surahListProvider.overrideWith((ref) => Future.value(const [])),
          todaysVerseProvider.overrideWith((ref) => completer.future),
        ],
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel(l10n.homeTodaysVerseLoading), findsOneWidget);

    completer.complete(null);
    await tester.pumpAndSettle();
  });
}
