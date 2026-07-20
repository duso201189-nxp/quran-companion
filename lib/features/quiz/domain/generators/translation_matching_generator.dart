import 'dart:math';

import '../entities/quiz_content_pool.dart';
import '../entities/quiz_question.dart';
import '../question_generator.dart';

/// "Bản dịch nào khớp với Ayah này?" — hiện văn bản Ả Rập 1 Ayah, 4
/// lựa chọn là bản dịch (1 đúng + 3 bản dịch của Ayah khác làm nhiễu).
class TranslationMatchingGenerator implements QuestionGenerator {
  const TranslationMatchingGenerator();

  @override
  QuizQuestionType get type => QuizQuestionType.translationMatching;

  @override
  QuizQuestion? generate(QuizContentPool pool, Random random) {
    final withTranslation = [
      for (final g in pool.surahs)
        for (final a in g.ayahs)
          if (a.translation != null) a,
    ];
    if (withTranslation.length < 4) return null;

    final shuffled = List.of(withTranslation)..shuffle(random);
    final correct = shuffled.first;
    final decoys = shuffled.skip(1).take(3).map((a) => a.translation!).toList();

    final options = [correct.translation!, ...decoys]..shuffle(random);
    return QuizQuestion(
      type: type,
      promptText: correct.arabic,
      promptIsArabic: true,
      options: options,
      correctOptionIndex: options.indexOf(correct.translation!),
      optionsAreArabic: false,
    );
  }
}
