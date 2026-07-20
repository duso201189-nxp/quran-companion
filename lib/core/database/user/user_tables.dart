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

  /// NULL = chưa phân loại vào bộ sưu tập nào — trạng thái hợp lệ
  /// vĩnh viễn, không phải tạm thời chờ migrate. Không khai báo FK
  /// Drift-level (không có tiền lệ trong file này); tính toàn vẹn do
  /// tầng repository đảm nhiệm, giống cách ayah_id được xử lý.
  TextColumn get collectionId => text().named('collection_id').nullable()();

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

/// Nhật ký phiên đọc (Sprint 8 — DR-2026-0003 mục A). Mỗi lần đọc là
/// một dòng độc lập — KHÔNG unique theo ngày/Surah (đọc nhiều lần một
/// ngày là bình thường). Streak/tổng phút được TÍNH TRÊN TRUY VẤN từ
/// bảng này (không có bảng streaks riêng — xem DR-2026-0003 mục A,
/// "thiết kế dẫn xuất-khi-đọc tương đương").
@DataClassName('StudySessionRow')
class StudySessions extends Table with SyncColumns {
  @override
  String get tableName => 'study_sessions';

  /// Ngày đọc, dạng 'yyyy-MM-dd' — khớp định dạng StatsStore.dayKey
  /// hiện có (SharedPreferences), để không cần quy đổi epoch↔ngày
  /// khi đối chiếu hai nguồn dữ liệu trong giai đoạn chuyển tiếp.
  TextColumn get date => text()();

  IntColumn get surahId => integer().named('surah_id')();

  /// Chỉ số Ayah 0-based trong Surah — khớp ReadingPositionStore.
  IntColumn get ayahFrom => integer().named('ayah_from')();
  IntColumn get ayahTo => integer().named('ayah_to')();

  IntColumn get durationSec => integer().named('duration_sec')();

  TextColumn get note => text().nullable()();

  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Chu kỳ Khatm (đọc trọn vẹn Qur'an) — Sprint 8, DR-2026-0003 mục A.
/// Vị trí đọc trong chu kỳ này ĐỘC LẬP với ReadingPositionStore (vị
/// trí đọc tự do hằng ngày không nhất thiết theo thứ tự Khatm).
@DataClassName('KhatmCycleRow')
class KhatmCycles extends Table with SyncColumns {
  @override
  String get tableName => 'khatm_cycles';

  TextColumn get name => text()();

  IntColumn get startedAt => integer().named('started_at')();

  /// Ngày mục tiêu hoàn thành, dạng 'yyyy-MM-dd' — tuỳ chọn.
  TextColumn get targetDate => text().named('target_date').nullable()();

  /// NULL = đang đọc (chu kỳ chưa hoàn thành).
  IntColumn get completedAt => integer().named('completed_at').nullable()();

  /// Ayah ID 1..6236 — vị trí hiện tại trong chu kỳ.
  IntColumn get currentAyahId =>
      integer().named('current_ayah_id').withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Bộ sưu tập Bookmark (Sprint 8 — DR-2026-0003 mục C). Chỉ áp dụng
/// cho Ayah (Bookmarks.collection_id), KHÔNG tổng quát hoá cho
/// Highlight/Note/Favorite — mô hình domain (CollectionItem) tổng
/// quát, nhưng bảng database giữ tối giản, tránh bảng chưa dùng đến.
@DataClassName('BookmarkCollectionRow')
class BookmarkCollections extends Table with SyncColumns {
  @override
  String get tableName => 'bookmark_collections';

  TextColumn get name => text()();
  TextColumn get emoji => text().nullable()();
  IntColumn get displayOrder =>
      integer().named('display_order').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Thẻ lịch ôn tập SRS (Sprint 10 Phase 1 — DR-2026-0005). item_type +
/// item_id tổng quát (dùng chung cho Ayah và, về sau, từ vựng) — hiện
/// chỉ 'ayah' được ghi (Flashcard 'lemma' hoãn lại, chưa có dữ liệu
/// từ vựng). Bảng này KHÔNG sở hữu khái niệm "Ayah nào cần ôn" — đó
/// vẫn là Revision Queue (ayah_statuses.status='review'). Scheduler
/// chỉ thêm lớp lịch trình (ease/interval/due_date) lên trên các mục
/// Queue đã có (xem SchedulerRepository, DR-2026-0005 mục 2).
///
/// uniqueKeys KHÔNG gồm user_id — SQLite coi mỗi NULL là khác biệt
/// nên user_id (nullable trước khi đăng nhập) trong ràng buộc UNIQUE
/// sẽ không có tác dụng thật; theo đúng tiền lệ của mọi bảng khác
/// trong file này (Bookmarks/Highlights/Notes/Favorites/AyahStatuses
/// đều bỏ user_id khỏi uniqueKeys), lệch có chủ đích so với sketch
/// SQL thô trong DATABASE.md.
@DataClassName('SrsCardRow')
class SrsCards extends Table with SyncColumns {
  @override
  String get tableName => 'srs_cards';

  /// 'ayah' | 'lemma' (chỉ 'ayah' dùng ở Sprint 10).
  TextColumn get itemType => text().named('item_type')();

  /// ayah_id hoặc lemma_id tùy [itemType].
  IntColumn get itemId => integer().named('item_id')();

  RealColumn get easeFactor =>
      real().named('ease_factor').withDefault(const Constant(2.5))();
  IntColumn get intervalDays =>
      integer().named('interval_days').withDefault(const Constant(0))();
  IntColumn get repetitions =>
      integer().named('repetitions').withDefault(const Constant(0))();

  /// Epoch ms UTC — thời điểm đến hạn ôn tập.
  IntColumn get dueDate => integer().named('due_date')();

  /// 'new' | 'learning' | 'review' | 'lapsed'.
  TextColumn get state => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {itemType, itemId},
      ];
}

/// Lịch sử kết quả Quiz (Sprint 10 Phase 4 — DR-2026-0005 mục 5). CHỈ
/// lưu điểm/kết quả — KHÔNG lưu câu hỏi hay nội dung Ayah (câu hỏi
/// sinh động từ dữ liệu nhóm A mỗi phiên, không có Question Bank).
///
/// surah_id nullable — lệch có chủ đích so với sketch SQL thô trong
/// DATABASE.md (surah_id không nullable ở đó): quiz hiện tại luôn là
/// 'mixed' (nhiều loại câu hỏi, nhiều Surah trong 1 phiên), không gắn
/// với đúng 1 Surah — surah_id để dành cho quiz theo phạm vi 1 Surah
/// (chưa xây ở Sprint 10).
@DataClassName('QuizResultRow')
class QuizResults extends Table with SyncColumns {
  @override
  String get tableName => 'quiz_results';

  /// 'mixed' — duy nhất loại hiện có (Sprint 10). Để dành cho các chế
  /// độ quiz tương lai (vd. theo 1 Surah) tái dùng cùng cột.
  TextColumn get quizType => text().named('quiz_type')();

  IntColumn get surahId => integer().named('surah_id').nullable()();
  IntColumn get score => integer()();
  IntColumn get total => integer()();
  IntColumn get takenAt => integer().named('taken_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
