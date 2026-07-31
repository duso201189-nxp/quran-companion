import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/learning_planner.dart';
import '../domain/sequential_learning_planner.dart';

/// Cài đặt LearningPlanner — mặc định tất định
/// (SequentialLearningPlanner, Sprint 11 Phase 1). Đổi sang AI Tutor
/// sau này chỉ cần override provider này ở nơi khởi tạo app;
/// LearningSessionController (Phase 2) và mọi module Review/Quiz/
/// Flashcard không đổi — cùng mẫu schedulingAlgorithmProvider
/// (DR-2026-0005 mục 3).
final learningPlannerProvider = Provider<LearningPlanner>(
  (ref) => const SequentialLearningPlanner(),
);
