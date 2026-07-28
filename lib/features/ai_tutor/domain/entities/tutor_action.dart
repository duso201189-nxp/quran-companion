/// Đích điều hướng của 1 TutorAction (Sprint 15 Phase 3 mục 2) — CHỈ
/// là định danh trừu tượng, KHÔNG chứa đường dẫn route cụ thể (route
/// string là AppRoutes, sống ở lib/app/router.dart — 1 file phụ
/// thuộc go_router/Flutter, domain KHÔNG được đụng tới, đúng yêu cầu
/// "Domain only. No Flutter dependency"). Tầng trình bày
/// (TutorHomeScreen, mục 4) tự ánh xạ giá trị này sang
/// context.push(AppRoutes...) thật — domain chỉ cần biết "loại đích
/// nào", không cần biết "đường dẫn nào".
enum TutorActionDestination {
  /// Phiên ôn tập SM-2 đã lên lịch (AppRoutes.reviewSession) — ứng
  /// với gợi ý dựa trên dueToday/reviewsToday
  /// (reviewDueCards/completeDailyReviewGoal).
  reviewSession,

  /// Duyệt Flashcard (AppRoutes.flashcards) — ứng với gợi ý
  /// reviewFrequentlyForgotten (không có Smart Deck riêng cho "hay
  /// quên", xem doc comment computeTutorSuggestions).
  flashcards,

  /// Smart Deck "Gốc từ yếu" (AppRoutes.smartDeck +
  /// SmartDeckType.weakRoots) — ứng với gợi ý strengthenWeakRoots.
  weakCards,

  /// Learning Session (AppRoutes.learningSession) — ứng với gợi ý
  /// completeDailyStudyGoal.
  learningSession,
}

/// 1 hành động điều hướng gắn với TutorSuggestion (Sprint 15 Phase 3
/// mục 2/3) — domain THUẦN, không phụ thuộc Flutter (không import
/// go_router/AppRoutes/SmartDeckType). [payload] dự phòng cho dữ liệu
/// bổ sung mà 1 destination TƯƠNG LAI có thể cần (vd id 1 thẻ cụ thể)
/// — CHƯA destination nào ở phase này thật sự cần payload (đều điều
/// hướng tĩnh tới 1 màn hình cố định), nên luôn null ở phase này —
/// công khai rõ, không phải bỏ sót (xem Return Phase 3 mục "Remaining
/// backlog").
class TutorAction {
  const TutorAction({required this.destination, this.payload});

  final TutorActionDestination destination;
  final Object? payload;
}
