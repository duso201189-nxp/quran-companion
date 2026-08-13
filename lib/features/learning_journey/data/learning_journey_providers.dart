import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai_tutor/data/ai_tutor_providers.dart';
import '../domain/entities/learning_journey.dart';
import '../domain/learning_journey_repository.dart';
import 'learning_journey_repository_impl.dart';

/// Provider Learning Journey (Sprint 16 Phase 1) — CÙNG hình dạng với
/// ai_tutor_providers.dart (Sprint 15 Phase 1): 1 Provider dựng
/// Repository từ dependency đã có (ở đây CHỈ 1 dependency —
/// aiTutorRepositoryProvider, không đổi), các FutureProvider.autoDispose
/// gọi lại đúng 1 phương thức Repository.
///
/// learningJourneyProvider KHÔNG được tối ưu ở Sprint 18 Phase 2 dù về
/// mặt tính toán CÓ THỂ dựng lại từ tutorContextProvider/
/// tutorSuggestionsProvider/tutorInsightsProvider (đã watch) — lý do:
/// learning_journey_screen.dart's onRefresh/onRetry CHỈ
/// ref.invalidate(learningJourneyProvider), KHÔNG invalidate 3 provider
/// AI Tutor bên dưới; nếu provider này đổi sang watch 3 provider đó,
/// "kéo để làm mới" sẽ ÂM THẦM trả lại dữ liệu CŨ (3 provider dưới vẫn
/// còn sống/cache) — tương đương 1 lỗi correctness. Sửa đúng cách cần
/// sửa luôn onRefresh/onRetry ở màn hình (invalidate cascade xuống) —
/// đó là thay đổi UI, ngoài phạm vi "No UI redesign" của phase này. Xem
/// docs/knowledge/provider_read_flow.md mục "Không tối ưu".
final learningJourneyRepositoryProvider = Provider<LearningJourneyRepository>(
  (ref) => LearningJourneyRepositoryImpl(ref.watch(aiTutorRepositoryProvider)),
);

final learningJourneyProvider =
    FutureProvider.autoDispose<LearningJourney>((ref) {
  return ref.watch(learningJourneyRepositoryProvider).getLearningJourney();
});
