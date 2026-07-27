# TODO — việc treo

Lộ trình: xem ROADMAP.md. Checklist phát hành: RELEASE_CHECKLIST.md.

## Quyết định / dữ liệu còn thiếu
- [ ] Tên tiếng Việt chuẩn cho 114 Surah (hiện dùng tên Latin trong
      data; thay qua bản data mới, không sửa code)
- [ ] Nguồn word-by-word tiếng Việt cho Bước 9 (lemmas/word_instances)
      — vẫn là lý do Flashcard bị hoãn lại ở Sprint 10 (DR-2026-0005
      mục 4: "không thiết kế giải pháp tạm").

## Kỹ thuật ngắn hạn
- [ ] Nối IoCacheManager vào AudioController (ưu tiên file offline
      trước khi stream) + UI quản lý cache trong Cài đặt
- [x] Bước 7 / Sprint 7.1: nền tảng UI màn hình tìm kiếm (route
      `/search`, điểm vào, ô nhập, Mode/Scope, 4 trạng thái thân màn
      hình, điều hướng tới Ayah, bộ chuyển trạng thái dev, audit
      accessibility/dark-mode/responsive, +87 test) — xem CHANGELOG.
- [ ] Bước 7 / Sprint 7.2: nối engine tìm kiếm thật — gọi
      `QuranRepository.searchAyahs` (FTS5 `search_index`, đã build
      trong data, gồm lớp bỏ dấu arabic_plain / vi_main_plain /
      translit_latin_plain) vào `SearchResultSection`/`ResultCard`
      đã xây ở Sprint 7.1, thay bộ dữ liệu mẫu tĩnh của dev preview.
- [ ] Sprint 7.2: sửa danh sách `source_code` hardcode trong
      `quran_repository_impl.searchAyahs` (chỉ nhận
      `arabic_plain`/`vi_main_plain`/`translit_latin_plain`/`en_sahih`)
      thành đọc động từ `translation_sources` — nguồn dịch mới thêm
      sau này sẽ không bị bỏ sót khỏi kết quả tìm kiếm (phát hiện lúc
      review kiến trúc trước Sprint 7.1, xem `DR-2026-0002`).
- [ ] Sprint 7.3+: Recent Searches, Suggestions, Filters, Ask AI thật
      — khung UI đã có sẵn (Empty State 2 khu vực placeholder, nút
      Mode "Hỏi AI" đã khoá), chưa nối dữ liệu/logic thật.
- [x] Bước 8 / Sprint 8: schema + repository + provider + UI cho
      Streak, Khatm %, Bookmark Collections
      ([DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md)) —
      `study_sessions`/`khatm_cycles`/`bookmark_collections` +
      `bookmarks.collection_id`, schemaVersion 2->3 hoàn toàn
      additive, `ReadingScreen` ghi phiên đọc thật qua
      `StudySessionRepository.logSession` khi dispose. +61 test
      (270 -> 305 xuyên suốt 5 phase) — xem CHANGELOG.
- [x] Quyết định nguồn CANONICAL cho streak (StatsStore vs
      study_sessions) — ghi trong
      [DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md)
      mục 1: `study_sessions`/Drift là nguồn duy nhất, mọi màn hình.
- [x] **Triển khai xong ở Sprint 9 Phase 5**: `HomeScreen`
      (`_StatChipsRow`) và `StatsScreen` (lưới chỉ số) giờ đọc
      `currentStreakProvider`/`longestStreakProvider` (Drift), không
      còn `stats.currentStreak`/`longestStreak` (`StatsStore`) ở bất
      kỳ đâu trong `lib/` (xác nhận bằng grep toàn project). `StatsScreen`
      vẫn hiện streak ở 2 vị trí (lưới chỉ số + mục "Phiên đọc") —
      KHÔNG gộp lại (ngoài phạm vi Phase 5, chỉ đổi nguồn đọc) — nhưng
      giờ cả hai LUÔN khớp số vì cùng một nguồn. `StatsStore.currentStreak`/
      `longestStreak` (getter) không còn nơi nào gọi tới — dead code,
      chưa xoá (ngoài phạm vi được giao, không tự ý đổi StatsStore).
- [ ] Ngưỡng "ngày đủ điều kiện tính streak" gộp theo tổng thời
      lượng/Ayah trong ngày (>=5 phút HOẶC >=5 Ayah, ý tưởng gốc
      trước Sprint 8) — VẪN CHƯA triển khai. `DR-2026-0004` chỉ quyết
      định NGUỒN dữ liệu (Drift, xem mục trên), không đổi công thức
      ngưỡng; ngưỡng ghi nhận mỗi phiên (>=5 giây, khớp
      `StatsStore.addSeconds`) giữ nguyên từ Sprint 8. Công thức
      "ngày đủ điều kiện" vẫn là quyết định sản phẩm còn treo, gắn
      với thiết kế Daily Goal thật — xem DATABASE.md mục Nhóm B.
- [x] Bước 8 phần còn lại — **Sprint 9 (Phase 1-5) xong** cho Daily
      Goal, Revision Queue, và Journey/streak
      ([DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md)):
      `DailyGoalStore` (SharedPreferences, chỉ tiêu) +
      `dailyGoalProgressProvider` (dẫn xuất từ `todayStudySummaryProvider`,
      không có bảng `profiles` mới) + dialog đặt chỉ tiêu + thẻ trên
      Trang chủ; `LibraryKind.review` + `UserContentRepository.watchAllReviewAyahs()`
      + màn hình Revision Queue (tái dùng `LibraryTabView`/
      `LibraryAyahTile`, route `/revision-queue`) + nối từ tab Học;
      `HomeScreen`/`StatsScreen` đổi nguồn streak sang
      `currentStreakProvider`/`longestStreakProvider` (Drift). Cả 3
      quyết định của DR-2026-0004 đã triển khai đầy đủ. CollectionItem
      tổng quát vẫn cố ý chưa xây (ngoài phạm vi ADR).
- [x] 2 nơi tự lặp logic "lưu vị trí + mở trang đọc" thay vì gọi
      [openAyahInReadingScreen](lib/features/quran/presentation/reading/reading_navigation.dart)
      có sẵn (vi phạm hợp đồng điều hướng chung `DR-2026-0002` mục
      9) — **đã sửa ở Sprint 9 Phase 4**: `LibraryScreen._open` và
      `ActiveKhatmCard._continueReading` giờ gọi thẳng hàm dùng
      chung, hành vi không đổi (xác nhận: 305/305 test cũ vẫn qua).
- [x] **Sprint 10 (Phase 1-4) — Learning Engine
      ([DR-2026-0005](docs/adr/DR-2026-0005.md), 6 quyết định)**:
      Scheduler SM-2 (`srs_cards`, schemaVersion 3->4) + màn hình
      "Lặp lại ngắt quãng" (`/review-session`, đọc `dueReviewCardsProvider`,
      4 mức đánh giá Again/Hard/Good/Easy qua `SchedulerRepository.applyReview`)
      — Revision Queue (`ayah_statuses.status='review'`) giữ nguyên
      độc lập, Scheduler chỉ TIÊU THỤ làm nguồn thành viên, không thay
      thế (khác định hướng ban đầu ở `DR-2026-0003`). Quiz sinh động 4
      loại câu hỏi (Surah identification/Ayah continuation/Translation
      matching/Verse recognition, `QuestionGenerator` thuần Dart) +
      màn hình "Trắc nghiệm" (`/quiz-session`) + `quiz_results`
      (schemaVersion 4->5) — KHÔNG có Question Bank, câu hỏi sinh mỗi
      phiên từ nhóm A rồi bỏ đi. Flashcard hoãn lại có chủ đích (xem
      mục lemmas/word_instances phía trên); Hifz/"Nhật ký" chưa xây
      (ngoài phạm vi 6 quyết định). +70 test (305 -> 375) — xem
      CHANGELOG.
- [ ] `docs/adr/DR-2026-0002-*.md` (Search, Sprint 7.1) vẫn chưa tồn
      tại trong repo — cùng vấn đề `DR-2026-0003` từng gặp, PHÁT HIỆN
      LẠI lúc backfill DR-2026-0003 (Sprint 9 Phase 0). 6 chỗ trong
      `lib/` + CHANGELOG.md trỏ tới "DR-2026-0002" đang trỏ vào chỗ
      trống. Xem `docs/adr/README.md` mục "Known gap". Ngoài phạm vi
      Sprint 9 Phase 0 (chỉ backfill 0003 + tạo 0004) — cần một lượt
      backfill riêng.
- [x] `docs/adr/DR-2026-0005.md` (Sprint 10 — Learning Engine:
      Scheduler SM-2 + Quiz) — **tạo xong ở Sprint 10 Finalization**,
      cùng cách backfill đã làm cho `DR-2026-0003` ở Sprint 9 Phase 0.
      6 quyết định (kiến trúc Learning Engine, quan hệ Revision Queue
      ↔ Scheduler, trừu tượng SchedulingAlgorithm, kiến trúc Quiz,
      hoãn Flashcard, chiến lược test) ghi đầy đủ, khớp implementation
      đã triển khai ở Phase 1-4. Tên file KHÔNG có slug mô tả (khác
      quy ước `DR-2026-0003-*`/`DR-2026-0004-*`) — theo đúng yêu cầu
      tường minh lúc tạo file. `DATABASE.md`/`ROADMAP.md`/`CHANGELOG.md`
      đã cập nhật link Markdown trỏ đúng file thật.
- [ ] Nâng MIN_COVERAGE trong ci.yml từ 70% dần về 80% (mục tiêu
      v1.0, ARCHITECTURE.md mục 9) khi Bước 7-9 landing kèm test đầy
      đủ — hạ tạm ở Bước 6 vì coverage thật ~74%, tránh CI đỏ thường
      trực trong lúc chưa viết thêm test. Sprint 10 (Phase 1-4) đã
      thêm 70 test mới (305 -> 375) cho toàn bộ code mới — con số
      coverage% thật chưa đo lại (`flutter test --coverage` không nằm
      trong phạm vi Phase 5), chỉ xác nhận KHÔNG có code mới nào thiếu
      test (khác với Sprint 9, xem CHANGELOG).
