/// Loại hoạt động học trong một Learning Session (Sprint 11 —
/// Learning Planner). Thêm loại mới chỉ cần thêm 1 giá trị enum + một
/// nhánh trong cài đặt LearningPlanner tương ứng — không đổi giao diện.
enum LearningActivityType { review, quiz, flashcard }

/// Ảnh chụp trạng thái các module học tại thời điểm hỏi "tiếp theo là
/// gì" — truyền vào tường minh, LearningPlanner không tự đọc
/// provider/repository nào. Đây là điều khiến LearningPlanner thuần
/// và tất định: cùng input luôn cho cùng output.
///
/// [dueFlashcardCount] null = module Flashcard chưa được cài (Sprint
/// 11: luôn null) — coi như "không sẵn có", khác 0 (sẵn có nhưng
/// không có gì đến hạn), dù cả hai đều dẫn tới bị bỏ qua.
typedef LearningPlanContext = ({
  int dueReviewCount,
  bool quizAvailable,
  int? dueFlashcardCount,
  Set<LearningActivityType> completedThisSession,
});

/// Trừu tượng quyết định hoạt động học tiếp theo (Sprint 11 — Learning
/// Planner). Thuần Dart — KHÔNG import Flutter/Riverpod/Drift/SQLite,
/// KHÔNG đọc đồng hồ hệ thống hay trạng thái ẩn — mọi input truyền
/// vào tường minh qua [LearningPlanContext].
///
/// Cài đặt hôm nay: SequentialLearningPlanner (tất định, thứ tự cố
/// định). Tương lai: một AI Tutor có thể thay thế hoàn toàn qua cùng
/// giao diện này — Review/Quiz/Flashcard không bao giờ phụ thuộc
/// LearningPlanner, nên việc thay thế không đụng tới chúng.
abstract interface class LearningPlanner {
  /// Trả về hoạt động tiếp theo, hoặc null khi không còn gì để làm
  /// (phiên kết thúc -> Learning Summary).
  LearningActivityType? next(LearningPlanContext context);
}
