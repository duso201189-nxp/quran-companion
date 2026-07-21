import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/analytics/domain/performance_insights_selector.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lemma.dart';
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
  int repetitions = 1,
  SrsCardState state = SrsCardState.review,
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
  group('selectFrequentlyForgotten', () {
    test('chỉ lấy Flashcard có SrsCard.state == lapsed', () {
      final flashcards = [_fc('a', 1), _fc('b', 2), _fc('c', 3)];
      final cardsByLemmaId = {
        1: _card(1, state: SrsCardState.lapsed),
        2: _card(2, state: SrsCardState.review),
        3: _card(3, state: SrsCardState.lapsed),
      };
      final result = selectFrequentlyForgotten(flashcards, cardsByLemmaId);
      expect(result.map((f) => f.id).toSet(), {'a', 'c'});
    });

    test('không có thẻ lapsed nào -> rỗng', () {
      final flashcards = [_fc('a', 1)];
      final cardsByLemmaId = {1: _card(1, state: SrsCardState.review)};
      expect(selectFrequentlyForgotten(flashcards, cardsByLemmaId), isEmpty);
    });
  });

  group('selectFastestImproving', () {
    test('sắp theo vận tốc repetitions/ngày giảm dần', () {
      final now = DateTime.utc(2026, 1, 11); // 10 ngày sau mốc tạo
      final flashcards = [
        _fc('a', 1, createdAt: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch),
        _fc('b', 2, createdAt: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch),
      ];
      final cardsByLemmaId = {
        1: _card(1, repetitions: 2), // 0.2 rep/ngày
        2: _card(2, repetitions: 8), // 0.8 rep/ngày
      };
      final result = selectFastestImproving(
        flashcards,
        cardsByLemmaId,
        now: now,
      );
      expect(result.map((f) => f.id), ['b', 'a']);
    });

    test('bỏ qua Flashcard chưa ôn lần nào (repetitions == 0)', () {
      final flashcards = [_fc('a', 1)];
      final cardsByLemmaId = {1: _card(1, repetitions: 0)};
      expect(
        selectFastestImproving(flashcards, cardsByLemmaId, now: DateTime.now()),
        isEmpty,
      );
    });

    test('thẻ vừa thêm hôm nay không chia cho 0 (tối thiểu 1 ngày)', () {
      final now = DateTime.utc(2026, 1, 1, 10);
      final flashcards = [
        _fc(
          'a',
          1,
          createdAt: DateTime.utc(2026, 1, 1, 9).millisecondsSinceEpoch,
        ),
      ];
      final cardsByLemmaId = {1: _card(1, repetitions: 1)};
      final result =
          selectFastestImproving(flashcards, cardsByLemmaId, now: now);
      expect(result.map((f) => f.id), ['a']);
    });
  });

  group('computePerformanceInsights', () {
    test('gộp đủ 4 loại, mỗi Flashcard được giải quyết đúng Lemma', () {
      final flashcards = [_fc('a', 1), _fc('b', 2)];
      final lemmasByLemmaId = {
        1: const Lemma(id: 1, arabic: 'كَتَبَ', rootId: 100),
        2: const Lemma(id: 2, arabic: 'قَرَأَ', rootId: 200),
      };
      final cardsByLemmaId = {
        1: _card(1, ease: 1.3, state: SrsCardState.lapsed),
        2: _card(2, ease: 2.5, state: SrsCardState.review),
      };

      final insights = computePerformanceInsights(
        flashcards,
        lemmasByLemmaId,
        cardsByLemmaId,
        now: DateTime.utc(2026, 1, 10),
      );

      expect(insights.frequentlyForgotten.map((r) => r.flashcard.id), ['a']);
      expect(insights.frequentlyForgotten.single.lemma?.arabic, 'كَتَبَ');
      expect(insights.difficultLemmas.first.flashcard.id, 'a');
    });
  });
}
