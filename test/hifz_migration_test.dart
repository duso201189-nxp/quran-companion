import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';

/// Sprint 7.7a — HÌNH DẠNG bảng `hifz_plans`.
///
/// Phép kiểm nâng cấp 6 -> 7 thật (dựng database v6 đầy đủ + dữ liệu
/// mẫu, mở qua UserDatabase để Drift chạy onUpgrade thật) nằm ở
/// `user_content_repository_test.dart`, nhóm 'schema & migration',
/// cùng chỗ với v1->v2 … v5->v6 — đó là nơi quy ước của dự án cho
/// migration. Tệp này chỉ giữ những khẳng định RIÊNG của Hifz mà bài
/// kiểm migration không nói: bộ cột, và việc CỐ Ý không có ràng buộc
/// duy nhất trên đoạn.
void main() {
  test('hifz_plans có đúng bộ cột đã thiết kế', () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final columns = await db
        .customSelect('PRAGMA table_info(hifz_plans)')
        .map((r) => r.read<String>('name'))
        .get();

    expect(columns.toSet(), {
      // SyncColumns — cùng khuôn mọi bảng nhóm B, sẵn sàng cho đồng bộ
      // tài khoản sau này (PROJ-P-004 khi có Supabase).
      'id',
      'user_id',
      'updated_at',
      'deleted_at',
      'is_dirty',
      // Đoạn: ordinal Ayah TOÀN CỤC 1..6236.
      'ayah_from',
      'ayah_to',
      // Vòng đời.
      'status',
      'started_at',
      'completed_at',
    });
  });

  test(
      'KHÔNG có ràng buộc duy nhất trên đoạn — kế hoạch chồng lấn và '
      'trùng khít đều hợp lệ ở tầng lưu trữ', () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // index_list liệt kê cả chỉ mục ngầm của PRIMARY KEY(id) — cái đó
    // ĐÚNG và phải còn. Điều cần chứng minh là không có ràng buộc duy
    // nhất nào phủ lên CẶP ĐOẠN (ayah_from, ayah_to).
    final indexes = await db
        .customSelect('PRAGMA index_list(hifz_plans)')
        .map(
          (r) => (
            name: r.read<String>('name'),
            unique: r.read<int>('unique'),
          ),
        )
        .get();

    for (final index in indexes.where((i) => i.unique == 1)) {
      final columns = await db
          .customSelect("PRAGMA index_info('${index.name}')")
          .map((r) => r.read<String?>('name'))
          .get();
      expect(
        columns.contains('ayah_from') || columns.contains('ayah_to'),
        isFalse,
        reason: 'Đoạn không được có ràng buộc duy nhất (quyết định 24)',
      );
    }
  });
}
