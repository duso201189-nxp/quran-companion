import 'dart:math';

import '../entities/quiz_content_pool.dart';
import '../entities/quiz_question.dart';
import '../question_generator.dart';

/// "Ayah tiếp theo là gì?" — hiện 1 Ayah, 4 lựa chọn văn bản Ả Rập là
/// Ayah kế tiếp thật (đúng) + 3 Ayah bất kỳ khác (nhiễu).
class AyahContinuationGenerator implements QuestionGenerator {
  const AyahContinuationGenerator();

  @override
  QuizQuestionType get type => QuizQuestionType.ayahContinuation;

  @override
  QuizQuestion? generate(QuizContentPool pool, Random random) {
    final eligible = pool.surahs.where((g) => g.ayahs.length >= 2).toList();
    if (eligible.isEmpty) return null;

    final group = eligible[random.nextInt(eligible.length)];
    final i = random.nextInt(group.ayahs.length - 1);
    final prompt = group.ayahs[i];
    final correct = group.ayahs[i + 1];

    final decoyPool = [
      for (final g in pool.surahs)
        for (final a in g.ayahs)
          if (a.ayahId != prompt.ayahId && a.ayahId != correct.ayahId) a,
    ]..shuffle(random);
    if (decoyPool.length < 3) return null;

    final options = [
      correct.arabic,
      ...decoyPool.take(3).map((a) => a.arabic),
    ]..shuffle(random);
    return QuizQuestion(
      type: type,
      promptText: prompt.arabic,
      promptIsArabic: true,
      options: options,
      correctOptionIndex: options.indexOf(correct.arabic),
      optionsAreArabic: true,
    );
  }
}
