import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/quran_providers.dart';
import '../../domain/entities/ayah_content.dart';
import '../../domain/entities/surah.dart';

/// Ném ra khi surahId không tồn tại (deep link sai, dữ liệu hỏng).
class SurahNotFoundException implements Exception {
  const SurahNotFoundException(this.surahId);

  final int surahId;

  @override
  String toString() => 'SurahNotFoundException($surahId)';
}

typedef SurahReading = ({Surah surah, List<AyahContent> ayahs});

/// Nạp Surah + toàn bộ Ayah kèm các lớp văn bản.
///
/// autoDispose: rời màn hình là giải phóng bộ nhớ — đọc Surah 2
/// (286 ayah × 4 lớp văn bản) không được tích lũy RAM khi
/// người dùng duyệt nhiều Surah liên tiếp.
final surahReadingProvider =
    FutureProvider.autoDispose.family<SurahReading, int>((ref, surahId) async {
  final repo = ref.watch(quranRepositoryProvider);
  final surah = await repo.getSurahById(surahId);
  if (surah == null) {
    throw SurahNotFoundException(surahId);
  }
  final ayahs = await repo.getAyahsOfSurah(surahId);

  // Sprint 30.1 — CỬA CHẶN, không phải truy vấn thêm.
  //
  // `AyahCard` dựng các lớp văn bản từ danh mục nguồn. Nếu danh mục
  // còn đang tải ở khung hình đầu, mọi thẻ Ayah sẽ dựng THIẾU lớp
  // (thấp hơn thật) rồi mới giãn ra một khung hình sau —
  // `ScrollablePositionedList` neo vị trí theo kích thước sai đó, và
  // một phép "chuyển tới Ayah" ngay sau đó dừng lệch chỗ (tái hiện
  // được ở `reading_screen_test`).
  //
  // Chờ ở đây khiến màn hình đọc chỉ hiện SAU khi đã có đủ dữ liệu
  // dựng. KHÔNG tốn thêm truy vấn: `translationSourcesProvider` không
  // autoDispose nên chỉ chạy MỘT lần cho cả phiên; các Surah sau chỉ
  // `await` một Future đã hoàn tất.
  await ref.watch(readingSourcesProvider.future);

  return (surah: surah, ayahs: ayahs);
});
