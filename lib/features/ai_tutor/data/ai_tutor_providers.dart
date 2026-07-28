import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analytics/data/analytics_providers.dart';
import '../domain/ai_tutor_repository.dart';
import '../domain/entities/tutor_context.dart';
import '../domain/entities/tutor_insight.dart';
import '../domain/entities/tutor_suggestion.dart';
import 'ai_tutor_repository_impl.dart';

/// Provider AI Tutor (Sprint 15 Phase 1 mục 5) — CÙNG hình dạng với
/// analytics_providers.dart (Sprint 14 Phase 1): 1 Provider dựng
/// Repository từ dependency đã có (ở đây CHỈ 1 dependency —
/// analyticsRepositoryProvider, không đổi), các FutureProvider.autoDispose
/// gọi lại đúng 1 phương thức Repository. Chưa có UI nào watch những
/// provider này (mục "No UI yet").
final aiTutorRepositoryProvider = Provider<AITutorRepository>((ref) {
  return AITutorRepositoryImpl(ref.watch(analyticsRepositoryProvider));
});

final tutorContextProvider = FutureProvider.autoDispose<TutorContext>((ref) {
  return ref.watch(aiTutorRepositoryProvider).getTutorContext();
});

final tutorSuggestionsProvider =
    FutureProvider.autoDispose<List<TutorSuggestion>>((ref) {
  return ref.watch(aiTutorRepositoryProvider).getSuggestions();
});

final tutorInsightsProvider =
    FutureProvider.autoDispose<List<TutorInsight>>((ref) {
  return ref.watch(aiTutorRepositoryProvider).getInsights();
});
