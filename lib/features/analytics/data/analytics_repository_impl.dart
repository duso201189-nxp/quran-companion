import '../../flashcards/domain/repositories/flashcard_repository.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../../learning/domain/repositories/scheduler_repository.dart';
import '../../lexicon/domain/entities/lemma.dart';
import '../../lexicon/domain/repositories/lexicon_repository.dart';
import '../../stats/domain/entities/study_session.dart';
import '../../stats/domain/repositories/study_session_repository.dart';
import '../domain/achievement_calculator.dart';
import '../domain/analytics_repository.dart';
import '../domain/entities/achievement.dart';
import '../domain/entities/history_bucket.dart';
import '../domain/entities/learning_goal.dart';
import '../domain/entities/learning_statistics.dart';
import '../domain/entities/performance_insights.dart';
import '../domain/learning_goal_calculator.dart';
import '../domain/learning_history_calculator.dart';
import '../domain/learning_statistics_calculator.dart';
import '../domain/performance_insights_selector.dart';

/// Ảnh chụp dữ liệu thô đã tải 1 LẦN từ SchedulerRepository +
/// StudySessionRepository (Sprint 14 Phase 3 mục 2) — CHI TIẾT TRIỂN
/// KHAI NỘI BỘ của [AnalyticsRepositoryImpl]: lớp `private` (tiền tố
/// `_`), Dart đảm bảo KHÔNG thể import/dùng từ file khác — đúng nghĩa
/// "Do NOT expose it publicly yet" bằng chính trình biên dịch, không
/// chỉ quy ước đặt tên.
///
/// LÝ DO tồn tại: getLearningGoals() (Phase 2.2) cần CẢ SrsCard (suy
/// reviewsToday) LẪN StudySession (suy 2 mốc lịch sử Ngày/Tuần) —
/// trước Phase 3, nó gọi lại 2 phương thức public
/// (getLearningStatistics + getLearningHistory x2), khiến
/// watchAllSessions() bị gọi 2 LẦN cho CÙNG 1 danh sách (1 lần cho
/// mốc Ngày, 1 lần cho mốc Tuần) — dữ liệu thô giống hệt nhau, tải 2
/// lần. [_AnalyticsSnapshot] gộp lại: tải CÁC repository nền tảng
/// ĐÚNG 1 LẦN, rồi gọi các Calculator thuần (không đổi, xem
/// learning_statistics_calculator.dart/learning_history_calculator.dart)
/// NHIỀU LẦN trên CÙNG dữ liệu đã tải — kết quả toán học giống hệt
/// trước (cùng hàm thuần, cùng input), chỉ khác số lần truy vấn.
///
/// PHẠM VI CỐ Ý DỪNG LẠI ở TRONG 1 lệnh gọi public — KHÔNG cache giữa
/// các lệnh gọi khác nhau (vd getLearningGoals() và getAchievements()
/// gọi liên tiếp trong 1 lần dựng Dashboard vẫn tải riêng, không chia
/// sẻ). Cache liên-lệnh-gọi sẽ có nguy cơ trả dữ liệu CŨ nếu người
/// dùng vừa ôn xong 1 thẻ giữa 2 lệnh gọi — vi phạm thẳng yêu cầu "no
/// statistic changes / Behavior must remain identical" (Phase 3 mục
/// 4). Xem Return Phase 3 mục "Remaining backlog" để biết ranh giới
/// này được công khai rõ, không phải bỏ sót.
///
/// SẴN SÀNG CHO AI TUTOR TƯƠNG LAI (mục 5): hình dạng này (tải thô 1
/// lần, dẫn xuất nhiều số liệu từ cùng ảnh chụp) chính là thứ AI Tutor
/// sẽ cần khi phải trả lời NHIỀU câu hỏi phái sinh từ CÙNG 1 trạng
/// thái học tập trong 1 lượt hội thoại (vd "tôi học được bao nhiêu" +
/// "tôi có nên ôn thêm không" + "tiến độ ra sao" hỏi liên tiếp) —
/// không cần nhiều vòng round-trip DB cho từng câu hỏi. Khi tới lúc
/// đó, điểm mở rộng tự nhiên là thêm 1 phương thức PUBLIC kiểu
/// `AnalyticsRepository.snapshot()` trả về 1 kiểu snapshot công khai
/// (không nhất thiết là chính lớp private này) — CHƯA làm ở phase
/// này, đúng yêu cầu "Keep all public AnalyticsRepository APIs
/// unchanged" (mục 3).
class _AnalyticsSnapshot {
  const _AnalyticsSnapshot({required this.allCards, required this.sessions});

  final List<SrsCard> allCards;
  final List<StudySession> sessions;
}

/// Triển khai AnalyticsRepository bằng TỔNG HỢP 4 repository đã có
/// (Sprint 14 Phase 1) — KHÔNG có Drift table/repository impl riêng
/// nào cho Analytics, mọi số liệu suy từ dữ liệu đã tồn tại. Đây LÀ
/// cơ chế cụ thể thực thi "No duplicated statistics".
///
/// Ghép ở tầng REPOSITORY (không phải tầng Provider như mọi tổng hợp
/// trước đó — vd resolvedFlashcardsProvider, flashcardSchedulerSyncProvider)
/// — cố ý, vì mục 5 ("Prepare Analytics API for future AI Tutor") cần
/// 1 mặt cắt gọi được trực tiếp không phụ thuộc Riverpod (AI Tutor có
/// thể không chạy trong cùng cây Widget).
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(
    this._scheduler,
    this._flashcards,
    this._lexicon,
    this._studySessions, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SchedulerRepository _scheduler;
  final FlashcardRepository _flashcards;
  final LexiconRepository _lexicon;
  final StudySessionRepository _studySessions;

  /// Tiêm được để test có kết quả xác định — cùng mẫu newId/nowMs đã
  /// dùng ở mọi repository impl khác trong dự án.
  final DateTime Function() _now;

  Future<List<SrsCard>> _loadAllCards() async {
    final ayah = await _scheduler.watchAllCards(LearningItemType.ayah).first;
    final lemma = await _scheduler.watchAllCards(LearningItemType.lemma).first;
    return [...ayah, ...lemma];
  }

  /// Xem doc comment [_AnalyticsSnapshot] — tải cards + sessions ĐÚNG
  /// 1 LẦN, dùng khi 1 lệnh gọi public cần cả 2 (hiện chỉ
  /// getLearningGoals()).
  Future<_AnalyticsSnapshot> _loadSnapshot() async {
    final cards = await _loadAllCards();
    final sessions = await _studySessions.watchAllSessions().first;
    return _AnalyticsSnapshot(allCards: cards, sessions: sessions);
  }

  @override
  Future<LearningStatistics> getLearningStatistics() async {
    final cards = await _loadAllCards();
    final currentStreak = await _studySessions.currentStreak();
    final longestStreak = await _studySessions.longestStreak();
    return computeLearningStatistics(
      cards,
      readingStreakDays: currentStreak,
      longestReadingStreakDays: longestStreak,
      now: _now(),
    );
  }

  @override
  Future<List<HistoryBucket>> getLearningHistory(
    HistoryGranularity granularity, {
    int count = 7,
  }) async {
    final sessions = await _studySessions.watchAllSessions().first;
    return computeLearningHistory(
      sessions,
      granularity,
      count: count,
      now: _now(),
    );
  }

  @override
  Future<PerformanceInsights> getPerformanceInsights({int limit = 20}) async {
    final flashcards = await _flashcards.watchAllFlashcards().first;
    final lemmaIds = [
      for (final f in flashcards)
        if (f.type.name == 'lemma') f.lexiconEntryId,
    ];
    final lemmas = await _lexicon.getLemmasByIds(lemmaIds);
    final lemmasByLemmaId = <int, Lemma>{for (final l in lemmas) l.id: l};

    final lemmaCards =
        await _scheduler.watchAllCards(LearningItemType.lemma).first;
    final cardsByLemmaId = <int, SrsCard>{
      for (final c in lemmaCards) c.itemId: c,
    };

    return computePerformanceInsights(
      flashcards,
      lemmasByLemmaId,
      cardsByLemmaId,
      now: _now(),
      limit: limit,
    );
  }

  @override
  Future<List<LearningGoal>> getLearningGoals() async {
    // Sprint 14 Phase 3: TRƯỚC ĐÂY gọi lại 2 phương thức public
    // (getLearningStatistics + getLearningHistory x2), khiến
    // watchAllSessions() bị tải 2 LẦN cho mốc Ngày và Tuần (cùng 1
    // danh sách) — xem doc comment [_AnalyticsSnapshot]. NAY tải cards
    // + sessions ĐÚNG 1 LẦN qua _loadSnapshot(), rồi gọi lại ĐÚNG các
    // Calculator thuần cũ (không đổi 1 dòng logic) trên dữ liệu đã
    // tải — kết quả toán học giống hệt trước.
    //
    // readingStreakDays/longestReadingStreakDays truyền 0 — KHÔNG
    // phải bỏ sót: computeLearningGoals chỉ đọc stats.reviewsToday từ
    // kết quả bên dưới, không đọc streak, nên bỏ 2 truy vấn
    // currentStreak()/longestStreak() mà getLearningStatistics() công
    // khai vẫn gọi (vẫn cần cho những nơi khác đọc streak thật) — an
    // toàn vì giá trị 0 này không rò ra ngoài List<LearningGoal>.
    //
    // Gọi _now() ĐÚNG 1 LẦN, dùng lại cho cả 3 Calculator — nhất quán
    // hơn bản cũ (gọi _now() riêng ở mỗi lệnh public, có thể lệch vài
    // mili-giây giữa các lệnh gọi thật ngoài đời, dù gần như không ai
    // để ý được).
    final snapshot = await _loadSnapshot();
    final now = _now();
    final stats = computeLearningStatistics(
      snapshot.allCards,
      readingStreakDays: 0,
      longestReadingStreakDays: 0,
      now: now,
    );
    final daily = computeLearningHistory(
      snapshot.sessions,
      HistoryGranularity.daily,
      count: 1,
      now: now,
    );
    final weekly = computeLearningHistory(
      snapshot.sessions,
      HistoryGranularity.weekly,
      count: 1,
      now: now,
    );
    return computeLearningGoals(
      minutesToday: daily.isEmpty ? 0 : daily.last.minutesStudied,
      reviewsToday: stats.reviewsToday,
      minutesThisWeek: weekly.isEmpty ? 0 : weekly.last.minutesStudied,
    );
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    final stats = await getLearningStatistics();
    return computeAchievements(
      cardsStudied: stats.cardsStudied,
      readingStreakDays: stats.readingStreakDays,
      longestReadingStreakDays: stats.longestReadingStreakDays,
      accuracy: stats.accuracy,
    );
  }
}
