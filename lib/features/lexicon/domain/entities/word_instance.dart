import 'lexicon_entry.dart';

/// Một lần xuất hiện CỤ THỂ của một Lexeme trong văn bản Qur'an —
/// tầng "Morphology" (Sprint 12 Phase 0.1 mục 2/3), thấp nhất trong
/// phân cấp Root -> Lemma -> Lexeme -> WordInstance. Gắn với
/// [lexemeId] (KHÔNG phải lemmaId trực tiếp) — Lemma chỉ tới được
/// gián tiếp qua Lexeme, đúng như phân cấp đã chốt.
class WordInstance implements LexiconEntry {
  const WordInstance({
    required this.id,
    required this.ayahId,
    required this.lexemeId,
    required this.position,
    required this.arabicForm,
    this.transliteration,
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.morphology;

  /// FK tới Ayah (nhóm A, ayahs.id) chứa lần xuất hiện này.
  final int ayahId;

  /// FK tới [Lexeme] mà lần xuất hiện này là một thể hiện của.
  final int lexemeId;

  /// Vị trí từ trong Ayah (1-based).
  final int position;

  /// Dạng chữ Ả Rập thực tế xuất hiện trong văn bản (đã biến đổi),
  /// khác với Lemma.arabic (dạng đầu mục từ điển).
  final String arabicForm;

  final String? transliteration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordInstance &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ayahId == other.ayahId &&
          lexemeId == other.lexemeId &&
          position == other.position &&
          arabicForm == other.arabicForm &&
          transliteration == other.transliteration;

  @override
  int get hashCode => Object.hash(
        id,
        ayahId,
        lexemeId,
        position,
        arabicForm,
        transliteration,
      );
}
