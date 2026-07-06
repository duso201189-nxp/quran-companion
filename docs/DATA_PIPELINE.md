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

⚠️ **Lưu ý pháp lý trước khi phát hành Store:** điều khoản Tanzil cho
bản DỊCH ghi "non-commercial". App miễn phí thường được chấp nhận,
nhưng nếu sau này có thu phí/quảng cáo thì PHẢI xin phép hoặc đổi
nguồn bản dịch. Đã ghi vào TODO.md mục pháp lý.

## Chạy pipeline

```bash
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
- Nguồn nào không phủ đủ 6.236 Ayah hoặc có văn bản rỗng
- Vi phạm foreign key

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
