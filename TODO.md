# TODO — việc treo

Lộ trình: xem ROADMAP.md. Checklist phát hành: RELEASE_CHECKLIST.md.

## Quyết định / dữ liệu còn thiếu
- [ ] Tên tiếng Việt chuẩn cho 114 Surah (hiện dùng tên Latin trong
      data; thay qua bản data mới, không sửa code)
- [ ] Nguồn word-by-word tiếng Việt cho Bước 9 (lemmas/word_instances)

## Kỹ thuật ngắn hạn
- [ ] Nối IoCacheManager vào AudioController (ưu tiên file offline
      trước khi stream) + UI quản lý cache trong Cài đặt
- [ ] Bước 7: màn hình tìm kiếm dùng FTS5 search_index (đã build
      trong data, gồm lớp bỏ dấu arabic_plain / vi_main_plain /
      translit_latin_plain)
- [ ] Bước 8: study_sessions ghi từ ReadingScreen (thời gian đọc) —
      nền cho Daily Goal + Streak (quy tắc ≥5 phút hoặc ≥5 Ayah)
- [ ] Nâng MIN_COVERAGE trong ci.yml từ 70% dần về 80% (mục tiêu
      v1.0, ARCHITECTURE.md mục 9) khi Bước 7-9 landing kèm test đầy
      đủ — hạ tạm ở Bước 6 vì coverage thật ~74%, tránh CI đỏ thường
      trực trong lúc chưa viết thêm test
