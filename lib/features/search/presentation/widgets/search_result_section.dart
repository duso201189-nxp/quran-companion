import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../quran/domain/entities/ayah_search_result.dart';
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
