import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Trạng thái lỗi dùng chung cho Tìm kiếm — HOÀN TOÀN độc lập với
/// logic tìm kiếm thật: không gọi provider, không biết gì về mạng hay
/// truy vấn (khác `_ErrorState` sẵn có trong SurahListScreen, vốn tự
/// gọi `ref.invalidate(surahListProvider)`). Nhận [message] +
/// [onRetry] từ nơi gọi — giống hệt cách `ResultCard` (Task 7.1.10)
/// nhận [onTap]: bên gọi quyết định hành vi, widget chỉ lo hiển thị.
///
/// Task 7.1.11 (Sprint 7.1 — đặt tên lại từ "ErrorView" trong backlog
/// gốc, xem ghi chú số thứ tự trong tóm tắt task): CHỈ xây component
/// — CHƯA nối vào cây hiển thị của `SearchScreen`. Không có điều
/// kiện lỗi thật để bật nó lên (chưa có mạng, chưa có provider —
/// `DR-2026-0002` mục 4, mục 6); việc nối dây thuộc Task 7.1.13 (bộ
/// chuyển trạng thái dành cho dev) hoặc sprint nối search engine
/// thật sau này.
///
/// Cùng ngôn ngữ hình ảnh với `_ErrorState` sẵn có trong
/// `SurahListScreen` (icon `cloud_off_outlined`, màu `scheme.error`,
/// cùng khoảng cách 24/12/16) — không phát minh giao diện lỗi mới.
class SearchErrorState extends StatelessWidget {
  const SearchErrorState({
    super.key,
    this.message,
    this.icon = Icons.cloud_off_outlined,
    this.onRetry,
  });

  /// Thông điệp lỗi — mặc định dùng lại chuỗi đã có
  /// (`AppLocalizations.errorLoadData`), không bịa chuỗi mới. Domain
  /// tương lai (vd Hadith lỗi mạng) có thể truyền thông điệp riêng
  /// nếu cần, vẫn phải lấy từ l10n ở nơi gọi.
  final String? message;

  /// Icon hiển thị — mặc định khớp `_ErrorState` hiện có.
  final IconData icon;

  /// Callback khi bấm "Thử lại" — null thì ẨN nút (một nút không làm
  /// gì sẽ gây hiểu lầm), khác `ResultCard.onTap` (thẻ vẫn hiển thị
  /// dù không bấm được, vì thẻ còn mang thông tin để đọc).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = message ?? l10n.errorLoadData;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Một nhãn duy nhất cho icon+thông điệp — KHÔNG gộp luôn
            // nút "Thử lại" vào đây, để nút giữ ngữ nghĩa nút bấm
            // riêng, độc lập với live region báo lỗi.
            Semantics(
              liveRegion: true,
              label: text,
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    Icon(icon, size: 56, color: scheme.error),
                    const SizedBox(height: 12),
                    Text(text, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
