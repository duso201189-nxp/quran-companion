import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/lexicon/data/lexicon_repository_impl.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_relation.dart';

/// Dữ liệu mẫu CHỈ DÙNG CHO TEST (in-memory database, `onCreate` chạy
/// thật nên các bảng Lexicon tồn tại — xem chú thích tại
/// content_tables.dart về khoảng trống dữ liệu thật trong bản đóng
/// gói). Gieo theo đúng thứ tự phụ thuộc khoá ngoại (foreign_keys ON).
Future<void> _seedLexicon(AppDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.surahs, [
      const SurahRow(
        id: 1,
        nameArabic: 'الفاتحة',
        nameLatin: 'Al-Fatihah',
        nameVi: 'Al-Fatihah',
        nameEn: 'The Opening',
        ayahCount: 7,
        revelationPlace: 'mecca',
        orderRevealed: 5,
      ),
    ]);
    b.insertAll(db.ayahs, [
      const AyahRow(
        id: 5,
        surahId: 1,
        ayahNumber: 5,
        textUthmani: '(fixture)',
        sajdah: false,
      ),
    ]);

    b.insertAll(db.roots, [
      const RootRow(id: 1, radicals: 'ك ت ب', meaningCore: 'viết'),
      const RootRow(id: 2, radicals: 'ق ر أ'),
    ]);

    b.insertAll(db.lemmas, [
      const LemmaRow(
        id: 10,
        arabic: 'كَتَبَ',
        transliteration: 'kataba',
        posTag: 'verb',
        meaningVi: 'đã viết',
        meaningEn: 'wrote',
        explanationVi: 'động từ thể I',
        rootId: 1,
        occurrenceCount: 42,
      ),
      const LemmaRow(
        id: 11,
        arabic: 'كِتَاب',
        meaningVi: 'sách',
        rootId: 1,
        occurrenceCount: 0,
      ),
      const LemmaRow(
        id: 20,
        arabic: 'دَوَّنَ',
        meaningVi: 'ghi chép',
        occurrenceCount: 0,
      ),
      const LemmaRow(
        id: 30,
        arabic: 'مَحَا',
        meaningVi: 'xoá',
        occurrenceCount: 0,
      ),
    ]);

    b.insertAll(db.lexemes, [
      const LexemeRow(
        id: 100,
        lemmaId: 10,
        formPattern: 'Form I',
        partOfSpeechDetail: 'quá khứ',
      ),
    ]);

    b.insertAll(db.wordInstances, [
      const WordInstanceRow(
        id: 1000,
        ayahId: 5,
        lexemeId: 100,
        position: 2,
        arabicForm: 'كَتَبْنَا',
        transliteration: 'katabna',
      ),
      const WordInstanceRow(
        id: 1001,
        ayahId: 5,
        lexemeId: 100,
        position: 1,
        arabicForm: 'إِنَّا',
      ),
    ]);

    b.insertAll(db.grammarFeatures, [
      const GrammarFeatureRow(
        id: 1,
        wordInstanceId: 1000,
        featureKey: 'tense',
        featureValue: 'past',
      ),
      const GrammarFeatureRow(
        id: 2,
        wordInstanceId: 1000,
        featureKey: 'person',
        featureValue: '3rd',
      ),
    ]);

    b.insertAll(db.phrases, [
      const PhraseRow(
        id: 1,
        arabic: 'إِنَّا كَتَبْنَا',
        meaningVi: 'chúng tôi đã viết',
      ),
    ]);
    b.insertAll(db.phraseWordInstances, [
      const PhraseWordInstanceRow(
        phraseId: 1,
        wordInstanceId: 1000,
        position: 2,
      ),
      const PhraseWordInstanceRow(
        phraseId: 1,
        wordInstanceId: 1001,
        position: 1,
      ),
    ]);

    b.insertAll(db.lexiconRelations, [
      const LexiconRelationRow(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: 'synonym',
      ),
      const LexiconRelationRow(
        id: 2,
        fromLemmaId: 30,
        toLemmaId: 10,
        relationType: 'antonym',
      ),
    ]);
  });
}

void main() {
  late AppDatabase db;
  late LexiconRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await _seedLexicon(db);
    repo = LexiconRepositoryImpl(db, const ConsoleLogger());
  });

  tearDown(() async {
    await db.close();
  });

  group('LexiconRepositoryImpl — Lemma', () {
    test('getLemmaById ánh xạ đầy đủ trường (bao gồm cột nullable có giá trị)',
        () async {
      final lemma = await repo.getLemmaById(10);

      expect(lemma, isNotNull);
      expect(lemma!.arabic, 'كَتَبَ');
      expect(lemma.transliteration, 'kataba');
      expect(lemma.posTag, 'verb');
      expect(lemma.meaningVi, 'đã viết');
      expect(lemma.meaningEn, 'wrote');
      expect(lemma.explanationVi, 'động từ thể I');
      expect(lemma.rootId, 1);
      expect(lemma.occurrenceCount, 42);
    });

    test('getLemmaById: cột nullable không có giá trị -> null trong entity',
        () async {
      final lemma = await repo.getLemmaById(20);

      expect(lemma, isNotNull);
      expect(lemma!.rootId, isNull);
      expect(lemma.transliteration, isNull);
      expect(lemma.posTag, isNull);
      expect(lemma.occurrenceCount, 0);
    });

    test('getLemmaById: id không tồn tại -> null, không throw', () async {
      expect(await repo.getLemmaById(999), isNull);
    });

    test('getLemmasByIds: giữ thứ tự [ids], bỏ qua id không tồn tại', () async {
      final result = await repo.getLemmasByIds([999, 11, 10]);
      expect(result.map((l) => l.id), [11, 10]);
    });

    test('getLemmasByIds: danh sách rỗng -> rỗng, không truy vấn', () async {
      expect(await repo.getLemmasByIds(const []), isEmpty);
    });
  });

  group('LexiconRepositoryImpl — searchLemmas (Sprint 13 Phase 3)', () {
    test('không có query -> mọi Lemma, sắp theo occurrenceCount giảm dần',
        () async {
      final result = await repo.searchLemmas();
      expect(result, hasLength(4));
      expect(result.first.id, 10); // occurrenceCount = 42, cao nhất
    });

    test('khớp transliteration', () async {
      final result = await repo.searchLemmas(query: 'kataba');
      expect(result.map((l) => l.id), [10]);
    });

    test('khớp meaningVi (chuỗi con)', () async {
      final result = await repo.searchLemmas(query: 'viết');
      expect(result.map((l) => l.id), contains(10));
    });

    test('không phân biệt hoa/thường', () async {
      final result = await repo.searchLemmas(query: 'KATABA');
      expect(result.map((l) => l.id), [10]);
    });

    test('limit giới hạn số kết quả, vẫn ưu tiên occurrenceCount cao nhất',
        () async {
      final result = await repo.searchLemmas(limit: 1);
      expect(result, hasLength(1));
      expect(result.single.id, 10);
    });

    test('không khớp gì -> rỗng, không throw', () async {
      expect(
        await repo.searchLemmas(query: 'khong-ton-tai-xyz'),
        isEmpty,
      );
    });
  });

  group('LexiconRepositoryImpl — Root', () {
    test('getRootById ánh xạ đầy đủ trường', () async {
      final root = await repo.getRootById(1);
      expect(root, isNotNull);
      expect(root!.radicals, 'ك ت ب');
      expect(root.meaningCore, 'viết');
    });

    test('getRootById: meaningCore null -> entity null tương ứng', () async {
      final root = await repo.getRootById(2);
      expect(root!.meaningCore, isNull);
    });

    test('getRootById: id không tồn tại -> null', () async {
      expect(await repo.getRootById(999), isNull);
    });

    test('getLemmasForRoot: mọi Lemma cùng gốc, đúng quan hệ FK', () async {
      final result = await repo.getLemmasForRoot(1);
      expect(result.map((l) => l.id).toSet(), {10, 11});
    });

    test('getLemmasForRoot: gốc không ai dùng -> rỗng', () async {
      expect(await repo.getLemmasForRoot(999), isEmpty);
    });
  });

  group('LexiconRepositoryImpl — Lexeme', () {
    test('getLexemesForLemma ánh xạ đầy đủ trường', () async {
      final result = await repo.getLexemesForLemma(10);
      expect(result.single.id, 100);
      expect(result.single.formPattern, 'Form I');
      expect(result.single.partOfSpeechDetail, 'quá khứ');
    });

    test('Lemma không có Lexeme nào -> rỗng', () async {
      expect(await repo.getLexemesForLemma(20), isEmpty);
    });
  });

  group('LexiconRepositoryImpl — WordInstance (morphology)', () {
    test('getWordInstancesForLexeme: sắp theo position, không theo id',
        () async {
      final result = await repo.getWordInstancesForLexeme(100);
      expect(result.map((w) => w.id), [1001, 1000]);
      expect(result.first.position, 1);
      expect(result.first.transliteration, isNull);
      expect(result.last.transliteration, 'katabna');
    });

    test('Lexeme không có WordInstance nào -> rỗng', () async {
      expect(await repo.getWordInstancesForLexeme(999), isEmpty);
    });
  });

  group('LexiconRepositoryImpl — GrammarFeature', () {
    test('getGrammarFeaturesForWordInstance trả mọi nhãn của 1 WordInstance',
        () async {
      final result = await repo.getGrammarFeaturesForWordInstance(1000);
      expect(result.map((g) => g.featureKey).toSet(), {'tense', 'person'});
    });

    test('WordInstance không có nhãn nào -> rỗng', () async {
      expect(await repo.getGrammarFeaturesForWordInstance(999), isEmpty);
    });
  });

  group('LexiconRepositoryImpl — Phrase (bảng nối có thứ tự)', () {
    test('getPhraseById dựng lại wordInstanceIds theo đúng [position]',
        () async {
      final phrase = await repo.getPhraseById(1);
      expect(phrase, isNotNull);
      // Chèn theo thứ tự id [1000, 1001] nhưng position là [2, 1] ->
      // kết quả PHẢI theo position, tức [1001, 1000].
      expect(phrase!.wordInstanceIds, [1001, 1000]);
      expect(phrase.meaningVi, 'chúng tôi đã viết');
    });

    test('getPhraseById: id không tồn tại -> null', () async {
      expect(await repo.getPhraseById(999), isNull);
    });
  });

  group('LexiconRepositoryImpl — getRelatedLemmas (toàn vẹn quan hệ)', () {
    test('synonym: chỉ trả Lemma có quan hệ synonym với lemmaId', () async {
      final result =
          await repo.getRelatedLemmas(10, LexiconRelationType.synonym);
      expect(result.map((l) => l.id), [20]);
    });

    test('antonym: đọc đúng cả 2 chiều FK (lemmaId là toLemmaId của quan hệ)',
        () async {
      // Quan hệ id=2 lưu fromLemmaId=30, toLemmaId=10 — truy vấn theo
      // lemmaId=10 (chiều "target") vẫn phải tìm ra Lemma 30.
      final result =
          await repo.getRelatedLemmas(10, LexiconRelationType.antonym);
      expect(result.map((l) => l.id), [30]);
    });

    test('quan hệ khác loại không lẫn vào nhau', () async {
      expect(
        await repo
            .getRelatedLemmas(10, LexiconRelationType.antonym)
            .then((r) => r.map((l) => l.id)),
        isNot(contains(20)),
      );
    });

    test('Lemma không có quan hệ nào -> rỗng', () async {
      expect(
        await repo.getRelatedLemmas(11, LexiconRelationType.synonym),
        isEmpty,
      );
    });
  });

  group('LexiconRepositoryImpl — getEntry (định tuyến theo LexiconEntryType)',
      () {
    test('mỗi loại trả đúng thực thể và đúng .type', () async {
      expect(
        (await repo.getEntry(LexiconEntryType.root, 1))?.type,
        LexiconEntryType.root,
      );
      expect(
        (await repo.getEntry(LexiconEntryType.lemma, 10))?.type,
        LexiconEntryType.lemma,
      );
      expect(
        (await repo.getEntry(LexiconEntryType.lexeme, 100))?.type,
        LexiconEntryType.lexeme,
      );
      expect(
        (await repo.getEntry(LexiconEntryType.morphology, 1000))?.type,
        LexiconEntryType.morphology,
      );
      expect(
        (await repo.getEntry(LexiconEntryType.grammar, 1))?.type,
        LexiconEntryType.grammar,
      );
      expect(
        (await repo.getEntry(LexiconEntryType.phrase, 1))?.type,
        LexiconEntryType.phrase,
      );
    });

    test('id không tồn tại, với mọi loại -> null, không throw', () async {
      for (final type in LexiconEntryType.values) {
        expect(await repo.getEntry(type, 999999), isNull);
      }
    });
  });
}
