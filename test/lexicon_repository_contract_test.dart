import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/lexicon/domain/entities/grammar_feature.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lemma.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexeme.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_relation.dart';
import 'package:quran_companion/features/lexicon/domain/entities/phrase.dart';
import 'package:quran_companion/features/lexicon/domain/entities/root.dart';
import 'package:quran_companion/features/lexicon/domain/entities/word_instance.dart';
import 'package:quran_companion/features/lexicon/domain/repositories/lexicon_repository.dart';

/// Cài đặt giả trong bộ nhớ — chỉ để kiểm chứng GIAO DIỆN
/// LexiconRepository là hiện thực hoá được và hành xử đúng hợp đồng
/// (không phải cài đặt Drift thật, KHÔNG thuộc Phase 1 — xem "Do NOT
/// modify any repository" / không có repository sản xuất nào được
/// tạo ở lib/ trong phase này).
class _FakeLexiconRepository implements LexiconRepository {
  final Map<int, Root> roots = {};
  final Map<int, Lemma> lemmas = {};
  final Map<int, Lexeme> lexemes = {};
  final Map<int, WordInstance> wordInstances = {};
  final Map<int, GrammarFeature> grammarFeatures = {};
  final Map<int, Phrase> phrases = {};
  final List<LexiconRelation> relations = [];

  @override
  Future<LexiconEntry?> getEntry(LexiconEntryType type, int id) async {
    return switch (type) {
      LexiconEntryType.lemma => lemmas[id],
      LexiconEntryType.root => roots[id],
      LexiconEntryType.lexeme => lexemes[id],
      LexiconEntryType.morphology => wordInstances[id],
      LexiconEntryType.grammar => grammarFeatures[id],
      LexiconEntryType.phrase => phrases[id],
    };
  }

  @override
  Future<Lemma?> getLemmaById(int id) async => lemmas[id];

  @override
  Future<List<Lemma>> getLemmasByIds(List<int> ids) async => [
        for (final id in ids)
          if (lemmas[id] case final l?) l,
      ];

  @override
  Future<List<Lemma>> searchLemmas({String? query, int limit = 50}) async {
    final trimmed = query?.trim().toLowerCase() ?? '';
    final matches = trimmed.isEmpty
        ? lemmas.values
        : lemmas.values.where(
            (l) =>
                l.arabic.toLowerCase().contains(trimmed) ||
                (l.transliteration?.toLowerCase().contains(trimmed) ?? false) ||
                (l.meaningVi?.toLowerCase().contains(trimmed) ?? false) ||
                (l.meaningEn?.toLowerCase().contains(trimmed) ?? false),
          );
    final sorted = matches.toList()
      ..sort((a, b) => b.occurrenceCount.compareTo(a.occurrenceCount));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<Lemma>> getRelatedLemmas(
    int lemmaId,
    LexiconRelationType relation,
  ) async {
    final relatedIds = [
      for (final r in relations)
        if (r.relationType == relation)
          if (r.fromLemmaId == lemmaId)
            r.toLemmaId
          else if (r.toLemmaId == lemmaId)
            r.fromLemmaId,
    ];
    return [
      for (final id in relatedIds)
        if (lemmas[id] case final l?) l,
    ];
  }

  @override
  Future<Root?> getRootById(int id) async => roots[id];

  @override
  Future<List<Lemma>> getLemmasForRoot(int rootId) async =>
      lemmas.values.where((l) => l.rootId == rootId).toList();

  @override
  Future<List<Lexeme>> getLexemesForLemma(int lemmaId) async =>
      lexemes.values.where((l) => l.lemmaId == lemmaId).toList();

  @override
  Future<List<WordInstance>> getWordInstancesForLexeme(int lexemeId) async =>
      wordInstances.values.where((w) => w.lexemeId == lexemeId).toList();

  @override
  Future<List<GrammarFeature>> getGrammarFeaturesForWordInstance(
    int wordInstanceId,
  ) async =>
      grammarFeatures.values
          .where((g) => g.wordInstanceId == wordInstanceId)
          .toList();

  @override
  Future<Phrase?> getPhraseById(int id) async => phrases[id];
}

void main() {
  late _FakeLexiconRepository repo;

  setUp(() {
    repo = _FakeLexiconRepository()
      ..roots[1] = const Root(id: 1, radicals: 'ك ت ب', meaningCore: 'viết')
      ..lemmas[10] =
          const Lemma(id: 10, arabic: 'كَتَبَ', meaningVi: 'viết', rootId: 1)
      ..lemmas[11] =
          const Lemma(id: 11, arabic: 'كِتَاب', meaningVi: 'sách', rootId: 1)
      ..lemmas[20] =
          const Lemma(id: 20, arabic: 'دَوَّنَ', meaningVi: 'ghi chép')
      ..lemmas[30] = const Lemma(id: 30, arabic: 'مَحَا', meaningVi: 'xoá')
      ..lexemes[100] = const Lexeme(id: 100, lemmaId: 10, formPattern: 'Form I')
      ..wordInstances[1000] = const WordInstance(
        id: 1000,
        ayahId: 5,
        lexemeId: 100,
        position: 3,
        arabicForm: 'كَتَبْنَا',
      )
      ..grammarFeatures[1] = const GrammarFeature(
        id: 1,
        wordInstanceId: 1000,
        featureKey: 'tense',
        featureValue: 'past',
      )
      ..phrases[1] = const Phrase(
        id: 1,
        arabic: 'بِسْمِ اللَّهِ',
        wordInstanceIds: [1000],
      )
      ..relations.addAll([
        const LexiconRelation(
          id: 1,
          fromLemmaId: 10,
          toLemmaId: 20,
          relationType: LexiconRelationType.synonym,
        ),
        const LexiconRelation(
          id: 2,
          fromLemmaId: 10,
          toLemmaId: 30,
          relationType: LexiconRelationType.antonym,
        ),
      ]);
  });

  group('getEntry — giải quyết tổng quát theo (type, id)', () {
    test('trả đúng thực thể cho từng LexiconEntryType', () async {
      expect(
        await repo.getEntry(LexiconEntryType.root, 1),
        isA<Root>(),
      );
      expect(
        await repo.getEntry(LexiconEntryType.lemma, 10),
        isA<Lemma>(),
      );
      expect(
        await repo.getEntry(LexiconEntryType.lexeme, 100),
        isA<Lexeme>(),
      );
      expect(
        await repo.getEntry(LexiconEntryType.morphology, 1000),
        isA<WordInstance>(),
      );
      expect(
        await repo.getEntry(LexiconEntryType.grammar, 1),
        isA<GrammarFeature>(),
      );
      expect(
        await repo.getEntry(LexiconEntryType.phrase, 1),
        isA<Phrase>(),
      );
    });

    test('id không tồn tại -> null, không throw', () async {
      expect(await repo.getEntry(LexiconEntryType.lemma, 999), isNull);
    });
  });

  group('Lemma', () {
    test('getLemmaById: có -> trả về, không có -> null', () async {
      expect((await repo.getLemmaById(10))?.arabic, 'كَتَبَ');
      expect(await repo.getLemmaById(999), isNull);
    });

    test('getLemmasByIds: bỏ qua id không tồn tại, giữ thứ tự các id có',
        () async {
      final result = await repo.getLemmasByIds([999, 11, 10]);
      expect(result.map((l) => l.id), [11, 10]);
    });

    test('getLemmasByIds: danh sách rỗng -> rỗng', () async {
      expect(await repo.getLemmasByIds([]), isEmpty);
    });
  });

  group('Root', () {
    test('getRootById', () async {
      expect((await repo.getRootById(1))?.radicals, 'ك ت ب');
      expect(await repo.getRootById(999), isNull);
    });

    test('getLemmasForRoot: trả mọi Lemma cùng gốc', () async {
      final result = await repo.getLemmasForRoot(1);
      expect(result.map((l) => l.id).toSet(), {10, 11});
    });

    test('getLemmasForRoot: gốc không ai dùng -> rỗng', () async {
      expect(await repo.getLemmasForRoot(999), isEmpty);
    });
  });

  group('Lexeme', () {
    test('getLexemesForLemma', () async {
      final result = await repo.getLexemesForLemma(10);
      expect(result.single.id, 100);
    });

    test('Lemma không có Lexeme nào -> rỗng', () async {
      expect(await repo.getLexemesForLemma(20), isEmpty);
    });
  });

  group('WordInstance (morphology)', () {
    test('getWordInstancesForLexeme', () async {
      final result = await repo.getWordInstancesForLexeme(100);
      expect(result.single.arabicForm, 'كَتَبْنَا');
    });
  });

  group('GrammarFeature', () {
    test('getGrammarFeaturesForWordInstance', () async {
      final result = await repo.getGrammarFeaturesForWordInstance(1000);
      expect(result.single.featureKey, 'tense');
    });
  });

  group('Phrase', () {
    test('getPhraseById', () async {
      expect((await repo.getPhraseById(1))?.wordInstanceIds, [1000]);
      expect(await repo.getPhraseById(999), isNull);
    });
  });

  group('getRelatedLemmas — quan hệ đồng nghĩa/trái nghĩa', () {
    test('synonym: chỉ trả Lemma có quan hệ synonym', () async {
      final result =
          await repo.getRelatedLemmas(10, LexiconRelationType.synonym);
      expect(result.map((l) => l.id), [20]);
    });

    test('antonym: chỉ trả Lemma có quan hệ antonym', () async {
      final result =
          await repo.getRelatedLemmas(10, LexiconRelationType.antonym);
      expect(result.map((l) => l.id), [30]);
    });

    test('không có quan hệ nào -> rỗng', () async {
      expect(
        await repo.getRelatedLemmas(20, LexiconRelationType.antonym),
        isEmpty,
      );
    });
  });
}
