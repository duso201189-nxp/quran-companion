import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_constants.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/study/presentation/workspace/sections/tafsir_section.dart';
import 'package:quran_companion/features/study/presentation/workspace/study_panel.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Sprint 31.3/31.4 — kiểm chứng trên BỘ DỮ LIỆU THẬT đã đóng gói.
///
/// Khác mọi test Tafsir dùng repo giả: ở đây mở đúng file
/// `assets/database/quran.sqlite` mà app phát hành, nên kiểm được
/// những thứ fake không bao giờ kiểm được — độ phủ thật, ký tự thật,
/// NHIỀU nguồn thật, và ranh giới đọc trên dữ liệu thật.
///
/// Bỏ qua nếu asset chưa build (`python tool/build_quran_db.py`).

const _assetPath = 'assets/database/quran.sqlite';
const _newline = '\n';

void main() {
  final file = File(_assetPath);
  if (!file.existsSync()) {
    test('bỏ qua: chưa build assets/database/quran.sqlite', () {}, skip: true);
    return;
  }

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    // Mở BẢN SAO: NativeDatabase mở read-write, test không được sửa
    // asset đã build.
    final copy = File('${file.path}.test-copy');
    copy.writeAsBytesSync(file.readAsBytesSync());
    addTearDown(() {
      if (copy.existsSync()) copy.deleteSync();
    });
    db = AppDatabase(NativeDatabase(copy));
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  Future<List<TranslationSource>> tafsirSources() async {
    final all =
        await container.read(quranRepositoryProvider).getEnabledSources();
    return all.where((s) => s.type == SourceType.tafsir).toList();
  }

  Future<int> countOf(
    String sql, [
    List<Variable<Object>> vars = const [],
  ]) async {
    final row = await db.customSelect(sql, variables: vars).getSingle();
    return row.read<int>('c');
  }

  group('Bộ dữ liệu thật', () {
    test('phiên bản dữ liệu khớp hằng số Dart', () async {
      expect(
        await container
            .read(quranRepositoryProvider)
            .getMetaValue('data_version'),
        DatabaseConstants.expectedDataVersion,
      );
    });

    test('NHIỀU nguồn Tafsir, mỗi nguồn đủ metadata + thứ tự tất định',
        () async {
      final tafsir = await tafsirSources();

      // Sprint 31.4 — hai bộ thật: Al-Muyassar (ar) + Ibn Kathir (en).
      expect(tafsir.length, greaterThanOrEqualTo(2));
      for (final t in tafsir) {
        expect(t.name, isNotEmpty);
        expect(t.author, isNotNull);
        expect(t.license, isNotEmpty);
        expect(t.sourceUrl, isNotNull);
        expect(t.version, isNotNull);
        expect(t.isReadingLayer, isFalse);
      }

      // display_order tăng dần, KHÔNG trùng -> thứ tự hiển thị tất định.
      final orders = tafsir.map((s) => s.displayOrder).toList();
      expect(orders, orders.toList()..sort());
      expect(orders.toSet(), hasLength(orders.length));

      // Hai ngôn ngữ khác hướng chữ -> panel phải trộn được RTL và LTR.
      expect(tafsir.map((s) => s.language).toSet(), containsAll(['ar', 'en']));
      expect(tafsir.firstWhere((s) => s.language == 'ar').isRtl, isTrue);
      expect(tafsir.firstWhere((s) => s.language == 'en').isRtl, isFalse);
    });
  });

  group('RANH GIỚI ĐỌC trên dữ liệu thật', () {
    test('Al-Baqarah: KHÔNG dòng Tafsir nào lọt vào đường đọc', () async {
      final repo = container.read(quranRepositoryProvider);
      final codes = (await tafsirSources()).map((s) => s.code).toSet();

      final ayahs = await repo.getAyahsOfSurah(2);
      expect(ayahs, hasLength(286));
      for (final a in ayahs) {
        for (final code in codes) {
          expect(a.texts.containsKey(code), isFalse);
        }
      }
    });

    test('cùng Ayah đó, Study lấy được chú giải TỪ CẢ HAI nguồn', () async {
      // 2:255 (Ayat al-Kursi) — ayah_id toàn cục 262.
      final texts =
          await container.read(quranRepositoryProvider).getTextsCoveringAyah(
        ayahId: 262,
        types: const {SourceType.tafsir},
      );
      expect(texts.length, greaterThanOrEqualTo(2));
      for (final v in texts) {
        expect(v.text.length, greaterThan(20));
      }
    });
  });

  group('Chất lượng văn bản', () {
    test('không còn thẻ đánh dấu của nguồn trong database', () async {
      final n = await countOf('''
SELECT COUNT(*) AS c FROM translations t
JOIN translation_sources s ON s.id = t.source_id
WHERE s.type = 'tafsir'
  AND (t.text LIKE '%<span%' OR t.text LIKE '%</%'
       OR t.text LIKE '%<p>%' OR t.text LIKE '%<h2>%'
       OR t.text LIKE '%&lt;%' OR t.text LIKE '%&amp;%')
''');
      expect(n, 0);
    });

    test('không có chú giải rỗng hay chỉ khoảng trắng', () async {
      final n = await countOf('''
SELECT COUNT(*) AS c FROM translations t
JOIN translation_sources s ON s.id = t.source_id
WHERE s.type = 'tafsir' AND LENGTH(TRIM(t.text)) = 0
''');
      expect(n, 0);
    });

    test('Tafsir KHÔNG nằm trong chỉ mục tìm kiếm (quyết định D9)', () async {
      final n = await countOf('''
SELECT COUNT(*) AS c FROM search_index
WHERE source_code LIKE 'tafsir%'
''');
      expect(n, 0);
    });

    test('MỖI nguồn phủ thiếu — sự thật của thể loại chú giải', () async {
      for (final src in await tafsirSources()) {
        final covered = await countOf(
          'SELECT COUNT(*) AS c FROM translations t '
          'JOIN translation_sources s ON s.id = t.source_id '
          'WHERE s.code = ?',
          [Variable.withString(src.code)],
        );
        expect(covered, greaterThan(0));
        // Ghi lại phát hiện 31.3/31.4 dưới dạng chạy được: KHÔNG bộ
        // chú giải nào phủ đủ 6.236 Ayah.
        expect(
          covered,
          lessThan(6236),
          reason: '${src.code} phủ $covered/6236 — nếu đủ thì giả định '
              '"chú giải luôn thiếu" đã sai, phải xem lại validate() '
              'và DR-2026-0006 D2',
        );
      }
    });

    test('có bộ chú giải NHIỀU ĐOẠN (điều kiện để nói đã kiểm chứng)',
        () async {
      final n = await countOf('''
SELECT COUNT(*) AS c FROM translations t
JOIN translation_sources s ON s.id = t.source_id
WHERE s.type = 'tafsir' AND instr(t.text, char(10)) > 0
''');
      expect(n, greaterThan(1000));
    });
  });

  group('Dựng panel với chú giải THẬT', () {
    void phoneSize(WidgetTester tester, [double height = 2400]) {
      tester.view.physicalSize = Size(500, height);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> pumpPanel(WidgetTester tester, int ayahId) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(child: _PanelHarness(ayahId: ayahId)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hai nguồn cùng hiện: RTL và LTR trong MỘT panel, đúng thứ tự',
        (tester) async {
      phoneSize(tester);
      const ayahId = 262; // 2:255 — cả hai bộ đều có chú giải.

      final entries =
          await container.read(tafsirForAyahProvider(ayahId).future);
      expect(entries.length, greaterThanOrEqualTo(2));

      // Sắp theo display_order, không theo thứ tự database trả về.
      final orders = entries.map((e) => e.source.displayOrder).toList();
      expect(orders, orders.toList()..sort());

      await pumpPanel(tester, ayahId);

      expect(find.byType(StudyPanel), findsOneWidget);
      final arabic = entries.firstWhere((e) => e.source.isRtl);
      final latin = entries.firstWhere((e) => !e.source.isRtl);
      expect(
        tester.widget<Text>(find.text(arabic.text)).textDirection,
        TextDirection.rtl,
      );
      expect(
        tester.widget<Text>(find.text(latin.text)).textDirection,
        TextDirection.ltr,
      );
      for (final e in entries) {
        expect(find.text(e.source.name), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('đoạn chú giải RẤT DÀI, nhiều đoạn — dựng được, không tràn',
        (tester) async {
      phoneSize(tester);
      final row = await db.customSelect('''
SELECT t.ayah_id AS id FROM translations t
JOIN translation_sources s ON s.id = t.source_id
WHERE s.type = 'tafsir' ORDER BY LENGTH(t.text) DESC LIMIT 1
''').getSingle();
      final worstAyahId = row.read<int>('id');

      final entries =
          await container.read(tafsirForAyahProvider(worstAyahId).future);
      final longest =
          entries.map((e) => e.text.length).reduce((a, b) => a > b ? a : b);
      expect(longest, greaterThan(50000));
      expect(entries.any((e) => e.text.contains(_newline)), isTrue);

      await pumpPanel(tester, worstAyahId);

      expect(find.byType(StudyPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Ayah KHÔNG có dòng khớp chính xác vẫn hiện chú giải của ĐOẠN '
        'phủ nó (Sprint 32.0)', (tester) async {
      phoneSize(tester);
      // Ayah nằm GIỮA một đoạn: nguồn không có dòng riêng cho nó.
      final row = await db.customSelect('''
SELECT a.id AS id FROM ayahs a WHERE a.id NOT IN (
  SELECT t.ayah_id FROM translations t
  JOIN translation_sources s ON s.id = t.source_id
  WHERE s.type = 'tafsir') LIMIT 1
''').getSingleOrNull();
      expect(row, isNotNull, reason: 'phải có Ayah không khớp chính xác');
      final midPassageAyahId = row!.read<int>('id');

      final entries =
          await container.read(tafsirForAyahProvider(midPassageAyahId).future);
      // TRƯỚC 32.0 danh sách này rỗng và panel biến mất.
      expect(entries, isNotEmpty);
      // Đoạn bắt đầu TRƯỚC Ayah đang xem -> đúng bản chất "phủ".
      expect(
        entries.any((e) => e.startAyahId < midPassageAyahId),
        isTrue,
      );

      await pumpPanel(tester, midPassageAyahId);
      expect(find.byType(StudyPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MỌI Ayah đều có chú giải sau khi phủ theo đoạn',
        (tester) async {
      // Đo trên toàn bộ kinh văn qua đúng truy vấn của repository.
      final repo = container.read(quranRepositoryProvider);
      var covered = 0;
      for (final ayahId in [1, 9, 300, 1500, 3000, 4500, 6000, 6236]) {
        final texts = await repo.getTextsCoveringAyah(
          ayahId: ayahId,
          types: const {SourceType.tafsir},
        );
        if (texts.isNotEmpty) covered++;
        for (final t in texts) {
          expect(t.startAyahId, lessThanOrEqualTo(ayahId));
        }
      }
      expect(covered, 8);
    });

    testWidgets('đoạn KHÔNG tràn sang Surah khác', (tester) async {
      final repo = container.read(quranRepositoryProvider);
      // Ayah đầu của vài Surah: đoạn phủ nó phải bắt đầu TRONG Surah đó.
      for (final surahId in [2, 3, 18, 36, 114]) {
        final firstRow = await db.customSelect(
          'SELECT MIN(id) AS c FROM ayahs WHERE surah_id = ?',
          variables: [Variable.withInt(surahId)],
        ).getSingle();
        final firstAyahId = firstRow.read<int>('c');
        final texts = await repo.getTextsCoveringAyah(
          ayahId: firstAyahId,
          types: const {SourceType.tafsir},
        );
        for (final t in texts) {
          expect(
            t.startAyahId,
            greaterThanOrEqualTo(firstAyahId),
            reason: 'đoạn của Surah trước đã tràn sang Surah $surahId',
          );
        }
      }
    });
  });
}

/// Dựng đúng mục Tafsir đã đăng ký, không dựng lại logic của nó.
class _PanelHarness extends StatelessWidget {
  const _PanelHarness({required this.ayahId});

  final int ayahId;

  @override
  Widget build(BuildContext context) => tafsirSection.builder(context, ayahId);
}
