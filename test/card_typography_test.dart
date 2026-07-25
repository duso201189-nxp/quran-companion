import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/theme/app_theme.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:quran_companion/shared/utils/highlight.dart';

/// Sprint 27.1 — kiểu chữ và kiểu tô đậm của thẻ nội dung nay dùng
/// chung giữa `ResultCard` (Tìm kiếm), `LibraryAyahTile` (Thư viện)
/// và `_AyahResultTile` (danh sách Surah).
///
/// Trước đây mỗi nơi chép một bản literal; hai bản lệch nhau là lỗi
/// hiển thị âm thầm. Test khoá lại GIÁ TRỊ của các hàm dùng chung, và
/// chứng minh chúng thực sự tới được văn bản hiển thị.

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

/// Span con đầu tiên có nội dung [text] trong widget [Text.rich].
TextSpan _spanWithText(WidgetTester tester, String text) {
  for (final widget in tester.widgetList<Text>(find.byType(Text))) {
    final root = widget.textSpan;
    if (root is! TextSpan) continue;
    for (final child in root.children ?? const <InlineSpan>[]) {
      if (child is TextSpan && child.text == text) return child;
    }
  }
  fail('Không tìm thấy span nào có nội dung "$text"');
}

void main() {
  group('Kiểu chữ dùng chung của thẻ nội dung', () {
    testWidgets('lấy đúng giá trị từ theme, không hardcode màu',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final context = tester.element(find.byType(SizedBox));
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final textTheme = theme.textTheme;

      expect(
        cardSourceLabelStyle(textTheme, scheme),
        textTheme.labelMedium?.copyWith(color: scheme.primary),
      );
      expect(
        cardSecondaryTextStyle(textTheme, scheme),
        textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: scheme.onSurfaceVariant,
        ),
      );
      expect(
        searchHighlightStyle(scheme),
        TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.primary,
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
        ),
      );
      expect(kPreviewArabicFontSize, 22);
    });

    testWidgets('phần khớp từ khoá thật sự mang searchHighlightStyle',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'The Most Merciful',
            highlightQuery: 'Merciful',
          ),
        ),
      );

      final context = tester.element(find.byType(ResultCard));
      final scheme = Theme.of(context).colorScheme;

      expect(
        _spanWithText(tester, 'Merciful').style,
        searchHighlightStyle(scheme),
      );
    });

    testWidgets('nhãn nguồn của ResultCard dùng cardSourceLabelStyle',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
          ),
        ),
      );

      final context = tester.element(find.byType(ResultCard));
      final theme = Theme.of(context);
      final label = tester.widget<Text>(find.text('Ar-Rahman · 55:1'));

      expect(
        label.style,
        cardSourceLabelStyle(theme.textTheme, theme.colorScheme),
      );
    });
  });
}
