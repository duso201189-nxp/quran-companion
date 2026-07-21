import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_result_section.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/search_test_harness.dart';

// Bộ dữ liệu mẫu tĩnh (3 Ayah) — CHỈ dùng để kiểm thử/minh hoạ, dùng
// lại đúng entity AyahSearchResult có sẵn, không bịa shape mới. Xem
// ghi chú Task 7.1.11 trong search_result_section.dart: bộ dữ liệu
// này KHÔNG nằm trong widget sản phẩm. Mục đầu tiên dùng lại
// [sampleAyah] dùng chung (Task 7.1.18) — 2 mục sau giữ riêng vì mục
// đích của DANH SÁCH này là kiểm số lượng/thứ tự, không phải một kết
// quả đơn lẻ như [sampleAyah] phục vụ.
const _sampleResults = [
  sampleAyah,
  AyahSearchResult(
    ayahId: 2533,
    surahId: 55,
    ayahNumber: 2,
    surahNameLatin: 'Ar-Rahman',
    arabic: 'علم القرآن',
    translation: 'Taught the Qur\'an',
  ),
  AyahSearchResult(
    ayahId: 1,
    surahId: 1,
    ayahNumber: 1,
    surahNameLatin: 'Al-Fatihah',
    arabic: 'بسم الله الرحمن الرحيم',
  ),
];

void main() {
  group('Task 7.1.11 — SearchResultSection (nền tảng, dùng chung mọi domain)',
      () {
    testWidgets('gốc: nhận title + children bất kỳ, không cần domain nào',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SearchResultSection(
            title: 'Hadith · 2',
            children: [Text('placeholder A'), Text('placeholder B')],
          ),
        ),
      );

      expect(find.text('Hadith · 2'), findsOneWidget);
      expect(find.text('placeholder A'), findsOneWidget);
      expect(find.text('placeholder B'), findsOneWidget);
      expect(find.byType(ResultCard), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '.ayahs: tiêu đề gồm số lượng đúng, mỗi kết quả một '
        'ResultCard.fromAyah', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return SearchResultSection.ayahs(
                l10n: l10n,
                results: _sampleResults,
              );
            },
          ),
        ),
      );

      expect(find.text('${l10n.searchResultsAyahs} · 3'), findsOneWidget);
      expect(find.byType(ResultCard), findsNWidgets(3));
      expect(find.text('Ar-Rahman · 55:1'), findsOneWidget);
      expect(find.text('Ar-Rahman · 55:2'), findsOneWidget);
      expect(find.text('Al-Fatihah · 1:1'), findsOneWidget);
    });

    testWidgets(
        '.ayahs: danh sách rỗng vẫn hiển thị tiêu đề "· 0", '
        'không crash', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return SearchResultSection.ayahs(l10n: l10n, results: const []);
            },
          ),
        ),
      );

      expect(find.text('${l10n.searchResultsAyahs} · 0'), findsOneWidget);
      expect(find.byType(ResultCard), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('.ayahs: onResultTap báo đúng Ayah nào được chạm',
        (tester) async {
      AyahSearchResult? tapped;
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return SearchResultSection.ayahs(
                l10n: l10n,
                results: _sampleResults,
                onResultTap: (r) => tapped = r,
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Al-Fatihah · 1:1'));
      expect(tapped, _sampleResults.last);
    });

    testWidgets(
        '.ayahs: không truyền onResultTap -> chạm không lỗi, '
        'không gọi gì', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return SearchResultSection.ayahs(
                l10n: l10n,
                results: _sampleResults,
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Ar-Rahman · 55:1'));
      expect(tester.takeException(), isNull);
    });
  });
}
