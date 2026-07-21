import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../../lexicon/data/lexicon_providers.dart';
import '../../lexicon/domain/entities/lexeme.dart';
import '../domain/entities/flashcard.dart';
import '../domain/entities/flashcard_deck.dart';
import '../domain/entities/smart_deck_type.dart';
import '../domain/repositories/flashcard_repository.dart';
import '../domain/resolved_flashcard.dart';
import '../domain/smart_deck_selector.dart';
import 'flashcard_repository_impl.dart';

export '../domain/resolved_flashcard.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Mọi Flashcard còn sống, mới nhất trước.
final allFlashcardsProvider = StreamProvider.autoDispose<List<Flashcard>>(
  (ref) => ref.watch(flashcardRepositoryProvider).watchAllFlashcards(),
);

final allFlashcardDecksProvider =
    StreamProvider.autoDispose<List<FlashcardDeck>>(
  (ref) => ref.watch(flashcardRepositoryProvider).watchAllDecks(),
);

/// Flashcard thuộc đúng 1 deck ([deckId] null = chưa gán deck nào) —
/// lọc lại từ allFlashcardsProvider (đã watch sẵn), không thêm truy
/// vấn Drift riêng (giống cách BookmarkCollectionRepository CÓ
/// watchAyahsInCollection riêng ở tầng repository, nhưng ở đây lọc đủ
/// nhẹ để làm ngay tại tầng Provider — Flashcard không nhiều bằng
/// Bookmark toàn app).
final flashcardsInDeckProvider =
    StreamProvider.autoDispose.family<List<Flashcard>, String?>(
  (ref, deckId) => ref
      .watch(flashcardRepositoryProvider)
      .watchAllFlashcards()
      .map((cards) => cards.where((c) => c.deckId == deckId).toList()),
);

/// Orchestration thuần (cùng vai trò schedulerSyncProvider — xem
/// lib/features/learning/data/scheduler_providers.dart): theo dõi
/// danh sách Flashcard loại 'lemma' và gọi
/// SchedulerRepository.syncItemsForType(LearningItemType.lemma, ...)
/// mỗi khi đổi. FlashcardRepository KHÔNG phụ thuộc SchedulerRepository
/// (giữ 2 repository độc lập, đúng tiền lệ Scheduler/UserContent) —
/// cầu nối luôn ở tầng Provider.
///
/// autoDispose: chỉ chạy khi có ai đang watch nó (vd. dueFlashcardCardsProvider).
final flashcardSchedulerSyncProvider = StreamProvider.autoDispose<void>((
  ref,
) async* {
  final flashcards =
      ref.watch(flashcardRepositoryProvider).watchAllFlashcards();
  final schedulerRepo = ref.watch(schedulerRepositoryProvider);
  await for (final cards in flashcards) {
    final lemmaIds = [
      for (final c in cards)
        if (c.type.name == 'lemma') c.lexiconEntryId,
    ];
    await schedulerRepo.syncItemsForType(LearningItemType.lemma, lemmaIds);
    yield null;
  }
});

/// Thẻ SRS (loại từ vựng) đến hạn ôn tập — cùng lọc/sắp/khử trùng lặp
/// [selectDueCardsOrdered] dùng cho dueReviewCardsProvider (Sprint 10
/// Phase 2), tái dùng thẳng thay vì viết lại.
final dueFlashcardCardsProvider = StreamProvider.autoDispose<List<SrsCard>>((
  ref,
) {
  ref.watch(flashcardSchedulerSyncProvider);
  return ref
      .watch(schedulerRepositoryProvider)
      .watchAllCards(LearningItemType.lemma)
      .map((cards) => selectDueCardsOrdered(cards, DateTime.now()));
});

/// Mọi SrsCard loại lemma, theo lemma_id (== itemId) — dùng cho các
/// Smart Deck cần easeFactor/state (Khó nhất, Mới học xong, Gốc yếu).
final lemmaCardsByIdProvider = StreamProvider.autoDispose<Map<int, SrsCard>>((
  ref,
) {
  ref.watch(flashcardSchedulerSyncProvider);
  return ref
      .watch(schedulerRepositoryProvider)
      .watchAllCards(LearningItemType.lemma)
      .map((cards) => {for (final c in cards) c.itemId: c});
});

/// Mọi Flashcard + Lemma đã giải quyết (chỉ loại 'lemma' — Root/Phrase
/// chưa có nguồn duyệt được, xem searchLemmas trong lexicon_repository.dart).
/// Giải quyết theo LÔ (getLemmasByIds) — không N+1 truy vấn.
final resolvedFlashcardsProvider =
    FutureProvider.autoDispose<List<ResolvedFlashcard>>((ref) async {
  final flashcards = await ref.watch(allFlashcardsProvider.future);
  final lemmaIds = [
    for (final f in flashcards)
      if (f.type.name == 'lemma') f.lexiconEntryId,
  ];
  final lemmas =
      await ref.watch(lexiconRepositoryProvider).getLemmasByIds(lemmaIds);
  final lemmaById = {for (final l in lemmas) l.id: l};
  return [
    for (final f in flashcards)
      (flashcard: f, lemma: lemmaById[f.lexiconEntryId]),
  ];
});

/// Smart Deck dạng danh sách phẳng (Sprint 13 Phase 3 mục 4). Truy
/// vấn ĐỘNG mỗi lần đọc — không có bảng/state lưu riêng cho Smart Deck
/// nào. [SmartDeckType.verbForms] trả về BẢN GỘP PHẲNG của
/// [verbFormGroupsProvider] (xem provider đó cho dạng có nhóm).
final smartDeckFlashcardsProvider =
    FutureProvider.autoDispose.family<List<Flashcard>, SmartDeckType>((
  ref,
  type,
) async {
  final flashcards = await ref.watch(allFlashcardsProvider.future);
  switch (type) {
    case SmartDeckType.todaysReview:
      final due = await ref.watch(dueFlashcardCardsProvider.future);
      return selectTodaysReview(flashcards, {for (final c in due) c.itemId});
    case SmartDeckType.mostDifficult:
      final cardsByLemmaId = await ref.watch(lemmaCardsByIdProvider.future);
      return selectMostDifficult(flashcards, cardsByLemmaId);
    case SmartDeckType.recentlyLearned:
      final cardsByLemmaId = await ref.watch(lemmaCardsByIdProvider.future);
      return selectRecentlyLearned(flashcards, cardsByLemmaId);
    case SmartDeckType.weakRoots:
      final lemmaIds = [
        for (final f in flashcards)
          if (f.type.name == 'lemma') f.lexiconEntryId,
      ];
      final lemmas =
          await ref.watch(lexiconRepositoryProvider).getLemmasByIds(lemmaIds);
      final lemmaById = {for (final l in lemmas) l.id: l};
      final cardsByLemmaId = await ref.watch(lemmaCardsByIdProvider.future);
      return selectWeakRoots(flashcards, lemmaById, cardsByLemmaId);
    case SmartDeckType.verbForms:
      final groups = await ref.watch(verbFormGroupsProvider.future);
      return [for (final list in groups.values) ...list];
  }
});

/// "Theo thể động từ" ở dạng GỘP NHÓM (thể -> Flashcard) — xem
/// selectVerbForms. Truy vấn getLexemesForLemma cho từng Lemma (chỉ
/// những Lemma đang có Flashcard, không quét toàn Lexicon).
final verbFormGroupsProvider =
    FutureProvider.autoDispose<Map<String, List<Flashcard>>>((ref) async {
  final flashcards = await ref.watch(allFlashcardsProvider.future);
  final lexiconRepo = ref.watch(lexiconRepositoryProvider);
  final lemmaIds = {
    for (final f in flashcards)
      if (f.type.name == 'lemma') f.lexiconEntryId,
  };
  final lexemesByLemmaId = <int, List<Lexeme>>{};
  for (final id in lemmaIds) {
    lexemesByLemmaId[id] = await lexiconRepo.getLexemesForLemma(id);
  }
  return selectVerbForms(flashcards, lexemesByLemmaId);
});
