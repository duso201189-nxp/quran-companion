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

  /// Ayah ID 1..6236 — vị trí hiện tại trong chu kỳ.
  final int currentAyahId;

  bool get isCompleted => completedAt != null;

  static const int totalAyahs = 6236;

  double get progressPercent =>
      (currentAyahId / totalAyahs * 100).clamp(0, 100);
}
