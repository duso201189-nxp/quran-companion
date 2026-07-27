import '../../flashcards/domain/entities/flashcard.dart';
import '../../flashcards/domain/resolved_flashcard.dart';
import '../../flashcards/domain/smart_deck_selector.dart'
    show selectMostDifficult, selectWeakRoots;
import '../../learning/domain/entities/srs_card.dart';
import '../../lexicon/domain/entities/lemma.dart';
import 'entities/performance_insights.dart';

/// Hàm THUẦN tính PerformanceInsights (Sprint 14 Phase 1 mục 4) — CHỈ
/// gộp/sắp dữ liệu đã tải sẵn, không tự truy vấn. "Weak Roots"/
/// "Difficult Lemmas" TÁI DÙNG NGUYÊN VẸN selectWeakRoots/
/// selectMostDifficult (Sprint 13 Phase 3 — smart_deck_selector.dart)
/// — KHÔNG viết lại logic đã có (đúng yêu cầu "no duplicated
/// statistics").
PerformanceInsights computePerformanceInsights(
  List<Flashcard> flashcards,
  Map<int, Lemma> lemmasByLemmaId,
  Map<int, SrsCard> cardsByLemmaId, {
  DateTime? now,
  int limit = 20,
}) {
  final weakRoots =
      selectWeakRoots(flashcards, lemmasByLemmaId, cardsByLemmaId);
  final difficultLemmas =
      selectMostDifficult(flashcards, cardsByLemmaId, limit: limit);
  final forgotten =
      selectFrequentlyForgotten(flashcards, cardsByLemmaId, limit: limit);
  final improving = selectFastestImproving(
    flashcards,
    cardsByLemmaId,
    now: now,
    limit: limit,
  );

  return PerformanceInsights(
    weakRoots: _resolve(weakRoots, lemmasByLemmaId),
    difficultLemmas: _resolve(difficultLemmas, lemmasByLemmaId),
    frequentlyForgotten: _resolve(forgotten, lemmasByLemmaId),
    fastestImproving: _resolve(improving, lemmasByLemmaId),
  );
}

/// "Hay quên" — SrsCard đang ở trạng thái 'lapsed' (đã tốt nghiệp rồi
/// trả lời sai ít nhất 1 lần gần đây) — suy trực tiếp từ state hiện
/// có, đúng định nghĩa 'lapsed' của SM2SchedulingAlgorithm, không cần
/// lịch sử từng lần ôn.
List<Flashcard> selectFrequentlyForgotten(
  List<Flashcard> flashcards,
  Map<int, SrsCard> cardsByLemmaId, {
  int limit = 20,
}) {
  final result = [
    for (final f in flashcards)
      if (f.type.name == 'lemma' &&
          cardsByLemmaId[f.lexiconEntryId]?.state == SrsCardState.lapsed)
        f,
  ];
  return result.take(limit).toList();
}

/// "Tiến bộ nhanh nhất" — XẤP XỈ: repetitions / số ngày kể từ khi
/// thêm Flashcard (Flashcard.createdAt). KHÔNG phải xu hướng thật
/// theo thời gian (cần lịch sử từng lần ôn để đo "đang cải thiện" so
/// với trước — không có, xem PerformanceInsights.fastestImproving) —
/// đây là chỉ số VẬN TỐC đạt số lần lặp lại thành công, không phải xu
/// hướng.
List<Flashcard> selectFastestImproving(
  List<Flashcard> flashcards,
  Map<int, SrsCard> cardsByLemmaId, {
  DateTime? now,
  int limit = 20,
}) {
  final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
  final withVelocity = [
    for (final f in flashcards)
      if (f.type.name == 'lemma' &&
          (cardsByLemmaId[f.lexiconEntryId]?.repetitions ?? 0) > 0)
        (
          flashcard: f,
          velocity: cardsByLemmaId[f.lexiconEntryId]!.repetitions /
              _daysSince(f.createdAt, nowMs),
        ),
  ]..sort((a, b) => b.velocity.compareTo(a.velocity));

  return [for (final e in withVelocity.take(limit)) e.flashcard];
}

double _daysSince(int createdAtMs, int nowMs) {
  final days = (nowMs - createdAtMs) / const Duration(days: 1).inMilliseconds;
  return days < 1 ? 1 : days; // tối thiểu 1 ngày, tránh chia cho 0.
}

List<ResolvedFlashcard> _resolve(
  List<Flashcard> flashcards,
  Map<int, Lemma> lemmasByLemmaId,
) =>
    [
      for (final f in flashcards)
        (flashcard: f, lemma: lemmasByLemmaId[f.lexiconEntryId]),
    ];
