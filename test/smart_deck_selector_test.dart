import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/flashcards/domain/smart_deck_selector.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lemma.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexeme.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

Flashcard _fc(String id, int lemmaId, {int createdAt = 0}) => Flashcard(
      id: id,
      type: FlashcardType.lemma,
      lexiconEntryType: LexiconEntryType.lemma,
      lexiconEntryId: lemmaId,
      createdAt: createdAt,
    );

SrsCard _card(
  int itemId, {
  double ease = 2.5,
  SrsCardState state = SrsCardState.review,
  int repetitions = 1,
}) =>
    SrsCard(
      id: 'card-$itemId',
      itemType: LearningItemType.lemma,
      itemId: itemId,
      easeFactor: ease,
      intervalDays: 1,
      repetitions: repetitions,
      dueDate: 0,
      state: state,
      updatedAtMs: 0,
    );

void main() {
  group('selectTodaysReview', () {
    test('chỉ lấy Flashcard loại lemma có lexiconEntryId nằm trong due', () {
      final flashcards = [_fc('a', 1), _fc('b', 2), _fc('c', 3)];
      final result = selectTodaysReview(flashcards, {1, 3});
      expect(result.map((f) => f.id), ['a', 'c']);
    });

    test('due rỗng -> rỗng', () {
      final flashcards = [_fc('a', 1)];
      expect(selectTodaysReview(flashcards, {}), isEmpty);
    });
  });

  group('selectMostDifficult', () {
    test('sắp theo easeFactor tăng dần (thấp nhất = khó nhất trước)', () {
      final flashcards = [_fc('a', 1), _fc('b', 2), _fc('c', 3)];
      final cardsByLemmaId = {
        1: _card(1, ease: 2.5),
        2: _card(2, ease: 1.3),
        3: _card(3, ease: 1.8),
      };
      final result = selectMostDifficult(flashcards, cardsByLemmaId);
      expect(result.map((f) => f.id), ['b', 'c', 'a']);
    });

    test('bỏ qua Flashcard chưa có SrsCard', () {
      final flashcards = [_fc('a', 1), _fc('b', 2)];
      final cardsByLemmaId = {1: _card(1, ease: 2.0)};
      final result = selectMostDifficult(flashcards, cardsByLemmaId);
      expect(result.map((f) => f.id), ['a']);
    });

    test('cắt ở limit', () {
      final flashcards = [_fc('a', 1), _fc('b', 2), _fc('c', 3)];
      final cardsByLemmaId = {
        1: _card(1, ease: 2.5),
        2: _card(2, ease: 1.3),
        3: _card(3, ease: 1.8),
      };
      final result = selectMostDifficult(flashcards, cardsByLemmaId, limit: 1);
      expect(result.map((f) => f.id), ['b']);
    });
  });

  group('selectRecentlyLearned', () {
    test('chỉ lấy state == review, sắp theo createdAt giảm dần', () {
      final flashcards = [
        _fc('a', 1, createdAt: 1000),
        _fc('b', 2, createdAt: 3000),
        _fc('c', 3, createdAt: 2000),
      ];
      final cardsByLemmaId = {
        1: _card(1, state: SrsCardState.review),
        2: _card(2, state: SrsCardState.learning), // chưa tốt nghiệp
        3: _card(3, state: SrsCardState.review),
      };
      final result = selectRecentlyLearned(flashcards, cardsByLemmaId);
      expect(result.map((f) => f.id), ['c', 'a']);
    });
  });

  group('selectWeakRoots', () {
    test('gộp theo rootId, chọn [rootLimit] gốc có ease trung bình thấp nhất',
        () {
      final flashcards = [
        _fc('a', 1),
        _fc('b', 2),
        _fc('c', 3),
      ];
      final lemmasByLemmaId = {
        1: const Lemma(id: 1, arabic: 'x', rootId: 100),
        2: const Lemma(id: 2, arabic: 'y', rootId: 100),
        3: const Lemma(id: 3, arabic: 'z', rootId: 200),
      };
      final cardsByLemmaId = {
        1: _card(1, ease: 1.3), // root 100 avg = (1.3+1.5)/2 = 1.4
        2: _card(2, ease: 1.5),
        3: _card(3, ease: 2.5), // root 200 avg = 2.5
      };
      final result = selectWeakRoots(
        flashcards,
        lemmasByLemmaId,
        cardsByLemmaId,
        rootLimit: 1,
      );
      expect(result.map((f) => f.id).toSet(), {'a', 'b'});
    });

    test('bỏ qua Lemma không có rootId (từ mượn/hư từ)', () {
      final flashcards = [_fc('a', 1)];
      final lemmasByLemmaId = {1: const Lemma(id: 1, arabic: 'x')};
      final cardsByLemmaId = {1: _card(1)};
      expect(
        selectWeakRoots(flashcards, lemmasByLemmaId, cardsByLemmaId),
        isEmpty,
      );
    });
  });

  group('selectVerbForms', () {
    test('gộp theo Lexeme.formPattern', () {
      final flashcards = [_fc('a', 1), _fc('b', 2)];
      final lexemesByLemmaId = {
        1: [const Lexeme(id: 10, lemmaId: 1, formPattern: 'I')],
        2: [const Lexeme(id: 20, lemmaId: 2, formPattern: 'II')],
      };
      final result = selectVerbForms(flashcards, lexemesByLemmaId);
      expect(result.keys.toSet(), {'I', 'II'});
      expect(result['I']!.map((f) => f.id), ['a']);
      expect(result['II']!.map((f) => f.id), ['b']);
    });

    test('Lexeme không có formPattern -> không xuất hiện ở nhóm nào', () {
      final flashcards = [_fc('a', 1)];
      final lexemesByLemmaId = {
        1: [const Lexeme(id: 10, lemmaId: 1)],
      };
      expect(selectVerbForms(flashcards, lexemesByLemmaId), isEmpty);
    });
  });
}
