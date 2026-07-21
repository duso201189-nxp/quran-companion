import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_screen.dart';
import 'package:quran_companion/features/search/presentation/search_screen.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_error_state.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_result_section.dart';

import 'fixtures/app_harness.dart';
import 'fixtures/search_test_harness.dart';

void main() {
  group('Task 7.1.1 — route + khung màn hình', () {
    testWidgets('route /search mở SearchScreen với Scaffold cơ bản',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsNothing);

      final context = tester.element(find.byType(Scaffold).first);
      unawaited(GoRouter.of(context).push(AppRoutes.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(Scaffold),
        ),
        findsOneWidget,
      );
    });
  });

  group('Task 7.1.3 — điểm vào từ Trang chủ', () {
    testWidgets('nút tìm kiếm trên Trang chủ mở SearchScreen', (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group("Task 7.1.4 — điểm vào từ tab Qur'an", () {
    testWidgets("nút tìm kiếm trên tab Qur'an mở SearchScreen", (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Qur'an").last);
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsNothing);

      // Cụ thể hóa trong SurahListScreen — tránh nhầm với nút tìm kiếm
      // của Trang chủ (vẫn còn trong cây IndexedStack) hoặc icon trang
      // trí trên SearchBar lọc Surah.
      final searchIcon = find.descendant(
        of: find.byType(SurahListScreen),
        matching: find.widgetWithIcon(IconButton, Icons.search),
      );
      expect(searchIcon, findsOneWidget);

      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });

  group('Task 7.1.5 — ô nhập từ khoá', () {
    Finder searchField() => find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(TextField),
        );

    Finder clearButton() => find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byIcon(Icons.clear),
        );

    testWidgets('hiển thị placeholder gợi ý, chưa có nút xoá khi rỗng',
        (tester) async {
      await openSearchScreen(tester);

      expect(find.text("Tìm kiếm trong Qur'an..."), findsOneWidget);
      expect(clearButton(), findsNothing);
    });

    testWidgets('gõ chữ -> hiện nút xoá; bấm xoá -> rỗng lại trở về ẩn',
        (tester) async {
      await openSearchScreen(tester);

      await tester.enterText(searchField(), 'mercy');
      await tester.pumpAndSettle();

      expect(find.text('mercy'), findsOneWidget);
      expect(clearButton(), findsOneWidget);

      await tester.tap(clearButton());
      await tester.pumpAndSettle();

      expect(find.text('mercy'), findsNothing);
      expect(clearButton(), findsNothing);
    });

    testWidgets('gõ chữ chưa gọi truy vấn hay hiển thị kết quả nào',
        (tester) async {
      await openSearchScreen(tester);

      await tester.enterText(searchField(), 'الرحمن');
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.6 — chuyển đổi Tìm kiếm / Hỏi AI', () {
    testWidgets('hiển thị 2 chế độ, Tìm kiếm đang chọn, Hỏi AI bị khoá',
        (tester) async {
      await openSearchScreen(tester);

      expect(find.text('Tìm kiếm'), findsOneWidget);
      expect(find.text('Hỏi AI · Sắp ra mắt'), findsOneWidget);

      final button = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(button.selected, {SearchMode.search});
      final askSegment =
          button.segments.firstWhere((s) => s.value == SearchMode.ask);
      expect(askSegment.enabled, isFalse);
    });

    testWidgets('bấm vào Hỏi AI không đổi chế độ, không lỗi', (tester) async {
      await openSearchScreen(tester);

      await tester.tap(find.text('Hỏi AI · Sắp ra mắt'));
      await tester.pumpAndSettle();

      final button = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(button.selected, {SearchMode.search});
      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.7 — Scope Chips', () {
    Finder scopeChips() => find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(ChoiceChip),
        );

    testWidgets('hiển thị 3 scope chip, "Tất cả" đang chọn mặc định',
        (tester) async {
      await openSearchScreen(tester);

      final chips = tester.widgetList<ChoiceChip>(scopeChips()).toList();
      expect(chips, hasLength(3));
      expect((chips[0].label as Text).data, 'Tất cả');
      expect((chips[1].label as Text).data, "Qur'an");
      expect((chips[2].label as Text).data, 'Ghi chú của tôi');
      expect(chips[0].selected, isTrue);
      expect(chips[1].selected, isFalse);
      expect(chips[2].selected, isFalse);
    });

    testWidgets('bấm chip khác chỉ đổi lựa chọn trực quan, không đụng Mode',
        (tester) async {
      await openSearchScreen(tester);

      await tester.tap(scopeChips().at(1)); // "Qur'an"
      await tester.pumpAndSettle();

      final chips = tester.widgetList<ChoiceChip>(scopeChips()).toList();
      expect(chips[0].selected, isFalse);
      expect(chips[1].selected, isTrue);
      expect(chips[2].selected, isFalse);

      // Search Mode hoàn toàn độc lập — đổi Scope không đụng Mode.
      final mode = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(mode.selected, {SearchMode.search});

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.8 — Empty State đầy đủ', () {
    testWidgets('hiển thị tiêu đề, gợi ý gõ, và 2 khu vực placeholder',
        (tester) async {
      await openSearchScreen(tester);

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsOneWidget);
      expect(
        find.text(
          'Nhập tên Surah, số Ayah (ví dụ 2:255), hoặc một từ khoá.',
        ),
        findsOneWidget,
      );
      expect(find.text('Gần đây'), findsOneWidget);
      expect(find.text('Gợi ý'), findsOneWidget);

      final recentChips = find.descendant(
        of: find.byKey(const Key('search-empty-recent-chips')),
        matching: find.byType(Container),
      );
      final suggestedChips = find.descendant(
        of: find.byKey(const Key('search-empty-suggested-chips')),
        matching: find.byType(Container),
      );
      expect(recentChips, findsNWidgets(3));
      expect(suggestedChips, findsNWidgets(4));
    });

    testWidgets('gõ chữ -> Empty State biến mất; xoá hết -> quay lại',
        (tester) async {
      await openSearchScreen(tester);

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(TextField),
        ),
        'mercy',
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsNothing);
      expect(find.text('Gần đây'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byIcon(Icons.clear),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsOneWidget);
    });

    testWidgets('không đụng Mode/Scope, không lỗi', (tester) async {
      await openSearchScreen(tester);

      final mode = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(mode.selected, {SearchMode.search});

      final scopeChips = tester
          .widgetList<ChoiceChip>(
            find.descendant(
              of: find.byType(SearchScreen),
              matching: find.byType(ChoiceChip),
            ),
          )
          .toList();
      expect(scopeChips[0].selected, isTrue);

      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.9 — SearchLoadingSkeleton', () {
    testWidgets('mặc định vẽ 3 thẻ khung xương, không lỗi', (tester) async {
      await tester.pumpWidget(localizedTestApp(const SearchLoadingSkeleton()));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('search-loading-card-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('search-loading-card-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('search-loading-card-2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('search-loading-card-3')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('itemCount tuỳ chỉnh được', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const SearchLoadingSkeleton(itemCount: 5)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('search-loading-card-4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('search-loading-card-5')),
        findsNothing,
      );
    });

    testWidgets('có nhãn accessibility "Đang tìm kiếm..." (live region)',
        (tester) async {
      await tester.pumpWidget(localizedTestApp(const SearchLoadingSkeleton()));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Đang tìm kiếm...'), findsOneWidget);
    });

    testWidgets(
        'không tự hiển thị trong SearchScreen — mặc định dev preview tắt '
        '(off), chỉ bật qua nút dev (Task 7.1.13)', (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchLoadingSkeleton), findsNothing);

      // Mode/Scope vẫn không đổi — mặc định chưa bật preview nào.
      final mode = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(mode.selected, {SearchMode.search});
    });
  });

  group('Task 7.1.13 — bộ chuyển trạng thái dành cho dev', () {
    testWidgets(
        'nút dev preview có mặt trên AppBar (flutter test luôn '
        'chạy ở debug mode)', (tester) async {
      await openSearchScreen(tester);

      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
    });

    testWidgets('chọn Loading -> hiện SearchLoadingSkeleton, ẩn Empty State',
        (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Loading');

      expect(find.byType(SearchLoadingSkeleton), findsOneWidget);
      expect(find.byType(SearchEmptyState), findsNothing);
    });

    testWidgets(
        'chọn Results -> hiện SearchResultSection với ResultCard '
        'từ bộ dữ liệu mẫu tĩnh', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');

      expect(find.byType(SearchResultSection), findsOneWidget);
      expect(find.byType(ResultCard), findsNWidgets(3));
      expect(find.byType(SearchEmptyState), findsNothing);
    });

    testWidgets(
        'chọn Error -> hiện SearchErrorState; bấm Thử lại quay về '
        'Off (Empty State thật)', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Error');

      expect(find.byType(SearchErrorState), findsOneWidget);
      expect(find.byType(SearchEmptyState), findsNothing);

      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchErrorState), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
    });

    testWidgets('chọn Empty tường minh -> vẫn là SearchEmptyState',
        (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Loading');
      expect(find.byType(SearchLoadingSkeleton), findsOneWidget);

      await pickDevPreview(tester, 'Empty');
      expect(find.byType(SearchLoadingSkeleton), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
    });

    testWidgets(
        'chọn "Off (real)" sau khi đã xem trước -> quay lại hành vi '
        'thật', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');
      expect(find.byType(ResultCard), findsNWidgets(3));

      await pickDevPreview(tester, 'Off (real)');
      expect(find.byType(ResultCard), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
    });

    testWidgets(
        'chuyển qua lại các trạng thái không đụng Mode/Scope, '
        'không lỗi', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');
      await pickDevPreview(tester, 'Error');
      await pickDevPreview(tester, 'Loading');

      final mode = tester.widget<SegmentedButton<SearchMode>>(
        find.byType(SegmentedButton<SearchMode>),
      );
      expect(mode.selected, {SearchMode.search});

      final scopeChips = tester
          .widgetList<ChoiceChip>(
            find.descendant(
              of: find.byType(SearchScreen),
              matching: find.byType(ChoiceChip),
            ),
          )
          .toList();
      expect(scopeChips[0].selected, isTrue);

      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.14 — chạm ResultCard mở đúng Ayah trên trang đọc', () {
    Future<void> openResultsPreview(WidgetTester tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');
    }

    testWidgets(
        'chạm ResultCard (Al-Fatihah 1:1) -> lưu đúng vị trí và mở '
        'ReadingScreen', (tester) async {
      await openResultsPreview(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(
        container.read(readingPositionStoreProvider).positionFor(1),
        isNull,
      );
      expect(find.byType(ReadingScreen), findsNothing);

      await tester.tap(find.text('Al-Fatihah · 1:1'));
      await tester.pumpAndSettle();

      // ayahNumber 1 -> ayahIndex 0 (1-based hiển thị, 0-based lưu).
      expect(
        container.read(readingPositionStoreProvider).positionFor(1),
        0,
      );
      expect(find.byType(ReadingScreen), findsOneWidget);
    });

    testWidgets(
        'chạm ResultCard khác Ayah (Ar-Rahman 55:2) -> lưu ĐÚNG chỉ số '
        'Ayah đó, không phải luôn là 0', (tester) async {
      await openResultsPreview(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      await tester.tap(find.text('Ar-Rahman · 55:2'));
      await tester.pumpAndSettle();

      // ayahNumber 2 -> ayahIndex 1 — chứng minh phép trừ 1 chạy
      // đúng, không phải trùng hợp ayahNumber 1 -> 0.
      expect(
        container.read(readingPositionStoreProvider).positionFor(55),
        1,
      );
    });

    testWidgets(
        'dùng lại ĐÚNG reading_position_store — không tạo bảng lưu '
        'lịch sử đọc riêng cho Search', (tester) async {
      await openResultsPreview(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final storeBeforeTap = container.read(readingPositionStoreProvider);

      await tester.tap(find.text('Al-Fatihah · 1:1'));
      await tester.pumpAndSettle();

      // Cùng một provider/instance trước và sau khi chạm — chứng
      // minh Search không nối vào một store riêng.
      final storeAfterTap = container.read(readingPositionStoreProvider);
      expect(identical(storeBeforeTap, storeAfterTap), isTrue);
      expect(storeAfterTap.positionFor(1), 0);
    });

    testWidgets(
        'dùng lại ĐÚNG route top-level AppRoutes.read (giống '
        'LibraryScreen._open) — không có route mới, không dùng '
        'AppRoutes.surahReading (route lồng trong shell, gây xung đột '
        'Navigator khi push từ ngoài vỏ tab)', (tester) async {
      await openResultsPreview(tester);

      await tester.tap(find.text('Al-Fatihah · 1:1'));
      await tester.pumpAndSettle();

      // AppRoutes.read(1) == '/read/1' chỉ khớp path '/read/:id' —
      // nếu code dùng nhầm AppRoutes.surahReading, ReadingScreen ở
      // đây sẽ không mount được (crash Navigator, xem doc comment
      // reading_navigation.dart), nên chỉ cần widget mount đúng
      // surahId là đủ bằng chứng route top-level đã được dùng.
      final screen = tester.widget<ReadingScreen>(find.byType(ReadingScreen));
      expect(screen.surahId, 1);
      expect(AppRoutes.read(1), '/read/1');
    });
  });
}
