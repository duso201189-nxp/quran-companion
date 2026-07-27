import 'dart:math';

import 'entities/quiz_content_pool.dart';
import 'entities/quiz_question.dart';
import 'generators/ayah_continuation_generator.dart';
import 'generators/surah_identification_generator.dart';
import 'generators/translation_matching_generator.dart';
import 'generators/verse_recognition_generator.dart';

/// Trừu tượng một chiến lược sinh câu hỏi (Sprint 10 — DR-2026-0005
/// mục 5). Thuần Dart — KHÔNG import Flutter/Riverpod/Drift/SQLite,
/// KHÔNG đọc đồng hồ hệ thống hay nguồn ngẫu nhiên nội bộ ([random]
/// truyền vào tường minh) — kiểm thử được tất định với seed cố định.
///
/// Thêm loại câu hỏi mới = viết thêm 1 class implement giao diện này
/// rồi thêm vào danh sách của [QuizQuestionFactory] — KHÔNG cần sửa
/// bất kỳ generator nào đã có ("cắm được mà không viết lại code cũ").
abstract interface class QuestionGenerator {
  QuizQuestionType get type;

  /// Sinh 1 câu hỏi từ [pool]. Trả về null nếu [pool] không đủ dữ
  /// liệu cho loại câu hỏi này (vd. chưa đủ 4 Surah để làm phương án
  /// nhiễu) — KHÔNG throw, để QuizQuestionFactory thử loại khác.
  QuizQuestion? generate(QuizContentPool pool, Random random);
}

/// Điều phối nhiều QuestionGenerator — chọn loại câu hỏi ngẫu nhiên
/// mỗi lần sinh, tự động bỏ qua loại không đủ dữ liệu (thử loại khác
/// thay vì thất bại cả câu hỏi). Danh sách generator mặc định gồm 4
/// loại của Sprint 10; truyền [generators] khác để mở rộng/thay thế
/// mà không sửa class này (test cũng dùng tham số này để cô lập từng
/// generator).
class QuizQuestionFactory {
  const QuizQuestionFactory([List<QuestionGenerator>? generators])
      : _generators = generators ??
            const [
              SurahIdentificationGenerator(),
              AyahContinuationGenerator(),
              TranslationMatchingGenerator(),
              VerseRecognitionGenerator(),
            ];

  final List<QuestionGenerator> _generators;

  /// Sinh 1 câu hỏi — thử các generator theo thứ tự đã trộn ngẫu
  /// nhiên, trả về câu hỏi đầu tiên sinh thành công. null nếu không
  /// generator nào đủ dữ liệu.
  QuizQuestion? generateOne(QuizContentPool pool, Random random) {
    final order = List.of(_generators)..shuffle(random);
    for (final generator in order) {
      final question = generator.generate(pool, random);
      if (question != null) return question;
    }
    return null;
  }

  /// Sinh tối đa [count] câu hỏi, tránh trùng đề bài trong cùng phiên
  /// (thử lại tối đa [maxAttemptsPerQuestion] lần/câu trước khi chấp
  /// nhận trùng hoặc bỏ qua) — có thể trả về ÍT hơn [count] nếu [pool]
  /// cạn dữ liệu phù hợp trước khi đủ số lượng (không lặp câu hỏi để
  /// cố lấp đầy).
  List<QuizQuestion> generateQuiz(
    QuizContentPool pool,
    Random random,
    int count, {
    int maxAttemptsPerQuestion = 5,
  }) {
    final questions = <QuizQuestion>[];
    final usedPrompts = <String>{};
    for (var i = 0; i < count; i++) {
      QuizQuestion? question;
      for (var attempt = 0; attempt < maxAttemptsPerQuestion; attempt++) {
        final candidate = generateOne(pool, random);
        if (candidate == null) break; // pool cạn -> thử lại cũng vậy
        question = candidate;
        if (usedPrompts.add(candidate.promptText)) break; // đề mới -> nhận
      }
      if (question == null) break; // pool cạn, dừng sớm
      questions.add(question);
    }
    return questions;
  }
}
