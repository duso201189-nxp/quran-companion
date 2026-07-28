import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../flashcards/data/flashcard_providers.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../../quiz/data/quiz_providers.dart';
import '../data/learning_planner_providers.dart';
import '../domain/learning_planner.dart';
import '../domain/learning_session_state.dart';
import '../domain/learning_session_summary.dart';

/// Điều phối tầng presentation cho một Learning Session (Sprint 11
/// Phase 2 — kiến trúc đã duyệt ở Phase 0 Revision mục 2): quyết
/// định hoạt động tiếp theo qua LearningPlanner, theo dõi hoạt động
/// đã hoàn thành, tích luỹ tóm tắt phiên.
///
/// KHÔNG sở hữu state của Review/Quiz/Flashcard — Review Session và
/// QuizSessionController giữ nguyên controller/state riêng, không đổi
/// gì (Phase 2 mục "Restrictions"). KHÔNG điều hướng, KHÔNG dựng UI —
/// chỉ [start]/[completeCurrentActivity] được gọi từ bên ngoài (Phase
/// 3, chưa xây). KHÔNG tính lịch trình SM-2 hay sinh câu hỏi Quiz —
/// những việc đó vẫn thuộc SchedulerRepository/QuizQuestionFactory.
class LearningSessionController extends Notifier<LearningSessionState> {
  @override
  LearningSessionState build() => (
        status: LearningSessionStatus.notStarted,
        currentActivity: null,
        completedActivities: const {},
        summary: const LearningSessionSummary(),
        error: null,
      );

  /// Snapshot dueReviewCount tại thời điểm Review trở thành hoạt động
  /// hiện tại — dùng để suy ra "đã ôn bao nhiêu thẻ" khi Review hoàn
  /// thành (chênh lệch trước/sau), vì Review Session không tự đếm và
  /// không được sửa để thêm bộ đếm này. Bookkeeping nội bộ thuần tuý
  /// — không ảnh hưởng quyết định của LearningPlanner (vẫn thuần,
  /// tất định), chỉ ảnh hưởng số liệu tóm tắt.
  int? _reviewCountAtActivityStart;

  /// Cùng vai trò [_reviewCountAtActivityStart] nhưng cho Flashcard
  /// (Sprint 13 Phase 2) — FlashcardReviewScreen cũng không tự đếm,
  /// cùng lý do.
  int? _flashcardCountAtActivityStart;

  /// Bắt đầu phiên: dựng LearningPlanContext từ trạng thái hiện có
  /// của từng module (chỉ đọc), hỏi LearningPlanner hoạt động đầu
  /// tiên.
  ///
  /// Bọc try/catch (Sprint S2, D1) — trước đây một lỗi ở bất kỳ await
  /// nào bên trong (đọc dueReviewCardsProvider/dueFlashcardCardsProvider
  /// lần đầu) sẽ trôi ra ngoài không ai bắt, vì [Notifier] không tự
  /// gói async work bằng AsyncValue như [AsyncNotifier]. Không đổi
  /// sang AsyncNotifier ở đây — vẫn phải giữ nguyên state là chính
  /// LearningSessionState (Phase 2's "restrictions"), chỉ thêm nhánh
  /// lỗi bằng status/error field của chính state đó.
  Future<void> start() async {
    try {
      final context = await _buildContext(const {});
      final planner = ref.read(learningPlannerProvider);
      final next = planner.next(context);
      _trackActivityStart(next, context);

      state = (
        status: next == null
            ? LearningSessionStatus.completed
            : LearningSessionStatus.inProgress,
        currentActivity: next,
        completedActivities: const {},
        summary: const LearningSessionSummary(),
        error: null,
      );
    } catch (e) {
      state = (
        status: LearningSessionStatus.failed,
        currentActivity: null,
        completedActivities: const {},
        summary: const LearningSessionSummary(),
        error: e,
      );
    }
  }

  /// Đánh dấu hoạt động hiện tại đã hoàn thành, tích luỹ tóm tắt từ
  /// module tương ứng, hỏi LearningPlanner hoạt động kế tiếp. No-op
  /// nếu chưa bắt đầu hoặc phiên đã kết thúc.
  ///
  /// Cùng lý do bọc try/catch như [start] (Sprint S2, D1). Khi lỗi,
  /// GIỮ NGUYÊN currentActivity/completedActivities/summary hiện có
  /// (không có gì trong try-block từng ghi vào [state] trước khi lỗi
  /// xảy ra — updatedCompleted/contextAfter/updatedSummary chỉ là
  /// biến cục bộ) — nhờ vậy [retry] gọi lại đúng activity đang dang dở
  /// mà không mất tiến trình đã tích luỹ trước đó.
  Future<void> completeCurrentActivity() async {
    final current = state.currentActivity;
    if (current == null) return;

    try {
      final updatedCompleted = {...state.completedActivities, current};
      final contextAfter = await _buildContext(updatedCompleted);
      final updatedSummary =
          await _accumulate(current, state.summary, contextAfter);

      final planner = ref.read(learningPlannerProvider);
      final next = planner.next(contextAfter);
      _trackActivityStart(next, contextAfter);

      state = (
        status: next == null
            ? LearningSessionStatus.completed
            : LearningSessionStatus.inProgress,
        currentActivity: next,
        completedActivities: updatedCompleted,
        summary: updatedSummary,
        error: null,
      );
    } catch (e) {
      state = (
        status: LearningSessionStatus.failed,
        currentActivity: current,
        completedActivities: state.completedActivities,
        summary: state.summary,
        error: e,
      );
    }
  }

  /// Thử lại sau khi `status == failed` (Sprint S2, D1) — gọi lại
  /// đúng thao tác đã lỗi: [start] nếu lỗi xảy ra trước khi có
  /// currentActivity nào (start() chưa từng thành công), ngược lại
  /// [completeCurrentActivity] (currentActivity vẫn còn nguyên từ lần
  /// thử trước, xem ghi chú ở đó).
  Future<void> retry() async {
    if (state.currentActivity == null) {
      await start();
    } else {
      await completeCurrentActivity();
    }
  }

  void _trackActivityStart(
    LearningActivityType? activity,
    LearningPlanContext context,
  ) {
    _reviewCountAtActivityStart =
        activity == LearningActivityType.review ? context.dueReviewCount : null;
    _flashcardCountAtActivityStart = activity == LearningActivityType.flashcard
        ? context.dueFlashcardCount
        : null;
  }

  /// Dựng LearningPlanContext từ trạng thái ĐỌC ĐƯỢC của từng module,
  /// không tính toán gì thêm.
  Future<LearningPlanContext> _buildContext(
    Set<LearningActivityType> completed,
  ) async {
    // Ưu tiên đọc giá trị ĐÃ CHỐT hiện tại (ref.read đồng bộ trên
    // AsyncValue, không phải .future) — completeCurrentActivity()
    // luôn được gọi SAU khi một nơi khác (listener ở tầng UI) đã thấy
    // giá trị mới nhất, nên provider chắc chắn đã có cache. Chỉ await
    // .future khi CHƯA có cache nào (lần đọc đầu tiên, vd. start() gọi
    // trước khi bất kỳ ai khác từng đọc provider này) — .future tại
    // đúng thời điểm "đang có thay đổi" từng trả về giá trị CŨ một
    // nhịp (đã xác nhận bằng debug trace), ref.read đồng bộ thì không.
    final cached = ref.read(dueReviewCardsProvider).valueOrNull;
    final List<SrsCard> dueReview;
    if (cached != null) {
      dueReview = cached;
    } else {
      dueReview = await ref.read(dueReviewCardsProvider.future);
    }

    // Cùng mẫu đọc dueReviewCardsProvider ở trên (ưu tiên cache đồng
    // bộ, chỉ await .future khi chưa có cache nào).
    final cachedFlashcards = ref.read(dueFlashcardCardsProvider).valueOrNull;
    final List<SrsCard> dueFlashcards;
    if (cachedFlashcards != null) {
      dueFlashcards = cachedFlashcards;
    } else {
      dueFlashcards = await ref.read(dueFlashcardCardsProvider.future);
    }

    return (
      dueReviewCount: dueReview.length,
      // Quiz sinh động từ nhóm A (luôn có nội dung Qur'an) — không có
      // khái niệm "due", nên không phụ thuộc trạng thái phiên Quiz
      // nào. Cố ý KHÔNG đọc quizSessionControllerProvider ở đây: đọc
      // nó sẽ kích hoạt AsyncNotifier.build() (sinh 10 câu hỏi ngẫu
      // nhiên) trước khi người dùng thật sự vào Quiz — chỉ đọc
      // provider đó trong [_accumulate], sau khi Quiz đã là hoạt
      // động và đã hoàn thành.
      quizAvailable: true,
      // Flashcard hiện thực ở Sprint 13 Phase 2 — không còn null
      // (Sprint 11: "module không tồn tại"). 0 = module tồn tại
      // nhưng không có Flashcard nào đến hạn — LearningPlanner phân
      // biệt đúng 2 trường hợp này (xem learning_planner.dart).
      dueFlashcardCount: dueFlashcards.length,
      completedThisSession: completed,
    );
  }

  /// Sao chép kết quả từ module vừa hoàn thành vào tóm tắt — không
  /// suy luận độc lập ngoài chênh lệch dueReviewCount (Review) đã nêu
  /// ở trên.
  Future<LearningSessionSummary> _accumulate(
    LearningActivityType justCompleted,
    LearningSessionSummary previous,
    LearningPlanContext contextAfter,
  ) async {
    switch (justCompleted) {
      case LearningActivityType.review:
        final remaining = contextAfter.dueReviewCount;
        final before = _reviewCountAtActivityStart ?? remaining;
        final completedCount = (before - remaining).clamp(0, before);
        return previous.copyWith(
          reviewCardsCompleted: previous.reviewCardsCompleted + completedCount,
        );
      case LearningActivityType.quiz:
        final quizState = await ref.read(quizSessionControllerProvider.future);
        return previous.copyWith(
          quizScore: quizState.score,
          quizTotal: quizState.questions.length,
        );
      case LearningActivityType.flashcard:
        // Cùng cách tính reviewCardsCompleted ở trên (chênh lệch
        // trước/sau) — FlashcardReviewScreen cũng không tự đếm.
        final remaining = contextAfter.dueFlashcardCount ?? 0;
        final before = _flashcardCountAtActivityStart ?? remaining;
        final completedCount = (before - remaining).clamp(0, before);
        return previous.copyWith(
          flashcardsCompleted: previous.flashcardsCompleted + completedCount,
        );
    }
  }
}

final learningSessionControllerProvider =
    NotifierProvider<LearningSessionController, LearningSessionState>(
  LearningSessionController.new,
);
