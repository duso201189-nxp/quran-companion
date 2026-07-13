import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/utils/highlight.dart';
import '../../../quran/domain/entities/ayah_search_result.dart';

/// Thẻ kết quả tìm kiếm — HỢP ĐỒNG HIỂN THỊ DÙNG CHUNG cho MỌI domain
/// (Qur'an hôm nay; Hadith, Ghi chú, Trả lời AI ở các sprint sau —
/// xem `DR-2026-0002` mục 2 "domain-agnostic" và mục 19 "component
/// hierarchy": ResultCard là một khối riêng, dùng lại cho mọi domain).
///
/// Widget này KHÔNG biết gì về nguồn dữ liệu cụ thể — chỉ nhận
/// icon/nhãn/văn bản đã dựng sẵn (kiểu nguyên thuỷ, không phải một
/// domain entity). Mỗi domain tự viết một factory chuyển đổi
/// (adapter) từ kiểu dữ liệu của mình sang các tham số này —
/// [ResultCard.fromAyah] là ví dụ cho Qur'an, dùng lại ĐÚNG entity
/// domain đã có (`AyahSearchResult`), không phát minh shape mới.
///
/// Task 7.1.10 (Sprint 7.1): chỉ xây nền tảng hiển thị — [onTap] là
/// callback tuỳ chọn, CHƯA nối vào `reading_position_store`/điều
/// hướng thật (thuộc Task 7.1.14). Widget này cũng CHƯA được gắn vào
/// cây hiển thị của `SearchScreen` — việc lắp ráp danh sách kết quả
/// và bộ dữ liệu mẫu thuộc Task 7.1.11.
///
/// Cùng padding/bo góc/màu nền đã dùng cho `_AyahResultTile`
/// (SurahListScreen) và `LibraryAyahTile` (Thư viện của tôi) — tái
/// dùng đúng khoảng cách/kiểu chữ đã có, không phát minh giá trị mới.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.icon,
    required this.sourceLabel,
    required this.primaryText,
    this.primaryTextDirection = TextDirection.ltr,
    this.useQuranFont = false,
    this.primaryFontSize,
    this.secondaryText,
    this.highlightQuery = '',
    this.onTap,
  });

  /// Adapter cho kết quả Ayah — dùng lại entity domain đã có, không
  /// bịa shape mới. Các domain tương lai (Hadith, Ghi chú, Trả lời
  /// AI) sẽ có factory tương ứng của riêng mình khi tới lượt, theo
  /// đúng mẫu này.
  factory ResultCard.fromAyah(
    AyahSearchResult result, {
    String highlightQuery = '',
    VoidCallback? onTap,
  }) {
    return ResultCard(
      icon: Icons.menu_book_outlined,
      sourceLabel:
          '${result.surahNameLatin} · ${result.surahId}:${result.ayahNumber}',
      primaryText: result.arabic,
      primaryTextDirection: TextDirection.rtl,
      useQuranFont: true,
      primaryFontSize: 22,
      secondaryText: result.translation,
      highlightQuery: highlightQuery,
      onTap: onTap,
    );
  }

  /// Icon nhận diện domain (vd: sách cho Qur'an, sau này Hadith/Ghi
  /// chú/AI có icon riêng) — không bắt buộc phải khớp domain thật,
  /// widget không kiểm tra.
  final IconData icon;

  /// Nhãn nguồn (vd: "Ar-Rahman · 55:1"). Luôn LTR theo ambient
  /// Directionality — giống quy ước đã có ở `_AyahResultTile`.
  final String sourceLabel;

  /// Văn bản chính (vd: Ả Rập cho Qur'an). Tối đa 2 dòng, có gạch
  /// dưới (ellipsis) khi tràn.
  final String primaryText;

  /// Hướng chữ của [primaryText] — RTL cho Ả Rập, LTR mặc định.
  final TextDirection primaryTextDirection;

  /// True để dùng font Qur'an (`quranTextStyle`) cho [primaryText] —
  /// domain không phải Qur'an (Hadith, Ghi chú...) để mặc định false,
  /// dùng kiểu chữ nội dung thường (`textTheme.bodyLarge`).
  final bool useQuranFont;

  /// Cỡ chữ tuỳ biến cho [primaryText] khi [useQuranFont] bật (mặc
  /// định 22, khớp `_AyahResultTile`/`LibraryAyahTile` hiện có).
  final double? primaryFontSize;

  /// Văn bản phụ tuỳ chọn (vd: bản dịch). Tối đa 2 dòng.
  final String? secondaryText;

  /// Từ khoá để tô đậm phần khớp — dùng lại [highlightSpans] (thuần,
  /// không phân biệt domain).
  final String highlightQuery;

  /// Callback khi chạm thẻ — null nghĩa là thẻ chỉ để xem, không bấm
  /// được. Điều hướng thật (nếu có) do màn hình gọi truyền vào.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final highlightStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: scheme.primary,
      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
    );

    final semanticsLabel = [
      sourceLabel,
      primaryText,
      if (secondaryText != null) secondaryText!,
    ].join('. ');

    final primaryStyle = useQuranFont
        ? quranTextStyle(
            fontSize: primaryFontSize ?? 22,
            color: scheme.onSurface,
          )
        : textTheme.bodyLarge?.copyWith(fontSize: primaryFontSize);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Semantics(
        label: semanticsLabel,
        button: onTap != null,
        excludeSemantics: true,
        child: Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: scheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sourceLabel,
                          style: textTheme.labelMedium
                              ?.copyWith(color: scheme.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: highlightSpans(
                        primaryText,
                        highlightQuery,
                        highlightStyle: highlightStyle,
                      ),
                    ),
                    textDirection: primaryTextDirection,
                    textAlign: primaryTextDirection == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: primaryStyle ?? textTheme.bodyLarge,
                  ),
                  if (secondaryText != null) ...[
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: highlightSpans(
                          secondaryText!,
                          highlightQuery,
                          highlightStyle: highlightStyle,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
