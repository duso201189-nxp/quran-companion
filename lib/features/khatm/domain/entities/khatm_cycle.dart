import '../../../../core/quran/ayah_ordinal.dart';
import '../../../../core/quran/quran_address.dart';

/// Một chu kỳ đọc trọn vẹn Qur'an (Khatm) — Sprint 8, DR-2026-0003
/// mục A. Vị trí đọc trong chu kỳ này độc lập với vị trí đọc tự do
/// hằng ngày (ReadingPositionStore).
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

  bool get isCompleted => completedAt != null;

  static const int totalAyahs = 6236;

  double get progressPercent =>
      (currentAyahId / totalAyahs * 100).clamp(0, 100);
}
