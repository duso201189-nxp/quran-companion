import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Trạng thái "không có kết quả" — Sprint R1.2. Tìm kiếm CHẠY THÀNH
/// CÔNG (không lỗi) nhưng danh sách kết quả rỗng. Khác biệt CÓ CHỦ
/// ĐÍCH với 3 trạng thái còn lại của `SearchScreen`:
/// - [SearchEmptyState]: CHƯA gõ gì — chưa có truy vấn nào chạy.
/// - [SearchLoadingSkeleton]: truy vấn đang chạy, chưa có kết quả.
/// - [SearchErrorState]: truy vấn THẤT BẠI (lỗi) — khác "chạy xong
///   nhưng rỗng".
///
/// Ngôn ngữ thiết kế dùng lại ĐÚNG bố cục `SearchErrorState` (icon +
/// thông điệp giữa màn hình, cùng cỡ icon 56/khoảng cách 24-12-16,
/// Semantics liveRegion) — cùng "họ" 3 trạng thái toàn-thân đã có của
/// màn hình này, không phát minh bố cục mới. Icon và MÀU sắc khác cả
/// hai: [Icons.search_off] (không phải `travel_explore_outlined` của
/// Empty State hay `cloud_off_outlined` của Error State), màu
/// `scheme.onSurfaceVariant` trung tính (không phải `scheme.error` —
/// đây không phải lỗi) để phân biệt trực quan rõ ràng.
class SearchNoResultsState extends StatelessWidget {
  const SearchNoResultsState({super.key, required this.query});

  /// Từ khoá đã tìm — hiển thị nguyên văn trong thông điệp
  /// (`searchNoResultsTitle`, vd 'Không tìm thấy kết quả cho "xyz"').
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = l10n.searchNoResultsTitle(query);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          liveRegion: true,
          label: '$title. ${l10n.searchNoResultsSubtitle}',
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 56,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.searchNoResultsSubtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
