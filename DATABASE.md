# Cơ sở dữ liệu — Qur'an Companion

Ba nhóm dữ liệu. Chi tiết lý do thiết kế: xem ARCHITECTURE.md mục 3.

## Nhóm A — Nội dung tĩnh (SQLite đóng gói, chỉ đọc)

Được build sẵn thành `assets/database/quran.sqlite` bằng script
(Bước 2), copy vào bộ nhớ app lần chạy đầu.

```sql
surahs(
  id INTEGER PRIMARY KEY,          -- 1..114
  name_arabic TEXT NOT NULL,
  name_latin  TEXT NOT NULL,
  name_vi     TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  ayah_count  INTEGER NOT NULL,
  revelation_place TEXT NOT NULL,  -- 'mecca' | 'madinah'
  order_revealed   INTEGER NOT NULL
)

ayahs(
  id INTEGER PRIMARY KEY,          -- 1..6236 (đánh số toàn cục)
  surah_id INTEGER REFERENCES surahs,
  ayah_number INTEGER NOT NULL,    -- số trong Surah
  text_uthmani TEXT NOT NULL,
  juz INTEGER, hizb INTEGER, page INTEGER,
  sajdah INTEGER DEFAULT 0         -- ayah có vị trí quỳ lạy
)

-- Bản dịch là DỮ LIỆU, không phải cột cứng:
-- thêm bản dịch mới = import file, KHÔNG sửa schema/code.
translation_sources(
  id INTEGER PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,       -- 'vi_hasan', 'en_sahih', 'translit'
  name TEXT, language TEXT, author TEXT,
  type TEXT NOT NULL,              -- 'translation'|'transliteration'|'tafsir'
  is_enabled INTEGER DEFAULT 1,
  display_order INTEGER
)

translations(
  source_id INTEGER REFERENCES translation_sources,
  ayah_id   INTEGER REFERENCES ayahs,
  text TEXT NOT NULL,
  PRIMARY KEY (source_id, ayah_id)
)

-- Từ vựng 2 tầng: lemma (từ gốc) / word_instance (lần xuất hiện)
lemmas(
  id INTEGER PRIMARY KEY,
  arabic TEXT NOT NULL,
  root TEXT,                       -- gốc 3 phụ âm Ả Rập
  transliteration TEXT,
  pos_tag TEXT,                    -- loại từ
  meaning_vi TEXT, meaning_en TEXT,
  explanation_vi TEXT,
  occurrence_count INTEGER         -- tính sẵn lúc build data
)

word_instances(
  id INTEGER PRIMARY KEY,
  ayah_id INTEGER REFERENCES ayahs,
  lemma_id INTEGER REFERENCES lemmas,
  position INTEGER NOT NULL,       -- vị trí trong Ayah
  arabic_form TEXT NOT NULL,       -- dạng biến đổi thực tế
  transliteration TEXT
)
-- "Các Ayah khác chứa từ này":
--   SELECT ayah_id FROM word_instances WHERE lemma_id = ?
```

-- AUDIO NHIỀU QARI: reciter là DỮ LIỆU, không hard-code trong code.
-- Thêm Qari mới = thêm 1 dòng (URL theo mẫu), không sửa mã nguồn.
reciters(
  id INTEGER PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,       -- 'alafasy', 'husary'...
  name TEXT NOT NULL,
  name_arabic TEXT,
  audio_url_template TEXT NOT NULL,
  -- vd: 'https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3'
  -- {sss}=surah 3 chữ số, {aaa}=ayah 3 chữ số
  bitrate_kbps INTEGER,
  is_enabled INTEGER DEFAULT 1,
  display_order INTEGER
)

-- TÌM KIẾM TOÀN VĂN (hiệu năng): FTS5 virtual table, build sẵn
-- trong file data. Tìm 'LIKE %...%' trên 6.236 Ayah x N bản dịch
-- quá chậm; FTS5 trả kết quả tức thời và có sẵn trong SQLite.
CREATE VIRTUAL TABLE search_index USING fts5(
  ayah_id UNINDEXED,
  source_code UNINDEXED,           -- 'arabic'|'vi_hasan'|'en_sahih'...
  content                          -- văn bản đã chuẩn hóa
);
-- Riêng tiếng Ả Rập: lưu thêm bản đã BỎ DẤU (tashkeel) để người
-- dùng gõ không dấu vẫn tìm được.

meta(key TEXT PRIMARY KEY, value TEXT)
-- data_version, schema_version của file data đóng gói.

Index (đã build trong file data): ayahs(surah_id, ayah_number),
ayahs(juz), ayahs(hizb), ayahs(page), ayahs(sajdah) partial,
translations(ayah_id), translations(source_id),
translation_sources(is_enabled, display_order),
reciters(is_enabled, display_order); về sau:
word_instances(ayah_id), word_instances(lemma_id).

FTS `search_index` chứa thêm 2 lớp bỏ dấu: `arabic_plain`,
`vi_main_plain`, `translit_latin_plain` — người dùng gõ
không dấu ("long" / "rahim") vẫn khớp.

## Nhóm B — Dữ liệu người dùng (Drift local ↔ Supabase, cùng schema)

Kể từ [DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md)
(Sprint 8), amend một phần bởi
[DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md)
(Sprint 9) và [DR-2026-0005](docs/adr/DR-2026-0005.md) (Sprint 10 —
Learning Engine/SRS/Quiz): **Drift schema files
(`lib/core/database/user/user_tables.dart`,
`lib/core/database/user/user_database.dart`) là Source of Truth cho
schema HIỆN TẠI.** Mục dưới đây là Design Specification — chia 3
tầng để không lẫn "đã có thật" với "còn là dự định":

- **Đã triển khai** — khớp `UserDatabase.schemaVersion` hiện tại
  (đang là **5**). Đây là bản ghi lại của schema thật, không phải
  nơi thiết kế; đổi schema thì sửa code trước, sửa mục này sau.
- **Đã định** — đã có tên bảng/cột dự kiến, gắn với một Bước cụ thể
  trong ROADMAP.md, nhưng CHƯA có trong code.
- **Ý tưởng tương lai** — hướng mở rộng chưa gắn Bước cụ thể, có thể
  đổi hình dạng nhiều lần trước khi thành "Đã định". (Hiện chưa có
  mục nào ở tầng này — sẽ thêm khi có ý tưởng thật cần ghi lại.)

QUY TẮC BẤT BIẾN của nhóm B (áp dụng cho MỌI bảng — xem mixin
`SyncColumns` trong `user_tables.dart`):

1. **Khóa chính = UUID v4 sinh phía client** (kiểu TEXT trong SQLite,
   uuid trong Postgres). KHÔNG dùng INTEGER tự tăng — hai thiết bị
   offline cùng tạo bản ghi sẽ đụng độ id khi sync. UUID sinh tại
   thiết bị loại bỏ hoàn toàn xung đột khóa.
2. `updated_at` (epoch ms, UTC) — giải quyết xung đột last-write-wins.
3. `deleted_at` NULL-able — soft delete, để thao tác xóa cũng đồng
   bộ được sang thiết bị khác.
4. `is_dirty` (mặc định `true`) — bản ghi thay đổi cục bộ chưa đẩy
   lên cloud; SyncEngine (Bước 11) đọc cờ này.
5. Cột `user_id` NULL-able (null khi chưa đăng nhập) khớp
   `auth.uid()` của Supabase khi bật RLS.

### Đã triển khai (schemaVersion 5)

```sql
bookmarks (id, user_id, updated_at, deleted_at, is_dirty,
           ayah_id, created_at,
           collection_id NULL REFERENCES bookmark_collections)
           -- 1 bookmark / Ayah (UNIQUE ayah_id). collection_id NULL
           -- = chưa phân loại — trạng thái hợp lệ vĩnh viễn. KHÔNG
           -- khai báo FK ở tầng Drift (không có tiền lệ FK trong
           -- schema này) — toàn vẹn do BookmarkCollectionRepository
           -- tự đảm nhiệm (Sprint 8).
highlights(id, user_id, updated_at, deleted_at, is_dirty,
           ayah_id, color)
           -- color: 6 màu mặc định. UNIQUE(ayah_id, color) — một
           -- Ayah nhiều màu được.
notes     (id, user_id, updated_at, deleted_at, is_dirty,
           ayah_id, content)
           -- Markdown cơ bản (**đậm**, *nghiêng*). UNIQUE ayah_id.
favorites (id, user_id, updated_at, deleted_at, is_dirty,
           ayah_id, created_at)
           -- 1 favorite / Ayah (UNIQUE ayah_id), Sprint 2.

-- Trạng thái học ĐƠN (không phải hệ cờ nhiều-giá-trị) — một Ayah
-- có tối đa 1 trạng thái tại một thời điểm; không có dòng = chưa đọc.
ayah_statuses(id, user_id, updated_at, deleted_at, is_dirty,
              ayah_id, status)   -- 'learning'|'learned'|'review'
              -- UNIQUE ayah_id. status='review' = Revision Queue
              -- ĐƠN GIẢN (DR-2026-0003 mục B, tái khẳng định ở
              -- DR-2026-0004 mục 3). Sprint 9: màn hình Revision
              -- Queue tái dùng UserContentRepository (thêm
              -- watchAllReviewAyahs()) + LibraryTabView/LibraryAyahTile
              -- có sẵn — KHÔNG có repository/bảng riêng.
              --
              -- Sprint 10 (DR-2026-0005 mục 1-2): srs_cards TIÊU THỤ
              -- danh sách này làm nguồn thành viên — KHÔNG thay thế
              -- (lệch có chủ đích so với dự định ban đầu ở
              -- DR-2026-0003, "sẽ thay thế Revision Queue đơn giản
              -- khi cần SM-2" — quyết định lại ở DR-2026-0005: Revision
              -- Queue vẫn độc lập, Scheduler là lớp lịch trình thêm
              -- vào bên trên). Xem srs_cards bên dưới.

-- Nhật ký phiên đọc (Sprint 8, DR-2026-0003 mục A). Sự kiện, KHÔNG
-- unique theo ngày — đọc nhiều lần một ngày là bình thường.
study_sessions(id, user_id, updated_at, deleted_at, is_dirty,
               date,               -- 'yyyy-MM-dd'
               surah_id, ayah_from, ayah_to,   -- Ayah 0-based
               duration_sec, note, created_at)
-- Streak (hiện tại/dài nhất) TÍNH TRÊN TRUY VẤN từ bảng này —
-- KHÔNG CÓ bảng streaks riêng (dẫn xuất-khi-đọc, DR-2026-0003 mục
-- A). Nguồn CANONICAL cho streak trên MỌI màn hình (DR-2026-0004
-- mục 1) — HomeScreen/StatsScreen đều đọc
-- currentStreakProvider/longestStreakProvider (Sprint 9 Phase 5);
-- StatsStore.currentStreak/longestStreak không còn nơi nào gọi tới.
-- Ngưỡng "phiên đủ để ghi": >=5 giây (khớp StatsStore.addSeconds
-- hiện có). Ngưỡng "ngày đủ điều kiện tính streak" gộp theo tổng
-- thời lượng/Ayah trong ngày (>=5 phút HOẶC >=5 Ayah, ý tưởng gốc
-- trước Sprint 8) VẪN CHƯA triển khai — DR-2026-0004 chỉ quyết định
-- NGUỒN dữ liệu (Drift), không đổi công thức ngưỡng — xem TODO.md.

-- KHATM TRACKER (Sprint 8, DR-2026-0003 mục A): mỗi chu kỳ đọc trọn
-- bộ Qur'an là 1 bản ghi. Nhiều chu kỳ/người dùng (đang đọc + lịch
-- sử) được.
khatm_cycles(id, user_id, updated_at, deleted_at, is_dirty,
             name,                          -- 'Khatm Ramadan 1448'...
             started_at, target_date,
             completed_at,                  -- NULL = đang đọc
             current_ayah_id)               -- vị trí đọc 1..6236,
                                             -- mặc định 1
-- Tiến độ % = current_ayah_id / 6236; tách khỏi ayah_statuses vì
-- khatm là VỊ TRÍ tuần tự theo chu kỳ, còn ayah_statuses là trạng
-- thái học vĩnh viễn.

-- Bộ sưu tập Bookmark (Sprint 8, DR-2026-0003 mục C). CHỈ áp dụng
-- cho Ayah ở tầng database (tránh bảng chưa dùng đến) — mô hình
-- domain (CollectionItem tổng quát cho loại khác) để mở, chưa xây.
bookmark_collections(id, user_id, updated_at, deleted_at, is_dirty,
                     name, emoji, display_order)

-- SRS tổng quát (Sprint 10 Phase 1, DR-2026-0005 mục 3): dùng CHUNG
-- cho từ vựng (lemma) và Hifz/Ayah — item_type + item_id thay vì
-- khóa cứng vào 1 loại, thêm loại thẻ mới không cần đổi schema.
-- Hiện chỉ item_type='ayah' được ghi — Flashcard ('lemma') hoãn lại
-- (chưa có dữ liệu từ vựng, xem mục "Đã định" > lemmas/word_instances
-- và TODO.md). SchedulingAlgorithm hôm nay là SM-2 (ARCHITECTURE.md
-- §10); ease_factor mặc định 2.5, sàn 1.3.
srs_cards(id, user_id, updated_at, deleted_at, is_dirty,
          item_type TEXT,                   -- 'ayah' (chỉ giá trị hiện có)
          item_id INTEGER,                  -- ayah_id (sẽ là lemma_id sau)
          ease_factor REAL DEFAULT 2.5,
          interval_days INTEGER DEFAULT 0,
          repetitions INTEGER DEFAULT 0,
          due_date INTEGER,                 -- epoch ms — hạn ôn tập
          state TEXT,                       -- new|learning|review|lapsed
          UNIQUE(item_type, item_id))
          -- LỆCH CÓ CHỦ ĐÍCH so với sketch gốc (từng ghi
          -- UNIQUE(user_id, item_type, item_id)): user_id nullable
          -- trước khi đăng nhập, và SQLite coi mỗi NULL khác biệt —
          -- đưa user_id vào UNIQUE sẽ không có tác dụng thật trong
          -- giai đoạn single-user hiện nay. Theo đúng tiền lệ của MỌI
          -- bảng khác trong file này (bookmarks/highlights/notes/
          -- favorites/ayah_statuses đều bỏ user_id khỏi uniqueKeys).
          --
          -- Quan hệ với ayah_statuses (DR-2026-0005 mục 1-2): thẻ
          -- item_type='ayah' được TẠO/XOÁ MỀM đồng bộ theo Revision
          -- Queue (ayah_statuses.status='review') — Scheduler đọc
          -- Queue làm nguồn thành viên, không sở hữu/không thay thế.
          -- Không backfill lúc migration (v3->v4) — tự đồng bộ khi
          -- đọc, xem SchedulerRepository.syncWithReviewQueue.

-- Kết quả Quiz (Sprint 10 Phase 4, DR-2026-0005 mục 5). CHỈ lưu điểm
-- — KHÔNG có Question Bank, KHÔNG lưu lại câu hỏi/nội dung Ayah: câu
-- hỏi sinh động mỗi phiên từ nhóm A (QuestionGenerator, thuần Dart,
-- không phụ thuộc database) rồi bỏ đi, không bao giờ ghi xuống nhóm B.
quiz_results(id, user_id, updated_at, deleted_at, is_dirty,
             quiz_type TEXT,                 -- 'mixed' (chỉ giá trị hiện có)
             surah_id INTEGER NULL,
             score INTEGER, total INTEGER,
             taken_at INTEGER)                -- epoch ms
             -- LỆCH CÓ CHỦ ĐÍCH so với sketch gốc (surah_id từng
             -- không nullable): quiz 'mixed' trộn nhiều loại câu hỏi
             -- từ nhiều Surah trong 1 phiên, không gắn với đúng 1
             -- Surah — surah_id để dành cho chế độ quiz theo phạm vi
             -- 1 Surah (chưa xây ở Sprint 10).
```

Supabase: mọi bảng nhóm B bật RLS `user_id = auth.uid()`.

### Đã định (gắn Bước cụ thể, chưa có trong code)

```sql
profiles(user_id PK, name, avatar_url,
         daily_goal_minutes, daily_goal_ayahs, settings_json)
         -- Mục tiêu đọc hằng ngày (Daily Goal) CỐ Ý không dùng bảng
         -- này — xem DR-2026-0004: chỉ tiêu lưu SharedPreferences
         -- (DailyGoalStore, giống ThemeController/LocaleController),
         -- tiến độ tính trên truy vấn từ study_sessions. Bảng
         -- profiles này chờ tới khi có Auth/Sync thật (Bước 10-11)
         -- mới cần, không xây trước cho có.

surah_progress(user_id, surah_id, ayahs_read, ayahs_memorized,
               percent, last_ayah_id, updated_at)
               -- cache tính từ ayah_statuses — tối ưu hoá, chưa cần
               -- thiết tới khi có dữ liệu thật cho thấy cần cache.

-- HIFZ (học thuộc lòng): kế hoạch theo dải Ayah. Bước 9 — CHƯA xây ở
-- Sprint 10 (không nằm trong 6 quyết định của DR-2026-0005; chỉ nêu
-- tên như 1 nhánh tương lai của Learning Engine). Ôn tập từng Ayah do
-- srs_cards(item_type='ayah') đảm nhiệm (đã có, xem "Đã triển khai");
-- status='learned' trong ayah_statuses đánh dấu kết quả cuối.
hifz_plans(id, user_id,
           surah_id, ayah_from, ayah_to,
           status,                          -- active|paused|completed
           started_at, completed_at,
           updated_at, deleted_at)

sync_queue(id, table_name, row_id,          -- hàng đợi offline
           operation,                       -- insert|update|delete
           created_at)
           -- Bước 11 — Cloud Sync.
```

### Ý tưởng tương lai

Chưa có mục nào — sẽ thêm khi có hướng mở rộng thật cần ghi lại,
không tạo trước cho có.

## Nhóm C — AI / RAG (v2.0, chỉ Supabase + pgvector)

```sql
knowledge_documents(id, title,
                    source_type,   -- 'quran'|'hadith'|'custom'
                    metadata JSONB)

knowledge_chunks(id, document_id REFERENCES knowledge_documents,
                 content TEXT,
                 surah_id INT NULL, ayah_id INT NULL,
                 hadith_ref TEXT NULL,
                 embedding vector(1536))
```

## Quy tắc migration (không bao giờ mất dữ liệu người dùng)

- Nhóm A: đổi schema = phát hành data file phiên bản mới kèm app;
  bảng `meta(key,value)` lưu data_version.
- Nhóm B: Drift `schemaVersion` + `MigrationStrategy` (onUpgrade
  từng bước v1->v2->v3, có test migration với dữ liệu mẫu);
  Supabase dùng migration SQL đánh số trong supabase/migrations/.
  Hai bên PHẢI cập nhật trong cùng PR.
- Nguyên tắc an toàn: chỉ THÊM bảng/cột (additive). Đổi tên hoặc
  xóa cột phải qua 2 phiên bản: phiên bản N ghi song song,
  phiên bản N+1 mới gỡ cột cũ — người dùng nhảy cóc phiên bản
  vẫn không mất dữ liệu.
- Dữ liệu nhóm A và nhóm B tách file database riêng: cập nhật
  nội dung Qur'an (thay file data) không đụng vào dữ liệu học
  của người dùng.
