import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/learning/data/retention_event_source_repository_impl.dart';
import 'package:quran_companion/features/learning/domain/repositories/retention_event_source_repository.dart';

/// Logger im lặng — cùng mẫu các test repository khác.
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

/// Sprint D7.8 (DR-2026-0027, đã `accepted`) — Nhóm A: cổng đọc Drift.
/// Dùng Drift THẬT trong bộ nhớ, không giả lập database
/// (TESTING_GUIDE §1.2).
void main() {
  late UserDatabase db;
  late RetentionEventSourceRepositoryImpl repo;
  var eventCounter = 0;

  /// Ghi thẳng một dòng `review_events` — test này kiểm ĐƯỜNG ĐỌC, nên
  /// dữ liệu vào được dựng trực tiếp thay vì chạy qua applyReview (đã
  /// có suite riêng cho đường ghi: scheduler_repository_test.dart).
  Future<void> seedEvent({
    required String itemType,
    required int itemId,
    required int reviewedAt,
    String? id,
    String cardId = 'card-1',
    String grade = 'good',
    String algorithmId = 'sm2-v1',
    String beforeState = 'new',
    String afterState = 'review',
    int beforeRepetitions = 0,
    int afterRepetitions = 1,
    int beforeIntervalDays = 0,
    int afterIntervalDays = 1,
    int beforeDueDate = 500,
    int afterDueDate = 900,
    double beforeEaseFactor = 2.5,
    double afterEaseFactor = 2.6,
    int? deletedAt,
  }) async {
    final rowId = id ?? 'evt-${++eventCounter}';
    await db.into(db.reviewEvents).insert(
          ReviewEventsCompanion.insert(
            id: rowId,
            updatedAt: reviewedAt,
            deletedAt: Value(deletedAt),
            cardId: cardId,
            itemType: itemType,
            itemId: itemId,
            reviewedAt: reviewedAt,
            grade: grade,
            algorithmId: algorithmId,
            beforeState: beforeState,
            beforeRepetitions: beforeRepetitions,
            beforeIntervalDays: beforeIntervalDays,
            beforeEaseFactor: beforeEaseFactor,
            beforeDueDate: beforeDueDate,
            afterState: afterState,
            afterRepetitions: afterRepetitions,
            afterIntervalDays: afterIntervalDays,
            afterEaseFactor: afterEaseFactor,
            afterDueDate: afterDueDate,
          ),
        );
  }

  setUp(() {
    eventCounter = 0;
    db = UserDatabase(NativeDatabase.memory());
    repo = RetentionEventSourceRepositoryImpl(db, _SilentLogger());
  });

  tearDown(() => db.close());

  // A1
  test('D7.8 tập item_id RỖNG -> danh sách rỗng, không dựng truy vấn',
      () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);

    expect(
      await repo.eventsForItems(
        itemType: RetentionItemScope.hifz,
        itemIds: const {},
      ),
      isEmpty,
    );
  });

  // A2
  test(
      'D7.8 CHỈ lấy đúng item_type — sự kiện ayah cùng item_id không lọt vào '
      'truy vấn hifz', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'ayah', itemId: 10, reviewedAt: 2000);

    final hifz = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );
    final ayah = await repo.eventsForItems(
      itemType: RetentionItemScope.ayah,
      itemIds: const {10},
    );

    expect([for (final e in hifz) e.reviewedAtMs], [1000]);
    expect([for (final e in ayah) e.reviewedAtMs], [2000]);
    expect(hifz.single.itemType, RetentionItemScope.hifz);
    expect(ayah.single.itemType, RetentionItemScope.ayah);
  });

  // A3
  test('D7.8 CHỈ lấy ordinal thuộc phạm vi — ordinal ngoài phạm vi bị loại',
      () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 2000);
    await seedEvent(itemType: 'hifz', itemId: 99, reviewedAt: 3000);

    final events = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10, 11},
    );

    expect([for (final e in events) e.itemId], [10, 11]);
  });

  // A4
  test('D7.8 nhiều sự kiện của CÙNG một mục đều trả về (không khử trùng)',
      () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 2000);
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 3000);

    final events = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );

    expect([for (final e in events) e.reviewedAtMs], [1000, 2000, 3000]);
  });

  // A5
  test('D7.8 kết quả tăng dần theo reviewed_at bất kể thứ tự ghi', () async {
    await seedEvent(itemType: 'ayah', itemId: 10, reviewedAt: 3000);
    await seedEvent(itemType: 'ayah', itemId: 11, reviewedAt: 1000);
    await seedEvent(itemType: 'ayah', itemId: 12, reviewedAt: 2000);

    final events = await repo.eventsForItems(
      itemType: RetentionItemScope.ayah,
      itemIds: const {10, 11, 12},
    );

    expect([for (final e in events) e.reviewedAtMs], [1000, 2000, 3000]);
  });

  // A6
  test(
      'D7.8 hai dòng TRÙNG reviewed_at ra theo thứ tự ỔN ĐỊNH, lặp lại được '
      'giữa các lần gọi (phá hoà bằng id)', () async {
    // Ba dòng TRÙNG reviewed_at, chèn theo thứ tự (b, a, c) KHÁC HẲN
    // thứ tự id tăng dần, và MỖI id gắn với một card_id riêng.
    //
    // card_id là một trong 14 trường được chiếu, còn `id` thì KHÔNG —
    // nhờ buộc hai thứ tương ứng nhau, thứ tự do
    // `ORDER BY reviewed_at ASC, id ASC` quyết định trở nên QUAN SÁT
    // ĐƯỢC qua cổng đọc mà không phải lộ thêm trường thứ mười lăm.
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 5000,
      id: 'b',
      cardId: 'card-b',
    );
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 5000,
      id: 'a',
      cardId: 'card-a',
    );
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 5000,
      id: 'c',
      cardId: 'card-c',
    );

    final first = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );
    final second = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );

    // Thứ tự CHÍNH XÁC theo id tăng dần — KHÔNG phải thứ tự chèn
    // (b, a, c). Bỏ `OrderingTerm.asc(t.id)` khỏi truy vấn là khẳng
    // định này đỏ ngay.
    expect(
      [for (final e in first) e.cardId],
      ['card-a', 'card-b', 'card-c'],
    );
    // Và LẶP LẠI y hệt ở lần gọi thứ hai — thứ tự ổn định, không phụ
    // thuộc lần chạy.
    expect(
      [for (final e in second) e.cardId],
      ['card-a', 'card-b', 'card-c'],
    );
    // Mọi dòng vẫn cùng một mốc thời gian: thứ tự trên KHÔNG thể do
    // reviewed_at quyết định.
    expect(
      [for (final e in first) e.reviewedAtMs],
      [5000, 5000, 5000],
    );
  });

  // A7
  test('D7.8 chiếu ĐÚNG 14 trường với đúng giá trị đã lưu', () async {
    await seedEvent(
      itemType: 'hifz',
      itemId: 42,
      reviewedAt: 1234,
      cardId: 'card-xyz',
      grade: 'hard',
      algorithmId: 'hifz-sm2-capped-v1',
      beforeState: 'review',
      afterState: 'lapsed',
      beforeRepetitions: 3,
      afterRepetitions: 0,
      beforeIntervalDays: 10,
      afterIntervalDays: 1,
      beforeDueDate: 1000,
      afterDueDate: 9999,
    );

    final e = (await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {42},
    ))
        .single;

    expect(e.itemType, RetentionItemScope.hifz);
    expect(e.itemId, 42);
    expect(e.cardId, 'card-xyz');
    expect(e.reviewedAtMs, 1234);
    expect(e.gradeRaw, 'hard');
    expect(e.algorithmId, 'hifz-sm2-capped-v1');
    expect(e.beforeStateRaw, 'review');
    expect(e.afterStateRaw, 'lapsed');
    expect(e.beforeRepetitions, 3);
    expect(e.afterRepetitions, 0);
    expect(e.beforeIntervalDays, 10);
    expect(e.afterIntervalDays, 1);
    expect(e.beforeDueDateMs, 1000);
    expect(e.afterDueDateMs, 9999);
  });

  // A8
  test(
      'D7.8 kiểu chiếu KHÔNG lộ ease factor, id, user_id, updated_at, '
      'deleted_at, is_dirty — đúng 14 trường công khai', () async {
    // Khẳng định ở mức NGUỒN: danh sách trường của kiểu chiếu là hợp
    // đồng của cổng đọc, và một trường thứ mười lăm thêm vào lặng lẽ
    // phải làm đỏ test này (DR-2026-0027 §Risks — phình danh sách
    // trường là rủi ro trôi dạt hàng đầu).
    final source = _readSource(
      'lib/features/learning/domain/repositories/'
      'retention_event_source_repository.dart',
    );
    final fields = RegExp(r'^\s{2}final\s+[\w<>, ?]+\s+(\w+);', multiLine: true)
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    expect(fields, hasLength(14));
    expect(
      fields.toSet(),
      {
        'itemType',
        'itemId',
        'cardId',
        'reviewedAtMs',
        'gradeRaw',
        'algorithmId',
        'beforeStateRaw',
        'afterStateRaw',
        'beforeRepetitions',
        'afterRepetitions',
        'beforeIntervalDays',
        'afterIntervalDays',
        'beforeDueDateMs',
        'afterDueDateMs',
      },
    );
    for (final forbidden in [
      'beforeEaseFactor',
      'afterEaseFactor',
      'userId',
      'updatedAt',
      'deletedAt',
      'isDirty',
    ]) {
      expect(
        fields,
        isNot(contains(forbidden)),
        reason: '$forbidden không được vượt qua cổng đọc',
      );
    }
    // `id` bị loại hoàn toàn khỏi kiểu chiếu (chỉ dùng làm khoá phá
    // hoà trong SQL).
    expect(fields, isNot(contains('id')));
  });

  // A9
  test(
      'D7.8 gradeRaw và algorithmId trả về NGUYÊN VẸN, kể cả giá trị grade '
      'lạ — repository KHÔNG lọc, KHÔNG phân giải', () async {
    await seedEvent(
      itemType: 'ayah',
      itemId: 7,
      reviewedAt: 1000,
      grade: 'again',
      algorithmId: 'sm2-v1',
    );
    await seedEvent(
      itemType: 'ayah',
      itemId: 7,
      reviewedAt: 2000,
      grade: 'khong-ton-tai',
      algorithmId: 'thuat-toan-tuong-lai-v9',
    );

    final events = await repo.eventsForItems(
      itemType: RetentionItemScope.ayah,
      itemIds: const {7},
    );

    expect([for (final e in events) e.gradeRaw], ['again', 'khong-ton-tai']);
    expect(
      [for (final e in events) e.algorithmId],
      ['sm2-v1', 'thuat-toan-tuong-lai-v9'],
    );
  });

  // A10
  test(
      'D7.8 beforeStateRaw/afterStateRaw trả về THÔ — srsCardStateFromDbValue '
      'KHÔNG được áp ở tầng này (trạng thái lạ không bị ép thành new)',
      () async {
    await seedEvent(
      itemType: 'hifz',
      itemId: 8,
      reviewedAt: 1000,
      beforeState: 'trang-thai-la',
      afterState: 'lapsed',
    );

    final e = (await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {8},
    ))
        .single;

    expect(e.beforeStateRaw, 'trang-thai-la');
    expect(e.afterStateRaw, 'lapsed');

    // Cổng đọc cũng không được import bộ giải mã có fallback im lặng.
    final source = _readSource(
      'lib/features/learning/data/retention_event_source_repository_impl.dart',
    );
    expect(source, isNot(contains('srsCardStateFromDbValue')));
  });

  // A11
  test(
      'D7.8 BẤT BIẾN: đọc KHÔNG làm đổi review_events — cùng số dòng, cùng '
      'id, cùng reviewed_at trước và sau hai lần đọc', () async {
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 11, reviewedAt: 2000);
    await seedEvent(itemType: 'ayah', itemId: 10, reviewedAt: 3000);

    Future<List<(String, int)>> snapshot() async {
      final rows = await db.select(db.reviewEvents).get();
      return [for (final r in rows) (r.id, r.reviewedAt)]
        ..sort((a, b) => a.$1.compareTo(b.$1));
    }

    final before = await snapshot();
    await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10, 11},
    );
    await repo.eventsForItems(
      itemType: RetentionItemScope.ayah,
      itemIds: const {10},
    );
    final after = await snapshot();

    expect(after, before);

    // Tệp triển khai KHÔNG được chứa lệnh ghi nào, bây giờ hay về sau.
    final source = _readSource(
      'lib/features/learning/data/retention_event_source_repository_impl.dart',
    );
    for (final forbidden in [
      '.insert(',
      '.update(',
      '.delete(',
      'insertOnConflictUpdate',
      'customStatement',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason: 'đường đọc không được chứa $forbidden',
      );
    }
  });

  // A12
  test(
      'D7.8 KHÔNG backfill: mục có srs_cards nhưng chưa sự kiện nào -> rỗng — '
      'trạng thái hiện tại không bao giờ bị quy đổi thành lịch sử', () async {
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

    expect(
      await repo.eventsForItems(
        itemType: RetentionItemScope.hifz,
        itemIds: const {10},
      ),
      isEmpty,
    );
  });

  // A13
  test(
      'D7.8 KHÔNG lọc deleted_at: dòng có deleted_at khác NULL vẫn trả về — '
      'khoá lại hành vi đã ghi trong tài liệu', () async {
    await seedEvent(
      itemType: 'hifz',
      itemId: 10,
      reviewedAt: 1000,
      deletedAt: 4242,
    );

    expect(
      await repo.eventsForItems(
        itemType: RetentionItemScope.hifz,
        itemIds: const {10},
      ),
      hasLength(1),
    );
  });
}

/// Đọc mã nguồn một tệp trong kho mã — cùng kỹ thuật fitness function
/// mà `test/repository_boundary_test.dart` đã dùng.
String _readSource(String relativePath) {
  final file = File(relativePath);
  if (!file.existsSync()) {
    fail('không tìm thấy $relativePath — test chạy sai thư mục gốc?');
  }
  return file.readAsStringSync();
}
