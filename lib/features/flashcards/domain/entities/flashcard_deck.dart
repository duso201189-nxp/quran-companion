/// Bộ sưu tập Flashcard (Sprint 13 Phase 1 mục 1 — dành chỗ, chưa có
/// UI đa-deck ở Sprint 13). Nhóm B — cùng database Flashcard, độc lập
/// hoàn toàn với Lexicon.
class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Epoch ms UTC.
  final int createdAt;
}
