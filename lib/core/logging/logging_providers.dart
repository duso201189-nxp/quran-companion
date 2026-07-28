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
/// Sprint S2, D2: [loggerProvider] giờ tiêm [crashReporterProvider]
/// vào ConsoleLogger — mọi lỗi log qua Logger.error() (tức mọi lỗi đi
/// qua withFailureLogging/withFailureLoggingStream, "DUY NHẤT chỗ áp
/// dụng... cho mọi Repository") giờ cũng tới CrashReporter, xem
/// console_logger.dart. Không có gì khác đổi — vẫn KHÔNG business
/// logic nào phụ thuộc trực tiếp vào 2 provider này.
final loggerProvider = Provider<Logger>(
  (ref) => ConsoleLogger(crashReporter: ref.watch(crashReporterProvider)),
);

final crashReporterProvider =
    Provider<CrashReporter>((ref) => const NoopCrashReporter());
