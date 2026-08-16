import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';

/// Sprint D6.6 (DR-2026-0024, đã `accepted`) — HÌNH DẠNG bảng
/// `review_events`.
///
/// Phép kiểm nâng cấp 7 -> 8 THẬT (dựng database v7 đầy đủ + dữ liệu
/// mẫu, mở qua UserDatabase để Drift chạy onUpgrade thật, xác nhận
/// KHÔNG backfill) nằm ở `user_content_repository_test.dart`, nhóm
/// 'schema & migration', cùng chỗ với v1->v2 … v6->v7 — đó là nơi quy
/// ước của dự án cho migration (xem `hifz_migration_test.dart` cho
/// tiền lệ cùng khuôn). Tệp này CHỈ giữ những khẳng định RIÊNG của
/// `review_events` mà bài kiểm migration không nói: bộ cột đầy đủ và
/// hai chỉ mục đã duyệt (DR-2026-0024 Quyết định 4/12).
void main() {
  test('review_events có đúng bộ cột đã thiết kế', () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final columns = await db
        .customSelect('PRAGMA table_info(review_events)')
        .map((r) => r.read<String>('name'))
        .get();

    expect(columns.toSet(), {
      // SyncColumns — cùng khuôn mọi bảng nhóm B. deleted_at tồn tại vì
      // mixin là TRỌN VẸN hoặc KHÔNG DÙNG, nhưng KHÔNG có mã nào được
      // uỷ quyền ghi vào cột đó (xem doc comment lớp ReviewEvents).
      'id',
      'user_id',
      'updated_at',
      'deleted_at',
      'is_dirty',
      // Định danh.
      'card_id',
      'item_type',
      'item_id',
      // Thời điểm.
      'reviewed_at',
      // Đầu vào.
      'grade',
      // Nguồn gốc thuật toán.
      'algorithm_id',
      // Trạng thái TRƯỚC lần ôn.
      'before_state',
      'before_repetitions',
      'before_interval_days',
      'before_ease_factor',
      'before_due_date',
      // Trạng thái SAU lần ôn.
      'after_state',
      'after_repetitions',
      'after_interval_days',
      'after_ease_factor',
      'after_due_date',
    });
  });

  test(
      'CÓ đúng hai chỉ mục đã duyệt (item_type,item_id,reviewed_at) và '
      '(reviewed_at) — DR-2026-0024 Quyết định 12', () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // index_list liệt kê cả chỉ mục ngầm của PRIMARY KEY(id) — cái đó
    // ĐÚNG và phải còn, không nằm trong tập cần kiểm ở đây.
    final indexNames = (await db
            .customSelect('PRAGMA index_list(review_events)')
            .map((r) => r.read<String>('name'))
            .get())
        .toSet();

    expect(indexNames, contains('idx_review_events_item'));
    expect(indexNames, contains('idx_review_events_reviewed_at'));

    final itemIndexColumns = await db
        .customSelect("PRAGMA index_info('idx_review_events_item')")
        .map((r) => r.read<String?>('name'))
        .get();
    expect(itemIndexColumns, ['item_type', 'item_id', 'reviewed_at']);

    final reviewedAtIndexColumns = await db
        .customSelect("PRAGMA index_info('idx_review_events_reviewed_at')")
        .map((r) => r.read<String?>('name'))
        .get();
    expect(reviewedAtIndexColumns, ['reviewed_at']);
  });

  test(
      'review_events KHÔNG có ràng buộc duy nhất nào — nhiều dòng cho '
      'cùng (item_type, item_id) là ĐÚNG mục đích (một dòng/một lần ôn)',
      () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final indexes = await db
        .customSelect('PRAGMA index_list(review_events)')
        .map((r) => r.read<int>('unique'))
        .get();

    // Chỉ mục PRIMARY KEY(id) tự nó là unique — đó là bình thường.
    // Không có chỉ mục unique NÀO KHÁC phủ lên (item_type, item_id).
    final itemIndexInfo = await db
        .customSelect('PRAGMA index_list(review_events)')
        .map(
          (r) => (
            name: r.read<String>('name'),
            unique: r.read<int>('unique'),
          ),
        )
        .get();
    final itemIndex =
        itemIndexInfo.where((i) => i.name == 'idx_review_events_item').single;
    expect(itemIndex.unique, 0, reason: 'idx_review_events_item KHÔNG unique');
    expect(indexes, isNotEmpty);
  });
}
