import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/quran/ayah_ordinal.dart';
import '../../quran/data/quran_providers.dart';
import '../../quran/data/user_content_providers.dart';
import 'boundary_completion_store.dart';

/// Ayah của MỘT Surah đang đủ điều kiện ôn tập — Sprint 7.4
/// (DR-2026-0023 mục 8).
///
/// Thu hẹp, KHÔNG định nghĩa lại: nguồn duy nhất quyết định "đủ điều
/// kiện hay chưa" vẫn là `revisionEligibleAyahsProvider` (Sprint 7.3 —
/// DR-2026-0021), sprint này chỉ lọc lấy phần thuộc [surahId]. Nhờ vậy
/// luật đủ-điều-kiện chỉ nằm một chỗ, và Scheduler vẫn hoàn toàn không
/// biết một Ayah lọt vào danh sách vì ranh giới hay vì lý do khác
/// (provenance-blind, DR-2026-0005 mục 1).
///
/// Phép lọc là số học thuần trên ordinal ([AyahOrdinal.ayahCounts]) —
/// không truy vấn database nội dung (nhóm A), nên `PROJ-P-002` không
/// bị đụng tới ở đây theo nghĩa mạnh nhất: không có database nào tham
/// gia cả.
final surahRevisionTargetProvider =
    FutureProvider.autoDispose.family<List<int>, int>((ref, surahId) async {
  if (surahId < 1 || surahId > AyahOrdinal.ayahCounts.length) {
    return const [];
  }

  final eligible = await ref.watch(revisionEligibleAyahsProvider.future);

  // Ayah của Surah n chiếm đúng một đoạn ordinal liền nhau — cộng dồn
  // ayahCounts của các Surah trước nó là ra cận dưới.
  var firstOrdinal = 1;
  for (var s = 1; s < surahId; s++) {
    firstOrdinal += AyahOrdinal.ayahCounts[s - 1];
  }
  final lastOrdinal = firstOrdinal + AyahOrdinal.ayahCounts[surahId - 1] - 1;

  return [
    for (final item in eligible)
      if (item.ayahId >= firstOrdinal && item.ayahId <= lastOrdinal)
        item.ayahId,
  ]..sort();
});

/// Tên Latin của một Surah — chỉ để đặt tiêu đề màn hình ôn tập giới
/// hạn theo Surah (Sprint 7.4). `null` khi không tra được; nơi gọi rơi
/// về tiêu đề chung thay vì để trống.
final surahLatinNameProvider =
    FutureProvider.autoDispose.family<String?, int>((ref, surahId) async {
  final surah = await ref.watch(quranRepositoryProvider).getSurahById(surahId);
  return surah?.nameLatin;
});

/// Lời mời ôn tập đang treo, kèm đủ thứ để hiển thị — Sprint 7.4.
///
/// `null` khi không có lời mời nào, hoặc khi Surah vừa xong KHÔNG còn
/// Ayah nào đủ điều kiện ôn (vd. người dùng đã ôn hết): mời ôn một
/// danh sách rỗng là mời vào một màn hình trống.
typedef SurahRevisionInvitation = ({
  int surahId,
  String surahName,
  int ayahCount,
});

final surahRevisionInvitationProvider =
    FutureProvider.autoDispose<SurahRevisionInvitation?>((ref) async {
  final surahId = ref.watch(boundaryCompletionProvider);
  if (surahId == null) return null;

  final target = await ref.watch(surahRevisionTargetProvider(surahId).future);
  if (target.isEmpty) return null;

  final surah = await ref.watch(quranRepositoryProvider).getSurahById(surahId);
  if (surah == null) return null;

  return (
    surahId: surahId,
    surahName: surah.nameLatin,
    ayahCount: target.length,
  );
});
