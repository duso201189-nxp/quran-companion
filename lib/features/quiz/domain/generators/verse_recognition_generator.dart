import 'dart:math';

import '../entities/quiz_content_pool.dart';
import '../entities/quiz_question.dart';
import '../question_generator.dart';

/// "Câu nào thuộc Surah X?" — nghịch đảo của SurahIdentification: đề
/// bài là TÊN Surah, 4 lựa chọn là văn bản Ả Rập của các Ayah (1 đúng
/// thuộc Surah đó + 3 Ayah từ Surah khác làm nhiễu).
class VerseRecognitionGenerator implements QuestionGenerator {
  const VerseRecognitionGenerator();

  @override
  QuizQuestionType get type => QuizQuestionType.verseRecognition;

  @override
  QuizQuestion? generate(QuizContentPool pool, Random random) {
    final groups = pool.surahs.where((g) => g.ayahs.isNotEmpty).toList();
    if (groups.length < 4) return null;

    final shuffledGroups = List.of(groups)..shuffle(random);
    final correctGroup = shuffledGroups.first;
    final correctAyah =
        correctGroup.ayahs[random.nextInt(correctGroup.ayahs.length)];
    final decoyAyahs = [
      for (final g in shuffledGroups.skip(1).take(3))
        g.ayahs[random.nextInt(g.ayahs.length)],
    ];

    final options = [
      correctAyah.arabic,
      ...decoyAyahs.map((a) => a.arabic),
    ]..shuffle(random);
    return QuizQuestion(
      type: type,
      promptText: correctGroup.surahNameLatin,
      promptIsArabic: false,
      options: options,
      correctOptionIndex: options.indexOf(correctAyah.arabic),
      optionsAreArabic: true,
    );
  }
}
