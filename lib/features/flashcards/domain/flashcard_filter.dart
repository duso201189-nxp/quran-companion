import '../../learning/domain/entities/srs_card.dart';
import 'entities/flashcard.dart';
import 'entities/flashcard_type.dart';
import 'resolved_flashcard.dart';

/// Trạng thái học để lọc (Sprint 13 Phase 3 mục 5). [due] tách riêng
/// khỏi SrsCardState — "đến hạn" là due_date đã qua, không phải 1
/// trạng thái SM-2 (1 thẻ [SrsCardState.review] vẫn có thể đang đến
/// hạn hoặc chưa, xem selectDueCardsOrdered).
enum FlashcardStatusFilter { all, due, newCard, learning, review, lapsed }

/// deckFilter dùng giá trị này để lọc "chưa gán deck nào" — deck.id
/// thật luôn là UUID (không rỗng), nên chuỗi rỗng an toàn làm sentinel
/// (cùng kiểu String? deckFilter, không cần enum 3 trạng thái riêng).
const String noDeckFilter = '';

/// Hàm THUẦN lọc Flashcard theo từ khoá/deck/loại/trạng thái — tách
/// khỏi widget để test trực tiếp, cùng kỷ luật
/// smart_deck_selector.dart/selectDueCardsOrdered.
List<ResolvedFlashcard> filterFlashcards({
  required List<ResolvedFlashcard> items,
  String query = '',
  String? deckFilter,
  FlashcardType? typeFilter,
  FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
  Map<int, SrsCard> cardsByLemmaId = const {},
  Set<int> dueLemmaIds = const {},
}) {
  final normalized = query.trim().toLowerCase();
  return [
    for (final item in items)
      if (_matchesQuery(item, normalized) &&
          _matchesDeck(item.flashcard, deckFilter) &&
          _matchesType(item.flashcard, typeFilter) &&
          _matchesStatus(
            item.flashcard,
            statusFilter,
            cardsByLemmaId,
            dueLemmaIds,
          ))
        item,
  ];
}

bool _matchesQuery(ResolvedFlashcard item, String normalizedQuery) {
  if (normalizedQuery.isEmpty) return true;
  final lemma = item.lemma;
  if (lemma == null) return false;
  final haystacks = [
    lemma.arabic,
    lemma.transliteration,
    lemma.meaningVi,
    lemma.meaningEn,
  ].whereType<String>().map((s) => s.toLowerCase());
  return haystacks.any((h) => h.contains(normalizedQuery));
}

bool _matchesDeck(Flashcard flashcard, String? deckFilter) {
  if (deckFilter == null) return true;
  if (deckFilter == noDeckFilter) return flashcard.deckId == null;
  return flashcard.deckId == deckFilter;
}

bool _matchesType(Flashcard flashcard, FlashcardType? typeFilter) =>
    typeFilter == null || flashcard.type == typeFilter;

bool _matchesStatus(
  Flashcard flashcard,
  FlashcardStatusFilter statusFilter,
  Map<int, SrsCard> cardsByLemmaId,
  Set<int> dueLemmaIds,
) {
  if (statusFilter == FlashcardStatusFilter.all) return true;
  if (statusFilter == FlashcardStatusFilter.due) {
    return dueLemmaIds.contains(flashcard.lexiconEntryId);
  }
  final state =
      cardsByLemmaId[flashcard.lexiconEntryId]?.state ?? SrsCardState.newCard;
  return switch (statusFilter) {
    FlashcardStatusFilter.newCard => state == SrsCardState.newCard,
    FlashcardStatusFilter.learning => state == SrsCardState.learning,
    FlashcardStatusFilter.review => state == SrsCardState.review,
    FlashcardStatusFilter.lapsed => state == SrsCardState.lapsed,
    FlashcardStatusFilter.all || FlashcardStatusFilter.due => true,
  };
}
