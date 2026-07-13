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
- [ ] Bước 8: study_sessions ghi từ ReadingScreen (thời gian đọc) —
      nền cho Daily Goal + Streak (quy tắc ≥5 phút hoặc ≥5 Ayah)
- [ ] Nâng MIN_COVERAGE trong ci.yml từ 70% dần về 80% (mục tiêu
      v1.0, ARCHITECTURE.md mục 9) khi Bước 7-9 landing kèm test đầy
      đủ — hạ tạm ở Bước 6 vì coverage thật ~74%, tránh CI đỏ thường
      trực trong lúc chưa viết thêm test
