/// Loại thành tựu (Sprint 14 Phase 2.2 mục 2). Mỗi loại ánh xạ tới
/// ĐÚNG 1 trường đã có sẵn trong LearningStatistics — không trường
/// nào tính lại số liệu mới.
///
/// [hundredCardsStudied] thay cho ví dụ gốc "100 Reviews" trong yêu
/// cầu — KHÔNG có bộ đếm lượt ôn cộng dồn trong toàn bộ vòng đời thẻ
/// (srs_cards chỉ lưu ảnh chụp hiện tại, `repetitions` RESET về 0 mỗi
/// khi trả lời sai — xem sm2_scheduling_algorithm.dart — nên không
/// phải "tổng số lượt ôn"). `cardsStudied` (số thẻ có repetitions>0)
/// là số liệu ĐÃ CÓ SẴN gần nghĩa nhất, dùng thay và công khai ở đây.
///
/// KHÔNG có thành tựu "First Deck Completed" như ví dụ gốc — khái
/// niệm "deck" hoàn toàn nằm ngoài AnalyticsRepository hiện tại
/// (không có nhóm theo deck trong LearningStatistics/
/// PerformanceInsights); thêm nó đòi hỏi mở rộng AnalyticsRepository
/// ghép thêm FlashcardDeck, việc đó cần quyết định kiến trúc riêng,
/// không tự ý làm trong 1 phase "foundation" (xem Return Phase 2.2 mục
/// "Remaining backlog").
enum AchievementKind {
  firstStudy,
  tenCardsStudied,
  hundredCardsStudied,
  sevenDayStreak,
  thirtyDayLongestStreak,
  sharpMemory,
}

/// 1 thành tựu — dẫn xuất, KHÔNG lưu trạng thái "đã mở khoá" (đúng
/// yêu cầu "derived, not persisted"): mất đúng ĐIỀU KIỆN HIỆN TẠI có
/// còn đúng không mỗi lần đọc, KHÔNG phải "đã từng đạt được, giữ mãi"
/// như hệ thống thành tựu (achievement) kiểu game thông thường — vd
/// [sevenDayStreak] sẽ hiện "chưa đạt" trở lại nếu chuỗi ngày đọc bị
/// đứt, vì readingStreakDays chính là streak HIỆN TẠI (không phải kỷ
/// lục). Hạn chế này công khai rõ ở đây thay vì giả vờ có "huy hiệu
/// vĩnh viễn" mà thực ra không lưu ở đâu cả.
class Achievement {
  const Achievement({
    required this.kind,
    required this.current,
    required this.target,
  });

  final AchievementKind kind;
  final int current;
  final int target;

  bool get isUnlocked => current >= target;

  double get progress => target <= 0 ? 1.0 : (current / target).clamp(0.0, 1.0);
}
