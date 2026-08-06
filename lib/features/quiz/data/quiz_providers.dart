import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../../quran/data/quran_providers.dart';
import '../../quran/presentation/reading/reading_position_store.dart';
import '../domain/entities/quiz_content_pool.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/question_generator.dart';
import '../domain/repositories/quiz_repository.dart';
import 'quiz_repository_impl.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Bộ sinh câu hỏi mặc định (4 loại — DR-2026-0005 mục 5). Provider
/// riêng để tương lai mở rộng/thay danh sách generator không cần sửa
/// nơi gọi, cùng mẫu schedulingAlgorithmProvider (Phase 2).
final questionGeneratorProvider = Provider<QuizQuestionFactory>(
  (ref) => const QuizQuestionFactory(),
);

/// Tập nội dung Qur'an tạm thời cho 1 phiên Quiz — nạp từ
/// QuranRepository (nhóm A), KHÔNG lưu lại (không nhân bản nội dung).
/// Bản dịch ưu tiên vi_main rồi en_sahih, cùng logic với
/// QuranRepositoryImpl._headersForIds (không viết lại ưu tiên khác).
///
/// Sprint 7.1 (Assessment Scoping — Study Architecture Constitution
/// §11: "Assessment content is always scoped to material the user has
/// already read or revised... An assessment drawn from unread content
/// is a violation of this constitution regardless of its technical
/// correctness."). Trước sprint này, pool được dựng từ 8 Surah NGẪU
/// NHIÊN trong toàn bộ 114 Surah, không quan tâm người dùng đã đọc gì
/// — nghĩa là câu hỏi có thể đến từ Ayah chưa từng đọc. Giờ dựng pool
/// CHỈ từ những gì [ReadingPositionStore] đã ghi nhận là đã đọc tới —
/// dùng lại nguyên tín hiệu Sprint 5.1 đã xác lập cho "Đọc tiếp" (`
/// positionFor`), không phát minh định nghĩa "đã đọc" mới. Surah chưa
/// từng mở (không có `positionFor`) không đóng góp gì vào pool — không
/// có nhánh dự phòng nào quay lại nội dung chưa đọc. Pool rỗng (máy
/// mới cài, chưa đọc gì) là kết quả ĐÚNG, không phải lỗi cần vá —
/// [QuizQuestionFactory]/[QuizSessionController]/[QuizSessionScreen]
/// đã tự xử lý pool rỗng đúng cách từ trước, không cần sửa gì thêm ở
/// 3 nơi đó.
final quizContentPoolProvider =
    FutureProvider.autoDispose<QuizContentPool>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final positions = ref.watch(readingPositionStoreProvider);
  final allSurahs = await repo.getAllSurahs();

  final groups = <QuizSurahAyahs>[];
  for (final surah in allSurahs) {
    final readUpTo = positions.positionFor(surah.id);
    if (readUpTo == null) continue;

    final contents = await repo.getAyahsOfSurah(surah.id);
    final readAyahs = [
      for (final c in contents)
        if (c.ayah.ayahNumber <= readUpTo + 1)
          QuizAyahText(
            ayahId: c.ayah.id,
            ayahNumber: c.ayah.ayahNumber,
            arabic: c.ayah.textUthmani,
            translation: c.texts['vi_main'] ?? c.texts['en_sahih'],
          ),
    ];
    if (readAyahs.isEmpty) continue;

    groups.add(
      QuizSurahAyahs(
        surahId: surah.id,
        surahNameLatin: surah.nameLatin,
        ayahs: readAyahs,
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
