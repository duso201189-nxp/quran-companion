import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_screen.dart';
import 'package:quran_companion/features/search/presentation/search_screen.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_error_state.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_no_results_state.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_result_section.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart';
import 'fixtures/search_test_harness.dart';

/// Repo giả CHỈ cho nhóm test "Sprint R1.1 — hiển thị kết quả thật"
/// bên dưới — trả về danh sách cố định thay vì rỗng như
/// [FakeQuranRepo] dùng chung trong `makeApp()`, để khẳng định
/// [ResultCard]/[SearchResultSection] thật sự render dữ liệu từ
/// provider, không chỉ "không lỗi khi rỗng". Method ngoài phạm vi
/// `throw UnimplementedError()` (quy ước `TESTING_GUIDE.md` §3.5).
class _FakeQuranRepoWithResults implements QuranRepository {
  const _FakeQuranRepoWithResults(this._results);

  final List<AyahSearchResult> _results;

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      _results;

  @override
  Future<List<Surah>> getAllSurahs() => throw UnimplementedError();

  @override
  Future<Surah?> getSurahById(int id) => throw UnimplementedError();

  @override
  Future<List<TranslationSource>> getEnabledSources() =>
      throw UnimplementedError();

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) =>
      throw UnimplementedError();

  @override
  Future<List<Reciter>> getEnabledReciters() => throw UnimplementedError();

  @override
  Future<String?> getMetaValue(String key) => throw UnimplementedError();

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) =>
      throw UnimplementedError();
}

/// Bọc [SearchScreen] một mình (route đơn lập, không qua vỏ app thật)
/// với [repo] tuỳ chọn — mẫu "Isolated single-route GoRouter" của
/// `TESTING_GUIDE.md` §3.4, dùng khi test chỉ cần một provider bị ghi
/// đè khác với `makeApp()`'s `FakeQuranRepo` (luôn trả rỗng).
Widget _wrapSearchScreen(QuranRepository repo) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, __) => const SearchScreen())],
  );
  return ProviderScope(
    overrides: [quranRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

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

    testWidgets(
        'Sprint R1.1/R1.2: gõ chữ đủ dài -> gọi engine tìm kiếm thật, '
        'không lỗi (repo giả trong makeApp() trả rỗng, xem '
        'app_harness.dart — kết quả rỗng nên hiện SearchNoResultsState, '
        'đúng hành vi Sprint R1.2 — xem search_screen_test.dart nhóm '
        '"Sprint R1.2" và search_providers_test.dart cho trường hợp có '
        'kết quả)', (tester) async {
      await openSearchScreen(tester);

      await tester.enterText(searchField(), 'الرحمن');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SearchNoResultsState), findsOneWidget);
      expect(find.byType(SearchResultSection), findsNothing);
      expect(find.byType(SearchEmptyState), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Task 7.1.8 — Empty State đầy đủ', () {
    testWidgets('hiển thị tiêu đề và gợi ý gõ', (tester) async {
      await openSearchScreen(tester);

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsOneWidget);
      expect(
        find.text(
          'Nhập tên Surah, số Ayah (ví dụ 2:255), hoặc một từ khoá.',
        ),
        findsOneWidget,
      );
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

      await tester.tap(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byIcon(Icons.clear),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm điều bạn cần trong Qur\'an'), findsOneWidget);
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

    testWidgets('chuyển qua lại các trạng thái không lỗi', (tester) async {
      await openSearchScreen(tester);
      await pickDevPreview(tester, 'Results');
      await pickDevPreview(tester, 'Error');
      await pickDevPreview(tester, 'Loading');

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

  group('Sprint R1.1 — hiển thị kết quả tìm kiếm thật', () {
    testWidgets(
        'gõ đủ 2 ký tự -> qua SearchLoadingSkeleton rồi hiện đúng '
        'ResultCard từ searchResultsProvider (không phải dữ liệu mẫu '
        'dev preview)', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([sampleAyah])),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'mercy');
      // pump() thay vì pumpAndSettle() ngay để bắt được khung hình
      // skeleton trước khi debounce 250ms trôi qua.
      await tester.pump();

      expect(find.byType(SearchLoadingSkeleton), findsOneWidget);

      // pumpAndSettle() một mình KHÔNG đảm bảo trôi qua đủ 250ms nếu
      // giữa 2 lần bơm không có frame mới nào được lên lịch (Timer
      // đang chờ không tự tính là "còn frame") — phải tự đẩy đồng hồ
      // ảo qua khỏi mốc debounce trước, rồi mới pumpAndSettle() phần
      // còn lại (rebuild sau khi Future resolve).
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SearchLoadingSkeleton), findsNothing);
      expect(find.byType(SearchResultSection), findsOneWidget);
      expect(find.byType(ResultCard), findsOneWidget);
      expect(find.textContaining('Ar-Rahman'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'xoá hết chữ sau khi có kết quả -> quay lại Empty State, '
        'không còn kết quả cũ sót lại', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([sampleAyah])),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'mercy');
      // Bơm 1 khung trước để widget rebuild và tạo Future debounce
      // MỚI, rồi mới đẩy đồng hồ ảo qua khỏi 250ms — nếu gộp chung 1
      // lần bơm, đồng hồ trôi qua TRƯỚC khi Future mới kịp tồn tại.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byType(ResultCard), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(ResultCard), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
    });

    testWidgets(
        'gõ 1 ký tự (dưới ngưỡng 2 ký tự) -> searchAyahs KHÔNG được '
        'gọi, không có khung chờ, và vẫn là Empty State (CHƯA thật sự '
        'tìm nên KHÔNG phải SearchNoResultsState — xem Sprint R1.2 '
        'nhóm test bên dưới)', (tester) async {
      const repo = _FakeQuranRepoWithResults([sampleAyah]);
      await tester.pumpWidget(_wrapSearchScreen(repo));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'm');
      await tester.pumpAndSettle();

      expect(find.byType(SearchLoadingSkeleton), findsNothing);
      expect(find.byType(ResultCard), findsNothing);
      expect(find.byType(SearchNoResultsState), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Sprint R1.2 — trạng thái "không có kết quả"', () {
    testWidgets(
        'truy vấn ≥ 2 ký tự chạy xong nhưng rỗng -> hiện '
        'SearchNoResultsState có ĐÚNG từ khoá, KHÔNG phải Empty/Error/'
        'Results', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([])),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SearchNoResultsState), findsOneWidget);
      expect(find.text('Không tìm thấy kết quả cho "xyz"'), findsOneWidget);
      expect(find.byType(SearchEmptyState), findsNothing);
      expect(find.byType(SearchErrorState), findsNothing);
      expect(find.byType(SearchLoadingSkeleton), findsNothing);
      expect(find.byType(SearchResultSection), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'gõ tiếp một truy vấn CÓ kết quả sau khi đã thấy "không có kết '
        'quả" -> SearchNoResultsState biến mất, ResultCard thật xuất '
        'hiện', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([])),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byType(SearchNoResultsState), findsOneWidget);

      // Đổi sang repo giả có kết quả bằng cách dựng lại widget (đơn
      // giản hơn thay đổi override giữa chừng) — chỉ cần khẳng định 2
      // trạng thái không lẫn vào nhau, không cần đúng 1 phiên tìm.
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([sampleAyah])),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'mercy');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(SearchNoResultsState), findsNothing);
      expect(find.byType(ResultCard), findsOneWidget);
    });

    testWidgets(
        'xoá hết chữ khi đang hiện "không có kết quả" -> quay lại '
        'Empty State', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([])),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byType(SearchNoResultsState), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(SearchNoResultsState), findsNothing);
      expect(find.byType(SearchEmptyState), findsOneWidget);
    });
  });

  group('Sprint R1.3 — focus/bàn phím ổn định qua các lần chuyển trạng thái',
      () {
    testWidgets(
        'chạm ô tìm kiếm rồi gõ ra kết quả thật -> vẫn giữ focus/bàn '
        'phím mở qua Loading -> Results, không bị rớt focus khi thân '
        'màn hình đổi nội dung', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([sampleAyah])),
      );
      await tester.pump();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.enterText(find.byType(TextField), 'mercy');
      await tester.pump();
      // Đúng khung Loading vẫn còn kết nối bàn phím — bài kiểm tra ổn
      // định focus, không phải nội dung Loading (đã có ở nhóm R1.1).
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(ResultCard), findsOneWidget);
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets(
        'bấm nút xoá KHÔNG làm mất focus ô tìm kiếm (chỉ xoá chữ, '
        'không đụng bàn phím)', (tester) async {
      await tester.pumpWidget(
        _wrapSearchScreen(const _FakeQuranRepoWithResults([sampleAyah])),
      );
      await tester.pump();

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'mercy');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(tester.testTextInput.isVisible, isTrue);
    });
  });
}
