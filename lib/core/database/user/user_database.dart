import 'package:drift/drift.dart';

import 'user_tables.dart';

part 'user_database.g.dart';

/// Database dữ liệu NGƯỜI DÙNG — file riêng biệt hoàn toàn với
/// database nội dung Qur'an: cập nhật nội dung không bao giờ đụng
/// dữ liệu học (DATABASE.md §migration).
@DriftDatabase(
  tables: [Bookmarks, Highlights, Notes, Favorites, AyahStatuses],
)
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // Nâng cấp schema: CHỈ ADDITIVE (thêm bảng/cột), đi từng
        // bước v(n) -> v(n+1); mỗi bước kèm test migration với dữ
        // liệu mẫu. KHÔNG BAO GIỜ drop dữ liệu người dùng.
        onUpgrade: (m, from, to) async {
          // v2: bảng favorites (Sprint 2 — hành động Yêu thích).
          if (from < 2) {
            await m.createTable(favorites);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
