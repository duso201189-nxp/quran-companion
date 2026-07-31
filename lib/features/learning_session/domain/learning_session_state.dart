import 'learning_planner.dart';
import 'learning_session_summary.dart';

/// Trạng thái tiến trình của một Learning Session. Hoàn thành phiên
/// được biểu diễn bằng `status == completed` — không dùng thêm cờ
/// bool `isComplete` riêng để tránh hai nguồn có thể lệch nhau.
///
/// `failed` (Sprint S2 — Quality & Polish, D1): thêm sau khi audit
/// phát hiện [LearningSessionController] không có nhánh lỗi nào —
/// một lỗi khi đọc dueReviewCardsProvider/dueFlashcardCardsProvider
/// hay khi Quiz ném lỗi sẽ trôi ra ngoài không ai bắt, màn hình đứng
/// yên ở vòng xoay tải mãi mãi, không có phản hồi gì cho người dùng.
enum LearningSessionStatus { notStarted, inProgress, completed, failed }

/// Trạng thái đầy đủ của LearningSessionController, expose cho nơi
/// gọi (Phase 3 — UI, chưa xây ở Phase 2 này): hoạt động hiện tại,
/// tập hoạt động đã hoàn thành, tóm tắt tích luỹ, trạng thái phiên.
///
/// [error] chỉ khác null khi `status == failed` (Sprint S2, D1) — giữ
/// nguyên đối tượng lỗi gốc (không ép về String ở tầng domain) để nơi
/// gọi tự quyết định cách hiển thị; tầng UI hiện tại chỉ dùng nó để
/// biết "có lỗi hay không", không hiển thị nội dung lỗi kỹ thuật cho
/// người dùng cuối (cùng nguyên tắc SearchErrorState đã áp dụng ở mọi
/// màn hình khác trong ứng dụng).
typedef LearningSessionState = ({
  LearningSessionStatus status,
  LearningActivityType? currentActivity,
  Set<LearningActivityType> completedActivities,
  LearningSessionSummary summary,
  Object? error,
});
