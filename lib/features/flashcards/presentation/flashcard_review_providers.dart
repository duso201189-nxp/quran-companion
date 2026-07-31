import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning/domain/entities/srs_card.dart';
import '../../lexicon/data/lexicon_providers.dart';
import '../../lexicon/domain/entities/lemma.dart';
import '../data/flashcard_providers.dart';

/// Một mục ôn tập hiển thị trên màn hình: thẻ SRS + nội dung Lemma đã
/// giải quyết — cùng vai trò ReviewSessionItem (Sprint 10 Phase 2)
/// nhưng cho Lexicon thay vì Ayah. itemId của thẻ 'lemma' CHÍNH LÀ
/// Lemma.id (xem lib/features/lexicon/domain/entities/lemma.dart,
/// SrsCard/scheduler_repository_impl.dart) — giải quyết thẳng qua
/// LexiconRepository.getLemmaById(), không qua bảng trung gian nào.
typedef FlashcardReviewItem = ({SrsCard card, Lemma lemma});

/// Mục ôn tập hiện tại — thẻ đầu tiên của dueFlashcardCardsProvider
/// (đã sắp/khử trùng lặp), với Lemma đã giải quyết để hiển thị. null
/// = đã ôn hết (hoặc chưa từng có Flashcard nào đến hạn).
final currentFlashcardReviewItemProvider =
    FutureProvider.autoDispose<FlashcardReviewItem?>((ref) async {
  final dueCards = await ref.watch(dueFlashcardCardsProvider.future);
  if (dueCards.isEmpty) return null;

  final card = dueCards.first;
  final lemma =
      await ref.watch(lexiconRepositoryProvider).getLemmaById(card.itemId);
  if (lemma == null) return null;

  return (card: card, lemma: lemma);
});
