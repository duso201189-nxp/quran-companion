# TODO — việc treo

Lộ trình: xem ROADMAP.md. Checklist phát hành: RELEASE_CHECKLIST.md.

## Quyết định / dữ liệu còn thiếu
- [ ] Tên tiếng Việt chuẩn cho 114 Surah (hiện dùng tên Latin trong
      data; thay qua bản data mới, không sửa code)
- [ ] Nguồn word-by-word tiếng Việt cho Bước 9 (lemmas/word_instances)

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
      Streak, Khatm %, Bookmark Collections (`DR-2026-0003`) —
      `study_sessions`/`khatm_cycles`/`bookmark_collections` +
      `bookmarks.collection_id`, schemaVersion 2->3 hoàn toàn
      additive, `ReadingScreen` ghi phiên đọc thật qua
      `StudySessionRepository.logSession` khi dispose. +61 test
      (270 -> 305 xuyên suốt 5 phase) — xem CHANGELOG.
- [ ] Ngưỡng "ngày đủ điều kiện tính streak" (hiện: bất kỳ phiên nào
      >=5 giây là đủ, khớp `StatsStore.addSeconds`) vs quy tắc gốc
      từng ghi ở DATABASE.md ("tổng study_sessions trong ngày phải
      >=5 phút HOẶC >=5 Ayah"). Quyết định Sprint 8: giữ >=5 giây làm
      NGƯỠNG GHI NHẬN (lọc nhiễu, khớp StatsStore) — chưa triển khai
      ngưỡng "ngày đủ điều kiện" gộp theo tổng thời lượng/Ayah trong
      ngày. Đây là quyết định sản phẩm (thế nào là một buổi đọc thật
      để tính streak) nên gắn với việc xây Daily Goal thật (hiện vẫn
      SharedPreferences) chứ không lẫn vào phần plumbing của Sprint
      8 — xem DATABASE.md mục Nhóm B để biết chi tiết ngưỡng gốc.
- [ ] Bước 8 phần còn lại (chưa làm trong Sprint 8): Daily Goal
      chuyển từ SharedPreferences sang UI/luồng thật, Revision Queue
      có màn hình riêng (hiện vẫn dùng `ayah_statuses.status='review'`
      có sẵn từ Bước 6, không có UI mới), "Journey" (tổng hợp dashboard
      Trang chủ) — CollectionItem tổng quát (domain contract cho các
      loại bộ sưu tập ngoài Ayah) cố ý chưa xây, xem DR-2026-0003.
- [ ] `docs/adr/DR-2026-0003-sprint8-data-architecture.md` chưa tồn
      tại trong repo — ADR này hiện chỉ có ở artifact Claude.ai, mọi
      chỗ trong docs (kể cả file này) trỏ tới "DR-2026-0003" đang trỏ
      vào chỗ trống trong repo. Cần lưu lại thành file thật trong
      `docs/adr/` để khớp quy ước của CLAUDE.md.
- [ ] Nâng MIN_COVERAGE trong ci.yml từ 70% dần về 80% (mục tiêu
      v1.0, ARCHITECTURE.md mục 9) khi Bước 7-9 landing kèm test đầy
      đủ — hạ tạm ở Bước 6 vì coverage thật ~74%, tránh CI đỏ thường
      trực trong lúc chưa viết thêm test
