import '../../../lexicon/domain/entities/lexicon_entry.dart';
import '../entities/flashcard.dart';
import '../entities/flashcard_deck.dart';
import '../entities/flashcard_type.dart';

/// Cổng dữ liệu Flashcard (Sprint 13 Phase 2). Domain thuần — không
/// biết Drift. KHÔNG phụ thuộc SchedulerRepository (đúng tiền lệ
/// SchedulerRepository/UserContentRepository độc lập, cầu nối ở tầng
/// Provider — xem flashcardSchedulerSyncProvider).
abstract interface class FlashcardRepository {
  /// Thêm 1 Flashcard trỏ tới (lexiconEntryType, lexiconEntryId). Nếu
  /// đã có Flashcard (còn sống) cho đúng cặp này -> trả về id đã có,
  /// KHÔNG tạo trùng (UNIQUE(lexicon_entry_type, lexicon_entry_id)).
  /// Nếu đã có nhưng bị xoá mềm -> hồi sinh (cùng mẫu Bookmarks/Favorites
  /// toggle).
  Future<String> addFlashcard({
    required FlashcardType type,
    required LexiconEntryType lexiconEntryType,
    required int lexiconEntryId,
    String? deckId,
    String? note,
  });

  /// Xoá mềm 1 Flashcard. Không lỗi nếu [flashcardId] không tồn tại.
  Future<void> removeFlashcard(String flashcardId);

  /// Chuyển 1 Flashcard sang deck khác — [deckId] null = gỡ khỏi mọi
  /// deck (Sprint 13 Phase 3 — Deck Management mục "Move flashcards").
  /// Không lỗi nếu [flashcardId] không tồn tại.
  Future<void> moveFlashcard(String flashcardId, String? deckId);

  /// Mọi Flashcard còn sống, mới nhất trước.
  Stream<List<Flashcard>> watchAllFlashcards();

  Future<String> createDeck(String name);

  Future<void> renameDeck(String deckId, String name);

  /// Xoá mềm 1 deck VÀ gỡ deckId khỏi mọi Flashcard đang trỏ tới nó
  /// (không có FK cascade ở DB — cùng nguyên tắc
  /// BookmarkCollectionRepository.deleteCollection).
  Future<void> deleteDeck(String deckId);

  Stream<List<FlashcardDeck>> watchAllDecks();
}
