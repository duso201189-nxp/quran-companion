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
  return (surah: surah, ayahs: ayahs);
});
