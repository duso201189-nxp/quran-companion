import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/theme/app_theme.dart';
import 'package:quran_companion/app/theme/theme_controller.dart';
import 'package:quran_companion/features/search/presentation/search_screen.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_error_state.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_result_section.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/search_test_harness.dart';

/// Độ chói tương đối theo công thức WCAG 2.1 (sRGB -> linear -> luminance).
double _relativeLuminance(Color c) {
  double linear(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linear(c.r);
  final g = linear(c.g);
  final b = linear(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Tỉ lệ tương phản WCAG 2.1 giữa hai màu — luôn >= 1.0.
double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a) + 0.05;
  final lb = _relativeLuminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

/// Trộn [foreground] lên [background] theo alpha 0..1 (Porter-Duff
/// "over" đơn giản) — mô phỏng đúng những gì mắt người thấy khi
/// `backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35)`
/// vẽ đè lên nền `scheme.surfaceContainerLow` của thẻ.
Color _compositeOver(Color foreground, Color background, double alpha) {
  return Color.from(
    alpha: 1,
    red: foreground.r * alpha + background.r * (1 - alpha),
    green: foreground.g * alpha + background.g * (1 - alpha),
    blue: foreground.b * alpha + background.b * (1 - alpha),
  );
}

ThemeData _themeFor(Brightness brightness) =>
    brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;

void main() {
  group('Task 7.1.16 — chữ tô đậm (highlight) đủ tương phản', () {
    for (final brightness in Brightness.values) {
      test(
          '${brightness.name}: primary trên primaryContainer(0.35) '
          'phủ surfaceContainerLow đạt tối thiểu WCAG AA cho chữ đậm '
          '(>= 3.0)', () {
        final scheme = _themeFor(brightness).colorScheme;

        final effectiveBg = _compositeOver(
          scheme.primaryContainer,
          scheme.surfaceContainerLow,
          0.35,
        );
        final ratio = _contrastRatio(scheme.primary, effectiveBg);

        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason: 'Tỉ lệ tương phản thực tế: $ratio (scheme: $brightness)',
        );
      });
    }

    testWidgets(
        'ResultCard có highlight vẫn dựng được ở dark mode, '
        'không lỗi', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          ResultCard.fromAyah(sampleAyah, highlightQuery: 'رحمن'),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الرحمن'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group(
      'Task 7.1.16 — surfaceContainerLow / surfaceContainerHighest '
      'phân biệt được (khung xương + placeholder chip)', () {
    for (final brightness in Brightness.values) {
      test('${brightness.name}: 2 màu khác nhau thật sự', () {
        final scheme = _themeFor(brightness).colorScheme;
        expect(
          scheme.surfaceContainerLow,
          isNot(scheme.surfaceContainerHighest),
          reason: 'Hai màu trùng nhau -> khung xương/placeholder sẽ vô '
              'hình trên nền thẻ ở chế độ $brightness',
        );
      });
    }
  });

  group('Task 7.1.16 — không lỗi khi dựng ở dark mode (mọi thành phần)', () {
    testWidgets('SearchErrorState (có nút Thử lại)', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          SearchErrorState(onRetry: () {}),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SearchResultSection.ayahs', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) => SearchResultSection.ayahs(
              l10n: AppLocalizations.of(context),
              results: const [sampleAyah],
            ),
          ),
          theme: AppTheme.dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SearchScreen: Empty State + cả 4 trạng thái dev preview',
        (tester) async {
      await openSearchScreen(
        tester,
        prefs: {ThemeController.prefsKey: 'dark'},
      );
      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);

      for (final label in ['Empty', 'Loading', 'Results', 'Error']) {
        await pickDevPreview(tester, label);
        expect(tester.takeException(), isNull, reason: 'trạng thái $label');
      }
    });

    testWidgets(
        'Mode Switch: nhãn "Ask" (đã khoá) vẫn hiển thị, đọc được ở '
        'dark mode', (tester) async {
      await openSearchScreen(
        tester,
        prefs: {ThemeController.prefsKey: 'dark'},
      );

      expect(find.text('Hỏi AI · Sắp ra mắt'), findsOneWidget);
      final askSegment = tester
          .widget<SegmentedButton<SearchMode>>(
            find.byType(SegmentedButton<SearchMode>),
          )
          .segments
          .firstWhere((s) => s.value == SearchMode.ask);
      expect(askSegment.enabled, isFalse);
      expect(tester.takeException(), isNull);
    });
  });
}
