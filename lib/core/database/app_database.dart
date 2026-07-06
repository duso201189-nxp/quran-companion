import 'package:drift/drift.dart';

import 'tables/content_tables.dart';

part 'app_database.g.dart';

/// Database nội dung Qur'an (nhóm A — chỉ đọc).
///
/// File SQLite được build sẵn bởi tool/build_quran_db.py và đóng gói
/// trong assets; lần chạy đầu app chép ra bộ nhớ trong rồi mở.
/// `onCreate` chỉ dùng cho TEST (in-memory) — bản phát hành luôn mở
/// file đã có sẵn dữ liệu.
///
/// Database NGƯỜI DÙNG (nhóm B) sẽ là một database Drift RIÊNG
/// (Bước 6) — tách file để cập nhật nội dung không đụng dữ liệu học.
@DriftDatabase(
  tables: [
    Surahs,
    Ayahs,
    TranslationSources,
    Translations,
    Reciters,
    MetaEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
