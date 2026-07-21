import 'tutor_action.dart';

/// Loại gợi ý AI Tutor (Sprint 15 Phase 1 mục 2) — mỗi loại tương ứng
/// ĐÚNG 1 điều kiện đơn giản suy từ TutorContext (xem
/// tutor_suggestion_generator.dart), KHÔNG có logic AI/LLM nào ở đây
/// (mục "No AI model integration yet") — đây là danh sách gợi ý dựa
/// trên NGƯỠNG/ĐIỀU KIỆN đơn thuần, giữ chỗ (placeholder) cho 1 AI
/// thật thay thế/bổ sung ở sprint sau.
enum TutorSuggestionKind {
  /// stats.dueToday > 0 — có thẻ đang chờ ôn hôm nay.
  reviewDueCards,

  /// LearningGoal(dailyStudyMinutes) chưa đạt.
  completeDailyStudyGoal,

  /// LearningGoal(dailyReviews) chưa đạt.
  completeDailyReviewGoal,

  /// PerformanceInsights.weakRoots không rỗng.
  strengthenWeakRoots,

  /// PerformanceInsights.frequentlyForgotten không rỗng.
  reviewFrequentlyForgotten,

  /// stats.readingStreakDays > 0 — nhắc giữ chuỗi ngày đọc.
  maintainStreak,
}

enum TutorSuggestionPriority { low, medium, high }

/// 1 gợi ý hành động — KHÔNG có trường "message"/"text" tính sẵn:
/// cùng kỷ luật với HistoryBucket/LearningGoal/Achievement (Sprint
/// 14) — Calculator thuần Dart không nhúng chuỗi 1 ngôn ngữ, tầng
/// trình bày TƯƠNG LAI (chưa xây ở phase này, "No UI yet") tự ánh xạ
/// [kind] sang chuỗi l10n.
class TutorSuggestion {
  const TutorSuggestion({
    required this.kind,
    required this.priority,
    this.relatedCount,
    this.action,
  });

  final TutorSuggestionKind kind;
  final TutorSuggestionPriority priority;

  /// Số lượng liên quan đã có sẵn từ Analytics (vd số thẻ due, số
  /// weak roots, số ngày streak) — KHÔNG tính lại, giúp tầng trình bày
  /// tương lai hiện "3 thẻ đang chờ ôn" mà không cần truy vấn thêm.
  /// Null nếu loại gợi ý không có số lượng gắn kèm tự nhiên.
  final int? relatedCount;

  /// Hành động điều hướng tương ứng (Sprint 15 Phase 3 mục 3) — THÊM
  /// MỚI dưới dạng tham số TUỲ CHỌN (không bắt buộc, mặc định null),
  /// giữ nguyên khả năng tương thích ngược: mọi nơi khởi tạo
  /// TutorSuggestion từ Phase 1/2 (không truyền [action]) vẫn biên
  /// dịch đúng, chỉ đơn giản không có hành động nào gắn kèm (xem
  /// TutorSuggestionCard — null nghĩa là KHÔNG hiện nút hành động).
  /// Null với [TutorSuggestionKind.maintainStreak] (chỉ mang tính
  /// khích lệ, không có màn hình đích tự nhiên nào) — xem
  /// tutor_suggestion_generator.dart.
  final TutorAction? action;
}
