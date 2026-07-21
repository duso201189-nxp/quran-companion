/// Loại quan hệ giữa 2 Lemma. KHÔNG phải LexiconEntryType — quan hệ
/// không phải một loại NỘI DUNG, xem [LexiconRelation].
enum LexiconRelationType { synonym, antonym }

/// Một quan hệ NGỮ NGHĨA giữa 2 Lemma (đồng nghĩa/trái nghĩa) —
/// Sprint 12 Phase 0.1 mục 2/3. CỐ Ý KHÔNG implement LexiconEntry:
/// đồng nghĩa/trái nghĩa là QUAN HỆ giữa hai mục đã tồn tại (2 Lemma),
/// tự nó không mang nội dung độc lập như Lemma/Root/Phrase — coi nó
/// như một LexiconEntryType riêng sẽ sai bản chất (không có gì để
/// "getById" ngoài cặp Lemma + loại quan hệ).
class LexiconRelation {
  const LexiconRelation({
    required this.id,
    required this.fromLemmaId,
    required this.toLemmaId,
    required this.relationType,
  });

  final int id;
  final int fromLemmaId;
  final int toLemmaId;
  final LexiconRelationType relationType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexiconRelation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fromLemmaId == other.fromLemmaId &&
          toLemmaId == other.toLemmaId &&
          relationType == other.relationType;

  @override
  int get hashCode => Object.hash(id, fromLemmaId, toLemmaId, relationType);
}
