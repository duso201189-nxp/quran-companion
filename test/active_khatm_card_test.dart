import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/khatm/data/khatm_cycle_providers.dart';
import 'package:quran_companion/features/khatm/domain/entities/khatm_cycle.dart';
import 'package:quran_companion/features/khatm/domain/repositories/khatm_cycle_repository.dart';
import 'package:quran_companion/features/khatm/presentation/active_khatm_card.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chỉ giả getAyahsByIds (dùng bởi "Continue reading") — các
/// phương thức khác không được ActiveKhatmCard gọi tới.
class _FakeQuranRepo implements QuranRepository {
  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          if (id == 300)
            const AyahSearchResult(
              ayahId: 300,
              surahId: 3,
              ayahNumber: 15,
              surahNameLatin: 'Ali Imran',
              arabic: 'x',
            ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [];
  @override
  Future<Surah?> getSurahById(int id) async => null;
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];
  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [];
  @override
  Future<String?> getMetaValue(String key) async => null;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];
}

/// Fake phản ứng (reactive) — cùng mẫu với
/// `fixtures/fake_bookmark_collection_repository.dart`. Sprint 5.1
/// Finding 3 cần test "bắt đầu chu kỳ mới thay thế thẻ hoàn thành"
/// TRÊN CÙNG một widget đang mở (tap Start Khatm -> UI tự cập nhật,
/// không remount) — một `Stream.value` chỉ chụp `current` một lần lúc
/// subscribe sẽ không bao giờ phản ánh lần đổi SAU đó, khác hành vi
/// thật của Drift `.watch()`.
class _FakeKhatmCycleRepository implements KhatmCycleRepository {
  KhatmCycle? current;
  bool startCalled = false;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  void _notifyChanged() => _changes.add(null);

  @override
  Future<String> startCycle({
    required String name,
    String? targetDate,
  }) async {
    startCalled = true;
    current = KhatmCycle(id: 'new', name: name, startedAt: 0);
    _notifyChanged();
    return 'new';
  }

  @override
  Stream<List<KhatmCycle>> watchAllCycles() async* {
    yield current == null ? [] : [current!];
    await for (final _ in _changes.stream) {
      yield current == null ? [] : [current!];
    }
  }

  @override
  Stream<KhatmCycle?> watchActiveCycle() async* {
    yield current;
    await for (final _ in _changes.stream) {
      yield current;
    }
  }

  @override
  Future<void> updateProgress(String cycleId, QuranAddress address) async {}

  @override
  Future<void> completeCycle(String cycleId) async {}

  @override
  Future<void> deleteCycle(String cycleId) async {}
}

void main() {
  late _FakeKhatmCycleRepository fakeKhatm;
  late SharedPreferences prefs;

  setUp(() async {
    fakeKhatm = _FakeKhatmCycleRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: ActiveKhatmCard()),
        ),
        GoRoute(
          path: '/read/:id',
          builder: (_, state) => Scaffold(
            body: Text('READ_SCREEN_${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
        khatmCycleRepositoryProvider.overrideWithValue(fakeKhatm),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets('không có chu kỳ đang mở -> trạng thái rỗng + nút Start Khatm',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No active Khatm cycle.'), findsOneWidget);
    expect(find.text('Start Khatm'), findsOneWidget);
    expect(find.text('Continue reading'), findsNothing);
  });

  testWidgets('bấm Start Khatm gọi startCycle với tên mặc định',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Khatm'));
    await tester.pumpAndSettle();

    expect(fakeKhatm.startCalled, isTrue);
    expect(fakeKhatm.current?.name, 'My Khatm');
  });

  testWidgets(
      'có chu kỳ đang mở -> hiện tên, vị trí Ayah, % tiến độ, thanh '
      'tiến độ, nút Continue reading', (tester) async {
    fakeKhatm.current = const KhatmCycle(
      id: 'c1',
      name: 'Ramadan 2026',
      startedAt: 1000,
      currentAyahId: 3118, // ~50.0% của 6236
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Ramadan 2026'), findsOneWidget);
    expect(find.text('Ayah 3118 / 6236'), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Continue reading'), findsOneWidget);
    expect(find.text('No active Khatm cycle.'), findsNothing);
  });

  testWidgets(
      'bấm Continue reading: lưu đúng vị trí (surah 3, ayahIndex 14) '
      'và điều hướng sang trang đọc', (tester) async {
    fakeKhatm.current = const KhatmCycle(
      id: 'c1',
      name: 'Chu kỳ',
      startedAt: 1000,
      currentAyahId: 300,
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(prefs.getInt(ReadingPositionStore.posKey(3)), isNull);

    await tester.tap(find.text('Continue reading'));
    await tester.pumpAndSettle();

    // ayahNumber 15 -> ayahIndex 14 (1-based hiển thị, 0-based lưu).
    expect(prefs.getInt(ReadingPositionStore.posKey(3)), 14);
    expect(find.text('READ_SCREEN_3'), findsOneWidget);
  });

  /// Sprint 5.1 (Finding 3) — trạng thái "vừa hoàn thành Khatm".
  group('Sprint 5.1 Finding 3 — trạng thái hoàn thành', () {
    testWidgets(
        'chu kỳ ĐÃ hoàn thành -> hiện thẻ hoàn thành, KHÔNG phải thẻ '
        'đang đọc dở hay thẻ rỗng', (tester) async {
      fakeKhatm.current = const KhatmCycle(
        id: 'c1',
        name: 'Ramadan 2026',
        startedAt: 1000,
        currentAyahId: 6236,
        completedAt: 2000,
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Khatm completed!'), findsOneWidget);
      expect(find.text('Ramadan 2026'), findsOneWidget);
      expect(find.text('Start Khatm'), findsOneWidget);
      // KHÔNG phải thẻ đang đọc dở:
      expect(find.text('Continue reading'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // KHÔNG phải thẻ rỗng:
      expect(find.text('No active Khatm cycle.'), findsNothing);
    });

    testWidgets(
        'chưa có chu kỳ nào (khác hẳn đã hoàn thành) -> vẫn hiện đúng '
        'thẻ rỗng như trước', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('No active Khatm cycle.'), findsOneWidget);
      expect(find.text('Khatm completed!'), findsNothing);
    });

    testWidgets(
        'chu kỳ đang đọc dở (chưa hoàn thành) -> vẫn hiện đúng thẻ '
        'đang đọc như trước, không đổi', (tester) async {
      fakeKhatm.current = const KhatmCycle(
        id: 'c1',
        name: 'Ramadan 2026',
        startedAt: 1000,
        currentAyahId: 3118,
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      expect(find.text('Ramadan 2026'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Continue reading'), findsOneWidget);
      expect(find.text('Khatm completed!'), findsNothing);
    });

    testWidgets(
        'bấm Start Khatm trên thẻ hoàn thành -> chu kỳ MỚI thay thế '
        'thẻ hoàn thành bằng thẻ đang đọc dở', (tester) async {
      fakeKhatm.current = const KhatmCycle(
        id: 'c1',
        name: 'Ramadan 2026',
        startedAt: 1000,
        currentAyahId: 6236,
        completedAt: 2000,
      );

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      expect(find.text('Khatm completed!'), findsOneWidget);

      await tester.tap(find.text('Start Khatm'));
      await tester.pumpAndSettle();

      // Chu kỳ mới (id 'new', currentAyahId mặc định 1, chưa hoàn
      // thành) đã thay thế chu kỳ cũ trong _FakeKhatmCycleRepository
      // — đúng hành vi thật của startCycle().
      expect(fakeKhatm.startCalled, isTrue);
      expect(find.text('Khatm completed!'), findsNothing);
      expect(find.text('My Khatm'), findsOneWidget);
      expect(find.text('Continue reading'), findsOneWidget);
    });
  });
}
