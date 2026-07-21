import 'dart:math';

import '../entities/quiz_content_pool.dart';
import '../entities/quiz_question.dart';
import '../question_generator.dart';

/// "Ayah này thuộc Surah nào?" — hiện văn bản Ả Rập 1 Ayah, 4 lựa
/// chọn là tên Surah (1 đúng + 3 Surah khác làm nhiễu).
class SurahIdentificationGenerator implements QuestionGenerator {
  const SurahIdentificationGenerator();

  @override
  QuizQuestionType get type => QuizQuestionType.surahIdentification;

  @override
  QuizQuestion? generate(QuizContentPool pool, Random random) {
    final groups = pool.surahs.where((g) => g.ayahs.isNotEmpty).toList();
    if (groups.length < 4) return null;

    final shuffledGroups = List.of(groups)..shuffle(random);
    final correctGroup = shuffledGroups.first;
    final promptAyah =
        correctGroup.ayahs[random.nextInt(correctGroup.ayahs.length)];
    final decoyNames = [
      for (final g in shuffledGroups.skip(1).take(3)) g.surahNameLatin,
    ];

    final options = [correctGroup.surahNameLatin, ...decoyNames]
      ..shuffle(random);
    return QuizQuestion(
      type: type,
      promptText: promptAyah.arabic,
      promptIsArabic: true,
      options: options,
      correctOptionIndex: options.indexOf(correctGroup.surahNameLatin),
      optionsAreArabic: false,
    );
  }
}
