import '../../../../core/quran/ayah_ordinal.dart';
import '../../../../core/quran/quran_address.dart';

/// Một chu kỳ đọc trọn vẹn Qur'an (Khatm) — Sprint 8, DR-2026-0003
/// mục A. Vị trí đọc trong chu kỳ này độc lập với vị trí đọc tự do
/// hằng ngày (ReadingPositionStore).
///
/// Sprint SF-Khatm làm rõ "độc lập" đó nghĩa là gì: [currentAyahId] là
/// BIÊN của một hành trình đọc TUẦN TỰ, không phải "chỗ vừa đọc gần
/// nhất". Hai thứ đó khác nhau, và chính [progressPercent] nói ra điều
/// đó: chia cho [totalAyahs] chỉ là một con số ĐÚNG khi mọi Ayah trước
/// biên đều đã đọc. Xem [isExtendedBy].
class KhatmCycle {
  const KhatmCycle({
    required this.id,
    required this.name,
    required this.startedAt,
    this.targetDate,
    this.completedAt,
    this.currentAyahId = 1,
  });

  final String id;
  final String name;

  /// Epoch ms UTC.
  final int startedAt;

  /// 'yyyy-MM-dd' — tuỳ chọn.
  final String? targetDate;

  /// null = đang đọc dở.
  final int? completedAt;

  /// Ayah ID 1..6236 — vị trí hiện tại trong chu kỳ. Đây là dạng LƯU
  /// TRỮ (khớp thẳng cột `current_ayah_id`); giữ nguyên qua Sprint SF3
  /// để không đổi biểu diễn trên đĩa.
  final int currentAyahId;

  /// [currentAyahId] dưới dạng [QuranAddress] — Sprint SF3 Tier 1.
  ///
  /// `null` chỉ khi [currentAyahId] không đổi được (ngoài 1..6236,
  /// xem [AyahOrdinal.tryFromOrdinal]); dữ liệu hợp lệ luôn có giá trị
  /// vì [currentAyahId] chỉ được ghi qua
  /// `KhatmCycleRepository.updateProgress`, nơi đã tự chặn ordinal sai.
  QuranAddress? get currentAddress => AyahOrdinal.tryFromOrdinal(
        currentAyahId,
      );

  /// Phiên đọc từ [from] tới [to] có NỐI TIẾP hành trình này không —
  /// Sprint SF-Khatm.
  ///
  /// Một phiên chỉ được tính khi nó vừa NỐI LIỀN phần đã đọc, vừa ĐẨY
  /// XA thêm:
  ///
  /// - **nối liền** — phiên bắt đầu tại/trước biên, hoặc đúng ngay sau
  ///   biên. Cái `+ 1` là chỗ vượt ranh giới Surah: biên ở 1:7 thì
  ///   phiên bắt đầu ở 2:1 vẫn là đọc tiếp, không phải nhảy cóc. Nhờ
  ///   điều kiện này, đọc Al-Kahf trong lúc biên đang ở 2:50 KHÔNG kéo
  ///   tiến độ lên 34% — đó là đọc, nhưng không phải hành trình này.
  /// - **đẩy xa** — phiên kết thúc sau biên. Đọc lại phần đã qua không
  ///   làm tiến độ tụt lại.
  ///
  /// Cả hai vế so trên ordinal vì hệ đó cho phép hỏi "ngay sau" bằng
  /// `+ 1`; [QuranAddress] cố ý không có phép lấy phần tử kế tiếp (F0
  /// không có `Range`, cũng không có `next`).
  ///
  /// Địa chỉ không quy đổi được -> `false`: không đoán, không ghi.
  bool isExtendedBy({required QuranAddress from, required QuranAddress to}) {
    final start = AyahOrdinal.tryToOrdinal(from);
    final end = AyahOrdinal.tryToOrdinal(to);
    if (start == null || end == null) return false;
    return start <= currentAyahId + 1 && end > currentAyahId;
  }

  bool get isCompleted => completedAt != null;

  static const int totalAyahs = 6236;

  double get progressPercent =>
      (currentAyahId / totalAyahs * 100).clamp(0, 100);
}
