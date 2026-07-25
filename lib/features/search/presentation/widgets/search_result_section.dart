import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../quran/domain/entities/ayah_search_result.dart';
import '../../../quran/domain/entities/surah.dart';
import 'result_card.dart';

/// Một khu vực kết quả (tiêu đề + số lượng + danh sách thẻ) — HỢP
/// ĐỒNG DÙNG CHUNG cho MỌI domain, giống [ResultCard] (Task 7.1.10):
/// widget gốc chỉ nhận [title] + [children] (đã dựng sẵn, thường là
/// [ResultCard]) — không biết gì về nguồn dữ liệu cụ thể (xem
/// `DR-2026-0002` mục 2, mục 19 — "ResultSection (per domain: header
/// + count) → ResultCard").
///
/// [SearchResultSection.ayahs] là adapter cho domain Ayah — dùng lại
/// ĐÚNG entity đã có (`AyahSearchResult`) và [ResultCard.fromAyah],
/// không bịa shape mới. Domain tương lai (Hadith, Ghi chú, Trả lời
/// AI) sẽ có factory tương ứng của riêng mình theo đúng mẫu này.
///
/// Task 7.1.11 (Sprint 7.1, theo đúng thứ tự backlog gốc): CHỈ xây
/// component lắp ráp — CHƯA gắn vào cây hiển thị của `SearchScreen`
/// (không có truy vấn/provider thật để cung cấp danh sách kết quả —
/// `DR-2026-0002` mục 4, mục 6). Bộ dữ liệu mẫu tĩnh để minh hoạ/kiểm
/// thử nằm trong file test, không nằm trong widget này — giữ widget
/// hoàn toàn không phụ thuộc dữ liệu cụ thể.
///
/// Tiêu đề dùng lại đúng kiểu chữ/khoảng cách đã có ở
/// `_SearchResultsView` (SurahListScreen): `titleSmall`, màu
/// `scheme.primary`, đậm 700, padding `(16, 16, 16, 8)`.
class SearchResultSection extends StatelessWidget {
  const SearchResultSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// Adapter cho domain Ayah.
  factory SearchResultSection.ayahs({
    Key? key,
    required AppLocalizations l10n,
    required List<AyahSearchResult> results,
    String query = '',
    void Function(AyahSearchResult result)? onResultTap,
  }) {
    return SearchResultSection(
      key: key,
      title: '${l10n.searchResultsAyahs} · ${results.length}',
      children: [
        for (final result in results)
          ResultCard.fromAyah(
            result,
            highlightQuery: query,
            onTap: onResultTap == null ? null : () => onResultTap(result),
          ),
      ],
    );
  }

  /// Adapter cho domain Surah (Sprint 26.2) — theo ĐÚNG mẫu của
  /// [SearchResultSection.ayahs]: dùng lại entity `Surah` đã có và
  /// [ResultCard] dùng chung, không thêm widget thẻ riêng.
  ///
  /// Nhãn nguồn dựng ở đây (chứ không trong một factory của
  /// ResultCard) vì cần [l10n] cho số câu — giữ ResultCard hoàn toàn
  /// không phụ thuộc l10n, đúng như thiết kế ban đầu của nó.
  factory SearchResultSection.surahs({
    Key? key,
    required AppLocalizations l10n,
    required List<Surah> results,
    String query = '',
    void Function(Surah surah)? onResultTap,
  }) {
    return SearchResultSection(
      key: key,
      title: '${l10n.searchResultsSurahs} · ${results.length}',
      children: [
        for (final surah in results)
          ResultCard(
            icon: Icons.menu_book_rounded,
            sourceLabel:
                '${surah.id} · ${l10n.surahAyahCount(surah.ayahCount)}',
            primaryText: surah.nameLatin,
            primaryFontSize: 18,
            // Tên tiếng Việt cũng nằm trong dữ liệu mà filterSurahs so
            // khớp -> hiện ra để người dùng thấy VÌ SAO Surah này khớp.
            secondaryText: surah.nameVi,
            highlightQuery: query,
            onTap: onResultTap == null ? null : () => onResultTap(surah),
          ),
      ],
    );
  }

  /// Tiêu đề khu vực, đã bao gồm số lượng (vd "Kết quả trong nội
  /// dung · 3") — dựng sẵn bởi bên gọi/factory, widget gốc không tự
  /// tính đếm gì.
  final String title;

  /// Danh sách thẻ kết quả — thường là [ResultCard], nhưng widget gốc
  /// chấp nhận bất kỳ [Widget] nào (domain tương lai không bắt buộc
  /// phải dùng ResultCard).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
