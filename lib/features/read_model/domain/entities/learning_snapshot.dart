import '../../../ai_tutor/domain/entities/tutor_context.dart';
import '../../../ai_tutor/domain/entities/tutor_insight.dart';
import '../../../learning_journey/domain/entities/daily_learning_plan.dart';
import '../../../smart_learning/domain/entities/smart_learning_session.dart';
import 'snapshot_timestamp.dart';

/// 1 ẢNH CHỤP BẤT BIẾN (immutable read model) của toàn bộ trạng thái
/// học tập tại 1 thời điểm (Sprint 18 Phase 1) — gói lại ĐÚNG 4 thứ
/// yêu cầu, KHÔNG hơn KHÔNG kém, TÁI SỬ DỤNG NGUYÊN VẸN 4 kiểu domain
/// đã có sẵn (TutorContext — Sprint 15, List&lt;TutorInsight&gt; —
/// Sprint 15, DailyLearningPlan — Sprint 16, SmartLearningSession —
/// Sprint 17) — KHÔNG có "mô hình trình bày" (presentation model) mới
/// nào bọc lại/rút gọn 4 kiểu này, đúng yêu cầu "No duplicated
/// presentation models".
///
/// ĐÂY LÀ PHÉP CHIẾU CHỈ-ĐỌC (read-only projection) — KHÔNG tính lại
/// bất kỳ số liệu học tập nào (xem learning_snapshot_generator.dart):
/// mọi trường đọc THẲNG từ SmartLearningSession.journey (đã có sẵn từ
/// Sprint 18 Phase 1 — xem doc comment SmartLearningSession.journey)
/// và chính SmartLearningSession đó — KHÔNG truy vấn
/// LearningJourneyRepository/AITutorRepository/AnalyticsRepository
/// trực tiếp ở BẤT KỲ đâu trong toàn bộ tính năng read_model.
///
/// "Bất biến" (immutable) — mọi trường `final`, không có setter/hàm
/// biến đổi tại chỗ nào; 1 LearningSnapshot đã tạo ra không bao giờ
/// đổi, muốn dữ liệu mới phải tạo 1 LearningSnapshot MỚI (qua
/// getSnapshot() lần nữa) — đúng yêu cầu "immutable".
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class LearningSnapshot {
  const LearningSnapshot({
    required this.timestamp,
    required this.context,
    required this.insights,
    required this.dailyPlan,
    required this.smartSession,
  });

  /// Thời điểm snapshot này được sinh ra.
  final SnapshotTimestamp timestamp;

  final TutorContext context;
  final List<TutorInsight> insights;
  final DailyLearningPlan dailyPlan;
  final SmartLearningSession smartSession;
}
