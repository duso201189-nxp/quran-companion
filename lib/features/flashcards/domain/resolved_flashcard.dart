import '../../lexicon/domain/entities/lemma.dart';
import 'entities/flashcard.dart';

/// 1 Flashcard + nội dung Lexicon đã giải quyết (null nếu chưa/không
/// giải quyết được) — hình dạng dùng chung Browse/Search/Filter/Smart
/// Deck. Domain thuần (không Riverpod/Drift) dù nơi TẠO RA giá trị
/// này luôn là tầng Provider (xem resolvedFlashcardsProvider) — đặt ở
/// domain vì [filterFlashcards]/smart_deck_selector.dart (đều thuần,
/// test không cần DB) cần cùng kiểu này.
typedef ResolvedFlashcard = ({Flashcard flashcard, Lemma? lemma});
