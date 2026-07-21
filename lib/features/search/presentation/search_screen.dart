import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../quran/domain/entities/ayah_search_result.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import 'widgets/search_error_state.dart';
import 'widgets/search_result_section.dart';

/// Chế độ tìm kiếm — trục riêng, KHÔNG phải nguồn nội dung (xem
/// [SearchMode.ask] vs Scope Chips ở Task 7.1.7). Chỉ 2 giá trị vì
/// đây là Sprint 7.1 (nền tảng UI); khi Bước 7.2+ nối AI thật
/// (`DR-2026-0002` mục 5 — AI là một provider, không thay thế công
/// cụ tìm kiếm), state chọn chế độ nên chuyển sang provider dùng
/// chung nếu có màn hình khác cần đọc — hiện tại chưa có, nên vẫn để
/// state cục bộ.
enum SearchMode { search, ask }

/// Phạm vi nội dung tìm — trục HOÀN TOÀN riêng với [SearchMode] (một
/// bên chọn "cách trả lời", một bên chọn "tìm ở đâu"; xem
/// `DR-2026-0002` mục 2 — Search domain-agnostic). Task 7.1.7: chỉ 2
/// phạm vi có thật hôm nay (Qur'an, Ghi chú của tôi) + "Tất cả"; các
/// domain tương lai (Tafsir, Hadith, Dua...) thêm bằng cách thêm giá
/// trị enum + provider riêng, KHÔNG sửa widget này.
enum SearchScope { all, quran, myNotes }

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
/// gợi ý placeholder, nút xoá hiện khi có chữ. Gõ chỉ cập nhật state
/// cục bộ của ô nhập; chưa truy vấn, chưa hiển thị kết quả — thuộc
/// các task sau (7.1.9 trở đi).
///
/// Task 7.1.6: chuyển chế độ Tìm kiếm / Hỏi AI. "Hỏi AI" luôn khoá
/// (disabled) + nhãn "Sắp ra mắt" — chưa có logic AI (`DR-2026-0002`
/// mục 5, mục 6: AI phụ thuộc mạng, không phải chỗ dựa mặc định).
///
/// Task 7.1.7: Scope Chips — chỉ đổi trạng thái CHỌN trực quan, không
/// lọc hay truy vấn gì. Độc lập hoàn toàn với [_mode].
///
/// Task 7.1.8: Empty State đầy đủ (tiêu đề + gợi ý cách gõ + hai khu
/// vực "Gần đây" / "Gợi ý"). Hai khu vực đó CHƯA có dữ liệu thật —
/// tính năng Recent Searches và Suggestions không nằm trong phạm vi
/// Sprint 7.1 — nên chỉ vẽ khối placeholder (không chữ, không thao
/// tác được) để giữ đúng HÌNH DẠNG bố cục cho lúc nối dữ liệu thật,
/// tránh vẽ sẵn nội dung minh hoạ có thể bị hiểu nhầm là tính năng
/// đã xong.
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
  SearchMode _mode = SearchMode.search;
  SearchScope _scope = SearchScope.all;

  /// [_DevPreviewState.real] = hành vi thật (theo [_queryController]);
  /// giá trị khác = đang ép xem trước một trạng thái (chỉ có thể xảy
  /// ra qua nút dev, chỉ tồn tại khi [kDebugMode]).
  _DevPreviewState _devPreview = _DevPreviewState.real;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String _scopeLabel(SearchScope scope, AppLocalizations l10n) =>
      switch (scope) {
        SearchScope.all => l10n.filterAll,
        SearchScope.quran => l10n.tabQuran,
        SearchScope.myNotes => l10n.searchScopeMyNotes,
      };

  /// Thân màn hình — ưu tiên trạng thái xem trước của dev (chỉ khả
  /// dụng khi [kDebugMode]), nếu không thì rơi về hành vi thật hôm
  /// nay (chỉ có Empty State, vì chưa có search engine).
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
    if (_queryController.text.trim().isEmpty) {
      return SearchEmptyState(l10n: l10n);
    }
    return const SizedBox.shrink();
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
                onPressed: () => setState(_queryController.clear),
              ),
          ],
          onChanged: (_) => setState(() {}),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<SearchMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: SearchMode.search,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.searchLabel),
                    ),
                    ButtonSegment(
                      value: SearchMode.ask,
                      enabled: false,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label:
                          Text('${l10n.searchAskLabel} · ${l10n.comingSoon}'),
                      tooltip: l10n.comingSoon,
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) =>
                      setState(() => _mode = selection.first),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final scope in SearchScope.values) ...[
                      ChoiceChip(
                        label: Text(_scopeLabel(scope, l10n)),
                        selected: _scope == scope,
                        onSelected: (_) => setState(() => _scope = scope),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildBody(l10n),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trạng thái rỗng đầy đủ — hiển thị khi ô tìm kiếm chưa có chữ (hoặc
/// khi dev ép xem trước, Task 7.1.13). Hai khu "Gần đây" / "Gợi ý"
/// chỉ vẽ HÌNH DẠNG (placeholder xám, không chữ, không bấm được) —
/// xem ghi chú Task 7.1.8 ở [SearchScreen]. Public (đổi tên từ
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
        const SizedBox(height: 28),
        Semantics(
          header: true,
          child: Text(
            l10n.searchEmptyRecentSectionTitle,
            style:
                textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        const _PlaceholderChipRow(
          key: Key('search-empty-recent-chips'),
          widths: [72, 96, 60],
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            l10n.searchEmptySuggestedSectionTitle,
            style:
                textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 8),
        const _PlaceholderChipRow(
          key: Key('search-empty-suggested-chips'),
          widths: [88, 64, 100, 76],
        ),
      ],
    );
  }
}

/// Hàng khối placeholder xám (bo tròn, không chữ, không thao tác) —
/// giữ chỗ cho nội dung thật của Recent Searches / Suggestions ở
/// sprint sau. Bọc [ExcludeSemantics] vì không mang thông tin gì cho
/// người dùng trình đọc màn hình.
class _PlaceholderChipRow extends StatelessWidget {
  const _PlaceholderChipRow({super.key, required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final width in widths)
            Container(
              width: width,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
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
