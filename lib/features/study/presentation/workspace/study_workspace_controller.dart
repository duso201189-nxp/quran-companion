import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../quran/data/quran_providers.dart';
import '../../../quran/domain/entities/ayah_search_result.dart';

/// Ayah đang được nghiên cứu — CHỦ THỂ của workspace, không phải một
/// tính năng học.
///
/// `autoDispose.family` theo `ayahId` (`DR-2026-0007` D4): workspace mở
/// cho đúng một Ayah rồi đóng, nên vòng đời gắn với Ayah đó và tự giải
/// phóng khi rời màn hình. KHÔNG có state Study toàn cục.
///
/// Dùng LẠI `getAyahsByIds` sẵn có — cùng phương thức mà Thư viện và
/// Tìm kiếm dùng để dựng tiêu đề Ayah. Không thêm repository, không
/// thêm truy vấn kiểu mới.
///
/// Trang đọc KHÔNG bao giờ đọc provider này: nó chỉ truyền `ayahId`
/// qua route, và Study tự nạp phần của mình.
final studyAyahProvider =
    FutureProvider.autoDispose.family<AyahSearchResult?, int>(
  (ref, ayahId) async {
    final rows = await ref.watch(quranRepositoryProvider).getAyahsByIds(
      [ayahId],
    );
    return rows.isEmpty ? null : rows.first;
  },
);
