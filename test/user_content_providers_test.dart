import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/library/domain/library_item.dart';
import 'package:quran_companion/features/library/domain/library_kind.dart';
import 'package:quran_companion/features/library/presentation/library_controller.dart';
import 'package:quran_companion/features/quran/data/retention_seeding_store.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_annotation.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/content_fixtures.dart';

/// Sprint 7.3 (Automatic Retention Seeding) — kiểm chứng
/// revisionEligibleAyahsProvider: hợp nhất Ayah gắn cờ THỦ CÔNG
/// (AyahStatus.review) với Ayah được ĐỌC (study_sessions) kể từ mốc
/// kích hoạt, phân giải qua QuranRepository THẬT (không fake) chạy
/// trên fixture nội dung dùng chung (test/fixtures/content_fixtures.dart:
/// Surah 1 = 7 Ayah, id toàn cục 1..7; Surah 114 = 6 Ayah, id toàn
/// cục 6231..6236).
///
/// "Xa quá khứ"/"xa tương lai" dùng làm mốc kích hoạt để kiểm soát
/// pre-cutoff/post-cutoff mà không cần tiêm đồng hồ vào
/// StudySessionRepositoryImpl (được dựng qua provider, dùng
/// DateTime.now() thật cho created_at) — phiên log trong lúc test
/// LUÔN có created_at = "bây giờ" thật, nên đặt cutoff thật xa quá
/// khứ/tương lai là cách kiểm soát trước/sau cutoff đáng tin cậy nhất.
const _farPastMs = 0;
const _farFutureMs = 4102444800000; // 2100-01-01T00:00:00Z

Future<ProviderContainer> _container({required int activationCutoffMs}) async {
  final appDb = AppDatabase(NativeDatabase.memory());
  await seedTestContent(appDb);
  final userDb = UserDatabase(NativeDatabase.memory());

  SharedPreferences.setMockInitialValues({
    RetentionSeedingActivation.key: activationCutoffMs,
  });
  final sp = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(appDb),
      userDatabaseProvider.overrideWithValue(userDb),
      sharedPreferencesProvider.overrideWithValue(sp),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await appDb.close();
    await userDb.close();
  });
  return container;
}

/// Đọc giá trị đã ổn định của [revisionEligibleAyahsProvider], giữ
/// provider autoDispose sống trong lúc chờ — cùng mẫu
/// scheduler_providers_test.dart._waitFor.
Future<List<({int ayahId, int savedAt})>> _eligibleAyahs(
  ProviderContainer c,
) async {
  final sub = c.listen(revisionEligibleAyahsProvider, (_, __) {});
  addTearDown(sub.close);
  for (var i = 0; i < 500; i++) {
    final value = c.read(revisionEligibleAyahsProvider).valueOrNull;
    if (value != null) return value;
    await Future<void>.delayed(Duration.zero);
  }
  throw StateError('revisionEligibleAyahsProvider không phát giá trị nào');
}

void main() {
  group('A/C/F — chỉ có gắn cờ thủ công (không đọc gì)', () {
    test('A: Ayah gắn cờ review thủ công vẫn xuất hiện', () async {
      final c = await _container(activationCutoffMs: _farFutureMs);
      await c
          .read(userContentRepositoryProvider)
          .setStatus(1, AyahStatus.review);

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId), contains(1));
    });

    test(
        'C: phiên đọc TRƯỚC mốc kích hoạt -> KHÔNG tự vào Queue (không '
        'có gắn cờ thủ công nào)', () async {
      final c = await _container(activationCutoffMs: _farFutureMs);
      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-01',
            surahId: 1,
            ayahFrom: 0,
            ayahTo: 6,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result, isEmpty);
    });

    test(
        'F: tính đủ-điều-kiện tự động KHÔNG ghi AyahStatus.review — bảng '
        'ayah_statuses vẫn rỗng sau khi có phiên đọc đủ điều kiện tự '
        'động', () async {
      final c = await _container(activationCutoffMs: _farPastMs);

      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 1,
            ayahFrom: 0,
            ayahTo: 2,
            durationSec: 60,
          );
      await _eligibleAyahs(c); // đợi provider tính xong

      final userDb = c.read(userDatabaseProvider);
      final rows = await userDb.select(userDb.ayahStatuses).get();
      expect(rows, isEmpty);
    });
  });

  group('B/I/J — đọc sau mốc kích hoạt -> tự vào Queue, id phân giải đúng', () {
    test(
        'B: đọc Surah 1, Ayah 1-3 (0-based 0..2) sau cutoff -> 3 Ayah đủ '
        'điều kiện, đúng id toàn cục', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 1,
            ayahFrom: 0,
            ayahTo: 2,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId).toSet(), {1, 2, 3});
    });

    test(
        'I: đọc nhiều Surah khác nhau -> id toàn cục của CẢ hai Surah '
        'đều xuất hiện đúng', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      final repo = c.read(studySessionRepositoryProvider);
      await repo.logSession(
        date: '2026-08-10',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 1,
        durationSec: 60,
      );
      await repo.logSession(
        date: '2026-08-10',
        surahId: 114,
        ayahFrom: 0,
        ayahTo: 1,
        durationSec: 60,
      );

      final result = await _eligibleAyahs(c);
      final ids = result.map((r) => r.ayahId).toSet();
      // Surah 1: Ayah 1,2 -> id 1,2. Surah 114 (id nền 6230): Ayah
      // 1,2 -> id 6231,6232 (khớp fixture: id = 6230 + n).
      expect(ids, {1, 2, 6231, 6232});
    });

    test(
        'J: phạm vi 0-based GIỮA Surah phân giải ra ĐÚNG id toàn cục '
        '(không lệch 1, không dùng công thức tay)', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      // 0-based 2..4 trong Surah 114 = Ayah số 3,4,5 -> id 6233,6234,6235.
      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 114,
            ayahFrom: 2,
            ayahTo: 4,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId).toSet(), {6233, 6234, 6235});
    });
  });

  group('D/E — trạng thái thủ công KHÔNG bị ghi đè bởi seeding tự động', () {
    test(
        'D: Ayah đang "learning" thủ công, sau đó được đọc -> vào Queue '
        'qua HỢP, nhưng AyahStatus vẫn là learning (không đổi)', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      final userRepo = c.read(userContentRepositoryProvider);
      await userRepo.setStatus(1, AyahStatus.learning);

      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 1,
            ayahFrom: 0,
            ayahTo: 0,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId), contains(1));

      final annotations = await userRepo.watchAnnotationsForAyahs([1]).first;
      expect(annotations[1]?.status, AyahStatus.learning);
    });

    test('E: cùng kịch bản với "learned"', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      final userRepo = c.read(userContentRepositoryProvider);
      await userRepo.setStatus(2, AyahStatus.learned);

      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 1,
            ayahFrom: 1,
            ayahTo: 1,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId), contains(2));

      final annotations = await userRepo.watchAnnotationsForAyahs([2]).first;
      expect(annotations[2]?.status, AyahStatus.learned);
    });
  });

  group('G/H — chồng lấn/nhiều phiên khử trùng lặp đúng', () {
    test(
        'G: 2 phiên chồng lấn cùng Surah -> mỗi Ayah chỉ xuất hiện ĐÚNG '
        '1 lần trong kết quả', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      final repo = c.read(studySessionRepositoryProvider);
      await repo.logSession(
        date: '2026-08-10',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 2,
        durationSec: 60,
      );
      await repo.logSession(
        date: '2026-08-10',
        surahId: 1,
        ayahFrom: 2,
        ayahTo: 4,
        durationSec: 60,
      );

      final result = await _eligibleAyahs(c);
      final ids = result.map((r) => r.ayahId).toList();
      expect(ids.toSet(), {1, 2, 3, 4, 5});
      expect(
        ids.length,
        ids.toSet().length,
        reason: 'không có Ayah.id trùng lặp trong kết quả',
      );
    });

    test('H: nhiều phiên KHÔNG chồng lấn cùng Surah -> hợp đủ toàn bộ',
        () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      final repo = c.read(studySessionRepositoryProvider);
      await repo.logSession(
        date: '2026-08-10',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 1,
        durationSec: 60,
      );
      await repo.logSession(
        date: '2026-08-10',
        surahId: 1,
        ayahFrom: 5,
        ayahTo: 6,
        durationSec: 60,
      );

      final result = await _eligibleAyahs(c);
      expect(result.map((r) => r.ayahId).toSet(), {1, 2, 6, 7});
    });

    test(
        'Ayah gắn cờ thủ công VÀ đã đọc -> vẫn chỉ 1 mục (hợp, không '
        'trùng lặp giữa 2 nguồn)', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      await c
          .read(userContentRepositoryProvider)
          .setStatus(1, AyahStatus.review);
      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 1,
            ayahFrom: 0,
            ayahTo: 0,
            durationSec: 60,
          );

      final result = await _eligibleAyahs(c);
      expect(result.where((r) => r.ayahId == 1), hasLength(1));
    });
  });

  group('N — Library Revision view (LibraryKind.review) giải quyết đúng', () {
    test(
        'libraryItemsProvider(LibraryKind.review) hiển thị đúng Ayah đủ '
        'điều kiện (thủ công + tự động), header phân giải đúng qua '
        'QuranRepository thật', () async {
      final c = await _container(activationCutoffMs: _farPastMs);
      await c
          .read(userContentRepositoryProvider)
          .setStatus(1, AyahStatus.review);
      await c.read(studySessionRepositoryProvider).logSession(
            date: '2026-08-10',
            surahId: 114,
            ayahFrom: 0,
            ayahTo: 0,
            durationSec: 60,
          );

      final sub =
          c.listen(libraryItemsProvider(LibraryKind.review), (_, __) {});
      addTearDown(sub.close);

      List<LibraryItem>? items;
      for (var i = 0; i < 500; i++) {
        final v = c.read(libraryItemsProvider(LibraryKind.review)).valueOrNull;
        if (v != null) {
          items = v;
          break;
        }
        await Future<void>.delayed(Duration.zero);
      }
      expect(items, isNotNull);
      final ids = items!.map((item) => item.ayah.ayahId).toSet();
      expect(ids, {1, 6231});
    });
  });
}
