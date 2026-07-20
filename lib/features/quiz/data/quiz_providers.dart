import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../quran/data/quran_providers.dart';
import '../domain/entities/quiz_content_pool.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/question_generator.dart';
import '../domain/repositories/quiz_repository.dart';
import 'quiz_repository_impl.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(ref.watch(userDatabaseProvider)),
);

/// Bộ sinh câu hỏi mặc định (4 loại — DR-2026-0005 mục 5). Provider
/// riêng để tương lai mở rộng/thay danh sách generator không cần sửa
/// nơi gọi, cùng mẫu schedulingAlgorithmProvider (Phase 2).
final questionGeneratorProvider = Provider<QuizQuestionFactory>(
  (ref) => const QuizQuestionFactory(),
);

/// Số Surah lấy ngẫu nhiên để dựng pool nội dung cho 1 phiên Quiz —
/// đủ đa dạng cho 4 loại câu hỏi (cần tối thiểu 4 Surah), không tải
/// hết 114 Surah mỗi phiên.
const int quizPoolSurahCount = 8;

/// Tập nội dung Qur'an tạm thời cho 1 phiên Quiz — nạp từ
/// QuranRepository (nhóm A), KHÔNG lưu lại (không nhân bản nội dung).
/// Bản dịch ưu tiên vi_main rồi en_sahih, cùng logic với
/// QuranRepositoryImpl._headersForIds (không viết lại ưu tiên khác).
final quizContentPoolProvider =
    FutureProvider.autoDispose<QuizContentPool>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final allSurahs = await repo.getAllSurahs();
  final chosen = (List.of(allSurahs)..shuffle())
      .take(quizPoolSurahCount)
      .toList();

  final groups = <QuizSurahAyahs>[];
  for (final surah in chosen) {
    final contents = await repo.getAyahsOfSurah(surah.id);
    if (contents.isEmpty) continue;
    groups.add(
      QuizSurahAyahs(
        surahId: surah.id,
        surahNameLatin: surah.nameLatin,
        ayahs: [
          for (final c in contents)
            QuizAyahText(
              ayahId: c.ayah.id,
              ayahNumber: c.ayah.ayahNumber,
              arabic: c.ayah.textUthmani,
              translation: c.texts['vi_main'] ?? c.texts['en_sahih'],
            ),
        ],
      ),
    );
  }
  return QuizContentPool(groups);
});

/// Trạng thái 1 phiên Quiz đang diễn ra.
typedef QuizSessionState = ({
  List<QuizQuestion> questions,
  int currentIndex,
  int score,
  bool isComplete,
});

/// Điều phối 1 phiên Quiz: sinh câu hỏi lúc bắt đầu (qua
/// QuizQuestionFactory + quizContentPoolProvider), ghi điểm từng câu,
/// lưu kết quả cuối phiên (qua QuizRepository). KHÔNG tự tính đúng/sai
/// bằng thuật toán riêng — chỉ so sánh với QuizQuestion.correctOptionIndex
/// đã có sẵn từ QuestionGenerator.
class QuizSessionController extends AsyncNotifier<QuizSessionState> {
  static const int questionCount = 10;

  @override
  Future<QuizSessionState> build() async {
    final pool = await ref.watch(quizContentPoolProvider.future);
    final generator = ref.watch(questionGeneratorProvider);
    final questions = generator.generateQuiz(pool, Random(), questionCount);
    return (
      questions: questions,
      currentIndex: 0,
      score: 0,
      isComplete: questions.isEmpty,
    );
  }

  /// Ghi nhận lựa chọn cho câu hỏi hiện tại, chuyển sang câu tiếp theo
  /// ngay lập tức. Trả về true nếu lựa chọn đúng (để UI hiện phản hồi
  /// — widget không tự so sánh đáp án). Khi hết câu hỏi, lưu kết quả
  /// qua QuizRepository.
  Future<bool> answer(int selectedOptionIndex) async {
    final current = state.valueOrNull;
    if (current == null || current.isComplete) return false;

    final question = current.questions[current.currentIndex];
    final correct = selectedOptionIndex == question.correctOptionIndex;
    final nextIndex = current.currentIndex + 1;
    final nextScore = current.score + (correct ? 1 : 0);
    final done = nextIndex >= current.questions.length;

    state = AsyncData(
      (
        questions: current.questions,
        currentIndex: nextIndex,
        score: nextScore,
        isComplete: done,
      ),
    );

    if (done) {
      await ref.read(quizRepositoryProvider).saveResult(
            quizType: 'mixed',
            score: nextScore,
            total: current.questions.length,
          );
    }
    return correct;
  }

  /// Bắt đầu lại: sinh bộ câu hỏi mới, đọc pool mới (Surah ngẫu nhiên
  /// khác có thể được chọn).
  Future<void> restart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final quizSessionControllerProvider =
    AsyncNotifierProvider<QuizSessionController, QuizSessionState>(
  QuizSessionController.new,
);
