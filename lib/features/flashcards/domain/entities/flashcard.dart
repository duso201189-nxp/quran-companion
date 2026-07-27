import '../../../lexicon/domain/entities/lexicon_entry.dart';
import 'flashcard_type.dart';

/// Một thẻ ghi nhớ — CON TRỎ vào 1 LexiconEntry, KHÔNG sao chép nội
/// dung (Sprint 13 Phase 1 mục 1: "Lexicon remains the single source
/// of truth"). Không có trường arabic/meaningVi/... ở đây — nội dung
/// luôn giải quyết qua LexiconRepository.getEntry(lexiconEntryType,
/// lexiconEntryId) tại thời điểm hiển thị.
///
/// Thuộc NHÓM B (dữ liệu người dùng — "tôi đang học từ nào"), khác
/// hẳn Lexicon (nhóm A, nội dung chỉ đọc) — xem FlashcardRepositoryImpl
/// (UserDatabase, không phải AppDatabase).
class Flashcard {
  const Flashcard({
    required this.id,
    required this.type,
    required this.lexiconEntryType,
    required this.lexiconEntryId,
    this.deckId,
    this.note,
    required this.createdAt,
  });

  final String id;
  final FlashcardType type;
  final LexiconEntryType lexiconEntryType;
  final int lexiconEntryId;
  final String? deckId;

  /// Ghi chú riêng của người dùng — chỉ thật sự có ý nghĩa với
  /// [FlashcardType.custom]/[FlashcardType.note], nhưng để ở thực thể
  /// gốc (nullable) thay vì bảng riêng, tránh 1 bảng gần như trống ở
  /// Sprint 13 (chỉ [FlashcardType.lemma] có dữ liệu thật).
  final String? note;

  /// Epoch ms UTC.
  final int createdAt;
}
