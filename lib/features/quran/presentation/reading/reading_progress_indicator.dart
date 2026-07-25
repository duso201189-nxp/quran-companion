import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Dải tiến độ đọc (Sprint 25.2) — đặt ở đáy trang đọc, ngay trên
/// AudioBar: vị trí Ayah hiện tại, phần trăm Surah, và một đường kẻ
/// mảnh 2px vừa là thanh tiến độ vừa là đường ngăn giữa vùng đọc và
/// dải này (một nét làm hai việc, không thêm khung viền thừa).
///
/// KHÔNG dùng provider: nhận thẳng [currentAyahIndex] — cùng con số
/// mà `ReadingScreen` ĐÃ tính trong `_onPositionsChanged` (chế độ Danh
/// sách) và `_savePage` (chế độ Mushaf), nên không có logic vị trí đọc
/// thứ hai ở đây. Vì là [ValueListenable], mỗi lần cuộn CHỈ dựng lại
/// đúng widget này — `ReadingScreen` không rebuild.
class ReadingProgressIndicator extends StatelessWidget {
  const ReadingProgressIndicator({
    super.key,
    required this.currentAyahIndex,
    required this.totalAyahs,
  });

  /// Chỉ số Ayah đang đọc, 0-based (cùng quy ước với
  /// `ReadingPositionStore.positionFor`).
  final ValueListenable<int> currentAyahIndex;

  /// Tổng số Ayah đã nạp của Surah. Nơi gọi chỉ dựng widget này khi
  /// giá trị > 0, nên ở đây không cần nhánh chia cho 0.
  final int totalAyahs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return ValueListenableBuilder<int>(
      valueListenable: currentAyahIndex,
      builder: (context, index, _) {
        final ayahNumber = (index + 1).clamp(1, totalAyahs);
        final value = ayahNumber / totalAyahs;
        final percent = (value * 100).round();

        return Semantics(
          // Một nhãn duy nhất cho cả dải. KHÔNG liveRegion: tự đọc lên
          // mỗi lần đổi Ayah sẽ biến trình đọc màn hình thành tiếng ồn
          // liên tục suốt lúc cuộn — người dùng vuốt tới đây khi MUỐN
          // biết mình đang ở đâu.
          label: l10n.readingProgressSemantics(
            ayahNumber,
            totalAyahs,
            percent,
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chuyển động rất nhẹ: đường kẻ trượt tới vị trí mới
                // thay vì nhảy giật theo từng Ayah. Lần dựng đầu KHÔNG
                // chạy animation (Tween không có `begin`) — mở lại
                // Surah là thấy ngay đúng vị trí đã lưu.
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: value),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  builder: (context, animatedValue, __) {
                    return LinearProgressIndicator(
                      value: animatedValue,
                      minHeight: 2,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: scheme.primary,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.readingProgressPosition(ayahNumber, totalAyahs),
                          style: labelStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('$percent%', style: labelStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
