import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/flashcards/domain/flashcard_filter.dart';
import 'package:quran_companion/features/flashcards/domain/resolved_flashcard.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lemma.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

Flashcard _fc(String id, int lemmaId, {String? deckId}) => Flashcard(
      id: id,
      type: FlashcardType.lemma,
      lexiconEntryType: LexiconEntryType.lemma,
      lexiconEntryId: lemmaId,
      deckId: deckId,
      createdAt: 0,
    );

ResolvedFlashcard _item(
  String id,
  int lemmaId, {
  String? deckId,
  String arabic = 'كَتَبَ',
  String? transliteration,
  String? meaningVi,
}) =>
    (
      flashcard: _fc(id, lemmaId, deckId: deckId),
      lemma: Lemma(
        id: lemmaId,
        arabic: arabic,
        transliteration: transliteration,
        meaningVi: meaningVi,
      ),
    );

void main() {
  group('filterFlashcards — query', () {
    test('khớp arabic', () {
      final items = [_item('a', 1, arabic: 'كَتَبَ')];
      expect(
        filterFlashcards(items: items, query: 'كَتَبَ'),
        hasLength(1),
      );
    });

    test('khớp transliteration, không phân biệt hoa/thường', () {
      final items = [_item('a', 1, transliteration: 'kataba')];
      expect(
        filterFlashcards(items: items, query: 'KATABA'),
        hasLength(1),
      );
    });

    test('khớp meaningVi (chuỗi con)', () {
      final items = [_item('a', 1, meaningVi: 'đã viết')];
      expect(filterFlashcards(items: items, query: 'viết'), hasLength(1));
    });

    test('không khớp -> loại khỏi kết quả', () {
      final items = [_item('a', 1, meaningVi: 'đã viết')];
      expect(
        filterFlashcards(items: items, query: 'không liên quan'),
        isEmpty,
      );
    });

    test('query rỗng -> giữ mọi mục', () {
      final items = [_item('a', 1), _item('b', 2)];
      expect(filterFlashcards(items: items, query: ''), hasLength(2));
    });

    test('lemma null (chưa giải quyết được) -> loại khỏi kết quả khi có query',
        () {
      final items = [
        (flashcard: _fc('a', 1), lemma: null),
      ];
      expect(filterFlashcards(items: items, query: 'bất kỳ'), isEmpty);
    });
  });

  group('filterFlashcards — deck', () {
    test('deckFilter null -> giữ mọi deck', () {
      final items = [_item('a', 1, deckId: 'd1'), _item('b', 2, deckId: null)];
      expect(filterFlashcards(items: items), hasLength(2));
    });

    test('deckFilter = noDeckFilter -> chỉ Flashcard chưa gán deck', () {
      final items = [_item('a', 1, deckId: 'd1'), _item('b', 2, deckId: null)];
      final result = filterFlashcards(items: items, deckFilter: noDeckFilter);
      expect(result.map((r) => r.flashcard.id), ['b']);
    });

    test('deckFilter = id cụ thể -> chỉ Flashcard thuộc đúng deck đó', () {
      final items = [_item('a', 1, deckId: 'd1'), _item('b', 2, deckId: 'd2')];
      final result = filterFlashcards(items: items, deckFilter: 'd1');
      expect(result.map((r) => r.flashcard.id), ['a']);
    });
  });

  group('filterFlashcards — type', () {
    test('typeFilter null -> giữ mọi loại', () {
      final items = [_item('a', 1)];
      expect(
        filterFlashcards(items: items, typeFilter: null),
        hasLength(1),
      );
    });

    test('typeFilter khác loại thật -> loại khỏi kết quả', () {
      final items = [_item('a', 1)]; // FlashcardType.lemma
      final result = filterFlashcards(
        items: items,
        typeFilter: FlashcardType.root,
      );
      expect(result, isEmpty);
    });
  });

  group('filterFlashcards — status', () {
    test('due: chỉ Flashcard nằm trong dueLemmaIds', () {
      final items = [_item('a', 1), _item('b', 2)];
      final result = filterFlashcards(
        items: items,
        statusFilter: FlashcardStatusFilter.due,
        dueLemmaIds: {1},
      );
      expect(result.map((r) => r.flashcard.id), ['a']);
    });

    test('newCard: Flashcard chưa có SrsCard -> coi là new', () {
      final items = [_item('a', 1)];
      final result = filterFlashcards(
        items: items,
        statusFilter: FlashcardStatusFilter.newCard,
        cardsByLemmaId: const {},
      );
      expect(result, hasLength(1));
    });

    test('review: chỉ Flashcard có SrsCard.state == review', () {
      final items = [_item('a', 1), _item('b', 2)];
      final cardsByLemmaId = {
        1: const SrsCard(
          id: 'c1',
          itemType: LearningItemType.lemma,
          itemId: 1,
          easeFactor: 2.5,
          intervalDays: 1,
          repetitions: 1,
          dueDate: 0,
          state: SrsCardState.review,
          updatedAtMs: 0,
        ),
        2: const SrsCard(
          id: 'c2',
          itemType: LearningItemType.lemma,
          itemId: 2,
          easeFactor: 2.5,
          intervalDays: 0,
          repetitions: 0,
          dueDate: 0,
          state: SrsCardState.learning,
          updatedAtMs: 0,
        ),
      };
      final result = filterFlashcards(
        items: items,
        statusFilter: FlashcardStatusFilter.review,
        cardsByLemmaId: cardsByLemmaId,
      );
      expect(result.map((r) => r.flashcard.id), ['a']);
    });
  });

  test('kết hợp nhiều điều kiện lọc cùng lúc', () {
    final items = [
      _item('a', 1, deckId: 'd1', meaningVi: 'đã viết'),
      _item('b', 2, deckId: 'd1', meaningVi: 'sách'),
      _item('c', 3, deckId: 'd2', meaningVi: 'đã viết'),
    ];
    final result = filterFlashcards(
      items: items,
      query: 'viết',
      deckFilter: 'd1',
    );
    expect(result.map((r) => r.flashcard.id), ['a']);
  });
}
