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
| Transliteration | **Quran.com QDC** (`api.qurancdn.com`) — word-by-word transliteration API; `tool/fetch_transliteration.py` → `tool/data/transliteration.json`, nguồn duy nhất hiện dùng — **sửa lại 2026-08-23, Session 89**, dòng này trước đó ghi Tanzil.net, đã lỗi thời từ khi `fetch_transliteration.py` được thêm; **nguồn đính chính lại 2026-08-29, Session 159A**, dòng này trước đó ghi "Quran.com / QUL" — xem khối đính chính ngay dưới bảng | **CHƯA XÁC ĐỊNH / UNKNOWN — CẦN Ý KIẾN PHÁP LÝ.** Kho mã không xác lập được điều khoản thượng nguồn nào chi phối bộ dữ liệu này (xem `docs/LICENSING.md` mục 1, dòng 2). Chuỗi `license` lưu trong CSDL — *"Quran.com/QUL community data — ghi nguồn khi phân phối"* — là **siêu dữ liệu do chính dự án này viết ra** (hằng chuỗi trong `tool/fetch_transliteration.py:206`–`:207`), **không phải** bằng chứng cấp phép từ thượng nguồn. Dự phòng: nếu thiếu `tool/data/transliteration.json`, `build_quran_db.py` tự tải từ Tanzil.net (en.transliteration, điều khoản phi thương mại, ghi nguồn) |
| English (Sahih International) | Tanzil.net (en.sahih) | Tanzil terms — phi thương mại, ghi nguồn |
| Tiếng Việt | QuranEnc.com (tự phát hiện key; ưu tiên Hasan Abdul Karim) | Sử dụng với ghi nguồn — kiểm tra điều khoản từng bản trên quranenc.com |
| Audio | everyayah.com (URL trong bảng `reciters`) | Phi thương mại — xem everyayah.com |

> ### ⚠ Đính chính 2026-08-29 (Session 159A) — nguồn phiên âm Latin và tình trạng giấy phép
>
> Khối này đính chính **dòng Transliteration** trong bảng trên. Đây là
> **đính chính tài liệu, không phải kết luận pháp lý**.
>
> **1. Danh tính nguồn — đã sửa (SỰ THẬT).** Bộ phiên âm Latin đang phát
> hành **không** lấy qua QUL. Nó được tải qua **điểm cuối QDC của
> Quran.com**, `api.qurancdn.com`:
> `tool/fetch_transliteration.py:30`–`:34` gọi
> `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` với
> `?words=true&word_fields=transliteration,text_uthmani`. Đó là đường
> tải duy nhất của bộ dữ liệu này. Trước 2026-08-29 dòng trong bảng ghi
> *"Quran.com / QUL"* — trích lại ở đây làm dấu vết lịch sử, **không**
> phải phát biểu hiện hành.
>
> **QDC và QUL là hai thứ khác nhau và không được gộp làm một.** FAQ của
> QUL **không** phải văn bản điều khoản chi phối bộ dữ liệu này; nó tiếp
> tục chi phối những bộ thực sự lấy qua QUL. Điều này khớp với đính chính
> Session 147 trong `docs/LICENSING.md` mục 1 và với U3 / Q3 của
> `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md`.
>
> **2. Chuỗi `license` trong CSDL không phải bằng chứng cấp phép thượng
> nguồn.** Giá trị lưu cho `translit_latin` là *"Quran.com/QUL community
> data — ghi nguồn khi phân phối"*. Giá trị đó **do chính dự án này
> viết**: nó là hằng chuỗi mã cứng trong
> `tool/fetch_transliteration.py:206`–`:207`, được chép vào
> `tool/data/transliteration.json` rồi vào CSDL phát hành. Nó **không**
> phải phát biểu của Quran.com hay của bất kỳ chủ thể quyền nào, và
> **không** phải căn cứ cho bất cứ điều gì. Câu *"Ghi nguồn Quran.com/QUL
> khi phân phối"* mà cột giấy phép ghi trước 2026-08-29 — trích lại ở đây
> làm dấu vết lịch sử, **không** phải phát biểu hiện hành — đọc chuỗi
> siêu dữ liệu đó như một nghĩa vụ thượng nguồn; cách đọc đó **được rút
> lại**.
>
> **3. Khối này KHÔNG kết luận điều gì.** Nó **không** xác lập rằng có sự
> cho phép. Nó **không** xác lập rằng sự cho phép bị từ chối. Nó **không**
> xác lập rằng việc phân phối lại được cho phép, và **không** xác lập
> rằng việc phân phối lại bị cấm. Nó **không** tuyên bố bộ dữ liệu đã
> được thông qua về mặt pháp lý, và **không** kết luận rằng có bất kỳ vi
> phạm nào. Nó **không** khẳng định có hay không có nghĩa vụ ghi nguồn.
> Điều khoản hay sự cho phép chi phối bộ phiên âm QDC — và điều khoản nào
> có hiệu lực tại ngày tải `2026-07-06` ghi trong siêu dữ liệu phát hành
> — vẫn **CHƯA XÁC ĐỊNH / UNKNOWN — CẦN Ý KIẾN PHÁP LÝ**. **P2-2 vẫn
> ĐANG MỞ**; không nhãn trạng thái nào bị đóng lại ở đây.
>
> **Phần không bị ảnh hưởng.** Mệnh đề dự phòng Tanzil.net trong dòng
> Transliteration, dấu đính chính Session 89, và mọi dòng nguồn khác
> trong bảng đều giữ nguyên. Session này không sửa `docs/LICENSING.md`,
> `privacy/index.md`, `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md`, hay
> bất kỳ Decision Record / ràng buộc pháp lý hiện hành nào — `PROJ-P-005`
> bao gồm.

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

**Đã vendor (Phase 3 Sprint R3a.1, 2026-08-03).** Quy tắc tương thích
phiên bản — xác nhận trực tiếp từ tác giả drift/sqlite3.dart
([github.com/simolus3/drift, thảo luận #3721](https://github.com/simolus3/drift/discussions/3721)):
tương thích XUÔI (file mới hơn dùng được với package cũ hơn) nhưng
KHÔNG tương thích NGƯỢC — `sqlite3.wasm` phiên bản x đòi hỏi
`package:sqlite3` PHẢI ≥ x. Do đó luôn ghim đúng version đang khoá
trong `pubspec.lock`, không lấy "latest".

| File | Nguồn (tag phát hành) | Khớp `pubspec.lock` | SHA-256 |
|---|---|---|---|
| `web/sqlite3.wasm` | [`sqlite3.dart` release `sqlite3-3.3.4`](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.3.4) — asset `sqlite3.wasm` (bản release, KHÔNG phải `sqlite3.debug.wasm`/`sqlite3mc.wasm`) | `sqlite3: 3.3.4` — khớp CHÍNH XÁC, không phải bản gần nhất | `cfab48c6bbb718552ec19bc4f1365e19185311b72e4739cc19ef7333758304d3` |
| `web/drift_worker.js` | [`drift` release `drift-2.34.0`](https://github.com/simolus3/drift/releases/tag/drift-2.34.0) — asset `drift_worker.js` | `drift: 2.34.0` — khớp CHÍNH XÁC | `b8b9f88cdfa0582eedacf3b55f6133b7d9bea7c8e74d4dc019a380da9976a7a8` |

**Khi nâng cấp `drift`/`sqlite3` sau này** (đã là mục "stop and ask
before" theo `CLAUDE.md`): tải lại đúng 2 file này từ tag phát hành
khớp version mới, cập nhật bảng trên trong CÙNG PR — đừng để version
Dart và version file WASM/JS lệch nhau lặng lẽ.

**Chưa xác nhận runtime thật** (Phase 3 Sprint R3a.1 chỉ vendor + build
kiểm tra tĩnh, KHÔNG mở app trong trình duyệt thật) — xem
`docs/release/PHASE3_SPRINT_R3A1_REPORT.md` mục "Remaining follow-up".
