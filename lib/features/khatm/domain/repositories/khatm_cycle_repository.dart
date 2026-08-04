import '../../../../core/quran/quran_address.dart';
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
  ///
  /// Biên của repository nhận [QuranAddress] (Sprint SF3 Tier 1), quy
  /// đổi sang ordinal lưu trữ qua `AyahOrdinal.tryToOrdinal` ở tầng
  /// triển khai. Nếu [address] không đổi được (mức Surah, hoặc không
  /// tồn tại thật — vd. `2:300`), đây là NO-OP: không ném lỗi, không
  /// ghi đè vị trí đang lưu bằng dữ liệu sai.
  ///
  /// Sprint SF-Khatm Completion — hai điều khoản nữa của hợp đồng này:
  ///
  /// - Nếu [address] đưa biên tới Ayah cuối cùng
  ///   (`KhatmCycle.completesJourney`), chu kỳ được đóng dấu hoàn thành
  ///   TRONG CÙNG lần ghi đó. Không cần, và không nên, gọi thêm
  ///   [completeCycle] — chính cái khe giữa hai lần ghi là chỗ chu kỳ
  ///   có thể kẹt vĩnh viễn ở 100% mà vẫn "đang đọc".
  /// - Chu kỳ ĐÃ hoàn thành không nhận tiến độ nữa: lời gọi tiếp theo
  ///   là NO-OP. Muốn đọc tiếp thì bắt đầu chu kỳ mới.
  Future<void> updateProgress(String cycleId, QuranAddress address);

  /// Đánh dấu hoàn thành — completedAt = hiện tại.
  Future<void> completeCycle(String cycleId);

  /// Xóa mềm 1 chu kỳ.
  Future<void> deleteCycle(String cycleId);
}
