import '../../smart_learning/domain/smart_learning_repository.dart';
import '../domain/entities/learning_snapshot.dart';
import '../domain/learning_snapshot_generator.dart';
import '../domain/learning_snapshot_repository.dart';

/// Triển khai LearningSnapshotRepository (Sprint 18 Phase 1) — ghép
/// DUY NHẤT SmartLearningRepository (Sprint 17, kiến trúc đã đóng
/// băng, KHÔNG đổi), KHÔNG tự ý gọi LearningJourneyRepository/
/// AITutorRepository/AnalyticsRepository trực tiếp — đúng yêu cầu
/// "Compose ONLY: SmartLearningRepository."
///
/// KHÔNG cache gì giữa các lệnh gọi (đúng yêu cầu "No caching policy
/// yet") — getSnapshot() tự gọi lại SmartLearningRepository mỗi lần,
/// chính SmartLearningRepository lại tự gọi lại LearningJourneyRepository
/// mỗi lần (Sprint 17 Phase 1), rồi LearningJourneyRepository lại tự
/// gọi lại AITutorRepository mỗi lần (Sprint 16 Phase 1), rồi
/// AITutorRepository lại tự gọi lại AnalyticsRepository mỗi lần
/// (Sprint 15 Phase 1) — CHƯA tối ưu xuyên 4 tầng, cùng ranh giới CỐ
/// Ý dừng lại đã thiết lập xuyên suốt dự án (tối ưu TRONG 1 lệnh gọi
/// được cho phép — Sprint 14 Phase 3 — tối ưu XUYÊN nhiều lệnh gọi thì
/// không, rủi ro trả dữ liệu cũ) — xem Return Phase 1 mục "Remaining
/// backlog". "No caching policy YET" (đúng nguyên văn yêu cầu) ngụ ý
/// đây LÀ nơi 1 chính sách cache sẽ được thêm ở phase sau, không phải
/// bị bỏ sót ở phase này.
class LearningSnapshotRepositoryImpl implements LearningSnapshotRepository {
  LearningSnapshotRepositoryImpl(
    this._smartLearning, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SmartLearningRepository _smartLearning;

  /// Tiêm được để test có kết quả xác định — cùng mẫu now/newId/nowMs
  /// đã dùng ở mọi repository impl khác trong dự án.
  final DateTime Function() _now;

  @override
  Future<LearningSnapshot> getSnapshot() async {
    final session = await _smartLearning.getSmartLearningSession();
    return computeLearningSnapshot(session, _now());
  }
}
