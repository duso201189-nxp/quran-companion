import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../quran/domain/entities/ayah_search_result.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../data/search_providers.dart';
import 'widgets/search_error_state.dart';
import 'widgets/search_no_results_state.dart';
import 'widgets/search_result_section.dart';

/// Năm trạng thái mà bộ chuyển đổi dành cho dev (Task 7.1.13) có thể
/// đặt — [real] nghĩa là "tắt xem trước, dùng hành vi thật của màn
/// hình". CỐ Ý KHÔNG dùng `_DevPreviewState?` (nullable) với `null`
/// đại diện cho "tắt": `PopupMenuButton` của Flutter tự diễn giải
/// kết quả `null` từ `showMenu` là "đóng menu không chọn gì" và gọi
/// `onCanceled` thay vì `onSelected` (xem
/// `packages/flutter/lib/src/material/popup_menu.dart`, dòng
/// `if (newValue == null) { onCanceled?.call(); return; }`) — nghĩa
/// là một mục menu có `value: null` sẽ KHÔNG BAO GIỜ thật sự được
/// chọn. [real] là một giá trị enum tường minh để tránh đúng cái bẫy
/// đó.
enum _DevPreviewState { real, empty, loading, results, error }

/// Dữ liệu mẫu TĨNH cho phần xem trước "Results" — chỉ phục vụ dev
/// preview (loại khỏi bản release cùng với cả nút bật/tắt, xem
/// [kDebugMode] ở [_SearchScreenState._buildBody]). Dùng lại đúng
/// entity domain đã có (`AyahSearchResult`), không bịa shape mới —
/// cùng kỷ luật với `ResultCard.fromAyah` (Task 7.1.10).
const _devPreviewResults = [
  AyahSearchResult(
    ayahId: 2532,
    surahId: 55,
    ayahNumber: 1,
    surahNameLatin: 'Ar-Rahman',
    arabic: 'الرحمن',
    translation: 'The Most Merciful',
  ),
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
    translation: 'In the name of Allah, the Most Gracious, the Most Merciful',
  ),
];

/// Màn hình Tìm kiếm — route top-level (không phải tab), push
/// full-screen giống "Thư viện của tôi" (xem `DR-2026-0002` mục 1).
///
/// Sprint 7.1 / Task 7.1.5: ô nhập từ khoá thay cho tiêu đề AppBar —
/// gợi ý placeholder, nút xoá hiện khi có chữ.
///
/// Sprint R1.1: gõ giờ đồng bộ vào [searchQueryProvider]
/// (`search/data/search_providers.dart` — ĐỘC LẬP với
/// `surahSearchQueryProvider` của `SurahListScreen`) và hiển thị kết quả
/// FTS5 thật qua [SearchResultSection.ayahs] — xem
/// `docs/release/PHASE3_SPRINT_R1_DESIGN_REVIEW.md`.
///
/// Sprint R1.2: truy vấn ≥ 2 ký tự chạy xong nhưng rỗng giờ hiện
/// [SearchNoResultsState] (khác Empty State/Loading/Error) thay vì
/// [SearchResultSection] rỗng. Truy vấn dưới 2 ký tự (chưa thật sự
/// chạy tìm) vẫn là Empty State — xem nhánh trong [_buildBody].
///
/// Task 7.1.6 (chuyển chế độ Tìm kiếm / "Hỏi AI") và Task 7.1.7 (Scope
/// Chips: Tất cả / Qur'an / Ghi chú của tôi) GỠ BỎ hoàn toàn ở Sprint
/// R3b.2 — cả `SearchMode` lẫn `SearchScope` không còn tồn tại trong
/// tệp này. Lý do: "Hỏi AI" luôn khoá từ khi xây (chưa có logic AI
/// thật, `DR-2026-0002` mục 5–6); "Tất cả" và "Qur'an" luôn chạy chung
/// một engine (không có 2 hành vi khác nhau để chọn); "Ghi chú của tôi"
/// bị khoá ở Sprint R3b.1 sau khi phát hiện nó render trống khi chọn.
/// Ba yếu tố cộng lại: hàng điều khiển 2 tầng không còn tầng nào tạo ra
/// khác biệt hành vi thật. Xem
/// `docs/release/PHASE3_SPRINT_R3B_DESIGN_REVIEW.md` §3–4 cho phân
/// tích, `docs/release/PHASE3_SPRINT_R3B_2_REPORT.md` cho việc thực
/// hiện. KHÔNG thay bằng cờ tính năng hay mã ẩn — khi một trục có dữ
/// liệu thật (AI thật; hoặc Notes có FTS5 index), thêm lại đúng kiểu
/// điều khiển tương ứng lúc đó từ đầu, không phục hồi mã cũ.
///
/// Task 7.1.8 (Empty State: tiêu đề + gợi ý cách gõ + hai khu vực
/// "Gần đây" / "Gợi ý" dạng khối placeholder xám) — hai khu vực đó GỠ
/// BỎ hoàn toàn ở Sprint R3b's close-out patch (2026-08-03), cùng đợt
/// với việc gỡ AI toggle/Scope Chips ở R3b.2: khối xám dưới một tiêu
/// đề thật không truyền đạt gì (không chữ, không thao tác được), và
/// Recent Searches/Suggestions vẫn chưa có ngày triển khai thật —
/// giữ hình dạng bố cục cho một tính năng chưa có lịch không còn hợp
/// lý sau khi toàn bộ Search đã được rà soát vì tính trung thực. Empty
/// State giờ chỉ còn icon + tiêu đề + gợi ý cách gõ. Xem
/// `docs/release/PHASE3_SPRINT_R3B_PLAN.md` mục A4/A5,
/// `docs/release/PHASE3_R3B_CLOSEOUT_PATCH_REPORT.md`. Khi Recent
/// Searches/Suggestions có dữ liệu thật, xây lại từ đầu đúng hình dạng
/// lúc đó cần, không phục hồi khối placeholder cũ.
///
/// Task 7.1.9: [SearchLoadingSkeleton] — component khung xương chờ
/// tải. Không có truy vấn thật (`DR-2026-0002` mục 4 — chưa có
/// provider) nên không có tín hiệu "đang tải" hợp lệ để tự bật —
/// chỉ xem được qua bộ chuyển trạng thái dành cho dev (Task 7.1.13).
///
/// Task 7.1.13: bộ chuyển trạng thái CHỈ-DÀNH-CHO-DEV — một nút trên
/// AppBar (biểu tượng bọ), CHỈ tồn tại khi `kDebugMode == true`, cho
/// phép ép thân màn hình hiển thị 1 trong 4 trạng thái
/// (Empty/Loading/Results/Error) mà KHÔNG cần gõ gì hay có truy vấn
/// thật. `kDebugMode` là hằng số biên dịch của Flutter
/// (`package:flutter/foundation.dart`) — nhánh `if (kDebugMode)` bị
/// loại bỏ hoàn toàn khỏi mã máy khi build `--release` (tree
/// shaking), nên nút này và toàn bộ logic xem trước không tồn tại
/// trong bản phát hành, không cần gói phụ thuộc mới nào.
///
/// Task 7.1.14: chạm vào `ResultCard` (qua preview "Results" của
/// 7.1.13 hôm nay; qua kết quả tìm kiếm thật khi search engine landing
/// sau này) gọi [openAyahInReadingScreen] — hàm DÙNG CHUNG với mọi
/// tính năng "nhảy tới Ayah" khác trong app (`DR-2026-0002` mục 9),
/// KHÔNG tạo cơ chế lưu vị trí đọc hay route mới. Xem doc comment của
/// hàm đó (`reading_navigation.dart`) để biết lý do đặt ở đó thay vì
/// trong file này.
///
/// Task 7.1.15: đợt kiểm tra + cải thiện accessibility toàn diện. Hầu
/// hết nhãn/role/loại trừ semantics trang trí đã có sẵn từ các task
/// trước (mỗi widget tự làm đúng lúc xây); phần thêm MỚI ở task này
/// là đánh dấu [Semantics.header] cho các tiêu đề khu vực (Empty
/// State + [SearchResultSection]) để trình đọc màn hình điều hướng
/// được theo "heading". Xem `test/search_accessibility_test.dart`
/// cho các phép kiểm: touch target ≥ 48dp, RTL, cỡ chữ 200%, thứ tự
/// đọc, không có Semantics thừa.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();

  /// [_DevPreviewState.real] = hành vi thật (theo [_queryController]);
  /// giá trị khác = đang ép xem trước một trạng thái (chỉ có thể xảy
  /// ra qua nút dev, chỉ tồn tại khi [kDebugMode]).
  _DevPreviewState _devPreview = _DevPreviewState.real;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  /// Thân màn hình — ưu tiên trạng thái xem trước của dev (chỉ khả
  /// dụng khi [kDebugMode]), nếu không thì rơi về hành vi thật: Empty
  /// State khi ô trống, còn lại theo [searchResultsProvider] thật
  /// (loading/error/data) — xem [searchQueryProvider].
  Widget _buildBody(AppLocalizations l10n) {
    if (kDebugMode) {
      switch (_devPreview) {
        case _DevPreviewState.real:
          break; // rơi xuống hành vi thật bên dưới
        case _DevPreviewState.empty:
          return SearchEmptyState(l10n: l10n);
        case _DevPreviewState.loading:
          return const SearchLoadingSkeleton();
        case _DevPreviewState.results:
          return SearchResultSection.ayahs(
            l10n: l10n,
            results: _devPreviewResults,
            onResultTap: (result) => openAyahInReadingScreen(
              context,
              ref,
              surahId: result.surahId,
              ayahNumber: result.ayahNumber,
            ),
          );
        case _DevPreviewState.error:
          return SearchErrorState(
            onRetry: () => setState(() => _devPreview = _DevPreviewState.real),
          );
      }
    }
    final query = _queryController.text;
    if (query.trim().isEmpty) {
      return SearchEmptyState(l10n: l10n);
    }
    // Sprint R1.1: engine FTS5 chỉ nối cho nội dung Qur'an — domain duy
    // nhất có dữ liệu hôm nay. Sprint R3b.2 gỡ bỏ Chế độ Tìm kiếm/Hỏi AI
    // và Scope Chips (xem doc comment [SearchScreen]) nên không còn
    // nhánh nào cần rẽ trước khi gọi provider — tìm kiếm luôn chạy trên
    // nội dung Qur'an.
    final resultsAsync = ref.watch(searchResultsProvider);
    return resultsAsync.when(
      loading: () => const SearchLoadingSkeleton(),
      error: (error, stackTrace) => SearchErrorState(
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (results) {
        if (results.isEmpty) {
          // Dưới ngưỡng 2 ký tự (searchResultsProvider trả rỗng NGAY,
          // KHÔNG gọi searchAyahs — xem search_providers.dart): đây
          // là "chưa gõ đủ để tìm", không phải "tìm xong nhưng rỗng"
          // (Sprint R1.2, mục 1) -> vẫn là Empty State, không phải
          // SearchNoResultsState. Ngưỡng này PHẢI khớp ngưỡng trong
          // searchResultsProvider.
          if (query.trim().length < 2) {
            return SearchEmptyState(l10n: l10n);
          }
          return SearchNoResultsState(query: query);
        }
        return SearchResultSection.ayahs(
          l10n: l10n,
          results: results,
          query: query,
          onResultTap: (result) => openAyahInReadingScreen(
            context,
            ref,
            surahId: result.surahId,
            ayahNumber: result.ayahNumber,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: SearchBar(
          controller: _queryController,
          hintText: l10n.searchQueryHint,
          leading: const Icon(Icons.search),
          elevation: const WidgetStatePropertyAll(0),
          trailing: [
            if (_queryController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: l10n.searchClearTooltip,
                onPressed: () => setState(() {
                  _queryController.clear();
                  // .clear() không tự gọi onChanged (không phải thao
                  // tác gõ của người dùng) -> phải tự đồng bộ
                  // searchQueryProvider, nếu không kết quả cũ sẽ còn
                  // sót lại sau khi ô đã trống.
                  ref.read(searchQueryProvider.notifier).state = '';
                }),
              ),
          ],
          onChanged: (value) => setState(() {
            ref.read(searchQueryProvider.notifier).state = value;
          }),
        ),
        actions: [
          // Chỉ tồn tại khi kDebugMode == true — bị tree-shake khỏi
          // bản release hoàn toàn (xem doc comment SearchScreen).
          if (kDebugMode)
            PopupMenuButton<_DevPreviewState>(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Dev preview (debug only)',
              initialValue: _devPreview,
              onSelected: (value) => setState(() => _devPreview = value),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _DevPreviewState.real,
                  child: Text('Off (real)'),
                ),
                PopupMenuItem(
                  value: _DevPreviewState.empty,
                  child: Text('Empty'),
                ),
                PopupMenuItem(
                  value: _DevPreviewState.loading,
                  child: Text('Loading'),
                ),
                PopupMenuItem(
                  value: _DevPreviewState.results,
                  child: Text('Results'),
                ),
                PopupMenuItem(
                  value: _DevPreviewState.error,
                  child: Text('Error'),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _buildBody(l10n),
        ),
      ),
    );
  }
}

/// Trạng thái rỗng đầy đủ — hiển thị khi ô tìm kiếm chưa có chữ (hoặc
/// khi dev ép xem trước, Task 7.1.13). Trước Sprint R3b's close-out
/// patch còn có 2 khu "Gần đây" / "Gợi ý" dạng khối placeholder xám —
/// gỡ bỏ, xem doc comment [SearchScreen]. Public (đổi tên từ
/// `_EmptyState`) để [SearchScreen._buildBody] và test truy cập
/// trực tiếp, khớp quy ước đặt tên với [SearchLoadingSkeleton] /
/// [SearchErrorState] / [SearchResultSection].
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Icon(
            Icons.travel_explore_outlined,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            l10n.searchEmptyTitle,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.searchEmptySubtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Khung xương chờ tải cho danh sách kết quả Ayah — hình dạng khớp
/// với thẻ kết quả thật (ResultCard, Task 7.1.10 chưa xây): cùng
/// padding/bo góc/màu nền đã dùng cho `_AyahResultTile` hiện có
/// trong SurahListScreen ("Kết quả trong nội dung"), để khi
/// ResultCard thật ra đời, khung chờ không lệch nhịp bố cục.
///
/// Chỉ có 1 nút Semantics ở ngoài (loa đọc "Đang tìm kiếm...") —
/// các thanh xám bên trong bị loại khỏi cây accessibility vì không
/// mang thông tin gì.
class SearchLoadingSkeleton extends StatelessWidget {
  const SearchLoadingSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.searchLoadingLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < itemCount; i++)
              Padding(
                key: ValueKey('search-loading-card-$i'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBar(scheme, width: 96, height: 12),
                      const SizedBox(height: 8),
                      _skeletonBar(scheme, width: double.infinity, height: 22),
                      const SizedBox(height: 6),
                      _skeletonBar(scheme, width: 180, height: 22),
                      const SizedBox(height: 10),
                      _skeletonBar(scheme, width: double.infinity, height: 14),
                      const SizedBox(height: 6),
                      _skeletonBar(scheme, width: 140, height: 14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBar(
    ColorScheme scheme, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
