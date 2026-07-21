import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning_journey/data/learning_journey_providers.dart';
import '../domain/entities/smart_learning_session.dart';
import '../domain/smart_learning_repository.dart';
import 'smart_learning_repository_impl.dart';

/// Provider Smart Learning (Sprint 17 Phase 1) — CÙNG hình dạng với
/// learning_journey_providers.dart/ai_tutor_providers.dart: 1 Provider
/// dựng Repository từ dependency đã có (ở đây CHỈ 1 dependency —
/// learningJourneyRepositoryProvider, không đổi), 1 FutureProvider.autoDispose
/// gọi lại đúng phương thức Repository. Chưa có UI nào watch provider
/// này (mục "No UI").
final smartLearningRepositoryProvider = Provider<SmartLearningRepository>(
  (ref) => SmartLearningRepositoryImpl(
    ref.watch(learningJourneyRepositoryProvider),
  ),
);

final smartLearningSessionProvider =
    FutureProvider.autoDispose<SmartLearningSession>((ref) {
  return ref.watch(smartLearningRepositoryProvider).getSmartLearningSession();
});
