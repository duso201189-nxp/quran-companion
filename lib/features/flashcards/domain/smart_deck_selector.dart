import '../../learning/domain/entities/srs_card.dart';
import '../../lexicon/domain/entities/lemma.dart';
import '../../lexicon/domain/entities/lexeme.dart';
import 'entities/flashcard.dart';

/// Hàm THUẦN chọn lọc Flashcard cho từng Smart Deck (Sprint 13 Phase
/// 3 mục 4) — tách riêng khỏi provider/DB để test trực tiếp không cần
/// ProviderContainer, cùng kỷ luật `selectDueCardsOrdered` đã dùng ở
/// scheduler_providers.dart (Sprint 10 Phase 2). KHÔNG hàm nào ở đây
/// tự truy vấn — mọi dữ liệu (Flashcard/SrsCard/Lemma/Lexeme) đã được
/// tầng Provider tải sẵn, truyền vào tường minh.

/// "Đến hạn hôm nay" — Flashcard loại lemma có SrsCard.itemId nằm
/// trong [dueLemmaIds] (SrsCard.itemId = Lemma.id trực tiếp, xem
/// lemma.dart). Chính là dueFlashcardCardsProvider đã có, chỉ nối lại
/// với Flashcard entity để hiển thị dạng Smart Deck.
List<Flashcard> selectTodaysReview(
  List<Flashcard> flashcards,
  Set<int> dueLemmaIds,
) =>
    [
      for (final f in flashcards)
        if (f.type.name == 'lemma' && dueLemmaIds.contains(f.lexiconEntryId)) f,
    ];

/// "Khó nhất" — sắp theo easeFactor SM-2 tăng dần (thấp = khó), bỏ
/// qua Flashcard chưa có SrsCard (chưa ôn lần nào, chưa đủ dữ liệu để
/// đánh giá "khó"). Cắt ở [limit].
List<Flashcard> selectMostDifficult(
  List<Flashcard> flashcards,
  Map<int, SrsCard> cardsByLemmaId, {
  int limit = 20,
}) {
  final withCard = [
    for (final f in flashcards)
      if (f.type.name == 'lemma' && cardsByLemmaId[f.lexiconEntryId] != null)
        (flashcard: f, card: cardsByLemmaId[f.lexiconEntryId]!),
  ]..sort((a, b) => a.card.easeFactor.compareTo(b.card.easeFactor));
  return [for (final e in withCard.take(limit)) e.flashcard];
}

/// "Mới học xong" — SrsCard đã tốt nghiệp (state == review, tức đã
/// qua ít nhất 1 lần ôn đúng). XẤP XỈ theo Flashcard.createdAt giảm
/// dần (mới thêm trước) vì SrsCard hiện KHÔNG lộ ra thời điểm ôn gần
/// nhất ở tầng domain (xem Return Phase 3 mục "Remaining backlog" —
/// cần Sprint 10 tự thêm nếu muốn chính xác hơn, ngoài phạm vi "reuse,
/// không redesign Scheduler" của phase này).
List<Flashcard> selectRecentlyLearned(
  List<Flashcard> flashcards,
  Map<int, SrsCard> cardsByLemmaId, {
  int limit = 20,
}) {
  final learned = [
    for (final f in flashcards)
      if (f.type.name == 'lemma' &&
          cardsByLemmaId[f.lexiconEntryId]?.state == SrsCardState.review)
        f,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return learned.take(limit).toList();
}

/// "Gốc từ yếu" — gộp Flashcard theo Root.id (qua Lemma.rootId), tính
/// easeFactor trung bình mỗi gốc, trả về Flashcard thuộc [rootLimit]
/// gốc có ease trung bình THẤP NHẤT (khó nhất). Bỏ qua Lemma không có
/// rootId (từ mượn/hư từ — không có "gốc" để gộp).
List<Flashcard> selectWeakRoots(
  List<Flashcard> flashcards,
  Map<int, Lemma> lemmasByLemmaId,
  Map<int, SrsCard> cardsByLemmaId, {
  int rootLimit = 5,
}) {
  final byRoot = <int, List<({Flashcard flashcard, double ease})>>{};
  for (final f in flashcards) {
    if (f.type.name != 'lemma') continue;
    final lemma = lemmasByLemmaId[f.lexiconEntryId];
    final card = cardsByLemmaId[f.lexiconEntryId];
    if (lemma?.rootId == null || card == null) continue;
    byRoot.putIfAbsent(lemma!.rootId!, () => []).add(
      (flashcard: f, ease: card.easeFactor),
    );
  }

  final avgByRoot = {
    for (final entry in byRoot.entries)
      entry.key: entry.value.map((e) => e.ease).reduce((a, b) => a + b) /
          entry.value.length,
  };
  final weakestRootIds = avgByRoot.keys.toList()
    ..sort((a, b) => avgByRoot[a]!.compareTo(avgByRoot[b]!));

  return [
    for (final rootId in weakestRootIds.take(rootLimit))
      for (final e in byRoot[rootId]!) e.flashcard,
  ];
}

/// "Theo thể động từ" — gộp Flashcard theo Lexeme.formPattern (vd
/// 'I'..'XII') của Lemma tương ứng. Trả về map thể -> Flashcard (khác
/// các Smart Deck trên: đây vốn là 1 nhóm-nhiều-nhóm, không phải 1
/// danh sách phẳng — trình bày ở tầng UI dưới dạng danh sách có mục
/// con theo từng thể).
Map<String, List<Flashcard>> selectVerbForms(
  List<Flashcard> flashcards,
  Map<int, List<Lexeme>> lexemesByLemmaId,
) {
  final byForm = <String, List<Flashcard>>{};
  for (final f in flashcards) {
    if (f.type.name != 'lemma') continue;
    final lexemes = lexemesByLemmaId[f.lexiconEntryId] ?? const <Lexeme>[];
    for (final lexeme in lexemes) {
      final form = lexeme.formPattern;
      if (form == null || form.isEmpty) continue;
      byForm.putIfAbsent(form, () => []).add(f);
    }
  }
  return byForm;
}
