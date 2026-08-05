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
///
/// CHỈ dùng cho việc GHI tiến độ (`ReadingScreen` — quyết định có gọi
/// `updateProgress` hay không). Một chu kỳ đã hoàn thành KHÔNG BAO GIỜ
/// xuất hiện ở đây — đó là đúng ý: `ReadingScreen` không được viết
/// tiếp vào một chu kỳ đã đóng. Cần biết chu kỳ GẦN ĐÂY NHẤT bất kể
/// trạng thái (vd để hiển thị) thì dùng [latestKhatmCycleProvider],
/// KHÔNG mở rộng provider này — xem doc comment ở đó.
final activeKhatmCycleProvider = StreamProvider.autoDispose<KhatmCycle?>(
  (ref) => ref.watch(khatmCycleRepositoryProvider).watchActiveCycle(),
);

/// Chu kỳ Khatm mới BẮT ĐẦU gần đây nhất — bất kể còn dở hay đã hoàn
/// thành — Sprint 5.1 (Finding 3).
///
/// Vì sao cần một provider riêng thay vì mở rộng
/// [activeKhatmCycleProvider]: hai nơi cần hai câu hỏi khác nhau.
/// `ReadingScreen` cần "chu kỳ nào đang được phép ghi tiến độ" — một
/// chu kỳ đã xong phải biến mất khỏi câu trả lời đó. `ActiveKhatmCard`
/// cần "chu kỳ nào để HIỂN THỊ" — một chu kỳ vừa xong phải XUẤT HIỆN
/// (ở trạng thái đã hoàn thành), không biến mất. `watchActiveCycle()`
/// lọc bỏ chu kỳ hoàn thành ngay trong câu SQL, nên không có cách nào
/// suy ra "vừa hoàn thành" từ dữ liệu nó trả về — thông tin đó đã bị
/// loại trước khi tới tầng UI. Dùng lại [watchAllCycles] (đã có sẵn,
/// đã có test, trước sprint này chưa nơi nào gọi) thay vì tạo repository
/// hay câu truy vấn mới.
final latestKhatmCycleProvider = StreamProvider.autoDispose<KhatmCycle?>(
  (ref) => ref
      .watch(khatmCycleRepositoryProvider)
      .watchAllCycles()
      .map((cycles) => cycles.isEmpty ? null : cycles.first),
);
