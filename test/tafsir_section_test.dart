import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/app.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/study/presentation/workspace/sections/tafsir_section.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint 31.2 — panel Tafsir, BẢN MẪU của mọi mục Study.
///
/// Kiểm cả hai chiều của ranh giới: Tafsir nạp được khi mở Study, và
/// KHÔNG bao giờ bị nạp khi chỉ đọc.

const _vi = TranslationSource(
  id: 2,
  code: 'vi_main',
  name: 'Ban dich tieng Viet',
  language: 'vi',
  type: SourceType.translation,
  displayOrder: 2,
);

/// Hai nguồn Tafsir — chứng minh panel không giả định "chỉ một".
const _tafsirVi = TranslationSource(
  id: 5,
  code: 'tafsir_vi',
  name: 'Tafsir tieng Viet',
  language: 'vi',
  type: SourceType.tafsir,
  displayOrder: 5,
);
const _tafsirAr = TranslationSource(
  id: 6,
  code: 'tafsir_muyassar',
  name: 'Tafsir Al-Muyassar',
  language: 'ar',
  type: SourceType.tafsir,
  displayOrder: 6,
);

class _Repo implements QuranRepository {
  _Repo({this.tafsirSources = const [], this.tafsirTexts = const {}});

  final List<TranslationSource> tafsirSources;
  final Map<String, String> tafsirTexts;

  int getAyahTextsCalls = 0;
  final List<int> requestedAyahIds = [];
  final List<Set<SourceType>> requestedTypes = [];

  static const _surah = Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai De',
    nameEn: 'The Opening',
    ayahCount: 2,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  );

  @override
  Future<List<TranslationSource>> getEnabledSources() async =>
      [_vi, ...tafsirSources];

  @override
  Future<Map<String, String>> getAyahTexts({
    required int ayahId,
    required Set<SourceType> types,
  }) async {
    getAyahTextsCalls++;
    requestedAyahIds.add(ayahId);
    requestedTypes.add(types);
    return tafsirTexts;
  }

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          AyahSearchResult(
            ayahId: id,
            surahId: 1,
            ayahNumber: id,
            surahNameLatin: 'Al-Fatihah',
            arabic: 'نص عربي $id',
          ),
      ];

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [
        AyahContent(
          ayah:
              Ayah(id: 1, surahId: 1, ayahNumber: 1, textUthmani: 'نص عربي 1'),
          texts: {'vi_main': 'ban viet mot'},
        ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];
  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;
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

Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late _Repo repo;
  late ProviderContainer container;

  Future<Widget> makeApp(_Repo r) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    repo = r;
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        quranRepositoryProvider.overrideWithValue(repo),
        userDatabaseProvider
            .overrideWithValue(UserDatabase(NativeDatabase.memory())),
        ayahAudioPlayerProvider.overrideWithValue(FakeAyahAudioPlayer()),
      ],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const QuranCompanionApp(),
    );
  }

  void testTafsir(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) async {
      tester.view.physicalSize = const Size(500, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 1));
      }
    });
  }

  group('Provider Tafsir', () {
    test('không có nguồn Tafsir -> trả rỗng và KHÔNG chạm database', () async {
      final r = _Repo();
      final c = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);

      expect(await c.read(tafsirForAyahProvider(1).future), isEmpty);
      expect(r.getAyahTextsCalls, 0);
    });

    test('chỉ nạp ĐÚNG một Ayah và ĐÚNG loại tafsir', () async {
      final r = _Repo(
        tafsirSources: const [_tafsirVi],
        tafsirTexts: const {'tafsir_vi': 'chu giai 1'},
      );
      final c = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);

      await c.read(tafsirForAyahProvider(42).future);

      expect(r.requestedAyahIds, [42]);
      expect(r.requestedTypes, [
        {SourceType.tafsir},
      ]);
    });

    test('nhiều nguồn Tafsir -> sắp theo display_order', () async {
      final r = _Repo(
        // Cố tình đảo thứ tự đầu vào.
        tafsirSources: const [_tafsirAr, _tafsirVi],
        tafsirTexts: const {
          'tafsir_vi': 'chu giai viet',
          'tafsir_muyassar': 'تفسير',
        },
      );
      final c = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);

      final entries = await c.read(tafsirForAyahProvider(1).future);
      expect(
        entries.map((e) => e.source.code),
        ['tafsir_vi', 'tafsir_muyassar'],
      );
    });

    test('nguồn có nhưng Ayah này thiếu văn bản -> bỏ qua nguồn đó', () async {
      final r = _Repo(
        tafsirSources: const [_tafsirVi, _tafsirAr],
        tafsirTexts: const {'tafsir_vi': 'chi co ban viet'},
      );
      final c = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);

      final entries = await c.read(tafsirForAyahProvider(1).future);
      expect(entries.map((e) => e.source.code), ['tafsir_vi']);
    });

    test('mỗi Ayah một mục provider riêng (autoDispose.family)', () async {
      final r = _Repo(
        tafsirSources: const [_tafsirVi],
        tafsirTexts: const {'tafsir_vi': 'x'},
      );
      final c = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(r)],
      );
      addTearDown(c.dispose);

      await c.read(tafsirForAyahProvider(1).future);
      await c.read(tafsirForAyahProvider(2).future);

      expect(r.requestedAyahIds, [1, 2]);
      expect(r.getAyahTextsCalls, 2);
    });
  });

  group('Dựng panel trong workspace', () {
    testTafsir('hai nguồn Tafsir hiện độc lập, đúng tên và hướng chữ',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(
          _Repo(
            tafsirSources: const [_tafsirVi, _tafsirAr],
            tafsirTexts: const {
              'tafsir_vi': 'chu giai tieng viet',
              'tafsir_muyassar': 'تفسير الآية',
            },
          ),
        ),
      );
      await settle(tester);

      container.read(routerProvider).go(AppRoutes.studyAyah(1));
      await settle(tester);

      expect(find.byType(StudyPanel), findsOneWidget);
      expect(find.text('Tafsir tieng Viet'), findsOneWidget);
      expect(find.text('chu giai tieng viet'), findsOneWidget);
      expect(find.text('Tafsir Al-Muyassar'), findsOneWidget);
      expect(find.text('تفسير الآية'), findsOneWidget);

      // Hướng chữ suy ra từ ngôn ngữ nguồn, không cấu hình thêm.
      expect(
        tester.widget<Text>(find.text('تفسير الآية')).textDirection,
        TextDirection.rtl,
      );
      expect(
        tester.widget<Text>(find.text('chu giai tieng viet')).textDirection,
        TextDirection.ltr,
      );
    });

    testTafsir('không có nguồn Tafsir -> panel biến mất hoàn toàn',
        (tester) async {
      await tester.pumpWidget(await makeApp(_Repo()));
      await settle(tester);

      container.read(routerProvider).go(AppRoutes.studyAyah(1));
      await settle(tester);

      // Không tiêu đề lơ lửng, không khung chờ, không truy vấn.
      expect(find.byType(StudyPanel), findsNothing);
      expect(repo.getAyahTextsCalls, 0);
      // Chủ thể vẫn hiển thị -> workspace vẫn hoạt động bình thường.
      expect(find.text('نص عربي 1'), findsOneWidget);
    });

    testTafsir('có nguồn nhưng Ayah chưa có chú giải -> panel vẫn ẩn',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(_Repo(tafsirSources: const [_tafsirVi])),
      );
      await settle(tester);

      container.read(routerProvider).go(AppRoutes.studyAyah(1));
      await settle(tester);

      expect(find.byType(StudyPanel), findsNothing);
      // ...nhưng đã thật sự đi hỏi database (khác trường hợp trên).
      expect(repo.getAyahTextsCalls, 1);
    });
  });

  group('Cách ly khỏi Reading', () {
    testTafsir('mở trang đọc KHÔNG nạp Tafsir', (tester) async {
      await tester.pumpWidget(
        await makeApp(
          _Repo(
            tafsirSources: const [_tafsirVi],
            tafsirTexts: const {'tafsir_vi': 'chu giai'},
          ),
        ),
      );
      await settle(tester);

      container.read(routerProvider).go(AppRoutes.read(1));
      await settle(tester);

      expect(repo.getAyahTextsCalls, 0);
      expect(container.exists(tafsirForAyahProvider(1)), isFalse);
      // Trang đọc vẫn hiện bản dịch bình thường.
      expect(find.text('ban viet mot'), findsOneWidget);
      // ...và tuyệt đối không hiện chú giải.
      expect(find.text('chu giai'), findsNothing);
    });

    testTafsir('rời Study -> provider Tafsir được giải phóng', (tester) async {
      await tester.pumpWidget(
        await makeApp(
          _Repo(
            tafsirSources: const [_tafsirVi],
            tafsirTexts: const {'tafsir_vi': 'chu giai'},
          ),
        ),
      );
      await settle(tester);

      container.read(routerProvider).go(AppRoutes.studyAyah(1));
      await settle(tester);
      expect(container.exists(tafsirForAyahProvider(1)), isTrue);

      container.read(routerProvider).go(AppRoutes.home);
      await settle(tester);
      expect(container.exists(tafsirForAyahProvider(1)), isFalse);
    });
  });
}
