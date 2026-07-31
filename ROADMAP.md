# Roadmap — Qur'an Companion

> **Tài liệu này là LỊCH SỬ, đóng băng tại Sprint 10.** Lộ trình hiện
> tại, đã đối chiếu trực tiếp với code hiện tại (không phải kế hoạch),
> nằm ở **[docs/release/PRODUCT_ROADMAP.md](docs/release/PRODUCT_ROADMAP.md)**
> — đọc file đó trước nếu bạn cần biết trạng thái THẬT của dự án hôm
> nay.
>
> **Vì sao đóng băng ở đây**: sau Sprint 10, dự án trải qua một đợt
> "khôi phục phát hành" (release recovery) — một mega-commit lớn
> (`d4976b0`) được tách lại thành 12 nhóm PR (P1–P4, F1–F8) và merge
> lần lượt, NGOÀI quy trình cập nhật ROADMAP/TODO/CHANGELOG bình
> thường. Kết quả: **phần lớn nội dung dự kiến cho v1.5 bên dưới —
> Từ vựng (Lexicon), Flashcard SM-2, Quiz, Phân tích học tập
> (Analytics), AI Tutor, Learning Journey, Smart Learning — ĐÃ ĐƯỢC
> XÂY VÀ MERGE**, dù bảng bên dưới (chưa từng cập nhật lại) vẫn hiện
> "—" (chưa làm). Xem
> [`docs/reports/release-recovery/README.md`](docs/reports/release-recovery/README.md)
> để biết toàn bộ câu chuyện, và `docs/release/PRODUCT_ROADMAP.md` để
> biết lộ trình thật từ đây trở đi.

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

## Cập nhật thật, ngoài phạm vi bảng trên (không sửa bảng — xem lý do ở đầu file)

Sau Sprint 10, các bước sau đã thực sự hoàn thành qua đợt "khôi phục
phát hành" (P1–P4/F1–F8, xem
[`docs/reports/release-recovery/`](docs/reports/release-recovery/)):

- **Bước 9 (Flashcard)**: đã xây đầy đủ (F2), cùng lớp Từ vựng/Lexicon
  làm nền (F1) — dữ liệu lemma/word_instances vẫn còn thiếu trong
  database đóng gói thật (xem `docs/architecture/DATABASE_REFERENCE.md`
  §1.1 — bảng có, dữ liệu rỗng), đây hiện là điểm chặn kỹ thuật ưu
  tiên cao nhất cho v1.0.
- **Thống kê/Analytics nâng cao** (F3), **AI Tutor** (F4, chỉ gợi ý
  dựa trên luật, KHÔNG gọi AI/LLM thật), **Learning Journey** (F5),
  **Smart Learning** (F6), **Read Model** (F7, chưa có UI), và việc
  hợp nhất Review/Quiz/Flashcard vào một luồng học duy nhất
  (**Learning Session**, F8) — tất cả đã merge, nằm ngoài phạm vi 12
  bước gốc bên trên vì được thiết kế/xây SAU khi bảng này viết.
- **Bước 10–12 (Auth, Sync, AI Companion thật)**: vẫn CHƯA làm — đây
  vẫn là ranh giới thật giữa v1.0/v1.5 hiện tại và v2.0. Xem
  `docs/release/PRODUCT_ROADMAP.md` mục v2.0.

Chi tiết đầy đủ, có trích dẫn code: `docs/architecture/MODULE_CATALOG.md`.
