import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_review_history_repository_impl.dart';

/// Logger im lặng — cùng mẫu các test Hifz khác.
class _SilentLogger implements Logger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// Sprint D6.11 (DR-2026-0026, đã `accepted`) — đọc `review_events`
/// bằng Drift THẬT trong bộ nhớ, không giả lập database.
void main() {
  late UserDatabase db;
  late HifzReviewHistoryRepositoryImpl repo;
  var eventCounter = 0;

  /// Ghi thẳng một dòng `review_events` — test này kiểm ĐƯỜNG ĐỌC, nên
  /// dữ liệu vào được dựng trực tiếp thay vì chạy qua applyReview (đã
  /// có suite riêng cho đường ghi: scheduler_repository_test.dart).
  Future<void> seedEvent({
    required String itemType,
    required int itemId,
    required int reviewedAt,
    String grade = 'good',
  }) async {
    final id = 'evt-${++eventCounter}';
    await db.into(db.reviewEvents).insert(
          ReviewEventsCompanion.insert(
            id: id,
            updatedAt: reviewedAt,
            cardId: 'card-$itemType-$itemId',
            itemType: itemType,
            itemId: itemId,
            reviewedAt: reviewedAt,
            grade: grade,
            algorithmId: 'hifz-sm2-capped-v1',
            beforeState: 'new',
            beforeRepetitions: 0,
            beforeIntervalDays: 0,
            beforeEaseFactor: 2.5,
            beforeDueDate: reviewedAt,
            afterState: 'review',
            afterRepetitions: 1,
            afterIntervalDays: 1,
            afterEaseFactor: 2.5,
            afterDueDate: reviewedAt,
          ),
        );
  }

  setUp(() {
    eventCounter = 0;
    db = UserDatabase(NativeDatabase.memory());
    repo = HifzReviewHistoryRepositoryImpl(db, _SilentLogger());
  });

  tearDown(() => db.close());

  test('tập ordinal RỖNG -> danh sách rỗng, không lỗi truy vấn', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);

    expect(await repo.reviewedAtMsForAyahs(const {}), isEmpty);
  });

  test('CHỈ lấy item_type = hifz — sự kiện ayah cùng item_id không lọt vào',
      () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'ayah', itemId: 10, reviewedAt: 2000);

    expect(await repo.reviewedAtMsForAyahs({10}), [1000]);
  });

  test('CHỈ lấy ordinal thuộc phạm vi', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 2000);
    await seedEvent(itemType: 'hifz', itemId: 99, reviewedAt: 3000);

    expect(await repo.reviewedAtMsForAyahs({10, 11}), [1000, 2000]);
  });

  test('nhiều lượt ôn cho CÙNG một Ayah đều được trả về (không khử trùng)',
      () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 2000);
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 3000);

    expect(await repo.reviewedAtMsForAyahs({10}), [1000, 2000, 3000]);
  });

  test('kết quả tăng dần theo reviewed_at bất kể thứ tự ghi', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 3000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 12, reviewedAt: 2000);

    expect(await repo.reviewedAtMsForAyahs({10, 11, 12}), [1000, 2000, 3000]);
  });

  test('KHÔNG lọc theo grade — lượt again được tính hệt lượt easy', () async {
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 1000,
      grade: 'again',
    );
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 2000,
      grade: 'easy',
    );

    expect(await repo.reviewedAtMsForAyahs({10}), hasLength(2));
  });

  test(
      'BẤT BIẾN: đọc không làm đổi review_events — cùng số dòng, cùng id, '
      'cùng reviewed_at trước và sau', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 2000);

    Future<List<(String, int)>> snapshot() async {
      final rows = await db.select(db.reviewEvents).get();
      return [for (final r in rows) (r.id, r.reviewedAt)]..sort(
          (a, b) => a.$1.compareTo(b.$1),
        );
    }

    final before = await snapshot();
    await repo.reviewedAtMsForAyahs({10, 11});
    await repo.reviewedAtMsForAyahs({10});
    final after = await snapshot();

    expect(after, before);
  });

  test(
      'KHÔNG backfill: database v8 mới, có srs_cards nhưng chưa sự kiện nào '
      '-> 0 — trạng thái không bao giờ bị quy đổi thành lịch sử', () async {
    await db.into(db.srsCards).insert(
          SrsCardsCompanion.insert(
            id: 'card-1',
            itemType: 'hifz',
            itemId: 10,
            repetitions: const Value(7),
            dueDate: 5000,
            state: 'review',
            updatedAt: 5000,
          ),
        );

    expect(await repo.reviewedAtMsForAyahs({10}), isEmpty);
  });

  test(
      'phạm vi CHỒNG LẤN: một Ayah dùng chung giữa hai đoạn xuất hiện trong '
      'kết quả của CẢ HAI — đây là PHẠM VI, không phải quy gán', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 2000);
    await seedEvent(itemType: 'hifz', itemId: 12, reviewedAt: 3000);

    // Đoạn A = 10..11, đoạn B = 11..12; Ayah 11 thuộc cả hai.
    final scopeA = await repo.reviewedAtMsForAyahs({10, 11});
    final scopeB = await repo.reviewedAtMsForAyahs({11, 12});

    expect(scopeA, [1000, 2000]);
    expect(scopeB, [2000, 3000]);
    // Tổng hai phạm vi (4) LỚN HƠN số sự kiện thật (3): tổng của các
    // đoạn chồng lấn KHÔNG cộng dồn được.
    expect(scopeA.length + scopeB.length, greaterThan(3));
  });
}
