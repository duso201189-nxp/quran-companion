import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'console_logger.dart';
import 'crash_reporter.dart';
import 'logger.dart';
import 'noop_crash_reporter.dart';

/// Provider DI cho hạ tầng reliability (Sprint 19 Phase 1, Task 4) —
/// CÙNG hình dạng với appDatabaseProvider (core/database/database_providers.dart):
/// 1 Provider dựng thẳng implementation cục bộ mặc định, KHÔNG cần
/// override bắt buộc ở main.dart (khác sharedPreferencesProvider —
/// Logger/CrashReporter không cần khởi tạo bất đồng bộ/plugin nền
/// tảng nào). Khi 1 implementation cloud thật được thêm ở sprint sau,
/// CHỈ cần `loggerProvider.overrideWithValue(...)`/
/// `crashReporterProvider.overrideWithValue(...)` ở main.dart — không
/// nơi nào khác cần sửa vì mọi nơi gọi đều phụ thuộc đúng interface
/// Logger/CrashReporter, không phụ thuộc ConsoleLogger/NoopCrashReporter
/// trực tiếp.
///
/// CHƯA có nơi nào trong app watch 2 provider này ("No write path",
/// "No business logic changes" — phase này chỉ dựng hạ tầng, chưa nối
/// dây vào Repository/UI nào).
final loggerProvider = Provider<Logger>((ref) => const ConsoleLogger());

final crashReporterProvider =
    Provider<CrashReporter>((ref) => const NoopCrashReporter());
