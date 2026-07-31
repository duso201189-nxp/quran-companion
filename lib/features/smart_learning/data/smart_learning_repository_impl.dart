import '../../learning_journey/domain/learning_journey_repository.dart';
import '../domain/entities/smart_learning_session.dart';
import '../domain/smart_learning_repository.dart';
import '../domain/smart_learning_session_generator.dart';

/// Triển khai SmartLearningRepository (Sprint 17 Phase 1) — ghép DUY
/// NHẤT LearningJourneyRepository (Sprint 16, kiến trúc đã đóng băng,
/// KHÔNG đổi), KHÔNG tự ý gọi AITutorRepository/AnalyticsRepository
/// trực tiếp — đúng yêu cầu "Compose ONLY: LearningJourneyRepository."
///
/// KHÔNG cache gì giữa các lệnh gọi (đúng yêu cầu "No caching") —
/// getSmartLearningSession() tự gọi lại LearningJourneyRepository mỗi
/// lần, chính LearningJourneyRepository lại tự gọi lại AITutorRepository
/// mỗi lần (Sprint 16 Phase 1), rồi AITutorRepository lại tự gọi lại
/// AnalyticsRepository mỗi lần (Sprint 15 Phase 1) — CHƯA tối ưu xuyên
/// 3 tầng, cùng ranh giới CỐ Ý dừng lại đã thiết lập xuyên suốt dự án
/// (tối ưu TRONG 1 lệnh gọi được cho phép — Sprint 14 Phase 3 — tối ưu
/// XUYÊN nhiều lệnh gọi thì không, rủi ro trả dữ liệu cũ) — xem Return
/// Phase 1 mục "Remaining backlog".
///
/// KHÔNG có logic AI/LLM nào — computeSmartLearningSession (rule-based
/// thuần) là toàn bộ "thông minh" ở phase này.
class SmartLearningRepositoryImpl implements SmartLearningRepository {
  SmartLearningRepositoryImpl(this._learningJourney, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final LearningJourneyRepository _learningJourney;

  /// Tiêm được để test có kết quả xác định — cùng mẫu now/newId/nowMs
  /// đã dùng ở mọi repository impl khác trong dự án.
  final DateTime Function() _now;

  @override
  Future<SmartLearningSession> getSmartLearningSession() async {
    final journey = await _learningJourney.getLearningJourney();
    return computeSmartLearningSession(journey, _now());
  }
}
