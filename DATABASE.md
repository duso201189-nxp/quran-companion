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

QUY TẮC BẤT BIẾN của nhóm B (áp dụng cho MỌI bảng bên dưới):

1. **Khóa chính = UUID v4 sinh phía client** (kiểu TEXT trong SQLite,
   uuid trong Postgres). KHÔNG dùng INTEGER tự tăng — hai thiết bị
   offline cùng tạo bản ghi sẽ đụng độ id khi sync. UUID sinh tại
   thiết bị loại bỏ hoàn toàn xung đột khóa.
2. `updated_at` (epoch ms, UTC) — giải quyết xung đột last-write-wins.
3. `deleted_at` NULL-able — soft delete, để thao tác xóa cũng đồng
   bộ được sang thiết bị khác.
4. Cột `user_id` khớp `auth.uid()` của Supabase (RLS).

```sql
profiles(user_id PK, name, avatar_url,
         daily_goal_minutes, daily_goal_ayahs, settings_json)

-- Hệ CỜ trạng thái: 1 Ayah bật được NHIỀU cờ cùng lúc.
-- 'Chưa đọc' = không có cờ nào.
ayah_flags(
  id PK, user_id, ayah_id,
  flag TEXT,   -- read|understood|favorite|noted|listened|
               -- review|memorized|applying
  created_at, updated_at, deleted_at,
  UNIQUE(user_id, ayah_id, flag)
)
-- Cờ tự động: read (tùy chọn bật trong Cài đặt), noted, listened.
-- Cờ thủ công: understood, favorite, review, memorized, applying.

surah_progress(user_id, surah_id, ayahs_read, ayahs_memorized,
               percent, last_ayah_id, updated_at)
               -- cache tính từ ayah_flags

-- Gom bookmark thành bộ sưu tập theo chủ đề (Favorite Collections)
bookmark_collections(id, user_id, name, emoji, display_order,
                     updated_at, deleted_at)

bookmarks (id, user_id, ayah_id,
           collection_id NULL REFERENCES bookmark_collections,
           created_at, deleted_at)
           -- collection_id NULL = bookmark chưa phân loại
highlights(id, user_id, ayah_id, color, updated_at, deleted_at)
          -- color: 6 màu mặc định + mã hex tùy chỉnh
notes     (id, user_id, ayah_id, content, updated_at, deleted_at)

study_sessions(id, user_id, date, surah_id,
               ayah_from, ayah_to, duration_sec, note, created_at)

streaks(user_id, current, longest, last_study_date)
-- QUY TẮC streak: một ngày chỉ được tính khi tổng study_sessions
-- của ngày đó đạt >= 5 phút HOẶC >= 5 Ayah được đánh dấu đã đọc.
-- Mở app vài giây KHÔNG tính. Ngưỡng đặt trong cấu hình, không
-- hard-code rải rác.

-- SRS tổng quát: dùng CHUNG cho từ vựng (lemma) và Hifz (ayah).
-- item_type + item_id thay vì khóa cứng vào lemma -> thêm loại
-- thẻ mới (ví dụ: cụm Ayah) không cần đổi schema.
srs_cards(id, user_id,
          item_type TEXT,                   -- 'lemma' | 'ayah'
          item_id INTEGER,                  -- lemma_id hoặc ayah_id
          ease_factor, interval_days, repetitions,  -- SM-2
          due_date, state,                  -- new|learning|review|lapsed
          updated_at, deleted_at,
          UNIQUE(user_id, item_type, item_id))

-- KHATM TRACKER: mỗi chu kỳ đọc trọn bộ Qur'an là 1 bản ghi.
-- Người dùng có thể có nhiều chu kỳ (đang đọc + lịch sử).
khatm_cycles(id, user_id,
             name,                          -- 'Khatm Ramadan 1448'...
             started_at, target_date,
             completed_at,                  -- NULL = đang đọc
             current_ayah_id,               -- vị trí đọc 1..6236
             updated_at, deleted_at)
-- Tiến độ % = current_ayah_id / 6236; tách khỏi ayah_flags vì
-- khatm là VỊ TRÍ tuần tự theo chu kỳ, cờ là trạng thái học vĩnh viễn.

-- HIFZ (học thuộc lòng): kế hoạch theo dải Ayah.
-- Ôn tập từng Ayah do srs_cards(item_type='ayah') đảm nhiệm;
-- cờ 'memorized' trong ayah_flags đánh dấu kết quả cuối.
hifz_plans(id, user_id,
           surah_id, ayah_from, ayah_to,
           status,                          -- active|paused|completed
           started_at, completed_at,
           updated_at, deleted_at)

quiz_results(id, user_id, quiz_type, surah_id, score, total, taken_at)

sync_queue(id, table_name, row_id,          -- hàng đợi offline
           operation,                       -- insert|update|delete
           created_at)
```

Supabase: mọi bảng nhóm B bật RLS `user_id = auth.uid()`.

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
