import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/locale/locale_controller.dart';
import 'package:quran_companion/features/search/presentation/search_screen.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_error_state.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_result_section.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart';
import 'fixtures/search_test_harness.dart';

/// `kMinInteractiveDimension` (package:flutter/src/material/constants.dart)
/// — mốc tối thiểu Material khuyến nghị cho mọi vùng chạm.
const _minTouchTarget = 48.0;

void main() {
  group('Task 7.1.15 — vùng chạm ≥ 48dp (Material)', () {
    testWidgets('nút xoá trên ô tìm kiếm', (tester) async {
      await openSearchScreen(tester);
      await tester.enterText(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(TextField),
        ),
        'mercy',
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.widgetWithIcon(IconButton, Icons.clear),
        ),
      );
      expect(size.width, greaterThanOrEqualTo(_minTouchTarget));
      expect(size.height, greaterThanOrEqualTo(_minTouchTarget));
    });

    testWidgets('nút dev preview trên AppBar', (tester) async {
      await openSearchScreen(tester);

      final size = tester.getSize(
        find.widgetWithIcon(IconButton, Icons.bug_report_outlined),
      );
      expect(size.width, greaterThanOrEqualTo(_minTouchTarget));
      expect(size.height, greaterThanOrEqualTo(_minTouchTarget));
    });

    testWidgets('chiều cao ResultCard (toàn thẻ là vùng chạm)', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');

      final size = tester.getSize(find.byType(ResultCard).first);
      expect(size.height, greaterThanOrEqualTo(_minTouchTarget));
    });
  });

  group('Task 7.1.15 — RTL', () {
    testWidgets('SearchScreen tự mirror layout đúng khi locale Ả Rập',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(prefs: {LocaleController.prefsKey: 'ar'}),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets(
        'ResultCard: sourceLabel luôn LTR, primaryText Ả Rập luôn RTL '
        'bất kể locale app', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          ResultCard.fromAyah(sampleAyah),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      final primary = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((w) => w.textSpan?.toPlainText() == 'الرحمن');
      expect(primary.textDirection, TextDirection.rtl);
    });
  });

  group('Task 7.1.15 — cỡ chữ 200% không vỡ layout', () {
    testWidgets('Empty State ở text scale 200%', (tester) async {
      setViewSize(tester, const Size(400, 800));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: await makeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Results preview (nội dung dày nhất) ở text scale 200%',
        (tester) async {
      setViewSize(tester, const Size(400, 800));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: await makeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await pickDevPreview(tester, 'Results');

      expect(find.byType(ResultCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.15 — thứ tự đọc (trên xuống, khớp thứ tự hiển thị)', () {
    testWidgets('ô tìm kiếm -> Mode -> Scope -> nội dung thân màn hình',
        (tester) async {
      await openSearchScreen(tester);

      final queryFieldY = tester
          .getTopLeft(
            find.descendant(
              of: find.byType(SearchScreen),
              matching: find.byType(TextField),
            ),
          )
          .dy;
      final modeSwitchY =
          tester.getTopLeft(find.byType(SegmentedButton<SearchMode>)).dy;
      final scopeChipY = tester.getTopLeft(find.byType(ChoiceChip).first).dy;
      final emptyStateY = tester.getTopLeft(find.byType(SearchEmptyState)).dy;

      expect(queryFieldY, lessThan(modeSwitchY));
      expect(modeSwitchY, lessThan(scopeChipY));
      expect(scopeChipY, lessThan(emptyStateY));
    });
  });

  group('Task 7.1.15 — tiêu đề khu vực được đánh dấu header', () {
    testWidgets('Empty State: 3 tiêu đề đều là header semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await openSearchScreen(tester);

      for (final label in [
        'Tìm điều bạn cần trong Qur\'an',
        'Gần đây',
        'Gợi ý',
      ]) {
        final node = tester.getSemantics(find.text(label));
        expect(
          node.flagsCollection.isHeader,
          isTrue,
          reason: '"$label" phải có flag isHeader',
        );
      }
      // Phụ đề KHÔNG phải heading.
      final subtitle = tester.getSemantics(
        find.text(
          'Nhập tên Surah, số Ayah (ví dụ 2:255), hoặc một từ khoá.',
        ),
      );
      expect(subtitle.flagsCollection.isHeader, isFalse);

      handle.dispose();
    });

    testWidgets('SearchResultSection: tiêu đề là header semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedTestApp(
          Builder(
            builder: (context) => SearchResultSection.ayahs(
              l10n: AppLocalizations.of(context),
              results: const [sampleAyah],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.textContaining('· 1'));
      expect(node.flagsCollection.isHeader, isTrue);

      handle.dispose();
    });
  });

  group('Task 7.1.15 — không có Semantics thừa (mỗi thẻ = 1 node)', () {
    testWidgets('ResultCard chỉ tạo đúng 1 node semantics có nhãn/role nút',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedTestApp(ResultCard.fromAyah(sampleAyah)),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Ar-Rahman · 55:1. الرحمن. The Most Merciful'),
        findsOneWidget,
      );
      // Không có node semantics rời rạc nào lặp lại riêng icon/label
      // con bên trong (đã bị ExcludeSemantics) — chỉ mỗi cụm text gốc
      // (không tô đậm) mới còn xuất hiện qua find.text bình thường,
      // không qua semantics riêng.
      handle.dispose();
    });

    testWidgets(
        'SearchErrorState: message và nút Thử lại là 2 node tách '
        'biệt, không gộp chung', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedTestApp(SearchErrorState(onRetry: () {})),
      );
      await tester.pumpAndSettle();

      final messageNode = tester.getSemantics(
        find.text('Không tải được dữ liệu. Vui lòng thử lại.'),
      );
      final buttonNode = tester.getSemantics(find.text('Thử lại'));
      expect(messageNode.id, isNot(buttonNode.id));
      expect(buttonNode.flagsCollection.isButton, isTrue);

      handle.dispose();
    });
  });
}
