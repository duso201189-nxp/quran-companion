# Changelog

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).
Phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

## [Unreleased]

### Added — Sprint 7.1: Nền tảng UI Tìm kiếm (Bước 7 — xem "Chưa làm" bên dưới, chưa xong)
- Màn hình Tìm kiếm (`/search`) — route top-level push full-screen,
  cùng mẫu với "Thư viện của tôi" (không phải tab thứ 6). Điểm vào từ
  nút tìm kiếm trên Trang chủ và tab Qur'an.
- Ô nhập từ khoá thay tiêu đề AppBar (gợi ý placeholder, nút xoá khi
  có chữ); chuyển đổi Tìm kiếm / Hỏi AI ("Hỏi AI" hiển thị khoá sẵn —
  Sắp ra mắt); Scope Chips (Tất cả / Qur'an / Ghi chú của tôi) — Mode
  và Scope là hai trục độc lập hoàn toàn.
- Bốn trạng thái thân màn hình, mỗi trạng thái là một component dùng
  chung cho MỌI domain tương lai (Qur'an hôm nay; Hadith/Ghi chú/Trả
  lời AI sau này — xem ADR `DR-2026-0002`): `SearchEmptyState` (tiêu
  đề + gợi ý cách gõ + 2 khu vực placeholder cho Recent/Suggestions),
  `SearchLoadingSkeleton`, `SearchErrorState`, `ResultCard` +
  `SearchResultSection` (factory `.fromAyah`/`.ayahs` dùng lại đúng
  entity domain có sẵn, không bịa shape mới).
- Chạm một kết quả lưu vị trí đọc (dùng lại `ReadingPositionStore` có
  sẵn, không tạo cơ chế lưu trữ mới) và mở đúng Ayah trên trang đọc
  qua route top-level `/read/:id` — hàm dùng chung mới
  `openAyahInReadingScreen` (`reading_navigation.dart`), theo đúng
  cơ chế `LibraryScreen` đã dùng (không phải route lồng trong shell
  `/quran/surah/:id`, vốn gây xung đột Navigator khi push từ ngoài
  vỏ tab — phát hiện và sửa trong sprint này).
- Bộ chuyển trạng thái dành cho dev (biểu tượng bọ trên AppBar) để
  xem trước cả 4 trạng thái không cần gõ hay có dữ liệu thật — CHỈ
  tồn tại ở debug build (`kDebugMode`), xác nhận bằng build
  `--release` thật + kiểm tra bundle không còn dấu vết.
- ADR `DR-2026-0002` (9 quyết định kiến trúc cho Search, kèm đánh
  đổi/phương án đã loại/mở rộng tương lai) viết trước khi code.

### Đã kiểm tra toàn diện (không đổi giao diện hiện có)
- Accessibility: header semantics cho tiêu đề khu vực, vùng chạm
  ≥ 48dp, RTL (mirror layout + hướng chữ đúng theo nội dung), cỡ chữ
  200% không tràn, thứ tự đọc khớp thứ tự hiển thị.
- Dark mode: rà soát không còn màu hard-code trong tính năng Search;
  đo tương phản chữ tô đậm (WCAG) ở cả 2 theme — đều vượt ngưỡng.
- Responsive: 320–1300px (điện thoại hẹp đến desktop), không tràn
  layout kể cả khi kết hợp cỡ chữ 200%.

### Tests
- +87 test cho tính năng Search (widget + unit), gộp bộ helper/
  fixture dùng chung (`test/fixtures/search_test_harness.dart`) —
  tổng dự án 244 test, tất cả qua `dart format` /
  `flutter analyze --fatal-infos` / `flutter test`.

### Chưa làm (Sprint 7.2 trở đi — Bước 7 CHƯA hoàn tất)
- Search engine thật: chưa nối `QuranRepository.searchAyahs` (FTS5
  `search_index`) vào UI đã xây — kết quả hiện chỉ xem được qua bộ
  chuyển trạng thái dành cho dev với dữ liệu mẫu tĩnh.
- Recent Searches, Suggestions, Filters, Ask AI thật — khung UI đã có
  chỗ (2 khu vực placeholder trong Empty State, nút Mode "Hỏi AI" đã
  khoá) nhưng chưa nối dữ liệu/logic.
- Danh sách `source_code` hardcode trong
  `quran_repository_impl.searchAyahs` chưa sửa thành đọc động từ
  `translation_sources` (nợ kỹ thuật đã ghi nhận từ lúc review kiến
  trúc, xem TODO.md).

## [0.6.0] — Sprint 6: Chú thích người dùng + User Database

### Added
- UserDatabase (file riêng, Drift): bookmarks, highlights, notes,
  ayah_statuses — UUID client, soft delete, updated_at, is_dirty
  (Sync Ready), migration strategy + test schema.
- Bookmark 1 chạm (icon trên mỗi Ayah) — toggle hồi sinh cùng UUID.
- Highlight 6 màu, một Ayah nhiều màu, nền Ayah nhuộm màu đã chọn.
- Ghi chú Markdown cơ bản (**đậm**, *nghiêng* — parser thuần có
  test, cú pháp hỏng giữ nguyên văn), hiện dưới Ayah.
- Trạng thái học 4 mức: Chưa đọc / Đang học / Đã học / Cần ôn —
  chip hiển thị trên thẻ Ayah.
- Sheet thao tác Ayah (nhấn giữ): bookmark, 6 màu, trạng thái,
  ghi chú — realtime qua Stream repository.
- UserContentRepository interface (domain tách hoàn toàn khỏi Drift).

### Changed
- AyahCard: nền ưu tiên trạng thái đang phát audio > màu highlight.

### Tests
- +15 unit (repository UUID/soft-delete/watch/reactive + markdown)
  và +3 widget (bookmark 1 chạm, sheet nhấn giữ, ghi chú end-to-end)
  — tổng dự kiến ~100.

## [0.5.0] — Bước 5: Audio

### Added
- Trình phát Ayah: play/pause, Ayah trước/kế, tốc độ xoay vòng
  0.75–2.0x, lặp (1 Ayah / cả Surah / tắt), chọn Qari (5 Qari từ
  bảng reciters, lựa chọn lưu bền).
- AudioBar mini dính đáy trang đọc; nút "Nghe từ Ayah này" trên
  từng Ayah.
- Ayah đang phát: highlight nền nhẹ + màn hình TỰ CUỘN theo
  (ScrollablePositionedList, animate 350ms).
- Kiến trúc AyahAudioPlayer interface (just_audio impl + fake cho
  test — logic phát test được 100% không cần thiết bị).
- IoCacheManager: tải offline theo Qari, ghi file tạm chống hỏng,
  mất mạng giữ phần đã tải, xóa theo Qari / toàn bộ, đo dung lượng.
- docs/AUDIO.md (kiến trúc + cấu hình phát nền khi phát hành).
- 13 test mới (8 controller + 4 cache + 1 widget luồng đầy đủ)
  — tổng ~82 test.

## [0.4.5] — Trải nghiệm đọc nâng cao

### Added
- Focus Mode: ẩn AppBar + mọi bản dịch, thuần văn bản Qur'an với
  dấu kết Ayah ﴿n﴾; chạm một lần để thoát.
- Mushaf Mode: gom Ayah theo trang Mushaf Madani (cột page trong
  data), văn bản liền mạch căn justify, lật trang PHẢI-SANG-TRÁI
  như bản in, hiện số trang — hỗ trợ Hifz ghi nhớ vị trí.
- Gesture: pinch 2 ngón đổi cỡ chữ Ả Rập live (chỉ ghi đĩa khi
  nhấc tay); vuốt ngang đổi Surah (chế độ danh sách).
- Tự lưu vị trí đọc theo TỪNG Surah + Surah gần nhất
  (ScrollablePositionedList theo dõi Ayah đầu khung nhìn);
  mở lại app quay về đúng chỗ. Nền tảng cho auto-scroll theo
  audio ở Bước 5 và nút "Tiếp tục đọc" ở Bước 8.
- Chế độ đọc lưu bền qua các phiên.
- 15 test mới (unit mushaf/position/settings + widget focus/
  mushaf/khôi phục vị trí) — tổng ~69 test.

### Deferred (đúng thứ tự bước)
- Auto-scroll + highlight Ayah theo audio -> Bước 5.
- Double-tap bookmark, long-press highlight/note -> Bước 6.
- Reading statistics + Khatm -> Bước 6/8/9b.

## [0.4.0] — Bước 4: Trang đọc Qur'an

### Added
- ReadingScreen (/quran/surah/:id): chữ Ả Rập lớn RTL (line-height
  2.0, font Uthmani + fallback), 3 lớp văn bản bật/tắt
  (phiên âm / Việt / Anh), số Ayah, biểu tượng sajdah.
- Bottom sheet Hiển thị: slider cỡ chữ Ả Rập (22–45, áp dụng live,
  clamp an toàn), 3 công tắc lớp văn bản — mọi cài đặt lưu bền.
- Nội dung giới hạn 700px căn giữa trên màn rộng (typography đọc lâu).
- Danh sách Surah điều hướng thật vào trang đọc (bỏ SnackBar tạm).
- Deep link an toàn: id sai -> màn "Không tìm thấy" thay vì crash.
- Đủ loading / error (not-found riêng, lỗi khác có Thử lại) / empty.
- 12 test mới (4 unit cài đặt + 8 widget) — tổng ~54 test.

## [0.3.0] — Bước 3: Danh sách 114 Surah

### Added
- Màn hình danh sách Surah thật (thay placeholder): số thứ tự,
  tên Latin, tên Ả Rập (chuẩn bị font Uthmani, có fallback),
  số câu, nơi mặc khải.
- Tìm kiếm không phân biệt dấu (foldDiacritics — tiếng Việt +
  transliteration) theo tên Latin/Việt/Anh/Ả Rập/số Surah.
- Lọc Tất cả / Mecca / Madinah (SegmentedButton M3).
- Đủ 3 state: loading, error (kèm nút Thử lại hoạt động thật),
  empty khi tìm không thấy.
- Accessibility: Semantics đọc trọn thông tin mỗi Surah,
  widget test text scale 200% không vỡ layout.
- 9 chuỗi l10n mới × 3 ngôn ngữ; docs/FONTS.md.
- 16 test mới (9 unit lọc/bỏ dấu + 7 widget) — tổng ~42 test.

## [0.2.1] — Gia cố lớp dữ liệu theo tiêu chuẩn chất lượng

### Added
- ayahs: cột hizb, sajdah (tính từ Tanzil metadata) + 9 index phủ
  mọi trục truy vấn (surah, juz, hizb, page, sajdah, nguồn dịch,
  reciter).
- FTS: lớp bỏ dấu Latin (vi_main_plain, translit_latin_plain) —
  gõ không dấu vẫn tìm được.
- 5 Qari trong seed reciters (Alafasy, Abdul Basit, Minshawi,
  Husary, Sudais) — thêm Qari mới chỉ là thêm dòng dữ liệu.
- PERFORMANCE.md: phương pháp đo + bảng kết quả từng bước;
  CI tự in kích thước APK/Web bundle vào summary.
- ARCHITECTURE: thiết kế CacheManager (dung lượng/xóa/tải trước
  theo Qari), chuẩn Accessibility bắt buộc, thiết kế mã hóa
  client-side cho dữ liệu người dùng trước Cloud Sync.
- Test ánh xạ juz/hizb/page/sajdah.

## [0.2.0] — Bước 2: Lớp dữ liệu Qur'an

### Added
- Schema Drift nhóm A: surahs, ayahs, translation_sources (kèm
  metadata license/source_url/version/updated_at), translations,
  reciters, meta — tên bảng/cột khai báo tường minh.
- Kết nối database đa nền tảng: native (copy asset + isolate riêng),
  web (drift WASM + nạp asset), chọn lúc compile.
- Cơ chế cập nhật nội dung bằng data_version — thay file data
  không đụng dữ liệu người dùng.
- Domain layer: entities (Surah, Ayah, TranslationSource, AyahContent)
  + QuranRepository interface; data layer: QuranRepositoryImpl
  (join 1 truy vấn, tránh N+1).
- Pipeline tool/build_quran_db.py: Tanzil (Uthmani + translit +
  Sahih International) + QuranEnc (tiếng Việt, tự phát hiện key),
  kiểm tra toàn vẹn 6 lớp, FTS5 (kèm Arabic bỏ dấu), seed 2 Qari.
- CI: build + cache dữ liệu, chạy build_runner trước analyze/test.
- 11 test repository (in-memory database).

### Changed (thiết kế)
- Nhóm B chuyển sang khóa chính UUID sinh phía client — loại bỏ
  đụng độ id khi sync đa thiết bị (phát hiện qua review điểm 9).
- Thêm bảng `reciters` (audio nhiều Qari, URL theo mẫu) và
  FTS5 `search_index` (tìm kiếm toàn văn hiệu năng cao) vào nhóm A.
- Migration: nguyên tắc additive 2 phiên bản, tách file data
  Qur'an khỏi database người dùng.
- `srs_cards` tổng quát hóa (item_type: lemma|ayah) để dùng chung
  cho Từ vựng và Hifz — tránh migration về sau.
- Thêm bảng `khatm_cycles` (Khatm Tracker) và `hifz_plans` (Hifz)
  vào thiết kế nhóm B; triển khai ở Bước 9b/9c.

### Sắp tới (Bước 2)
- Database Drift + import dữ liệu Qur'an (114 Surah, 6.236 Ayah).

## [0.1.0] — Bước 1: Nền móng

### Added
- Khung project Flutter đa nền tảng (Android, iOS, Web, Desktop).
- Material Design 3, seed color #1B7A43, Light/Dark Mode
  (lưu và khôi phục lựa chọn).
- Điều hướng go_router + StatefulShellRoute 5 tab, giữ trạng thái
  từng tab; responsive 3 breakpoint (NavigationBar / Rail / Rail mở rộng).
- Localization ARB: Tiếng Việt (mặc định) · English · العربية (RTL);
  không còn chuỗi hard-code.
- Hệ thống môi trường Dev/Staging/Prod qua --dart-define-from-file;
  file env không commit.
- CI GitHub Actions: gitleaks secret scan, format check,
  analyze --fatal-infos, pub outdated, test, coverage gate ≥ 80%,
  build Android APK + Web + iOS no-codesign.
- Bộ lint nghiêm ngặt (analysis_options.yaml).
- 14 unit/widget test.
- Bộ tài liệu: README, ARCHITECTURE, DATABASE, CHANGELOG, TODO.
