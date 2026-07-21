import 'entities/tutor_context.dart';
import 'entities/tutor_insight.dart';
import 'entities/tutor_suggestion.dart';

/// Cổng AI Tutor (Sprint 15 Phase 1 mục 3) — CHỈ được phép tổng hợp
/// từ AnalyticsRepository (xem AITutorRepositoryImpl), KHÔNG được
/// biết tới SchedulerRepository/FlashcardRepository/LexiconRepository
/// trực tiếp — Analytics vẫn là NGUỒN DUY NHẤT của mọi số liệu học
/// tập (đúng yêu cầu "Analytics remains the single source of learning
/// insights"). Domain thuần Dart — không phụ thuộc Flutter/Riverpod,
/// cùng nguyên tắc với AnalyticsRepository (Sprint 14 Phase 1 mục 5)
/// để gọi được trực tiếp từ bất kỳ ngữ cảnh nào (AI Tutor thật, sprint
/// sau, có thể không chạy trong cây Widget).
///
/// Phase 1 CHỈ là nền kiến trúc — mọi triển khai hiện tại (xem
/// AITutorRepositoryImpl) suy ra gợi ý/nhận định bằng ĐIỀU KIỆN/NGƯỠNG
/// đơn giản, KHÔNG gọi AI/LLM nào ("No AI model integration yet",
/// "Foundation only").
abstract interface class AITutorRepository {
  /// Bối cảnh học tập gói lại từ AnalyticsRepository — dùng trực tiếp
  /// (vd hiển thị tổng quan) hoặc làm nền cho [getSuggestions]/
  /// [getInsights] (cả 2 đều tự gọi lại phương thức này).
  Future<TutorContext> getTutorContext();

  /// Gợi ý hành động suy từ [getTutorContext] — hiện là ĐIỀU
  /// KIỆN/NGƯỠNG thuần (không AI), xem tutor_suggestion_generator.dart.
  Future<List<TutorSuggestion>> getSuggestions();

  /// Nhận định tổng quan suy từ [getTutorContext] — hiện đọc thẳng số
  /// liệu đã có (không AI), xem tutor_insight_generator.dart.
  Future<List<TutorInsight>> getInsights();
}
