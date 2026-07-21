import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../smart_learning/data/smart_learning_providers.dart';
import '../domain/entities/learning_snapshot.dart';
import '../domain/learning_snapshot_generator.dart';
import '../domain/learning_snapshot_repository.dart';
import 'learning_snapshot_repository_impl.dart';

/// Provider Read Model (Sprint 18 Phase 1) — CÙNG hình dạng với
/// smart_learning_providers.dart/learning_journey_providers.dart: 1
/// Provider dựng Repository từ dependency đã có (ở đây CHỈ 1
/// dependency — smartLearningRepositoryProvider, không đổi). Vẫn giữ
/// nguyên (KHÔNG xoá) dù learningSnapshotProvider bên dưới, từ Sprint
/// 18 Phase 2, không còn đi qua nó nữa trên đường đọc chính — vẫn là
/// điểm truy cập LearningSnapshotRepository chuẩn cho bất kỳ nơi nào
/// khác cần (test, ngữ cảnh phi-Riverpod), đúng khuôn dạng mọi
/// *_providers.dart khác trong dự án.
final learningSnapshotRepositoryProvider = Provider<LearningSnapshotRepository>(
  (ref) => LearningSnapshotRepositoryImpl(
    ref.watch(smartLearningRepositoryProvider),
  ),
);

/// Sprint 18 Phase 2 — tái dùng smartLearningSessionProvider (KHÔNG
/// đổi, vẫn gọi thẳng SmartLearningRepository.getSmartLearningSession()
/// — an toàn thay thế bất kỳ SmartLearningRepository nào được override,
/// cùng lý lẽ đã áp dụng cho dailyLearningPlanProvider ở
/// learning_journey_providers.dart) thay vì luôn dựng
/// learningSnapshotRepositoryProvider.getSnapshot() MỚI mỗi khi được
/// watch. Đây là điểm tiết kiệm LỚN NHẤT trong toàn bộ chuỗi: nếu
/// smartLearningSessionProvider ĐÃ được màn hình khác (vd
/// SmartLearningScreen) giữ sống, tránh được TOÀN BỘ chuỗi phía dưới
/// (SmartLearning → LearningJourney → 3x AITutor → tối đa 12x
/// Analytics). computeLearningSnapshot là ĐÚNG hàm thuần mà
/// LearningSnapshotRepositoryImpl.getSnapshot() đã dùng nội bộ — KHÔNG
/// có logic mới. Chưa có UI nào watch/refresh provider này (Read Model
/// chưa có màn hình) nên không có rủi ro "kéo làm mới trả dữ liệu cũ".
final learningSnapshotProvider =
    FutureProvider.autoDispose<LearningSnapshot>((ref) async {
  final session = await ref.watch(smartLearningSessionProvider.future);
  return computeLearningSnapshot(session, DateTime.now());
});
