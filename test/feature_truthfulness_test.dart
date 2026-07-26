import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/feature_gate.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/features/lexicon/data/lexicon_providers.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';

/// RC-1 — CỔNG TRUNG THỰC.
///
/// Ba lời hứa mà bản build phải giữ, kiểm trên ĐÚNG database sẽ phát
/// hành chứ không phải trên repo giả:
///
/// 1. Tính năng đang hiện KHÔNG BAO GIỜ dẫn tới kho dữ liệu rỗng.
/// 2. Mọi lối vào trong tab Học đều giải ra nội dung thật.
/// 3. Không nhãn nào trên màn hình tuyên bố có AI.
///
/// Lỗi loại này sống sót qua 26 sprint vì KHÔNG CÓ GÌ ĐI TÌM NÓ: mã
/// đúng, test xanh, phân tích tĩnh sạch — chỉ có dữ liệu là không tồn
/// tại. Đây là thứ đi tìm.

const _assetPath = 'assets/database/quran.sqlite';

void main() {
  group('Nhãn không được hứa AI', () {
    // Không cần database — đọc thẳng file .arb, nguồn của mọi chữ
    // người dùng đọc.
    const arbFiles = [
      'lib/l10n/app_vi.arb',
      'lib/l10n/app_en.arb',
      'lib/l10n/app_ar.arb',
    ];

    test('không chuỗi nào tuyên bố trí tuệ nhân tạo', () {
      // App KHÔNG có mô hình và KHÔNG suy luận: `AITutorRepositoryImpl`
      // tự ghi rõ "KHÔNG có logic AI/LLM nào". Chừng nào điều đó còn
      // đúng, không chuỗi nào được nói ngược lại.
      const claims = [
        'AI',
        'A.I.',
        'trí tuệ nhân tạo',
        'ذكاء اصطناعي',
        'GPT',
        'LLM',
      ];

      for (final path in arbFiles) {
        final map = jsonDecode(File(path).readAsStringSync()) as Map;
        for (final entry in map.entries) {
          final key = entry.key as String;
          final value = entry.value;
          if (key.startsWith('@') || value is! String) continue;
          for (final claim in claims) {
            final pattern = RegExp(
              claim == 'AI' ? r'\bAI\b' : RegExp.escape(claim),
              caseSensitive: claim != 'AI',
            );
            expect(
              pattern.hasMatch(value),
              isFalse,
              reason: '$path → "$key" tuyên bố "$claim": "$value"',
            );
          }
        }
      }
    });

    test('không khoá nào còn mang tên cũ aiTutor', () {
      for (final path in arbFiles) {
        final map = jsonDecode(File(path).readAsStringSync()) as Map;
        for (final key in map.keys) {
          expect(
            (key as String).toLowerCase().contains('aitutor'),
            isFalse,
            reason: '$path còn khoá $key',
          );
        }
      }
    });
  });

  final file = File(_assetPath);
  if (!file.existsSync()) {
    test('bỏ qua: chưa build assets/database/quran.sqlite', () {}, skip: true);
    return;
  }

  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    final copy = File('${file.path}.truth-copy');
    copy.writeAsBytesSync(file.readAsBytesSync());
    db = AppDatabase(NativeDatabase(copy));
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      if (copy.existsSync()) copy.deleteSync();
    });
  });

  group('Cổng tính năng khớp dữ liệu thật', () {
    test('mỗi GatedFeature: cổng mở KHI VÀ CHỈ KHI dữ liệu có thật', () async {
      for (final feature in GatedFeature.values) {
        final open =
            await container.read(featureAvailabilityProvider(feature).future);

        final hasData = switch (feature) {
          GatedFeature.flashcards => (await container
                  .read(lexiconRepositoryProvider)
                  .searchLemmas(limit: 1))
              .isNotEmpty,
        };

        expect(
          open,
          hasData,
          reason: '$feature: cổng nói $open nhưng dữ liệu nói $hasData',
        );
      }
    });

    test('Flashcard đóng trên bản dữ liệu này — và nêu đúng lý do', () async {
      // Không khoá cứng "phải đóng": khi morphology được nạp, cổng
      // phải TỰ mở mà không ai sửa test. Điều được khoá là mối quan hệ
      // giữa hai vế.
      final lemmas = await db
          .customSelect('SELECT COUNT(*) AS c FROM lemmas')
          .getSingle()
          .then((r) => r.read<int>('c'));
      final open = await container
          .read(featureAvailabilityProvider(GatedFeature.flashcards).future);

      expect(open, lemmas > 0);
      if (!open) {
        expect(
          lemmas,
          0,
          reason: 'cổng đóng thì bảng lemmas phải thật sự rỗng',
        );
      }
    });
  });

  group('Lối vào Học giải ra nội dung thật', () {
    test('Quiz luôn có kho câu hỏi — dựng từ nội dung Qur\'an', () async {
      final surahs =
          await container.read(quranRepositoryProvider).getAllSurahs();
      expect(surahs, hasLength(114));
    });

    test('Study Workspace: Ayah bất kỳ đều giải ra chú giải', () async {
      final covered = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM ayahs a WHERE EXISTS ('
            '  SELECT 1 FROM translations t'
            '  JOIN translation_sources s ON s.id = t.source_id'
            "  WHERE s.type = 'tafsir' AND t.ayah_id <= a.id"
            '    AND t.ayah_id >= ('
            '      SELECT MIN(a2.id) FROM ayahs a2 WHERE a2.surah_id = a.surah_id'
            '    )'
            ')',
          )
          .getSingle()
          .then((r) => r.read<int>('c'));
      expect(covered, 6236);
    });

    test('Tìm kiếm có chỉ mục thật đứng sau', () async {
      final rows = await db
          .customSelect('SELECT COUNT(*) AS c FROM search_index')
          .getSingle()
          .then((r) => r.read<int>('c'));
      expect(rows, greaterThan(0));

      final hits = await container
          .read(quranRepositoryProvider)
          .searchAyahs('الرحمن', limit: 5);
      expect(hits, isNotEmpty);
    });
  });
}
