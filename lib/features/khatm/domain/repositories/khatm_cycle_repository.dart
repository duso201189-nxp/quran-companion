import '../entities/khatm_cycle.dart';

/// Cổng dữ liệu chu kỳ Khatm (Sprint 8 — DR-2026-0003 mục A). Domain
/// không biết Drift.
abstract interface class KhatmCycleRepository {
  /// Bắt đầu 1 chu kỳ mới. Trả về id chu kỳ vừa tạo.
  Future<String> startCycle({required String name, String? targetDate});

  /// Mọi chu kỳ còn sống, mới bắt đầu nhất trước.
  Stream<List<KhatmCycle>> watchAllCycles();

  /// Chu kỳ đang đọc dở (completedAt == null) mới bắt đầu nhất;
  /// null nếu không có chu kỳ nào đang mở.
  Stream<KhatmCycle?> watchActiveCycle();

  /// Cập nhật vị trí đọc hiện tại trong chu kỳ.
  Future<void> updateProgress(String cycleId, int currentAyahId);

  /// Đánh dấu hoàn thành — completedAt = hiện tại.
  Future<void> completeCycle(String cycleId);

  /// Xóa mềm 1 chu kỳ.
  Future<void> deleteCycle(String cycleId);
}
