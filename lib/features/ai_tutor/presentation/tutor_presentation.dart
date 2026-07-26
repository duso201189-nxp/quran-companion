import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../domain/entities/tutor_action.dart';
import '../domain/entities/tutor_insight.dart';
import '../domain/entities/tutor_suggestion.dart';

/// Ánh xạ TutorSuggestionKind/TutorSuggestionPriority/TutorActionDestination/
/// TutorInsightKind sang icon+chuỗi l10n — TÁCH RA từ tutor_home_screen.dart
/// (Sprint 15 Phase 2/3) ở Sprint 16 Phase 2, để LearningJourneyScreen
/// (màn hình MỚI, tiêu thụ CÙNG TutorSuggestion/TutorInsight qua
/// LearningJourneyRepository -> AITutorRepository) dùng LẠI đúng 1 bộ
/// ánh xạ, KHÔNG tạo bản sao thứ 2 (đúng yêu cầu "No duplicated
/// calculations"/"No duplicated navigation logic" — dù đây là trình
/// bày chứ không phải tính toán, trùng lặp icon/chuỗi giữa 2 màn hình
/// vẫn là thứ nên tránh, cùng tinh thần).
///
/// Domain (TutorSuggestion/TutorInsight) vẫn giữ NGUYÊN kỷ luật
/// locale-thuần — các hàm này CHỈ tồn tại ở tầng trình bày (thư mục
/// presentation/), không ai trong domain gọi tới.
({IconData icon, String title, String detail}) suggestionPresentation(
  AppLocalizations l10n,
  TutorSuggestion suggestion,
) {
  final count = suggestion.relatedCount ?? 0;
  return switch (suggestion.kind) {
    TutorSuggestionKind.reviewDueCards => (
        icon: Icons.today_rounded,
        title: l10n.studyCoachSuggestionReviewDueTitle,
        detail: l10n.studyCoachSuggestionReviewDueDetail(count),
      ),
    TutorSuggestionKind.completeDailyStudyGoal => (
        icon: Icons.menu_book_rounded,
        title: l10n.studyCoachSuggestionDailyStudyTitle,
        detail: l10n.studyCoachSuggestionDailyStudyDetail(count),
      ),
    TutorSuggestionKind.completeDailyReviewGoal => (
        icon: Icons.style_rounded,
        title: l10n.studyCoachSuggestionDailyReviewTitle,
        detail: l10n.studyCoachSuggestionDailyReviewDetail(count),
      ),
    TutorSuggestionKind.strengthenWeakRoots => (
        icon: Icons.psychology_rounded,
        title: l10n.studyCoachSuggestionWeakRootsTitle,
        detail: l10n.studyCoachSuggestionWeakRootsDetail(count),
      ),
    TutorSuggestionKind.reviewFrequentlyForgotten => (
        icon: Icons.replay_rounded,
        title: l10n.studyCoachSuggestionForgottenTitle,
        detail: l10n.studyCoachSuggestionForgottenDetail(count),
      ),
    TutorSuggestionKind.maintainStreak => (
        icon: Icons.local_fire_department_rounded,
        title: l10n.studyCoachSuggestionStreakTitle,
        detail: l10n.studyCoachSuggestionStreakDetail(count),
      ),
  };
}

String suggestionPriorityLabel(
  AppLocalizations l10n,
  TutorSuggestionPriority p,
) {
  return switch (p) {
    TutorSuggestionPriority.high => l10n.studyCoachPriorityHigh,
    TutorSuggestionPriority.medium => l10n.studyCoachPriorityMedium,
    TutorSuggestionPriority.low => l10n.studyCoachPriorityLow,
  };
}

/// Nhãn nút hành động theo đích — CÙNG 1 đích dùng lại nhãn giống
/// nhau (vd reviewSession dùng chung cho cả reviewDueCards/
/// completeDailyReviewGoal) vì hành động thật sự giống nhau (đi ôn
/// tập), không phải trùng lặp.
String suggestionActionLabel(AppLocalizations l10n, TutorActionDestination d) {
  return switch (d) {
    TutorActionDestination.reviewSession => l10n.studyCoachActionReviewNow,
    TutorActionDestination.flashcards => l10n.studyCoachActionOpenFlashcards,
    TutorActionDestination.weakCards => l10n.studyCoachActionOpenWeakCards,
    TutorActionDestination.learningSession =>
      l10n.studyCoachActionContinueLearning,
  };
}

({IconData icon, String label, String value}) insightPresentation(
  AppLocalizations l10n,
  TutorInsight insight,
) {
  return switch (insight.kind) {
    TutorInsightKind.accuracySummary => (
        icon: Icons.track_changes_rounded,
        label: l10n.statAccuracy,
        value: '${(insight.value * 100).round()}%',
      ),
    TutorInsightKind.streakSummary => (
        icon: Icons.local_fire_department_rounded,
        label: l10n.statsCurrentStreak,
        value: l10n.streakDays(insight.value.round()),
      ),
    TutorInsightKind.cardsStudiedSummary => (
        icon: Icons.style_rounded,
        label: l10n.statCardsStudied,
        value: '${insight.value.round()}',
      ),
    TutorInsightKind.achievementsUnlockedSummary => (
        icon: Icons.emoji_events_rounded,
        label: l10n.studyCoachInsightAchievementsUnlockedLabel,
        value: '${insight.value.round()}',
      ),
  };
}
