import '../../learning/domain/entities/srs_card.dart';
import 'entities/learning_statistics.dart';

/// Hàm THUẦN tính LearningStatistics từ SrsCard đã tải sẵn (mọi loại
/// — ayah + lemma) — tách khỏi provider để test trực tiếp không cần
/// DB, cùng kỷ luật selectDueCardsOrdered/smart_deck_selector.dart.
/// KHÔNG tự truy vấn gì — [readingStreakDays]/[longestReadingStreakDays]
/// (tái dùng StudySessionRepository) truyền vào tường minh, tính ở
/// tầng Provider/Repository, không tính lại ở đây.
LearningStatistics computeLearningStatistics(
  List<SrsCard> allCards, {
  required int readingStreakDays,
  required int longestReadingStreakDays,
  DateTime? now,
}) {
  final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
  final todayStart = _startOfDayMs(now ?? DateTime.now());
  final todayEnd = todayStart + const Duration(days: 1).inMilliseconds;

  final studied = allCards.where((c) => c.repetitions > 0).toList();
  final dueToday = allCards.where((c) => c.dueDate <= nowMs).length;

  // XẤP XỈ có chủ đích — xem doc comment LearningStatistics.reviewsToday.
  final reviewsToday = allCards
      .where((c) => c.updatedAtMs >= todayStart && c.updatedAtMs < todayEnd)
      .length;

  final notLapsed = studied.where((c) => c.state != SrsCardState.lapsed);
  final accuracy = studied.isEmpty ? 0.0 : notLapsed.length / studied.length;

  final averageEase = allCards.isEmpty
      ? 0.0
      : allCards.map((c) => c.easeFactor).reduce((a, b) => a + b) /
          allCards.length;
  final averageInterval = allCards.isEmpty
      ? 0.0
      : allCards.map((c) => c.intervalDays).reduce((a, b) => a + b) /
          allCards.length;

  return LearningStatistics(
    cardsStudied: studied.length,
    dueToday: dueToday,
    reviewsToday: reviewsToday,
    accuracy: accuracy,
    averageEase: averageEase,
    averageInterval: averageInterval,
    readingStreakDays: readingStreakDays,
    longestReadingStreakDays: longestReadingStreakDays,
  );
}

int _startOfDayMs(DateTime dt) {
  final d = DateTime(dt.year, dt.month, dt.day);
  return d.toUtc().millisecondsSinceEpoch;
}
