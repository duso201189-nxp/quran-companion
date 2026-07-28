import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../domain/entities/session_strategy.dart';

/// Ánh xạ SessionStrategy sang icon+chuỗi l10n — TẦNG TRÌNH BÀY thuần
/// (cùng kỷ luật suggestionPresentation/insightPresentation của AI
/// Tutor, Sprint 16 Phase 2): domain (SessionStrategy) không nhúng
/// chuỗi 1 ngôn ngữ, hàm này CHỈ tồn tại ở presentation/, dùng chung
/// cho cả SessionSummaryCard lẫn RecommendationCard trong
/// SmartLearningScreen — KHÔNG có 2 bản sao ánh xạ.
({IconData icon, String label}) sessionStrategyPresentation(
  AppLocalizations l10n,
  SessionStrategy strategy,
) {
  return switch (strategy) {
    SessionStrategy.shortReview => (
        icon: Icons.today_rounded,
        label: l10n.smartLearningStrategyShortReview,
      ),
    SessionStrategy.deepStudy => (
        icon: Icons.menu_book_rounded,
        label: l10n.smartLearningStrategyDeepStudy,
      ),
    SessionStrategy.memorization => (
        icon: Icons.psychology_rounded,
        label: l10n.smartLearningStrategyMemorization,
      ),
    SessionStrategy.recovery => (
        icon: Icons.replay_rounded,
        label: l10n.smartLearningStrategyRecovery,
      ),
  };
}
