# Roadmap — Qur'an Companion

## Phase phát hành

| Phase | Nội dung | Trạng thái |
|---|---|---|
| v1.0 | Đọc + Audio + Chú thích + Tìm kiếm + Dashboard | Đang phát triển |
| v1.5 | Từ vựng, Flashcard SM-2, Quiz, Thống kê, Khatm, Auth, Sync | — |
| v2.0 | AI RAG đa provider, Hifz mode, Widget hệ điều hành | — |

## 12 bước v1.0 → v1.5

| # | Bước | Trạng thái |
|---|---|---|
| 1 | Project + Theme + Router + L10n + CI | ✅ v0.1.x |
| 2 | Database Drift + pipeline dữ liệu Qur'an | ✅ v0.2.1 |
| 3 | Danh sách 114 Surah | ✅ v0.3.0 |
| 4 | Trang đọc + Focus/Mushaf/gesture/vị trí | ✅ v0.4.5 |
| 5 | Audio (Qari, tốc độ, lặp, cache offline) | ✅ v0.5.0 — chờ xác nhận thiết bị |
| 6 | Bookmark + Highlight + Note + Trạng thái + User DB | 🔨 v0.6.0 — Sprint này |
| 7 | Tìm kiếm toàn văn (FTS5 đã build sẵn) | 🔨 Sprint 7.1 xong (nền tảng UI: màn hình, 4 trạng thái, điều hướng) — engine tìm kiếm thật (nối FTS5) là Sprint 7.2 |
| 8 | Dashboard: Journey, Daily Goal, Streak, Khatm %, Revision Queue, Collections | 🔨 Sprint 8 xong (Khatm %/Bookmark Collections, [DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md)) + Sprint 9 xong (Daily Goal, Revision Queue, Streak canonical, [DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md) — cả 3 quyết định đã triển khai đủ) — còn lại ngoài phạm vi 2 ADR: "Journey" (Trang chủ) chưa hiện tóm tắt Khatm (hiện chỉ ở tab Thống kê) |
| 9 | Flashcard SM-2 + Quiz + Thống kê + Nhật ký | 🔨 Sprint 10 xong (Learning Engine — Scheduler SM-2/Spaced Repetition review session + Quiz sinh động 4 loại câu hỏi, [DR-2026-0005](docs/adr/DR-2026-0005.md)) — Thống kê đã có từ Sprint 8; Flashcard hoãn lại có chủ đích (chưa có dữ liệu từ vựng lemma/word_instances, xem TODO.md); Hifz và "Nhật ký" chưa xây (ngoài phạm vi 6 quyết định Sprint 10 — Hifz chỉ nêu tên như nhánh tương lai của Learning Engine, "Nhật ký" chưa từng được định nghĩa cụ thể) |
| 10 | Authentication (Supabase) | v1.5 |
| 11 | Cloud Sync + Crashlytics | v1.5 |
| 12 | AI Companion (RAG) | v2.0 |
