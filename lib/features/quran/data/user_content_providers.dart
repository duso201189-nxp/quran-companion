import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../../stats/data/study_session_providers.dart';
import '../domain/entities/ayah_annotation.dart';
import '../domain/entities/ayah_content.dart';
import '../domain/repositories/user_content_repository.dart';
import '../presentation/reading/reading_controller.dart';
import 'quran_providers.dart';
import 'retention_seeding_store.dart';
import 'user_content_repository_impl.dart';

final userContentRepositoryProvider = Provider<UserContentRepository>(
  (ref) => UserContentRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Chú thích của mọi Ayah trong một Surah — cập nhật realtime.
final ayahAnnotationsProvider = StreamProvider.autoDispose
    .family<Map<int, AyahAnnotation>, int>((ref, surahId) async* {
  final reading = await ref.watch(surahReadingProvider(surahId).future);
  yield* ref.watch(userContentRepositoryProvider).watchAnnotationsForAyahs(
    [for (final a in reading.ayahs) a.ayah.id],
  );
});

/// Ayah đủ điều kiện Revision Queue sau Sprint 7.3 (Automatic
/// Retention Seeding — DR-2026-0021, amends DR-2026-0004 mục 3):
///
///     Ayah gắn cờ THỦ CÔNG (watchAllReviewAyahs(), KHÔNG đổi)
///     HỢP (union)
///     Ayah được ĐỌC (study_sessions) từ mốc kích hoạt trở đi
///     (retentionSeedingActivationProvider — prospective-only,
///     không backfill hồi tố).
///
/// Đây LÀ nơi hợp lệ để nối UserContentRepository (nhóm B) với
/// QuranRepository (nhóm A) — phân giải (surahId, ayahFrom/To 0-based
/// từ study_sessions) sang Ayah.id toàn cục CẦN dữ liệu nhóm A, mà
/// UserContentRepositoryImpl/StudySessionRepositoryImpl chỉ biết
/// UserDatabase (nhóm B). Không repository nào được phép biết cả hai
/// database (PROJ-P-002) — việc ghép diễn ra ở TẦNG PROVIDER, đúng
/// mẫu schedulerSyncProvider đã dùng để nối Scheduler với
/// UserContentRepository (hai repository độc lập, không cái nào phụ
/// thuộc trực tiếp cái kia).
final revisionEligibleAyahsProvider =
    StreamProvider.autoDispose<List<({int ayahId, int savedAt})>>((ref) async* {
  final userRepo = ref.watch(userContentRepositoryProvider);
  final studySessionRepo = ref.watch(studySessionRepositoryProvider);
  final quranRepo = ref.watch(quranRepositoryProvider);
  final activatedAtMs = ref.watch(retentionSeedingActivationProvider);

  final manual = userRepo.watchAllReviewAyahs();
  final ranges = studySessionRepo.watchAyahRangesCoveredSince(activatedAtMs);

  // Cache Ayah của từng Surah đã tra trong vòng đời provider này —
  // nhiều phạm vi cùng Surah (nhiều phiên đọc) không tra lại nhóm A
  // nhiều lần, cùng ý tưởng headerCache của library_controller.dart.
  final surahAyahsCache = <int, List<AyahContent>>{};

  await for (final combined in _combineLatest2(manual, ranges)) {
    final (manualRows, rangeRows) = combined;

    // Map khử trùng lặp theo Ayah.id — hợp cả hai nguồn, giữ savedAt
    // của lần xuất hiện đầu (thông tin hiển thị, không ảnh hưởng
    // logic đủ-điều-kiện hay-không).
    final byAyahId = <int, int>{
      for (final r in manualRows) r.ayahId: r.savedAt,
    };

    for (final range in rangeRows) {
      final ayahs = surahAyahsCache[range.surahId] ??=
          await quranRepo.getAyahsOfSurah(range.surahId);
      for (final content in ayahs) {
        final zeroBasedIndex = content.ayah.ayahNumber - 1;
        if (zeroBasedIndex < range.ayahFrom || zeroBasedIndex > range.ayahTo) {
          continue;
        }
        byAyahId.putIfAbsent(content.ayah.id, () => activatedAtMs);
      }
    }

    yield [
      for (final entry in byAyahId.entries)
        (ayahId: entry.key, savedAt: entry.value),
    ];
  }
});

/// Ghép 2 stream — phát khi cả 2 đã có giá trị đầu, sau đó phát lại
/// mỗi khi MỘT trong hai đổi (giữ giá trị mới nhất bên còn lại) —
/// cùng mẫu `_combineLatest5` trong user_content_repository_impl.dart,
/// thu gọn còn 2 tham số cho provider này (không thêm dependency
/// rxdart chỉ vì một hàm, cùng lý do đã nêu ở đó).
Stream<(A, B)> _combineLatest2<A, B>(Stream<A> a, Stream<B> b) {
  late StreamController<(A, B)> controller;
  A? va;
  B? vb;
  var ha = false, hb = false;
  final subs = <StreamSubscription<void>>[];

  void emit() {
    if (ha && hb) controller.add((va as A, vb as B));
  }

  controller = StreamController<(A, B)>(
    onListen: () {
      subs.addAll([
        a.listen(
          (v) {
            va = v;
            ha = true;
            emit();
          },
          onError: controller.addError,
        ),
        b.listen(
          (v) {
            vb = v;
            hb = true;
            emit();
          },
          onError: controller.addError,
        ),
      ]);
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
      await controller.close();
    },
  );
  return controller.stream;
}
