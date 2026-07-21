import 'lexicon_entry.dart';

/// Từ điển đầu mục (mục từ điển) — đơn vị ngữ nghĩa mà người dùng
/// thực sự học (Sprint 12 Phase 0.1 mục 3). Đây là mức độ hạt
/// (granularity) Flashcards lên lịch ôn tập (LearningItemType.lemma,
/// SrsCard.itemId = Lemma.id) — KHÔNG đổi so với Phase 0.
class Lemma implements LexiconEntry {
  const Lemma({
    required this.id,
    required this.arabic,
    this.transliteration,
    this.posTag,
    this.meaningVi,
    this.meaningEn,
    this.explanationVi,
    this.rootId,
    this.occurrenceCount = 0,
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.lemma;

  /// Dạng đầu mục từ điển, vd 'كَتَبَ'.
  final String arabic;
  final String? transliteration;

  /// Loại từ khái quát (danh từ/động từ/giới từ...) — chi tiết hình
  /// thái cụ thể hơn (thể/vần) thuộc về Lexeme, không phải ở đây.
  final String? posTag;

  final String? meaningVi;
  final String? meaningEn;
  final String? explanationVi;

  /// FK tới [Root] — nullable vì không phải Lemma nào cũng đã gắn
  /// gốc từ trong dữ liệu (vd. từ mượn, hư từ).
  final int? rootId;

  /// Tổng số lần xuất hiện trong Qur'an — tính sẵn lúc build dữ liệu.
  final int occurrenceCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lemma &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          arabic == other.arabic &&
          transliteration == other.transliteration &&
          posTag == other.posTag &&
          meaningVi == other.meaningVi &&
          meaningEn == other.meaningEn &&
          explanationVi == other.explanationVi &&
          rootId == other.rootId &&
          occurrenceCount == other.occurrenceCount;

  @override
  int get hashCode => Object.hash(
        id,
        arabic,
        transliteration,
        posTag,
        meaningVi,
        meaningEn,
        explanationVi,
        rootId,
        occurrenceCount,
      );
}
