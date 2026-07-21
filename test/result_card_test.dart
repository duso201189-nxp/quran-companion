import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';

import 'fixtures/search_test_harness.dart';

Text _textWithContent(WidgetTester tester, String content) {
  return tester.widgetList<Text>(find.byType(Text)).firstWhere(
        (w) => (w.data ?? w.textSpan?.toPlainText()) == content,
      );
}

void main() {
  group('Task 7.1.10 — ResultCard (nền tảng, dùng chung mọi domain)', () {
    testWidgets('hiển thị icon, nhãn nguồn, văn bản chính và văn bản phụ',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
            primaryTextDirection: TextDirection.rtl,
            secondaryText: 'The Most Merciful',
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.text('Ar-Rahman · 55:1'), findsOneWidget);
      expect(find.text('الرحمن'), findsOneWidget);
      expect(find.text('The Most Merciful'), findsOneWidget);

      final primary = _textWithContent(tester, 'الرحمن');
      expect(primary.textDirection, TextDirection.rtl);
      expect(primary.maxLines, 2);
    });

    testWidgets(
        'secondaryText tuỳ chọn — không có vẫn hiển thị đúng (domain '
        'không có bản dịch, vd Hadith sau này)', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const ResultCard(
            icon: Icons.book_outlined,
            sourceLabel: 'Sahih al-Bukhari · 1234',
            primaryText: 'Một đoạn Hadith mẫu để kiểm thử bố cục.',
          ),
        ),
      );

      expect(find.text('Sahih al-Bukhari · 1234'), findsOneWidget);
      expect(
        find.text('Một đoạn Hadith mẫu để kiểm thử bố cục.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('có từ khoá tô đậm vẫn giữ nguyên toàn bộ văn bản, không lỗi',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
            primaryTextDirection: TextDirection.rtl,
            secondaryText: 'The Most Merciful',
            highlightQuery: 'رحمن',
          ),
        ),
      );

      expect(find.text('الرحمن'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gộp thành MỘT nhãn accessibility duy nhất', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
            primaryTextDirection: TextDirection.rtl,
            secondaryText: 'The Most Merciful',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Ar-Rahman · 55:1. الرحمن. The Most Merciful'),
        findsOneWidget,
      );
    });

    testWidgets('có onTap -> chạm gọi callback; không có onTap -> không lỗi',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        localizedTestApp(
          ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ResultCard));
      expect(tapped, isTrue);

      tapped = false;
      await tester.pumpWidget(
        localizedTestApp(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
          ),
        ),
      );
      await tester.tap(find.byType(ResultCard));
      expect(tapped, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'ResultCard.fromAyah dùng đúng entity AyahSearchResult có '
        'sẵn — không bịa shape mới', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          ResultCard.fromAyah(sampleAyah, highlightQuery: 'رحمن'),
        ),
      );

      expect(find.text('Ar-Rahman · 55:1'), findsOneWidget);
      expect(find.text('الرحمن'), findsOneWidget);
      expect(find.text('The Most Merciful'), findsOneWidget);

      final primary = _textWithContent(tester, 'الرحمن');
      expect(primary.textDirection, TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ResultCard.fromAyah không có bản dịch vẫn hiển thị được',
        (tester) async {
      const result = AyahSearchResult(
        ayahId: 1,
        surahId: 1,
        ayahNumber: 1,
        surahNameLatin: 'Al-Fatihah',
        arabic: 'بسم الله الرحمن الرحيم',
      );

      await tester.pumpWidget(localizedTestApp(ResultCard.fromAyah(result)));

      expect(find.text('Al-Fatihah · 1:1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
