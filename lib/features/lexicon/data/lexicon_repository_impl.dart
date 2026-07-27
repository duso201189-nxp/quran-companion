import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/grammar_feature.dart';
import '../domain/entities/lemma.dart';
import '../domain/entities/lexeme.dart';
import '../domain/entities/lexicon_entry.dart';
import '../domain/entities/lexicon_relation.dart';
import '../domain/entities/phrase.dart';
import '../domain/entities/root.dart';
import '../domain/entities/word_instance.dart';
import '../domain/repositories/lexicon_repository.dart';

/// Triển khai LexiconRepository trên AppDatabase (Drift, nhóm A).
///
/// CHỈ đọc — không có phương thức ghi (đúng bản chất nhóm A, giống
/// QuranRepositoryImpl). Ánh xạ Database Row -> Domain Entity tập
/// trung trong các hàm `_xFromRow` riêng, không lặp lại logic ánh xạ
/// ở nhiều nơi (mỗi loại thực thể có đúng 1 hàm ánh xạ, mọi phương
/// thức truy vấn loại đó đều gọi lại hàm này).
///
/// LƯU Ý: các bảng Lexicon chưa có trong
/// `assets/database/quran.sqlite` thật — mọi phương thức ở đây sẽ ném
/// lỗi "no such table" khi chạy với file đóng gói hiện tại, cho tới
/// khi có dữ liệu thật (xem chú thích tại content_tables.dart/
/// TODO.md). Test dùng NativeDatabase.memory() nên không gặp vấn đề
/// này (onCreate tạo bảng thật).
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging() (core/logging/repository_boundary_logging.dart),
/// Logger TIÊM QUA constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở
/// đây. Hành vi giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên
/// vẹn) — vd lỗi "no such table" ở trên giờ được log trước khi ném ra.
class LexiconRepositoryImpl implements LexiconRepository {
  LexiconRepositoryImpl(this._db, this._logger);

  final AppDatabase _db;
  final Logger _logger;

  // ------------------------- mappers -------------------------

  Root _rootFromRow(RootRow row) => Root(
        id: row.id,
        radicals: row.radicals,
        meaningCore: row.meaningCore,
      );

  Lemma _lemmaFromRow(LemmaRow row) => Lemma(
        id: row.id,
        arabic: row.arabic,
        transliteration: row.transliteration,
        posTag: row.posTag,
        meaningVi: row.meaningVi,
        meaningEn: row.meaningEn,
        explanationVi: row.explanationVi,
        rootId: row.rootId,
        occurrenceCount: row.occurrenceCount,
      );

  Lexeme _lexemeFromRow(LexemeRow row) => Lexeme(
        id: row.id,
        lemmaId: row.lemmaId,
        formPattern: row.formPattern,
        partOfSpeechDetail: row.partOfSpeechDetail,
      );

  WordInstance _wordInstanceFromRow(WordInstanceRow row) => WordInstance(
        id: row.id,
        ayahId: row.ayahId,
        lexemeId: row.lexemeId,
        position: row.position,
        arabicForm: row.arabicForm,
        transliteration: row.transliteration,
      );

  GrammarFeature _grammarFeatureFromRow(GrammarFeatureRow row) =>
      GrammarFeature(
        id: row.id,
        wordInstanceId: row.wordInstanceId,
        featureKey: row.featureKey,
        featureValue: row.featureValue,
      );

  /// Không nhận [PhraseRow] đơn thuần — cần truy vấn thêm bảng nối
  /// phrase_word_instances để dựng wordInstanceIds theo đúng thứ tự,
  /// nên đây là hàm async riêng thay vì `_xFromRow` đồng bộ như các
  /// loại khác.
  Future<Phrase> _phraseFromRow(PhraseRow row) async {
    final links = await (_db.select(_db.phraseWordInstances)
          ..where((t) => t.phraseId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return Phrase(
      id: row.id,
      arabic: row.arabic,
      transliteration: row.transliteration,
      meaningVi: row.meaningVi,
      meaningEn: row.meaningEn,
      wordInstanceIds: [for (final l in links) l.wordInstanceId],
    );
  }

  // ------------------------- getEntry -------------------------

  @override
  Future<LexiconEntry?> getEntry(LexiconEntryType type, int id) {
    return withFailureLogging<LexiconEntry?>(_logger, 'getEntry', () {
      return switch (type) {
        LexiconEntryType.lemma => getLemmaById(id),
        LexiconEntryType.root => getRootById(id),
        LexiconEntryType.lexeme => _getLexemeById(id),
        LexiconEntryType.morphology => _getWordInstanceById(id),
        LexiconEntryType.grammar => _getGrammarFeatureById(id),
        LexiconEntryType.phrase => getPhraseById(id),
      };
    });
  }

  Future<Lexeme?> _getLexemeById(int id) async {
    final row = await (_db.select(_db.lexemes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _lexemeFromRow(row);
  }

  Future<WordInstance?> _getWordInstanceById(int id) async {
    final row = await (_db.select(_db.wordInstances)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _wordInstanceFromRow(row);
  }

  Future<GrammarFeature?> _getGrammarFeatureById(int id) async {
    final row = await (_db.select(_db.grammarFeatures)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _grammarFeatureFromRow(row);
  }

  // ------------------------- Lemma -------------------------

  @override
  Future<Lemma?> getLemmaById(int id) {
    return withFailureLogging(_logger, 'getLemmaById', () async {
      final row = await (_db.select(_db.lemmas)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _lemmaFromRow(row);
    });
  }

  @override
  Future<List<Lemma>> getLemmasByIds(List<int> ids) {
    return withFailureLogging(_logger, 'getLemmasByIds', () async {
      if (ids.isEmpty) return const [];
      final rows =
          await (_db.select(_db.lemmas)..where((t) => t.id.isIn(ids))).get();
      final byId = {for (final r in rows) r.id: _lemmaFromRow(r)};
      // Giữ đúng thứ tự [ids] truyền vào, bỏ qua id không tồn tại —
      // cùng hành vi QuranRepositoryImpl.getAyahsByIds đã thiết lập.
      return [
        for (final id in ids)
          if (byId[id] case final l?) l,
      ];
    });
  }

  @override
  Future<List<Lemma>> searchLemmas({String? query, int limit = 50}) {
    return withFailureLogging(_logger, 'searchLemmas', () async {
      final trimmed = query?.trim() ?? '';
      final select = _db.select(_db.lemmas)
        ..orderBy([(t) => OrderingTerm.desc(t.occurrenceCount)])
        ..limit(limit);
      if (trimmed.isNotEmpty) {
        final like = '%$trimmed%';
        select.where(
          (t) =>
              t.arabic.like(like) |
              t.transliteration.like(like) |
              t.meaningVi.like(like) |
              t.meaningEn.like(like),
        );
      }
      final rows = await select.get();
      return rows.map(_lemmaFromRow).toList(growable: false);
    });
  }

  @override
  Future<List<Lemma>> getRelatedLemmas(
    int lemmaId,
    LexiconRelationType relation,
  ) {
    return withFailureLogging(_logger, 'getRelatedLemmas', () async {
      final typeValue = relation.name;
      final asSource = await (_db.select(_db.lexiconRelations)
            ..where(
              (t) =>
                  t.fromLemmaId.equals(lemmaId) &
                  t.relationType.equals(typeValue),
            ))
          .get();
      final asTarget = await (_db.select(_db.lexiconRelations)
            ..where(
              (t) =>
                  t.toLemmaId.equals(lemmaId) &
                  t.relationType.equals(typeValue),
            ))
          .get();
      final relatedIds = [
        for (final r in asSource) r.toLemmaId,
        for (final r in asTarget) r.fromLemmaId,
      ];
      return getLemmasByIds(relatedIds);
    });
  }

  // ------------------------- Root -------------------------

  @override
  Future<Root?> getRootById(int id) {
    return withFailureLogging(_logger, 'getRootById', () async {
      final row = await (_db.select(_db.roots)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _rootFromRow(row);
    });
  }

  @override
  Future<List<Lemma>> getLemmasForRoot(int rootId) {
    return withFailureLogging(_logger, 'getLemmasForRoot', () async {
      final rows = await (_db.select(_db.lemmas)
            ..where((t) => t.rootId.equals(rootId)))
          .get();
      return rows.map(_lemmaFromRow).toList(growable: false);
    });
  }

  // ------------------------- Lexeme -------------------------

  @override
  Future<List<Lexeme>> getLexemesForLemma(int lemmaId) {
    return withFailureLogging(_logger, 'getLexemesForLemma', () async {
      final rows = await (_db.select(_db.lexemes)
            ..where((t) => t.lemmaId.equals(lemmaId)))
          .get();
      return rows.map(_lexemeFromRow).toList(growable: false);
    });
  }

  // ------------------------- Morphology (WordInstance) -------------------

  @override
  Future<List<WordInstance>> getWordInstancesForLexeme(int lexemeId) {
    return withFailureLogging(_logger, 'getWordInstancesForLexeme', () async {
      final rows = await (_db.select(_db.wordInstances)
            ..where((t) => t.lexemeId.equals(lexemeId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      return rows.map(_wordInstanceFromRow).toList(growable: false);
    });
  }

  // ------------------------- Grammar -------------------------

  @override
  Future<List<GrammarFeature>> getGrammarFeaturesForWordInstance(
    int wordInstanceId,
  ) {
    return withFailureLogging(
      _logger,
      'getGrammarFeaturesForWordInstance',
      () async {
        final rows = await (_db.select(_db.grammarFeatures)
              ..where((t) => t.wordInstanceId.equals(wordInstanceId)))
            .get();
        return rows.map(_grammarFeatureFromRow).toList(growable: false);
      },
    );
  }

  // ------------------------- Phrase -------------------------

  @override
  Future<Phrase?> getPhraseById(int id) {
    return withFailureLogging(_logger, 'getPhraseById', () async {
      final row = await (_db.select(_db.phrases)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : await _phraseFromRow(row);
    });
  }
}
