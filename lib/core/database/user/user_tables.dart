import 'package:drift/drift.dart';

/// Bảng nhóm B — dữ liệu người dùng. QUY TẮC BẤT BIẾN (DATABASE.md):
/// - PK = UUID v4 sinh phía client (TEXT) — không đụng độ đa thiết bị.
/// - updated_at (epoch ms UTC) — last-write-wins khi sync.
/// - deleted_at nullable — soft delete, thao tác xóa cũng sync được.
/// - is_dirty — bản ghi thay đổi cục bộ chưa đẩy lên cloud.
/// - user_id nullable — null khi chưa đăng nhập; gán khi sync lần đầu.

mixin SyncColumns on Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id').nullable()();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();
  BoolColumn get isDirty =>
      boolean().named('is_dirty').withDefault(const Constant(true))();
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table with SyncColumns {
  @override
  String get tableName => 'bookmarks';

  IntColumn get ayahId => integer().named('ayah_id')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// 1 bookmark / Ayah — toggle hồi sinh bản ghi soft-deleted.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ayahId},
      ];
}

@DataClassName('HighlightRow')
class Highlights extends Table with SyncColumns {
  @override
  String get tableName => 'highlights';

  IntColumn get ayahId => integer().named('ayah_id')();

  /// Tên màu ('amber', 'green'...) — một Ayah nhiều màu được.
  TextColumn get color => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ayahId, color},
      ];
}

@DataClassName('NoteRow')
class Notes extends Table with SyncColumns {
  @override
  String get tableName => 'notes';

  IntColumn get ayahId => integer().named('ayah_id')();

  /// Nội dung — Markdown cơ bản (**đậm**, *nghiêng*).
  TextColumn get content => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ayahId},
      ];
}

@DataClassName('FavoriteRow')
class Favorites extends Table with SyncColumns {
  @override
  String get tableName => 'favorites';

  IntColumn get ayahId => integer().named('ayah_id')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// 1 favorite / Ayah — toggle hồi sinh bản ghi soft-deleted.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ayahId},
      ];
}

@DataClassName('AyahStatusRow')
class AyahStatuses extends Table with SyncColumns {
  @override
  String get tableName => 'ayah_statuses';

  IntColumn get ayahId => integer().named('ayah_id')();

  /// 'learning' | 'learned' | 'review' — không có dòng = chưa đọc.
  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {ayahId},
      ];
}
