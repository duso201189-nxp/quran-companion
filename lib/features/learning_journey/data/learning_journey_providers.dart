import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai_tutor/data/ai_tutor_providers.dart';
import '../domain/daily_learning_plan_generator.dart';
import '../domain/entities/daily_learning_plan.dart';
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

/// Sprint 18 Phase 2 — tái dùng tutorSuggestionsProvider (KHÔNG đổi,
/// vẫn gọi thẳng AITutorRepository.getSuggestions() — vì vậy an toàn
/// thay thế bất kỳ AITutorRepository nào được override, đã kiểm chứng
/// bằng test "dailyLearningPlanProvider trả plan đã sắp xếp đúng..."
/// hiện có trong learning_journey_providers_test.dart, KHÔNG cần sửa)
/// thay vì luôn ref.watch(learningJourneyRepositoryProvider).getDailyPlan()
/// — vốn kích hoạt 1 lượt AITutorRepository.getSuggestions() MỚI hoàn
/// toàn (kéo theo 4 lượt AnalyticsRepository MỚI) mỗi khi được watch,
/// dù tutorSuggestionsProvider có thể ĐÃ được màn hình khác (vd
/// TutorHomeScreen) giữ sống với cùng kết quả. computeDailyLearningPlan
/// là ĐÚNG hàm thuần mà LearningJourneyRepositoryImpl.getDailyPlan() đã
/// dùng nội bộ — KHÔNG có logic mới, KHÔNG bỏ qua lệnh gọi
/// AITutorRepository nào (chỉ tái dùng KẾT QUẢ của lệnh gọi ĐÓ nếu đã
/// có sẵn). Chưa có UI nào watch/refresh provider này nên không có rủi
/// ro "kéo làm mới trả dữ liệu cũ" như learningJourneyProvider ở trên.
final dailyLearningPlanProvider =
    FutureProvider.autoDispose<DailyLearningPlan>((ref) async {
  final suggestions = await ref.watch(tutorSuggestionsProvider.future);
  return computeDailyLearningPlan(suggestions, DateTime.now());
});
