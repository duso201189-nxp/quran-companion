import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/quiz/domain/entities/quiz_content_pool.dart';
import 'package:quran_companion/features/quiz/domain/entities/quiz_question.dart';
import 'package:quran_companion/features/quiz/domain/generators/ayah_continuation_generator.dart';
import 'package:quran_companion/features/quiz/domain/generators/surah_identification_generator.dart';
import 'package:quran_companion/features/quiz/domain/generators/translation_matching_generator.dart';
import 'package:quran_companion/features/quiz/domain/generators/verse_recognition_generator.dart';
import 'package:quran_companion/features/quiz/domain/question_generator.dart';

QuizAyahText _ayah(int id, int number, {String? translation}) => QuizAyahText(
      ayahId: id,
      ayahNumber: number,
      arabic: 'ayah-$id',
      translation: translation ?? 'dịch-$id',
    );

/// Pool đủ lớn (5 Surah, mỗi Surah >=2 Ayah, đều có bản dịch) — đủ
/// dữ liệu cho cả 4 loại câu hỏi.
QuizContentPool _richPool() => QuizContentPool([
      for (var s = 1; s <= 5; s++)
        QuizSurahAyahs(
          surahId: s,
          surahNameLatin: 'Surah-$s',
          ayahs: [
            for (var a = 1; a <= 3; a++) _ayah(s * 100 + a, a),
          ],
        ),
    ]);

void main() {
  group('SurahIdentificationGenerator', () {
    const generator = SurahIdentificationGenerator();

    test('sinh câu hỏi: đề bài là Ả Rập, 4 lựa chọn tên Surah, đúng 1 khớp',
        () {
      final question = generator.generate(_richPool(), Random(1));
      expect(question, isNotNull);
      expect(question!.type, QuizQuestionType.surahIdentification);
      expect(question.promptIsArabic, isTrue);
      expect(question.optionsAreArabic, isFalse);
      expect(question.options, hasLength(4));
      expect(question.options.toSet().length, 4, reason: 'không trùng lựa chọn');
      expect(
        question.options[question.correctOptionIndex],
        startsWith('Surah-'),
      );
    });

    test('không đủ 4 Surah -> trả về null (không throw)', () {
      final pool = QuizContentPool([
        QuizSurahAyahs(surahId: 1, surahNameLatin: 'A', ayahs: [_ayah(1, 1)]),
        QuizSurahAyahs(surahId: 2, surahNameLatin: 'B', ayahs: [_ayah(2, 1)]),
      ]);
      expect(generator.generate(pool, Random(1)), isNull);
    });
  });

  group('AyahContinuationGenerator', () {
    const generator = AyahContinuationGenerator();

    test('đề bài + đáp án đúng là 2 Ayah LIỀN KỀ thật trong cùng Surah', () {
      final question = generator.generate(_richPool(), Random(2));
      expect(question, isNotNull);
      expect(question!.type, QuizQuestionType.ayahContinuation);
      expect(question.optionsAreArabic, isTrue);
      expect(question.options, hasLength(4));

      // Đề bài dạng 'ayah-<surah*100+n>' -> đáp án đúng phải là
      // 'ayah-<surah*100+n+1>' (liền kề thật, không phải Ayah bất kỳ).
      final promptId = int.parse(question.promptText.split('-').last);
      final correctText = question.options[question.correctOptionIndex];
      final correctId = int.parse(correctText.split('-').last);
      expect(correctId, promptId + 1);
    });

    test('Surah chỉ có 1 Ayah, không đủ Ayah khác làm nhiễu -> null', () {
      final pool = QuizContentPool([
        QuizSurahAyahs(surahId: 1, surahNameLatin: 'A', ayahs: [_ayah(1, 1)]),
      ]);
      expect(generator.generate(pool, Random(1)), isNull);
    });
  });

  group('TranslationMatchingGenerator', () {
    const generator = TranslationMatchingGenerator();

    test('đề bài Ả Rập, lựa chọn là bản dịch, đúng 1 khớp đúng Ayah', () {
      final question = generator.generate(_richPool(), Random(3));
      expect(question, isNotNull);
      expect(question!.type, QuizQuestionType.translationMatching);
      expect(question.promptIsArabic, isTrue);
      expect(question.optionsAreArabic, isFalse);
      final promptId = int.parse(question.promptText.split('-').last);
      final correctText = question.options[question.correctOptionIndex];
      expect(correctText, 'dịch-$promptId');
    });

    test('không Ayah nào có bản dịch -> null', () {
      const pool = QuizContentPool([
        QuizSurahAyahs(
          surahId: 1,
          surahNameLatin: 'A',
          ayahs: [
            QuizAyahText(ayahId: 1, ayahNumber: 1, arabic: 'x'),
            QuizAyahText(ayahId: 2, ayahNumber: 2, arabic: 'y'),
          ],
        ),
      ]);
      expect(generator.generate(pool, Random(1)), isNull);
    });
  });

  group('VerseRecognitionGenerator', () {
    const generator = VerseRecognitionGenerator();

    test('đề bài là tên Surah, lựa chọn là văn bản Ayah, đúng 1 thuộc '
        'Surah đó', () {
      final question = generator.generate(_richPool(), Random(4));
      expect(question, isNotNull);
      expect(question!.type, QuizQuestionType.verseRecognition);
      expect(question.promptIsArabic, isFalse);
      expect(question.optionsAreArabic, isTrue);
      expect(question.promptText, startsWith('Surah-'));

      final surahNum = int.parse(question.promptText.split('-').last);
      final correctText = question.options[question.correctOptionIndex];
      final correctAyahId = int.parse(correctText.split('-').last);
      // ayahId được đặt = surahId*100 + ayahNumber -> chia 100 ra đúng Surah.
      expect(correctAyahId ~/ 100, surahNum);
    });

    test('không đủ 4 Surah -> null', () {
      final pool = QuizContentPool([
        QuizSurahAyahs(surahId: 1, surahNameLatin: 'A', ayahs: [_ayah(1, 1)]),
      ]);
      expect(generator.generate(pool, Random(1)), isNull);
    });
  });

  group('QuizQuestionFactory', () {
    test('generateOne: sinh được câu hỏi từ pool đủ dữ liệu', () {
      const factory = QuizQuestionFactory();
      final question = factory.generateOne(_richPool(), Random(5));
      expect(question, isNotNull);
    });

    test('generateOne: pool rỗng -> null (mọi generator đều từ chối)', () {
      const factory = QuizQuestionFactory();
      expect(factory.generateOne(const QuizContentPool([]), Random(1)), isNull);
    });

    test('generateQuiz: sinh đúng số lượng câu hỏi yêu cầu khi đủ dữ liệu',
        () {
      const factory = QuizQuestionFactory();
      final questions = factory.generateQuiz(_richPool(), Random(6), 10);
      expect(questions, hasLength(10));
    });

    test('generateQuiz: tránh trùng đề bài trong cùng phiên khi có thể', () {
      const factory = QuizQuestionFactory();
      final questions = factory.generateQuiz(_richPool(), Random(7), 8);
      final prompts = questions.map((q) => q.promptText).toList();
      expect(prompts.toSet().length, prompts.length);
    });

    test('generateQuiz: pool rỗng -> danh sách rỗng, không throw', () {
      const factory = QuizQuestionFactory();
      expect(
        factory.generateQuiz(const QuizContentPool([]), Random(1), 10),
        isEmpty,
      );
    });

    test('generators tuỳ chỉnh: chỉ dùng generator được truyền vào', () {
      const onlyTranslation =
          QuizQuestionFactory([TranslationMatchingGenerator()]);
      final question = onlyTranslation.generateOne(_richPool(), Random(1));
      expect(question!.type, QuizQuestionType.translationMatching);
    });
  });
}
