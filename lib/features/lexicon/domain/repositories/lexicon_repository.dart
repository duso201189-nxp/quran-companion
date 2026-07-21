import '../entities/grammar_feature.dart';
import '../entities/lemma.dart';
import '../entities/lexeme.dart';
import '../entities/lexicon_entry.dart';
import '../entities/lexicon_relation.dart';
import '../entities/phrase.dart';
import '../entities/root.dart';
import '../entities/word_instance.dart';

/// Cổng đọc nội dung Lexicon (Sprint 12 — Phase 0.1 mục 2). Nhóm A,
/// chỉ đọc. Domain thuần — không biết Drift.
///
/// THIẾT KẾ CHO TƯƠNG LAI, không chỉ cho Vocabulary/Flashcards (Phase
/// 0.1 mục 2 — "Do not optimize only for Vocabulary"): mỗi loại nội
/// dung có nhóm phương thức RIÊNG, kiểu tường minh — thêm loại nội
/// dung mới (vd. idiom, tafsir note) là THÊM một nhóm phương thức mới,
/// KHÔNG sửa các nhóm đã có (Open/Closed). [getEntry] là lối vào tổng
/// quát duy nhất, dùng khi nơi gọi chỉ có (type, id) — mọi nhu cầu cụ
/// thể khác dùng phương thức kiểu tường minh bên dưới.
///
/// KHÔNG có phương thức nào cho Synonym/Antonym dạng "getById" — đó
/// là quan hệ ([LexiconRelation]), truy vấn qua [getRelatedLemmas].
///
/// Lexicon KHÔNG phụ thuộc Flashcards/LearningSession — bất kỳ tính
/// năng nào khác (Trang đọc, Tìm kiếm, AI Tutor tương lai) đều có thể
/// dùng cổng này trực tiếp, không cần đi qua Flashcards.
abstract interface class LexiconRepository {
  /// Giải quyết tổng quát theo (type, id) — dùng khi nơi gọi chỉ biết
  /// cặp này (vd. Flashcard.lexiconEntryId).
  Future<LexiconEntry?> getEntry(LexiconEntryType type, int id);

  // ---- Lemma ----
  Future<Lemma?> getLemmaById(int id);
  Future<List<Lemma>> getLemmasByIds(List<int> ids);

  /// Tìm Lemma theo [query] khớp arabic/transliteration/meaningVi/
  /// meaningEn (LIKE, không phân biệt hoa/thường), sắp theo
  /// occurrenceCount giảm dần (từ thường gặp trước). [query] rỗng/null
  /// -> [limit] Lemma phổ biến nhất (duyệt không cần gõ gì).
  ///
  /// Thêm ở Sprint 13 Phase 3 — Flashcard cần "Thêm Flashcard từ
  /// Lemma" (Phase 0.1 liệt kê Flashcards là consumer nhưng chưa cần
  /// duyệt/tìm cho tới tính năng này). CHỈ đọc, không đổi schema —
  /// cùng tinh thần syncItemsForType đã thêm cho SchedulerRepository ở
  /// Phase 2 (mở rộng có chủ đích một giao diện đã đóng băng, không
  /// phải thiết kế lại nó).
  Future<List<Lemma>> searchLemmas({String? query, int limit = 50});

  /// Các Lemma có quan hệ [relation] với Lemma [lemmaId] (đồng nghĩa/
  /// trái nghĩa) — xem [LexiconRelation].
  Future<List<Lemma>> getRelatedLemmas(
    int lemmaId,
    LexiconRelationType relation,
  );

  // ---- Root ----
  Future<Root?> getRootById(int id);

  /// Mọi Lemma sinh ra từ gốc [rootId] — "những từ nào cùng gốc?".
  Future<List<Lemma>> getLemmasForRoot(int rootId);

  // ---- Lexeme ----
  Future<List<Lexeme>> getLexemesForLemma(int lemmaId);

  // ---- Morphology (WordInstance) ----
  Future<List<WordInstance>> getWordInstancesForLexeme(int lexemeId);

  // ---- Grammar ----
  Future<List<GrammarFeature>> getGrammarFeaturesForWordInstance(
    int wordInstanceId,
  );

  // ---- Phrase ----
  Future<Phrase?> getPhraseById(int id);
}
