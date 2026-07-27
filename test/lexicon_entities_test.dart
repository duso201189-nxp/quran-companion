import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/lexicon/domain/entities/grammar_feature.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lemma.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexeme.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_relation.dart';
import 'package:quran_companion/features/lexicon/domain/entities/phrase.dart';
import 'package:quran_companion/features/lexicon/domain/entities/root.dart';
import 'package:quran_companion/features/lexicon/domain/entities/word_instance.dart';

void main() {
  group('LexiconEntryType (enum behavior)', () {
    test('có đúng 6 giá trị, không có synonym/antonym', () {
      expect(LexiconEntryType.values, hasLength(6));
      expect(
        LexiconEntryType.values.map((e) => e.name),
        containsAll(
          ['lemma', 'root', 'lexeme', 'morphology', 'grammar', 'phrase'],
        ),
      );
      expect(
        LexiconEntryType.values.map((e) => e.name),
        isNot(contains('synonym')),
      );
      expect(
        LexiconEntryType.values.map((e) => e.name),
        isNot(contains('antonym')),
      );
    });
  });

  group('LexiconRelationType (enum behavior)', () {
    test('chỉ có synonym và antonym', () {
      expect(LexiconRelationType.values, hasLength(2));
      expect(LexiconRelationType.values, [
        LexiconRelationType.synonym,
        LexiconRelationType.antonym,
      ]);
    });
  });

  group('Root (entity creation + equality)', () {
    test('tạo với đủ trường, meaningCore tuỳ chọn', () {
      const root = Root(id: 1, radicals: 'ك ت ب', meaningCore: 'viết/ghi');
      expect(root.id, 1);
      expect(root.radicals, 'ك ت ب');
      expect(root.meaningCore, 'viết/ghi');
      expect(root.type, LexiconEntryType.root);
    });

    test('meaningCore null vẫn tạo được', () {
      const root = Root(id: 2, radicals: 'ق ر أ');
      expect(root.meaningCore, isNull);
    });

    test('2 instance cùng giá trị -> bằng nhau (value equality)', () {
      const a = Root(id: 1, radicals: 'ك ت ب', meaningCore: 'viết');
      const b = Root(id: 1, radicals: 'ك ت ب', meaningCore: 'viết');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('khác id -> không bằng nhau', () {
      const a = Root(id: 1, radicals: 'ك ت ب');
      const b = Root(id: 2, radicals: 'ك ت ب');
      expect(a, isNot(equals(b)));
    });

    test('khác radicals -> không bằng nhau dù cùng id', () {
      const a = Root(id: 1, radicals: 'ك ت ب');
      const b = Root(id: 1, radicals: 'ق ر أ');
      expect(a, isNot(equals(b)));
    });
  });

  group('Lemma (entity creation + equality)', () {
    test('tạo với đủ trường tuỳ chọn', () {
      const lemma = Lemma(
        id: 10,
        arabic: 'كَتَبَ',
        transliteration: 'kataba',
        posTag: 'verb',
        meaningVi: 'đã viết',
        meaningEn: 'wrote',
        explanationVi: 'động từ thể I',
        rootId: 1,
        occurrenceCount: 42,
      );
      expect(lemma.id, 10);
      expect(lemma.arabic, 'كَتَبَ');
      expect(lemma.rootId, 1);
      expect(lemma.occurrenceCount, 42);
      expect(lemma.type, LexiconEntryType.lemma);
    });

    test('occurrenceCount mặc định 0, rootId có thể null (từ mượn/hư từ)', () {
      const lemma = Lemma(id: 11, arabic: 'فِي');
      expect(lemma.occurrenceCount, 0);
      expect(lemma.rootId, isNull);
    });

    test('value equality: cùng mọi trường -> bằng nhau', () {
      const a = Lemma(id: 1, arabic: 'كَتَبَ', meaningVi: 'viết');
      const b = Lemma(id: 1, arabic: 'كَتَبَ', meaningVi: 'viết');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('khác meaningVi -> không bằng nhau', () {
      const a = Lemma(id: 1, arabic: 'كَتَبَ', meaningVi: 'viết');
      const b = Lemma(id: 1, arabic: 'كَتَبَ', meaningVi: 'đọc');
      expect(a, isNot(equals(b)));
    });
  });

  group('Lexeme (entity creation + equality)', () {
    test('tạo với formPattern/partOfSpeechDetail', () {
      const lexeme = Lexeme(
        id: 100,
        lemmaId: 10,
        formPattern: 'Form I',
        partOfSpeechDetail: 'động từ, gốc quá khứ',
      );
      expect(lexeme.lemmaId, 10);
      expect(lexeme.formPattern, 'Form I');
      expect(lexeme.type, LexiconEntryType.lexeme);
    });

    test('value equality', () {
      const a = Lexeme(id: 1, lemmaId: 10, formPattern: 'Form I');
      const b = Lexeme(id: 1, lemmaId: 10, formPattern: 'Form I');
      const c = Lexeme(id: 1, lemmaId: 10, formPattern: 'Form III');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('WordInstance (entity creation + equality)', () {
    test('tạo với đủ trường, gắn lexemeId KHÔNG phải lemmaId', () {
      const wi = WordInstance(
        id: 1000,
        ayahId: 5,
        lexemeId: 100,
        position: 3,
        arabicForm: 'كَتَبْنَا',
        transliteration: 'katabna',
      );
      expect(wi.ayahId, 5);
      expect(wi.lexemeId, 100);
      expect(wi.position, 3);
      expect(wi.type, LexiconEntryType.morphology);
    });

    test('value equality', () {
      const a = WordInstance(
        id: 1,
        ayahId: 5,
        lexemeId: 100,
        position: 3,
        arabicForm: 'كَتَبْنَا',
      );
      const b = WordInstance(
        id: 1,
        ayahId: 5,
        lexemeId: 100,
        position: 3,
        arabicForm: 'كَتَبْنَا',
      );
      expect(a, equals(b));
    });

    test('khác position -> không bằng nhau', () {
      const a = WordInstance(
        id: 1,
        ayahId: 5,
        lexemeId: 100,
        position: 3,
        arabicForm: 'كَتَبْنَا',
      );
      const b = WordInstance(
        id: 1,
        ayahId: 5,
        lexemeId: 100,
        position: 4,
        arabicForm: 'كَتَبْنَا',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('GrammarFeature (entity creation + equality)', () {
    test('tạo với featureKey/featureValue', () {
      const feature = GrammarFeature(
        id: 1,
        wordInstanceId: 1000,
        featureKey: 'tense',
        featureValue: 'past',
      );
      expect(feature.wordInstanceId, 1000);
      expect(feature.featureKey, 'tense');
      expect(feature.featureValue, 'past');
      expect(feature.type, LexiconEntryType.grammar);
    });

    test(
        'value equality — cùng wordInstanceId nhưng khác featureKey thì '
        'khác nhau (1 WordInstance mang nhiều nhãn đồng thời)', () {
      const tense = GrammarFeature(
        id: 1,
        wordInstanceId: 1000,
        featureKey: 'tense',
        featureValue: 'past',
      );
      const person = GrammarFeature(
        id: 2,
        wordInstanceId: 1000,
        featureKey: 'person',
        featureValue: '3rd',
      );
      expect(tense, isNot(equals(person)));
      expect(tense.wordInstanceId, person.wordInstanceId);
    });
  });

  group('Phrase (entity creation + equality)', () {
    test('tạo với danh sách wordInstanceIds theo thứ tự', () {
      const phrase = Phrase(
        id: 1,
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        meaningVi: 'Nhân danh Allah',
        wordInstanceIds: [10, 11, 12, 13],
      );
      expect(phrase.wordInstanceIds, [10, 11, 12, 13]);
      expect(phrase.type, LexiconEntryType.phrase);
    });

    test('wordInstanceIds mặc định rỗng', () {
      const phrase = Phrase(id: 2, arabic: 'x');
      expect(phrase.wordInstanceIds, isEmpty);
    });

    test('value equality theo NỘI DUNG danh sách, không phải identity', () {
      const a = Phrase(id: 1, arabic: 'x', wordInstanceIds: [1, 2, 3]);
      const b = Phrase(id: 1, arabic: 'x', wordInstanceIds: [1, 2, 3]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('khác thứ tự wordInstanceIds -> không bằng nhau', () {
      const a = Phrase(id: 1, arabic: 'x', wordInstanceIds: [1, 2, 3]);
      const b = Phrase(id: 1, arabic: 'x', wordInstanceIds: [3, 2, 1]);
      expect(a, isNot(equals(b)));
    });

    test('khác độ dài danh sách -> không bằng nhau', () {
      const a = Phrase(id: 1, arabic: 'x', wordInstanceIds: [1, 2]);
      const b = Phrase(id: 1, arabic: 'x', wordInstanceIds: [1, 2, 3]);
      expect(a, isNot(equals(b)));
    });
  });

  group('LexiconRelation (entity creation + equality)', () {
    test('tạo với relationType synonym/antonym', () {
      const rel = LexiconRelation(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: LexiconRelationType.synonym,
      );
      expect(rel.fromLemmaId, 10);
      expect(rel.toLemmaId, 20);
      expect(rel.relationType, LexiconRelationType.synonym);
    });

    test(
        'LexiconRelation KHÔNG implement LexiconEntry (quan hệ, không '
        'phải nội dung độc lập)', () {
      const rel = LexiconRelation(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: LexiconRelationType.antonym,
      );
      expect(rel, isNot(isA<LexiconEntry>()));
    });

    test('value equality', () {
      const a = LexiconRelation(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: LexiconRelationType.synonym,
      );
      const b = LexiconRelation(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: LexiconRelationType.synonym,
      );
      const c = LexiconRelation(
        id: 1,
        fromLemmaId: 10,
        toLemmaId: 20,
        relationType: LexiconRelationType.antonym,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('mọi thực thể implement LexiconEntry trả đúng .type', () {
    test('Root/Lemma/Lexeme/WordInstance/GrammarFeature/Phrase', () {
      expect(const Root(id: 1, radicals: 'x').type, LexiconEntryType.root);
      expect(const Lemma(id: 1, arabic: 'x').type, LexiconEntryType.lemma);
      expect(const Lexeme(id: 1, lemmaId: 1).type, LexiconEntryType.lexeme);
      expect(
        const WordInstance(
          id: 1,
          ayahId: 1,
          lexemeId: 1,
          position: 1,
          arabicForm: 'x',
        ).type,
        LexiconEntryType.morphology,
      );
      expect(
        const GrammarFeature(
          id: 1,
          wordInstanceId: 1,
          featureKey: 'k',
          featureValue: 'v',
        ).type,
        LexiconEntryType.grammar,
      );
      expect(const Phrase(id: 1, arabic: 'x').type, LexiconEntryType.phrase);
    });
  });
}
