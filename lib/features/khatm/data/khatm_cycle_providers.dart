import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/entities/khatm_cycle.dart';
import '../domain/repositories/khatm_cycle_repository.dart';
import 'khatm_cycle_repository_impl.dart';

final khatmCycleRepositoryProvider = Provider<KhatmCycleRepository>(
  (ref) => KhatmCycleRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Chu kỳ Khatm đang đọc dở (completedAt == null) mới nhất; null nếu
/// không có chu kỳ nào đang mở.
final activeKhatmCycleProvider = StreamProvider.autoDispose<KhatmCycle?>(
  (ref) => ref.watch(khatmCycleRepositoryProvider).watchActiveCycle(),
);

/// Phần trăm hoàn thành của chu kỳ đang đọc dở — đọc thẳng
/// KhatmCycle.progressPercent (công thức đã ở domain model, không
/// tính lại ở đây) để tránh trùng lặp logic.
final khatmProgressProvider = Provider.autoDispose<double?>(
  (ref) => ref.watch(activeKhatmCycleProvider).valueOrNull?.progressPercent,
);
