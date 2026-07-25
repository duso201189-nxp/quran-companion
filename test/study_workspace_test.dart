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
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_panel.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_section.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_workspace_controller.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_workspace_screen.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_workspace_shell.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint 31.1 — bộ khung Study Workspace.
///
/// Kiểm ĐÚNG những gì bộ khung hứa: route đăng ký được, deep link mở
/// được, lối vào từ trang đọc hoạt động, vòng đời Study tách khỏi
/// Reading, và cơ chế đăng ký mục là chung (không gắn cứng tính năng).

/// Bơm nhịp có giới hạn — Drift stream sống khiến `pumpAndSettle`
/// không bao giờ thấy "hết frame" (xem `sprint8_navigation_test`).
Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _Repo implements QuranRepository {
  int getAyahsByIdsCalls = 0;
  int getAyahsOfSurahCalls = 0;

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
  Future<Map<String, String>> getAyahTexts({
    required int ayahId,
    required Set<SourceType> types,
  }) async =>
      const {};

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async {
    getAyahsByIdsCalls++;
    return [
      for (final id in ids)
        if (id == 1 || id == 2)
          AyahSearchResult(
            ayahId: id,
            surahId: 1,
            ayahNumber: id,
            surahNameLatin: 'Al-Fatihah',
            arabic: 'نص عربي $id',
          ),
    ];
  }

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async {
    getAyahsOfSurahCalls++;
    return const [
      AyahContent(
        ayah: Ayah(id: 1, surahId: 1, ayahNumber: 1, textUthmani: 'نص عربي 1'),
        texts: {'vi_main': 'ban viet mot'},
      ),
      AyahContent(
        ayah: Ayah(id: 2, surahId: 1, ayahNumber: 2, textUthmani: 'نص عربي 2'),
        texts: {'vi_main': 'ban viet hai'},
      ),
    ];
  }

  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [
        TranslationSource(
          id: 2,
          code: 'vi_main',
          name: 'Ban dich tieng Viet',
          language: 'vi',
          type: SourceType.translation,
          displayOrder: 2,
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

void main() {
  late _Repo repo;
  late ProviderContainer container;

  Future<Widget> makeApp() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    repo = _Repo();
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

  void testWorkspace(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) async {
      tester.view.physicalSize = const Size(500, 1200);
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

  group('Đăng ký route + deep link', () {
    test('AppRoutes.studyAyah dựng đúng đường dẫn', () {
      expect(AppRoutes.studyAyah(2583), '/study/2583');
    });

    test('KHÔNG đụng route tab Học', () {
      expect(AppRoutes.study, '/study');
      expect(AppRoutes.studyAyah(1), isNot(AppRoutes.study));
    });

    test('Study KHÔNG bị coi là trang đọc (mini player vẫn hiện)', () {
      // Ranh giới Sprint 29.0: thanh phát thu gọn chỉ ẩn trên trang
      // đọc. Study là màn hình khác -> vẫn điều khiển được audio.
      expect(AppRoutes.isReadingLocation(AppRoutes.studyAyah(5)), isFalse);
    });
  });

  testWorkspace('deep link /study/:ayahId mở đúng workspace', (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go(AppRoutes.studyAyah(2));
    await settle(tester);

    expect(find.byType(StudyWorkspaceScreen), findsOneWidget);
    // Study tự nạp CHỦ THỂ của mình từ ayahId trong đường dẫn.
    expect(find.text('نص عربي 2'), findsOneWidget);
    expect(find.text('Al-Fatihah 1:2'), findsOneWidget);
  });

  testWorkspace('deep link tới ayahId không tồn tại -> trạng thái rỗng',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go('/study/999999');
    await settle(tester);

    expect(find.byType(StudyWorkspaceScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWorkspace('trang đọc -> chạm giữ Ayah -> Nghiên cứu -> mở workspace',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go(AppRoutes.read(1));
    await settle(tester);
    expect(find.byType(ReadingScreen), findsOneWidget);

    await tester.longPress(find.text('نص عربي 1').first);
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    await tester.tap(find.text(l10n.studyOpenWorkspace));
    await settle(tester);

    expect(find.byType(StudyWorkspaceScreen), findsOneWidget);
  });

  testWorkspace('mở trang đọc KHÔNG khởi tạo bất kỳ provider Study nào',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go(AppRoutes.read(1));
    await settle(tester);
    expect(find.byType(ReadingScreen), findsOneWidget);

    // `studyAyahProvider` là đường duy nhất Study nạp dữ liệu; nếu
    // Reading chạm tới nó thì `getAyahsByIds` đã được gọi.
    expect(repo.getAyahsByIdsCalls, 0);

    // `container.exists` là phép hỏi CHÍNH XÁC cho một provider family
    // đã khởi tạo hay chưa — `getAllProviderElements()` không dùng
    // được vì `origin.toString()` không mang tên biến provider.
    expect(container.exists(studyAyahProvider(1)), isFalse);
    expect(container.exists(studyAyahProvider(2)), isFalse);
  });

  testWorkspace('mở Study KHÔNG kéo theo provider của trang đọc',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go(AppRoutes.studyAyah(1));
    await settle(tester);
    expect(find.byType(StudyWorkspaceScreen), findsOneWidget);

    // `getAyahsOfSurah` là đường nạp của Reading — Study không dùng.
    expect(repo.getAyahsOfSurahCalls, 0);
    expect(repo.getAyahsByIdsCalls, greaterThan(0));
  });

  testWorkspace('rời Study -> provider autoDispose được giải phóng',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await settle(tester);

    container.read(routerProvider).go(AppRoutes.studyAyah(1));
    await settle(tester);
    expect(container.exists(studyAyahProvider(1)), isTrue);

    container.read(routerProvider).go(AppRoutes.home);
    await settle(tester);

    expect(
      container.exists(studyAyahProvider(1)),
      isFalse,
      reason: 'studyAyahProvider phải là autoDispose.family — không có '
          'state Study toàn cục (DR-2026-0007 D4).',
    );
  });

  group('Cơ chế đăng ký mục', () {
    test('Tafsir là mục đầu tiên được đăng ký (Sprint 31.2)', () {
      expect(kStudySections.map((s) => s.id), ['tafsir']);
    });

    testWidgets('vỏ dựng mục bất kỳ được đăng ký, theo đúng thứ tự',
        (tester) async {
      // Bơm hai mục giả: chứng minh vỏ hoàn toàn KHÔNG biết tính năng
      // cụ thể nào — thêm Tafsir sau này chỉ là thêm một giá trị.
      // Sprint 31.2 — mục tự dựng khung của mình qua [StudyPanel], nên
      // nó có thể tự ẩn khi rỗng. Vỏ chỉ xếp chỗ.
      final sections = [
        StudySection(
          id: 'alpha',
          builder: (context, ayahId) => StudyPanel(
            title: 'Muc Alpha',
            child: Text('alpha:$ayahId'),
          ),
        ),
        StudySection(
          id: 'beta',
          builder: (context, ayahId) => StudyPanel(
            title: 'Muc Beta',
            child: Text('beta:$ayahId'),
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StudyWorkspaceShell(ayahId: 42, sections: sections),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Muc Alpha'), findsOneWidget);
      expect(find.text('Muc Beta'), findsOneWidget);
      // Mục nhận đúng ayahId của workspace, không phải dữ liệu dựng sẵn.
      expect(find.text('alpha:42'), findsOneWidget);
      expect(find.text('beta:42'), findsOneWidget);

      final alphaTop = tester.getTopLeft(find.text('Muc Alpha')).dy;
      final betaTop = tester.getTopLeft(find.text('Muc Beta')).dy;
      expect(alphaTop, lessThan(betaTop));
    });

    testWidgets('mục tự ẩn -> không để lại tiêu đề lơ lửng', (tester) async {
      final sections = [
        StudySection(
          id: 'hidden',
          builder: (context, ayahId) => const SizedBox.shrink(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StudyWorkspaceShell(ayahId: 1, sections: sections),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(StudyWorkspaceShell)).height, 0);
    });

    testWidgets('danh sách mục rỗng -> vỏ không chiếm chỗ', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StudyWorkspaceShell(ayahId: 1, sections: []),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(find.byType(StudyWorkspaceShell)).height, 0);
    });
  });
}
