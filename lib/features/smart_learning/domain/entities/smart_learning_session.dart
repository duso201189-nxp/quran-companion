import '../../../learning_journey/domain/entities/learning_journey.dart';
import 'learning_recommendation.dart';

/// Phiên học thông minh CHO HÔM NAY (Sprint 17 Phase 1, thêm [journey]
/// ở Sprint 18 Phase 1) — danh sách [LearningRecommendation] ĐÃ XẾP
/// HẠNG (recommendations.first là đề xuất ưu tiên nhất — xem
/// smart_learning_session_generator.dart cho quy tắc xếp hạng), suy
/// TRỰC TIẾP từ LearningJourneyRepository.getLearningJourney(), không
/// có nguồn dữ liệu nào khác, không lưu trữ (đúng yêu cầu "No
/// persistence", "No write path" — đối tượng này chỉ tồn tại trong bộ
/// nhớ của 1 lượt gọi, giống DailyLearningPlan — Sprint 16 Phase 1).
///
/// [journey] THÊM MỚI (Sprint 18 Phase 1) dưới dạng trường BỔ SUNG —
/// KHÔNG đổi chữ ký SmartLearningRepository.getSmartLearningSession()
/// (vẫn trả về ĐÚNG kiểu SmartLearningSession, không phải "redesign
/// SmartLearningRepository"), chỉ SURFACE lại LearningJourney mà
/// computeSmartLearningSession() vốn ĐÃ NHẬN làm tham số nhưng trước
/// đây bỏ qua không lưu lại. Đây là lời giải cho 1 ràng buộc tưởng
/// chừng mâu thuẫn ở Sprint 18 Phase 1: LearningSnapshotRepository
/// PHẢI tạo ra TutorContext/TutorInsights/DailyLearningPlan nhưng CHỈ
/// được phép ghép AT SmartLearningRepository (không được đụng
/// LearningJourneyRepository/AITutorRepository/AnalyticsRepository
/// trực tiếp) — có [journey] ở đây, LearningSnapshotRepository lấy đủ
/// cả 4 thứ cần thiết TỪ ĐÚNG 1 lệnh gọi getSmartLearningSession(),
/// không cần biết LearningJourneyRepository tồn tại. Xem
/// lib/features/read_model/domain/learning_snapshot_generator.dart.
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class SmartLearningSession {
  const SmartLearningSession({
    required this.date,
    required this.recommendations,
    required this.journey,
  });

  /// Ngày áp dụng (đã cắt về 00:00 — cùng quy ước DailyLearningPlan.date).
  final DateTime date;

  /// ĐÃ xếp hạng theo thứ tự ưu tiên đã có sẵn trong
  /// DailyLearningPlan.steps (xem generator) — KHÔNG tính lại mức ưu
  /// tiên nào.
  final List<LearningRecommendation> recommendations;

  /// LearningJourney NGUỒN đã dùng để sinh [recommendations] — giữ
  /// lại nguyên vẹn (không trích xuất/rút gọn), để tầng ĐỌC LẠI (vd
  /// LearningSnapshotRepository) có thể lấy TutorContext/TutorInsights/
  /// DailyLearningPlan mà không cần gọi thêm repository nào khác.
  final LearningJourney journey;
}
