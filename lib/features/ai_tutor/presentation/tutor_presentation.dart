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
        title: l10n.aiTutorSuggestionReviewDueTitle,
        detail: l10n.aiTutorSuggestionReviewDueDetail(count),
      ),
    TutorSuggestionKind.completeDailyStudyGoal => (
        icon: Icons.menu_book_rounded,
        title: l10n.aiTutorSuggestionDailyStudyTitle,
        detail: l10n.aiTutorSuggestionDailyStudyDetail(count),
      ),
    TutorSuggestionKind.completeDailyReviewGoal => (
        icon: Icons.style_rounded,
        title: l10n.aiTutorSuggestionDailyReviewTitle,
        detail: l10n.aiTutorSuggestionDailyReviewDetail(count),
      ),
    TutorSuggestionKind.strengthenWeakRoots => (
        icon: Icons.psychology_rounded,
        title: l10n.aiTutorSuggestionWeakRootsTitle,
        detail: l10n.aiTutorSuggestionWeakRootsDetail(count),
      ),
    TutorSuggestionKind.reviewFrequentlyForgotten => (
        icon: Icons.replay_rounded,
        title: l10n.aiTutorSuggestionForgottenTitle,
        detail: l10n.aiTutorSuggestionForgottenDetail(count),
      ),
    TutorSuggestionKind.maintainStreak => (
        icon: Icons.local_fire_department_rounded,
        title: l10n.aiTutorSuggestionStreakTitle,
        detail: l10n.aiTutorSuggestionStreakDetail(count),
      ),
  };
}

String suggestionPriorityLabel(
  AppLocalizations l10n,
  TutorSuggestionPriority p,
) {
  return switch (p) {
    TutorSuggestionPriority.high => l10n.aiTutorPriorityHigh,
    TutorSuggestionPriority.medium => l10n.aiTutorPriorityMedium,
    TutorSuggestionPriority.low => l10n.aiTutorPriorityLow,
  };
}

/// Nhãn nút hành động theo đích — CÙNG 1 đích dùng lại nhãn giống
/// nhau (vd reviewSession dùng chung cho cả reviewDueCards/
/// completeDailyReviewGoal) vì hành động thật sự giống nhau (đi ôn
/// tập), không phải trùng lặp.
String suggestionActionLabel(AppLocalizations l10n, TutorActionDestination d) {
  return switch (d) {
    TutorActionDestination.reviewSession => l10n.aiTutorActionReviewNow,
    TutorActionDestination.flashcards => l10n.aiTutorActionOpenFlashcards,
    TutorActionDestination.weakCards => l10n.aiTutorActionOpenWeakCards,
    TutorActionDestination.learningSession =>
      l10n.aiTutorActionContinueLearning,
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
        label: l10n.aiTutorInsightAchievementsUnlockedLabel,
        value: '${insight.value.round()}',
      ),
  };
}
