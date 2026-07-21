/// Smart Deck — TRUY VẤN ĐỘNG trên Flashcard/SrsCard/Lexicon đã có,
/// KHÔNG phải bảng/dữ liệu lưu riêng (Sprint 13 Phase 3 mục 4 —
/// "dynamic queries, not duplicated data"). Xem
/// lib/features/flashcards/domain/smart_deck_selector.dart cho logic
/// chọn lọc thuần (không đụng DB) của từng loại.
///
/// [favorites] CỐ Ý không có mặt (khác ví dụ nêu trong yêu cầu) —
/// Flashcard không có cờ "yêu thích" riêng, và thêm cờ mới là thêm
/// dữ liệu lưu trữ mới, đi ngược "No duplicated data"/"Reuse" của
/// chính phase này. Xem Return Phase 3 mục "Remaining backlog".
enum SmartDeckType {
  todaysReview,
  mostDifficult,
  recentlyLearned,
  weakRoots,
  verbForms,
}
