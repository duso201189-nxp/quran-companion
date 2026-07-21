import '../../../flashcards/domain/resolved_flashcard.dart';

/// Gói 4 loại Performance Insight (Sprint 14 Phase 1 mục 4) — CHỈ áp
/// dụng Flashcard loại 'lemma' (Root/gốc từ là khái niệm Lexicon,
/// không có ở SrsCard loại 'ayah'). Mỗi danh sách tái dùng thẳng
/// ResolvedFlashcard (Sprint 13) để UI vẽ lại bằng FlashcardTile có
/// sẵn, không tạo kiểu hiển thị mới.
class PerformanceInsights {
  const PerformanceInsights({
    required this.weakRoots,
    required this.difficultLemmas,
    required this.frequentlyForgotten,
    required this.fastestImproving,
  });

  /// Tái dùng NGUYÊN VẸN selectWeakRoots (Sprint 13 Phase 3) — gộp
  /// theo Root.id, easeFactor trung bình thấp nhất.
  final List<ResolvedFlashcard> weakRoots;

  /// Tái dùng NGUYÊN VẸN selectMostDifficult (Sprint 13 Phase 3) —
  /// easeFactor cá nhân thấp nhất.
  final List<ResolvedFlashcard> difficultLemmas;

  /// MỚI (Phase 1) — SrsCard đang ở trạng thái 'lapsed' (đã tốt
  /// nghiệp rồi trả lời sai) — đúng định nghĩa "hay quên" trong SM-2,
  /// suy trực tiếp từ state hiện có, không cần lịch sử.
  final List<ResolvedFlashcard> frequentlyForgotten;

  /// MỚI (Phase 1) — XẤP XỈ tốc độ tiến bộ: repetitions / số ngày kể
  /// từ khi thêm Flashcard (Flashcard.createdAt). KHÔNG phải xu hướng
  /// thật theo thời gian (cần lịch sử để đo "đang cải thiện" đúng
  /// nghĩa) — xem Return Phase 1 mục "Architecture compliance".
  final List<ResolvedFlashcard> fastestImproving;
}
