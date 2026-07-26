# Pipeline dữ liệu Qur'an

## Nguyên tắc

1. Dữ liệu Qur'an KHÔNG nằm trong source code — chỉ có script build.
2. File `assets/database/quran.sqlite` là SẢN PHẨM BUILD
   (không commit vào git; CI tự build và cache).
3. Import lại bất cứ lúc nào: script idempotent, xóa file cũ build mới.
4. Mọi nguồn phải có metadata: tên, tác giả, phiên bản, ngày import,
   license, URL gốc — lưu trong `translation_sources` / `meta`,
   hiển thị ở màn hình Giới thiệu của app.

## Nguồn dữ liệu & giấy phép

| Dữ liệu | Nguồn | Giấy phép / điều kiện |
|---|---|---|
| Arabic Uthmani | Tanzil.net (text verified) | Phân phối nguyên văn, cấm sửa văn bản, PHẢI ghi nguồn + link tanzil.net |
| Transliteration | Tanzil.net (en.transliteration) | Tanzil terms — phi thương mại, ghi nguồn |
| English (Sahih International) | Tanzil.net (en.sahih) | Tanzil terms — phi thương mại, ghi nguồn |
| Tiếng Việt | QuranEnc.com (tự phát hiện key; ưu tiên Hasan Abdul Karim) | Sử dụng với ghi nguồn — kiểm tra điều khoản từng bản trên quranenc.com |
| Audio | everyayah.com (URL trong bảng `reciters`) | Phi thương mại — xem everyayah.com |
| Tafsir | Quran.com/QUL — Tafsir Al-Muyassar (`ar-tafsir-muyassar`) | Dữ liệu cộng đồng Quran.com/QUL — ghi nguồn; **kiểm tra điều khoản trước khi phát hành thương mại** |

⚠️ **Lưu ý pháp lý trước khi phát hành Store:** điều khoản Tanzil cho
bản DỊCH ghi "non-commercial". App miễn phí thường được chấp nhận,
nhưng nếu sau này có thu phí/quảng cáo thì PHẢI xin phép hoặc đổi
nguồn bản dịch. Đã ghi vào TODO.md mục pháp lý.

## Chạy pipeline

```bash
# Tải bộ Tafsir (tuỳ chọn, chạy TRƯỚC khi build; ghi ra tool/data/)
python3 tool/fetch_tafsir.py

# Liệt kê các bản dịch tiếng Việt có trên QuranEnc
python3 tool/build_quran_db.py --list-vi

# Build đầy đủ (tự chọn bản Việt: ưu tiên 'hasan' -> 'rwwad')
python3 tool/build_quran_db.py

# Chỉ định bản Việt cụ thể
python3 tool/build_quran_db.py --vi-key vietnamese_rwwad
```

Script tự **kiểm tra toàn vẹn** trước khi hoàn tất, build FAIL nếu:
- ≠ 114 Surah hoặc ≠ 6.236 Ayah
- Surah nào có số Ayah không khớp metadata / đánh số không liên tục
- Nguồn **bản dịch/phiên âm** nào không phủ đủ 6.236 Ayah, hoặc BẤT KỲ
  nguồn nào có văn bản rỗng
- Vi phạm foreign key

### Chú giải viết theo ĐOẠN, không theo từng Ayah (Sprint 32.0)

Sprint 31.3/31.4 đã **hiểu sai** dữ liệu này. Báo cáo lúc đó ghi
"Al-Muyassar chỉ phủ 5.278/6.236 Ayah (15% khoảng trống)" và
"Ibn Kathir chỉ phủ 30%". Cả hai đều SAI.

Đo lại đúng cách (đếm ĐOẠN, không đếm dòng):

| Bộ | Số mục | Phủ thực tế | Nhịp đoạn |
|---|---|---|---|
| Al-Muyassar | 5.278 | **6.236/6.236 (100%)** | 1–14 Ayah |
| Ibn Kathir | 1.895 | **6.231/6.236 (99,9%)** | 1–20 Ayah |

Chú giải gắn vào Ayah ĐẦU của một đoạn; các Ayah tiếp theo trong đoạn
không có dòng riêng. Nguồn trả về đúng như vậy (Ibn Kathir: 4.341 mục
văn bản rỗng, 0 khoảng trống phân trang).

`validate()` vì vậy nhận `partial_codes`: nguồn chú giải được phép có
ít DÒNG hơn số Ayah — đó là hình dạng dữ liệu, không phải thiếu sót.
Văn bản RỖNG vẫn bị cấm với mọi nguồn.

**Hệ quả kiến trúc:** truy vấn khớp chính xác `ayah_id` bỏ sót 945 Ayah
có chú giải thật. Xem `getTextsCoveringAyah` — quy tắc "mục gần nhất
trước đó trong CÙNG Surah".

### Tafsir không vào chỉ mục tìm kiếm

`search_index` cố ý bỏ qua nguồn `type='tafsir'` (quyết định D9,
Sprint 30.2): chú giải dài sẽ lấn át kết quả tìm trong kinh văn. Kiểm
chứng bằng test trên dữ liệu thật (`tafsir_real_corpus_test.dart`).

## Cập nhật dữ liệu (bản dịch mới, sửa lỗi nguồn)

1. Sửa/thêm importer trong `tool/build_quran_db.py`.
2. Tăng `DATA_VERSION` trong script **và**
   `DatabaseConstants.expectedDataVersion` trong Dart (cùng PR).
3. Build lại → app tự chép đè file nội dung ở lần mở kế tiếp.
   Dữ liệu người dùng KHÔNG bị ảnh hưởng (database riêng).

## Thêm loại dữ liệu mới — KHÔNG đổi kiến trúc

| Muốn thêm | Cách làm |
|---|---|
| Tafsir | 1 dòng `translation_sources` (type='tafsir') + import văn bản vào `translations` |
| Bản dịch khác | Tương tự, type='translation' |
| Qari mới | 1 dòng bảng `reciters` (URL theo mẫu) |
| Word-by-word, Root, Morphology | Ghi vào `lemmas` + `word_instances` (schema đã thiết kế — DATABASE.md); viết importer từ corpus.quran.com |
| Hadith | Nhóm C `knowledge_documents/chunks` (phục vụ AI RAG) |

## Web runtime (Bước triển khai Web)

Drift trên Web cần 2 file đặt trong thư mục `web/` của project:
- `sqlite3.wasm` — tải từ trang releases của package sqlite3.dart
- `drift_worker.js` — tải từ trang releases của drift

Không có 2 file này, bản Web build được nhưng mở database sẽ lỗi
runtime. (Sẽ kiểm tra ở bước chạy thử Web.)
