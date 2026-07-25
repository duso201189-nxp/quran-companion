# Design system consolidation plan — Sprint 21.2

Chuyển [design_system_audit.md](design_system_audit.md) (Sprint 21.1)
thành kế hoạch thực thi kỹ thuật. Tài liệu này **KHÔNG chứa code**,
**KHÔNG có gì được refactor ở phase này** — thuần lập kế hoạch. Mọi
số liệu/trích dẫn kế thừa trực tiếp từ audit gốc; nếu 2 tài liệu lệch
nhau, đọc lại mã nguồn thật, đừng tin số liệu cũ mù quáng.

---

# Executive Summary

**Overall health**: Tốt, không có nợ kỹ thuật nghiêm trọng. Kỷ luật
kiến trúc CỐT LÕI (color token 100% qua `ColorScheme`, elevation gần
như không dùng — thiết kế phẳng nhất quán, domain thuần Dart tách khỏi
UI) đã đạt chuẩn production và KHÔNG cần sửa. Vấn đề DUY NHẤT là ở
**tầng trình bày**: cùng 1 hình dạng UI (thẻ, trạng thái rỗng/lỗi/
đang tải, tiêu đề phần) bị viết tay lại hàng chục lần thay vì tái sử
dụng — đúng dạng nợ kỹ thuật "dễ sửa, ít rủi ro" chứ không phải lỗi
kiến trúc sâu.

**Main risks**:
1. **Rủi ro lớn nhất KHÔNG phải kỹ thuật, mà là ĐỘ CHÍNH XÁC xác
   minh** — 1 số cặp "trông giống nhau" ĐàTỪNG được audit trước đó
   xác nhận là KHÔNG tương đương sau khi đọc kỹ (`_AccuracyMetricCard`
   có vòng tròn tiến độ, `TutorHeader`/`JourneyProgressCard`'s mục
   thống kê dùng bố cục Row khác `StatCard`'s Column — Sprint 20 Phase
   2). Gộp cưỡng ép mà không đọc trực tiếp từng cặp sẽ tạo ra hồi quy
   giao diện âm thầm.
2. **Rủi ro thiết kế treo lơ lửng** — mẫu "padding ngang responsive"
   (mục Spacing patterns của audit) hiện dùng ít nhất 3 tổ hợp số
   khác nhau (760/720 mặc định 16, 900/860 mặc định 16, 720/704 mặc
   định **8**) — gộp lại chắc chắn ĐỔI hành vi hiển thị ở vài màn
   hình, cần người có thẩm quyền thiết kế quyết định trước, không thể
   máy móc hoá.
3. **Rủi ro phạm vi lan** — 1 số thay đổi (thêm icon vào trạng thái
   lỗi hiện chỉ có chữ, đổi `titleMedium` sang đậm mặc định) là CẢI
   THIỆN giao diện, không đơn thuần "hợp nhất code không đổi gì" — cần
   phân biệt rõ 2 loại thay đổi này trong từng PR.

**Expected impact**: Ước tính giảm ròng **400-700 dòng code trùng
lặp** trên toàn bộ 4 Phase (chi tiết ước tính từng hạng mục ở
Consolidation Roadmap), tăng đáng kể diện phủ accessibility (mọi nơi
áp dụng `LoadingState`/`EmptyStateBanner`/`SearchErrorState` tự động
kế thừa `Semantics(liveRegion:)`/`Semantics(header:)` đã có sẵn),
KHÔNG có tính năng mới, KHÔNG đổi behavior nghiệp vụ.

---

# Consolidation Roadmap

Quy tắc chia Phase: **A = đã xác nhận tương đương, rủi ro gần 0** →
**B = tái dùng widget CÓ SẴN, rủi ro thấp** → **C = cần thêm 1 lượt
xác minh/quyết định thiết kế trước khi thực thi** → **D = ghi nhận,
không hành động ngay hoặc giá trị thấp**.

## Phase A — Rủi ro gần 0, đã xác nhận tương đương từng dòng

### A1. Card "hero" 4-file (TutorHeader/JourneyHeader/SmartLearningHeader/SessionSummaryCard)

- **Current implementations**: `tutor_header.dart:35-40`,
  `journey_header.dart:27-32`, `smart_learning_header.dart:24-29`,
  `session_summary_card.dart:34-39` — CÙNG
  `Container(padding: all(20), decoration: BoxDecoration(color:
  scheme.primaryContainer, borderRadius: circular(16)))` bọc
  Row(icon+title) rồi nội dung phụ.
- **Shared replacement**: `lib/shared/widgets/feature_hero_card.dart`
  (`FeatureHeroCard` — nhận `child`, giữ nguyên `padding(20)`/
  `primaryContainer`/`radius(16)`).
- **Migration difficulty**: Thấp — thay `Container(...)` bằng
  `FeatureHeroCard(child: ...)`, giữ nguyên nội dung con.
- **Risk**: Thấp — đã đọc trực tiếp cả 4 file, xác nhận decoration
  NGOÀI giống hệt; nội dung BÊN TRONG (Column/Row con) không đổi.
- **Estimated files affected**: 4 (sửa) + 1 (mới).
- **Testing requirements**: Chạy lại toàn bộ widget test hiện có của
  4 màn hình liên quan (AI Tutor, Learning Journey, Smart Learning,
  Learning Session) — KHÔNG cần test mới cho decoration (đã phủ qua
  test hiện có kiểm tra nội dung hiển thị); thêm 1 test nhỏ cho
  `FeatureHeroCard` xác nhận render đúng `child`.
- **Rollback strategy**: Đổi từng file độc lập trong 1 commit riêng
  mỗi file (hoặc 1 commit gộp cả 4, dễ `git revert` 1 lần) — KHÔNG
  xoá 4 class gốc cho tới khi `flutter test` xanh toàn bộ.
- **Expected code reduction**: ~4×6 dòng decoration lặp lại → 1 widget
  ~15 dòng — giảm ròng ước tính **~25-35 dòng**.
- **Priority**: Critical.

### A2. Card "điều hướng chéo tính năng" (_JourneyEntryCard / _SmartLearningEntryCard)

- **Current implementations**: `tutor_home_screen.dart:139-144`
  (`_JourneyEntryCard`) và `learning_journey_screen.dart:162-167`
  (`_SmartLearningEntryCard`) — GIỐNG HỆT:
  `Material(color: scheme.secondaryContainer.withValues(alpha:0.6),
  borderRadius: circular(16), child: InkWell(borderRadius:
  circular(16), onTap:))`.
- **Shared replacement**: `lib/shared/widgets/cross_feature_entry_card.dart`
  (`CrossFeatureEntryCard` — nhận `onTap`, `child`).
- **Migration difficulty**: Thấp.
- **Risk**: Thấp — 2 file, decoration NGOÀI xác nhận giống hệt qua
  đọc trực tiếp.
- **Estimated files affected**: 2 (sửa) + 1 (mới).
- **Testing requirements**: Test điều hướng hiện có của
  `tutor_home_screen_test.dart`/`learning_journey_screen_test.dart`
  (nếu có) phải xanh nguyên vẹn — đây là các test đã xác nhận tap
  đúng route, không đổi.
- **Rollback strategy**: `git revert` 1 commit.
- **Expected code reduction**: ~2×6 dòng → 1 widget ~12 dòng — giảm
  ròng ước tính **~10-15 dòng**.
- **Priority**: Critical.

### A3. Error state — 3 bản sao y hệt SearchErrorState

- **Current implementations**: `reading_screen.dart:1207-1249`
  (`_ReadingErrorState`), `surah_list_screen.dart:378-406`
  (`_ErrorState`), `library_tab_view.dart:93-122` (`_ErrorState`) —
  cấu trúc GIỐNG HỆT `search_error_state.dart:34-97`: Icon(56,
  color:error) + SizedBox(12) + Text + SizedBox(16) +
  `FilledButton.icon(refresh, retry)`.
- **Shared replacement**: `SearchErrorState` (đã tồn tại,
  `lib/features/search/presentation/widgets/search_error_state.dart`)
  — KHÔNG cần widget mới, chỉ thay điểm gọi.
- **Migration difficulty**: Thấp — với `reading_screen.dart`, cần giữ
  lại nhánh `notFound` (icon khác + KHÔNG hiện nút thử lại khi
  `notFound == true`) — `SearchErrorState` đã hỗ trợ `icon:` tuỳ
  chỉnh và `onRetry: null` để ẩn nút, nên vẫn khớp được, nhưng cần
  kiểm tra kỹ nhánh này khi migrate (không phải copy 1-1 đơn giản như
  2 file còn lại).
- **Risk**: Thấp cho `surah_list_screen.dart`/`library_tab_view.dart`
  (khớp 1-1). Thấp-Trung bình cho `reading_screen.dart` (có nhánh
  `notFound` cần verify).
- **Estimated files affected**: 3.
- **Testing requirements**: Test hiện có cho từng màn hình (nếu có
  test lỗi/retry) phải xanh; thêm test xác nhận `reading_screen.dart`'s
  nhánh "Surah không tồn tại" vẫn ẩn đúng nút thử lại sau khi đổi.
- **Rollback strategy**: 3 commit riêng (1/file) — dễ revert độc lập
  nếu 1 trong 3 phát sinh vấn đề mà 2 file kia thì không.
- **Expected code reduction**: 3 lớp ~35-45 dòng mỗi lớp → 3 lệnh gọi
  ~5 dòng mỗi lệnh — giảm ròng ước tính **~90-120 dòng**.
- **Priority**: Critical.

### A4. Button — `_GradeButton` trùng lặp

- **Current implementations**: `flashcard_review_screen.dart:200-228`
  và `review_session_screen.dart:203-231` — `FilledButton.tonal` với
  `backgroundColor: color.withValues(alpha:0.15)`,
  `foregroundColor: color`, `padding: symmetric(vertical:14)`, gọi 4
  lần cho Again/Hard/Good/Easy với `scheme.error/tertiary/primary/secondary`.
- **Shared replacement**: `lib/shared/widgets/grade_button.dart`
  (`GradeButton` — nhận `label`, `color`, `onPressed`).
- **Migration difficulty**: Thấp — tham số đã tách sẵn ở cả 2 bản gốc.
- **Risk**: Thấp nhất toàn kế hoạch — 2 điểm gọi, đã xác nhận gần như
  y hệt qua đọc trực tiếp.
- **Estimated files affected**: 2 (sửa) + 1 (mới).
- **Testing requirements**: Test review/grade hiện có (nếu có, kiểm
  tra tap đúng `ReviewGrade`) phải xanh nguyên vẹn.
- **Rollback strategy**: `git revert` 1 commit.
- **Expected code reduction**: 2×~28 dòng → 1 widget ~30 dòng + 2×~20
  dòng gọi lại — giảm ròng ước tính **~25-35 dòng**.
- **Priority**: Critical.

## Phase B — Tái dùng widget dùng chung CÓ SẴN, rủi ro thấp

### B1. Loading — áp dụng `LoadingState` rộng rãi

- **Current implementations**: ~21 lệnh gọi `CircularProgressIndicator()`
  trần rải khắp `reading_screen.dart`, `audio_bar.dart` (×2),
  `collections_screen.dart`, `assign_to_collection_sheet.dart`,
  `library_tab_view.dart`, `flashcard_decks_screen.dart`,
  `flashcard_browse_screen.dart`, `smart_deck_screen.dart` (×2),
  `flashcard_review_screen.dart`, `add_flashcard_screen.dart`,
  `quiz_session_screen.dart`, `review_session_screen.dart`,
  `move_to_deck_sheet.dart`, `surah_list_screen.dart` (×2),
  `reading_stats_section.dart` (×2, cỡ nhỏ 22×22),
  `active_khatm_card.dart` (cỡ nhỏ 22×22),
  `learning_session_screen.dart`.
- **Shared replacement**: `LoadingState` (đã tồn tại,
  `lib/shared/widgets/loading_state.dart`).
- **Migration difficulty**: Thấp cho đa số (thay trực tiếp, thêm 1
  khoá l10n `semanticsLabel` mới mỗi màn hình/phần — việc máy móc).
  Trung bình cho 2 biến thể "cỡ nhỏ 22×22" — cần xác nhận
  `LoadingState(height: 22)` không phá bố cục chật hẹp trước khi đổi.
- **Risk**: Thấp — đã kiểm chứng an toàn qua Sprint 20 Phase 2's
  Task 5 (home_screen.dart).
- **Estimated files affected**: ~15.
- **Testing requirements**: Widget test hiện có của từng màn hình
  phải xanh (đa số chỉ kiểm tra `find.byType(CircularProgressIndicator)`
  hoặc nội dung sau khi tải xong, không phụ thuộc chi tiết loading
  UI); thêm assertion `find.bySemanticsLabel(...)` cho vài màn hình
  tiêu biểu để chứng minh accessibility thật sự được thêm (theo mẫu
  `test/home_screen_test.dart` Sprint 20 Phase 2).
- **Rollback strategy**: Chia theo NHÓM TÍNH NĂNG (vd 1 PR cho
  Flashcards, 1 PR cho Library, 1 PR cho Reading) — mỗi PR revert độc
  lập nếu phát sinh vấn đề riêng nhóm đó, không phải revert toàn bộ
  21 điểm cùng lúc.
- **Expected code reduction**: Gần như trung lập về SỐ DÒNG (thay 1
  dòng bằng 1 dòng phần lớn) — giá trị chính là accessibility, không
  phải giảm dòng. Ước tính ròng: **gần 0, có thể +50 dòng** (thêm khoá
  l10n mới) chứ không giảm.
- **Priority**: High.

### B2. Empty state — áp dụng `EmptyStateBanner` cho nhóm "chỉ chữ"

- **Current implementations**: `flashcard_decks_screen.dart:32-42`,
  `smart_deck_screen.dart:76-83,126-133` (×2),
  `add_flashcard_screen.dart:125-135`, `collections_screen.dart:30-39`
  — Text căn giữa, `padding: all(24)`, KHÔNG icon, KHÔNG nền.
- **Shared replacement**: `EmptyStateBanner` (đã tồn tại,
  `lib/shared/widgets/empty_state_banner.dart`).
- **Migration difficulty**: Thấp về code, nhưng đây là **THAY ĐỔI
  GIAO DIỆN THẬT** (thêm icon + nền màu vốn hiện KHÔNG có) — không
  phải "chỉ hợp nhất code, giao diện y hệt". Cần xác nhận với người có
  thẩm quyền thiết kế TRƯỚC khi coi là "an toàn tự động".
- **Risk**: Thấp về mặt code, Trung bình về mặt "đổi giao diện ngoài ý
  định ban đầu của PR".
- **Estimated files affected**: 5.
- **Testing requirements**: Widget test xác nhận text rỗng vẫn hiển
  thị đúng nội dung (khớp `find.text(...)`); KHÔNG cần test hình ảnh
  mới trừ khi có golden test sẵn.
- **Rollback strategy**: 1 commit/file, dễ revert riêng lẻ.
- **Expected code reduction**: 5×~10 dòng ad hoc → 5×1 dòng gọi —
  giảm ròng ước tính **~40-50 dòng**.
- **Priority**: High.

### B3. Error state — áp dụng `SearchErrorState` cho nhóm rút gọn còn lại

- **Current implementations**: Nhóm "chỉ chữ" (8+ lệnh:
  `collections_screen.dart`, `flashcard_decks_screen.dart`,
  `flashcard_browse_screen.dart`, `smart_deck_screen.dart` ×2,
  `add_flashcard_screen.dart`, `assign_to_collection_sheet.dart`,
  `move_to_deck_sheet.dart`) + nhóm "chữ màu error" (5 lệnh:
  `flashcard_review_screen.dart`, `quiz_session_screen.dart`,
  `review_session_screen.dart`, `active_khatm_card.dart`,
  `reading_stats_section.dart`) + trường hợp icon-trần
  (`reading_stats_section.dart:98-101`, đã ghi nhận là điểm tệ nhất ở
  accessibility_audit.md).
- **Shared replacement**: `SearchErrorState(onRetry: ... hoặc null)`.
- **Migration difficulty**: Thấp về code. **THAY ĐỔI GIAO DIỆN THẬT**
  (thêm icon vào những nơi hiện chỉ có chữ) — cùng lưu ý như B2.
  Riêng `reading_stats_section.dart:98-101` (icon-trần, không chữ,
  không nút) là SỬA LỖI thật (đã xác nhận vi phạm accessibility), ưu
  tiên làm SỚM trong Phase B, không chờ phần còn lại.
- **Risk**: Thấp-Trung bình (đổi giao diện, không chỉ hợp nhất code).
- **Estimated files affected**: ~13.
- **Testing requirements**: Test hiện có cho từng luồng lỗi (nếu có)
  phải xanh; thêm test cho `reading_stats_section.dart`'s
  `_StreakCard` xác nhận lỗi giờ có `Semantics`/text/nút thử lại
  (đúng mẫu Sprint 20 Phase 2's `flashcard_tile_test.dart`).
- **Rollback strategy**: Theo nhóm tính năng, như B1.
- **Expected code reduction**: 13×~8 dòng ad hoc → 13×1 dòng gọi —
  giảm ròng ước tính **~80-100 dòng**.
- **Priority**: High (riêng mục icon-trần: **Critical** — đây là sửa
  lỗi accessibility đã biết, không phải thẩm mỹ).

### B4. Section — mở rộng `SectionHeader` (tham số màu) + áp dụng nốt phần tương đương còn lại

- **Current implementations**: 3 bản độc lập của "tiêu đề `titleSmall`
  + `scheme.primary` + đậm": `search_result_section.dart:82-85`,
  `surah_list_screen.dart:252-255` (bản gốc, tự nhận bị copy),
  `profile_screen.dart`'s `_SectionLabel` (144-161). Cộng 1 nơi
  tương đương `SectionHeader` chưa chuyển:
  `progress_dashboard_screen.dart:555-557` (tiêu đề `ExpansionTile`).
- **Shared replacement**: `SectionHeader` hiện có, thêm tham số tuỳ
  chọn `Color? color`.
- **Migration difficulty**: Thấp (mở rộng tham số, không đổi 10 lệnh
  gọi `SectionHeader` hiện tại) — riêng `ExpansionTile.title` cần
  kiểm tra `Semantics(header:true)` có tương thích với ngữ cảnh
  `ExpansionTile` không (chưa xác minh trong audit gốc).
- **Risk**: Thấp.
- **Estimated files affected**: 4 (3 hợp nhất + 1 chuyển đổi) + 1
  (sửa `SectionHeader`).
- **Testing requirements**: `test/shared_widgets_a11y_test.dart` (đã
  có từ Sprint 20 Phase 2) cần thêm case cho tham số `color` mới; test
  hiện có của 4 màn hình liên quan phải xanh.
- **Rollback strategy**: `git revert` 1 commit riêng cho phần mở rộng
  `SectionHeader`, tách khỏi commit áp dụng ở 4 điểm gọi.
- **Expected code reduction**: 3×~10 dòng ad hoc → 3×1 dòng gọi — giảm
  ròng ước tính **~25-30 dòng**.
- **Priority**: High.

## Phase C — Cần thêm 1 lượt xác minh/quyết định thiết kế trước khi thực thi

### C1. Card patterns — mở rộng Archetype A/B (phần còn lại, ~28 điểm)

- **Current implementations**: Toàn bộ danh sách còn lại ở
  `design_system_audit.md` mục 2 (Archetype A: `active_khatm_card.dart`,
  `stats_screen.dart` ×3, `reading_stats_section.dart` ×2,
  `progress_dashboard_screen.dart` ×2, `goal_card.dart`,
  `achievement_card.dart`, `tutor_suggestion_card.dart`,
  `recommendation_card.dart`, `journey_progress_card.dart`,
  `learning_summary_screen.dart` ×2; Archetype B:
  `home_screen.dart` ×2, `result_card.dart`, `surah_list_screen.dart`'s
  `SurahTile`, `study_screen.dart`, `quiz_session_screen.dart`,
  `library_ayah_tile.dart`).
- **Shared replacement**: `SurfaceCard` (khuôn A) /
  `TappableSurfaceCard` (khuôn B) — CHƯA tồn tại, cần thiết kế.
- **Migration difficulty**: Cao — mỗi điểm cần đọc trực tiếp, so khớp
  TỪNG DÒNG với ứng viên gộp trước khi quyết định (đúng kỷ luật đã áp
  dụng cho `StatCard` ở Sprint 20 Phase 2, nơi 1/4 ứng viên được gộp,
  3/4 bị từ chối sau khi đọc kỹ). KHÔNG giả định "trông giống là gộp
  được".
- **Risk**: Trung bình — rủi ro chính là gộp cưỡng ép làm mất tinh
  chỉnh có chủ đích (padding 148 cố định ở `AchievementCard`, width
  132 cố định ở `JourneyProgressCard`'s mục con — LƯU Ý: mục con của
  `JourneyProgressCard` đã bị loại khỏi `StatCard` ở Sprint 20, KHÔNG
  nằm trong phạm vi C1 này; C1 chỉ nói tới khung `Container` NGOÀI
  của chính `JourneyProgressCard`).
- **Estimated files affected**: ~20-28 (tuỳ số lượng thực sự tương
  đương sau khi xác minh — CON SỐ NÀY SẼ GIẢM sau bước xác minh, đúng
  như `StatCard` chỉ gộp được 1/4 ứng viên ban đầu).
- **Testing requirements**: Test hồi quy toàn diện cho MỖI file trước
  khi gộp (chụp lại `find.byType`/`find.text` hiện có làm baseline) —
  khối lượng lớn nhất trong toàn kế hoạch.
- **Rollback strategy**: KHÔNG làm 1 PR lớn — chia thành nhiều PR nhỏ
  theo TỪNG NHÓM đã xác nhận tương đương (vd tất cả file dùng đúng
  `padding:14 + surfaceContainerLow + radius:16` là 1 PR, nhóm
  `padding:20 + primaryContainer` là 1 PR khác) để rollback từng nhóm
  độc lập.
- **Expected code reduction**: Lớn nhất toàn kế hoạch nếu thực thi đầy
  đủ — ước tính **~200-350 dòng** (dè dặt, vì số điểm THỰC SỰ gộp được
  sẽ ít hơn danh sách ban đầu sau khi xác minh).
- **Priority**: Medium (giá trị cao nhưng khối lượng xác minh lớn —
  không nên bắt đầu trước khi Phase A/B hoàn tất và ổn định).

### C2. Empty state — widget "rỗng đầy đủ" mới

- **Current implementations**: `surah_list_screen.dart:408-434`
  (`_EmptyState`), `library_tab_view.dart:68-91` (`_EmptyState`, GẦN
  NHƯ Y HỆT bản trên), `flashcard_browse_screen.dart:325-369`
  (`_NoFlashcardsEmptyState`, có thêm CTA — biến thể lớn hơn).
- **Shared replacement**: `FullEmptyState` (widget MỚI, chưa tồn tại)
  — Icon(56) + SizedBox(12) + Text, căn giữa, `padding: all(24)`,
  KHÔNG nền màu (khác `EmptyStateBanner`'s dải ngang có nền).
- **Migration difficulty**: Trung bình — cần xác nhận
  `surah_list_screen._EmptyState` và `library_tab_view._EmptyState`
  THỰC SỰ giống hệt (audit gốc ghi "gần như y hệt", CHƯA khẳng định
  100%) trước khi gộp 2 file này; `_NoFlashcardsEmptyState` có thêm
  nút CTA — cần quyết định đưa CTA vào widget dùng chung (tham số tuỳ
  chọn) hay giữ riêng.
- **Risk**: Trung bình.
- **Estimated files affected**: 2-3 + 1 (mới).
- **Testing requirements**: So sánh trực tiếp 2 file trước khi gộp
  (đọc lại, không suy đoán); widget test cho `FullEmptyState` mới.
- **Rollback strategy**: `git revert` theo widget mới trước, giữ 2
  class cũ cho tới khi xác nhận ổn định.
- **Expected code reduction**: ~2×20 dòng → 1 widget ~25 dòng + 2×2
  dòng gọi — giảm ròng ước tính **~30-40 dòng**.
- **Priority**: Medium.

### C3. List item — `NamedEntityTile` (Deck/Collection)

- **Current implementations**: `flashcard_decks_screen.dart:79-101`
  (`_DeckTile`), `collections_screen.dart:85-107` (`_CollectionTile`)
  — `ListTile(leading: CircleAvatar(...), title: Text(name), subtitle:
  Text(số lượng), trailing: PopupMenuButton(rename/delete))`.
- **Shared replacement**: `lib/shared/widgets/named_entity_tile.dart`.
- **Migration difficulty**: Trung bình — action enum khác nhau
  (`_DeckAction` vs `_CollectionAction`) cần trừu tượng hoá qua
  callback thay vì enum cụ thể.
- **Risk**: Thấp-Trung bình.
- **Estimated files affected**: 2 + 1 (mới).
- **Testing requirements**: Test hiện có cho rename/delete ở cả 2 màn
  hình phải xanh nguyên vẹn.
- **Rollback strategy**: `git revert` 1 commit.
- **Expected code reduction**: 2×~23 dòng → 1 widget ~30 dòng + 2×~10
  dòng gọi — giảm ròng ước tính **~15-25 dòng**.
- **Priority**: Medium.

### C4. Animation — `AnimatedBarChart`/`ChartBar`

- **Current implementations**: `progress_dashboard_screen.dart:458-469`
  (biểu đồ lịch sử, 300ms) và `stats_screen.dart:264-276` (biểu đồ
  tuần, 300ms) — CÙNG công thức `height: max==0?4:4+K*(value/max)`,
  CÙNG `borderRadius: circular(6)`.
- **Shared replacement**: `lib/shared/widgets/animated_chart_bar.dart`.
- **Migration difficulty**: Trung bình — audit gốc CHƯA xác nhận hằng
  số `K` (76 ở Analytics) có khớp giá trị dùng ở `stats_screen.dart`
  — BẮT BUỘC đối chiếu số trước khi gộp.
- **Risk**: Trung bình (phụ thuộc kết quả đối chiếu `K`).
- **Estimated files affected**: 2 + 1 (mới).
- **Testing requirements**: Test hiện có cho 2 biểu đồ (nếu có, kiểm
  tra render đúng số cột) phải xanh; xác nhận bằng mắt (không có test
  ảnh) chiều cao cột không đổi trước/sau.
- **Rollback strategy**: `git revert` 1 commit.
- **Expected code reduction**: 2×~15 dòng → 1 widget ~20 dòng + 2×~5
  dòng gọi — giảm ròng ước tính **~10-15 dòng**.
- **Priority**: Medium.

### C5. Spacing — helper "padding ngang responsive"

- **Current implementations**: ≥7 điểm với ÍT NHẤT 3 tổ hợp
  (breakpoint, max-width, mặc định) khác nhau: `home_screen.dart`
  (760/720/16), `progress_dashboard_screen.dart`/`study_screen.dart`
  (900/860/16), `library_tab_view.dart` (720/704/**8**) — và các điểm
  khác chưa đối chiếu số chính xác trong audit gốc
  (`tutor_home_screen.dart`, `learning_journey_screen.dart`,
  `smart_learning_screen.dart`).
- **Shared replacement**: `lib/shared/layout/responsive_content_width.dart`.
- **Migration difficulty**: Cao — KHÔNG PHẢI vấn đề code, mà là
  **CẦN QUYẾT ĐỊNH THIẾT KẾ TRƯỚC** (chọn 1 breakpoint/max-width/mặc
  định chuẩn, hoặc xác nhận sự khác biệt hiện tại LÀ có chủ đích và
  giữ nguyên qua tham số).
- **Risk**: Trung bình-Cao — ĐÂY LÀ HẠNG MỤC DUY NHẤT trong toàn kế
  hoạch nơi "gộp lại" CHẮC CHẮN đổi hành vi hiển thị ở ít nhất 1 màn
  hình (`library_tab_view.dart`'s mặc định 8 sẽ thành khác nếu áp
  chuẩn chung).
- **Estimated files affected**: ~7+.
- **Testing requirements**: Kiểm tra bằng mắt (không có golden test)
  ở NHIỀU kích thước màn hình cho mỗi file trước/sau — khuyến nghị
  dùng `resize_window`/responsive preview trong quá trình migrate.
- **Rollback strategy**: KHÔNG gộp trong 1 PR — làm TỪNG FILE, mỗi
  file xác nhận riêng giá trị breakpoint có nên đổi hay giữ qua tham
  số override.
- **Expected code reduction**: Nhỏ về dòng code (mỗi điểm chỉ ~3-4
  dòng) — giá trị chính là NHẤT QUÁN HÀNH VI, không phải giảm dòng.
- **Priority**: High cho việc RA QUYẾT ĐỊNH (bất nhất nhìn thấy được),
  Medium cho việc THỰC THI (chờ quyết định).

### C6. Border radius — đặt tên hằng số

- **Current implementations**: Bảng tần suất ở
  `design_system_audit.md` mục 12 — giá trị ĐÃ nhất quán cao (16 là
  giá trị phổ biến nhất, 999 cho pill nhất quán tuyệt đối), NGOẠI TRỪ
  cặp 20 vs 24 dùng thay thế nhau cho vai trò "thẻ hero".
- **Shared replacement**: Hằng số trong `AppTheme` (`radiusChart`,
  `radiusCompact`, `radiusTappable`, `radiusCard`, `radiusHero`,
  `radiusPill`).
- **Migration difficulty**: Thấp (đặt tên, không đổi giá trị) NGOẠI
  TRỪ quyết định 20 vs 24 (cần chọn 1).
- **Risk**: Thấp (đặt tên) / Thấp (thống nhất 20↔24, phạm vi nhỏ — chỉ
  2-3 điểm).
- **Estimated files affected**: Tất cả file dùng `BorderRadius.circular(...)`
  MỘT KHI làm cùng đợt với C1 (khuyến nghị không làm riêng lẻ).
- **Testing requirements**: Không cần test riêng (đổi giá trị literal
  thành hằng số cùng giá trị không đổi hành vi) — trừ điểm 20↔24 cần
  xác nhận bằng mắt.
- **Rollback strategy**: Gộp chung rollback với C1 (làm cùng lúc).
- **Expected code reduction**: Không đáng kể về dòng — giá trị là khả
  năng BẢO TRÌ (đổi 1 hằng số thay vì sửa N file).
- **Priority**: Medium (tốt nhất làm cùng C1, không đứng riêng).

## Phase D — Ghi nhận, không hành động ngay hoặc giá trị thấp

### D1. Typography — tiêu đề đậm thành theme-level

- **Current implementations**: ~25+ điểm `textTheme.titleSmall/titleMedium
  ?.copyWith(fontWeight: FontWeight.w700)`.
- **Shared replacement**: Getter `TextStyle` được đặt tên trong
  `AppTheme` (KHÔNG sửa `ThemeData.textTheme` trực tiếp — xem lý do
  rủi ro dưới).
- **Migration difficulty**: Cao — `titleMedium`/`titleSmall` CŨNG
  được dùng KHÔNG đậm ở nhiều dialog/sheet
  (`assign_to_collection_sheet.dart:40-43`,
  `move_to_deck_sheet.dart:46-48`, `ayah_actions_sheet.dart:59`,
  `add_flashcard_screen.dart:163`) — sửa `ThemeData` trực tiếp sẽ đổi
  giao diện những nơi này NGOÀI Ý MUỐN.
- **Risk**: Trung bình-Cao nếu sửa `ThemeData`; Thấp nếu chỉ thêm
  getter mới (không đổi cách dùng `titleMedium`/`titleSmall` hiện có).
- **Estimated files affected**: ~25 (nếu áp dụng đầy đủ — KHÔNG khuyến
  nghị làm hết trong 1 đợt).
- **Testing requirements**: Golden test hoặc so sánh bằng mắt ở MỌI
  màn hình có `titleMedium`/`titleSmall` KHÔNG đậm, đảm bảo không bị
  đổi ngoài ý muốn.
- **Rollback strategy**: Chỉ thêm getter mới trước (không xâm lấn) —
  áp dụng dần dần ở PR sau, không đổi hàng loạt.
- **Expected code reduction**: ~25×1 dòng `.copyWith(...)` bớt đi —
  giảm ròng ước tính **~25-30 dòng**, giá trị chính là NHẤT QUÁN, không
  phải số dòng.
- **Priority**: Medium.

### D2. Typography — thang cỡ chữ Qur'an theo ngữ cảnh

- **Current implementations**: `quranTextStyle(fontSize: N)` với N ∈
  {20,22,24,26,28,30} tuỳ màn hình, không theo quy tắc rõ ràng.
- **Shared replacement**: Hằng số `QuranTextScale.secondary/compact/hero`
  cạnh `quranBaseFontSize()` hiện có.
- **Migration difficulty**: Trung bình — cần quyết định MỖI ngữ cảnh
  (tìm kiếm/ôn tập/quiz/trang chủ/đọc chính) nên dùng cỡ nào, không
  chỉ đặt tên số hiện tại.
- **Risk**: Thấp (không bắt buộc đổi số hiện tại ngay, chỉ đặt tên).
- **Estimated files affected**: ~10.
- **Testing requirements**: Không bắt buộc nếu chỉ đặt tên giữ nguyên
  giá trị.
- **Rollback strategy**: N/A (thêm hằng số, không đổi hành vi).
- **Expected code reduction**: Không đáng kể — giá trị là khả năng bảo
  trì/nhất quán tương lai.
- **Priority**: Low.

### D3. Color token usage — không hành động

- Đã đạt chuẩn (xem audit gốc mục 11) — DUY NHẤT nên làm: ghi chú rõ
  4 ngoại lệ (`kHighlightColorValues`, `Colors.transparent`,
  `Colors.black` bóng đổ, `Colors.white` icon tick) là CÓ CHỦ Ý, tránh
  bị hiểu nhầm là vi phạm ở lần review sau.
- **Priority**: Low.

### D4. Elevation usage — không hành động

- Đã đạt chuẩn (xem audit gốc mục 13). Ghi chú: `cardTheme.elevation`
  trong `app_theme.dart` hiện là cấu hình CHẾT (không widget nào dùng
  `Card(...)`) — GIỮ LẠI, không xoá, vì Phase C1's `SurfaceCard`/
  `TappableSurfaceCard` (nếu dựng) nên ĐỌC giá trị từ `cardTheme` thay
  vì lặp lại số — biến cấu hình chết thành sống.
- **Priority**: Low.

### D5. Animation duration — hằng số dùng chung

- Các giá trị 120/250/300/350/700ms rải rác, không đặt tên.
- **Shared replacement**: `AppDurations.fast/medium/slow` (gợi ý, CHƯA
  cấp thiết).
- **Priority**: Low.

---

# Merge Rules

## Khi nào MỚI ĐƯỢC gộp (MAY be merged)

1. **Chỉ gộp sau khi đọc TOÀN VĂN cả 2 (hoặc nhiều) file, không suy
   đoán từ tên biến/tên class/ảnh chụp màn hình.** Bằng chứng: mọi
   quyết định gộp ĐÚNG trong lịch sử dự án này (`StatCard` gộp
   `_MetricCard(accented:false)` với `TutorInsightCard` — Sprint 20
   Phase 2) đều dựa trên so khớp TỪNG DÒNG cây widget, không dựa trên
   "trông có vẻ giống".
2. **Cây widget bên NGOÀI (decoration/layout container) phải giống hệt
   hoặc khác biệt CHỈ Ở 1 tham số có thể tham số hoá đơn giản** (vd 1
   `bool accented` đổi 2 màu — như `StatCard` đã làm). KHÔNG gộp nếu
   cần > 2-3 tham số điều kiện để tái tạo mọi biến thể — dấu hiệu đây
   là 2 khái niệm khác nhau bị ép chung.
3. **Ngữ nghĩa Semantics/accessibility phải bảo toàn được** — nếu 1
   bản có `Semantics(label:)`/`ExcludeSemantics`/`Tooltip` mà bản kia
   không có, widget dùng chung PHẢI giữ mức accessibility CAO NHẤT
   trong số các bản gốc, không phải mức thấp nhất.
4. **API công khai (constructor) của widget dùng chung không được ép
   nơi gọi truyền tham số KHÔNG dùng tới** — nếu 1 nơi gọi không bao
   giờ cần `onTap`, đừng bắt nó truyền `onTap: null` chỉ vì nơi khác
   cần — cân nhắc 2 widget riêng (như `SurfaceCard` tĩnh vs
   `TappableSurfaceCard` chạm được) thay vì 1 widget với tham số thừa.
5. **Ưu tiên MỞ RỘNG tham số cho widget dùng chung sẵn có hơn tạo
   widget mới**, nếu hình dạng lõi giống hệt và chỉ thiếu 1 biến thể
   nhỏ (bằng chứng: `SectionHeader` nên thêm `color:` thay vì tạo
   `ColoredSectionHeader` riêng — mục B4).

## Khi nào TUYỆT ĐỐI KHÔNG được gộp (MUST NOT be merged)

1. **Không gộp nếu 1 bản có PHẦN TỬ HÌNH ẢNH mà bản kia không có**
   (vòng tròn tiến độ, biểu đồ, ảnh) — dù phần còn lại giống hệt.
   Bằng chứng: `_AccuracyMetricCard` (có `CircularProgressIndicator`
   dạng vòng) bị TỪ CHỐI gộp vào `StatCard` dù cùng thuộc họ "thẻ chỉ
   số" — Sprint 20 Phase 2.
2. **Không gộp nếu BỐ CỤC gốc khác nhau thật (Row vs Column, chiều
   rộng CỐ ĐỊNH vs co giãn)** — dù nội dung hiển thị giống nhau. Bằng
   chứng: `TutorHeader`'s mục thống kê (Row icon-cạnh-text, lồng
   trong Row chia đều) và `JourneyProgressCard`'s mục thống kê (Row
   icon-cạnh-text, width cố định 132, lồng trong Wrap) đều bị từ chối
   gộp vào `StatCard` (Column icon-trên-text) — Sprint 20 Phase 2.
3. **Không gộp 2 widget chỉ vì cùng "loại vai trò" (vd "đều là thẻ",
   "đều là tiêu đề") nếu KHÔNG cùng công thức padding/màu/bo góc cụ
   thể** — "loại vai trò" không phải tiêu chí gộp, CÔNG THỨC THỊ GIÁC
   THỰC TẾ mới là tiêu chí.
4. **Không gộp nếu việc gộp yêu cầu SỬA `ThemeData` toàn cục theo cách
   ảnh hưởng tới những nơi KHÔNG nằm trong phạm vi gộp** — bằng chứng:
   D1 (tiêu đề đậm) cố ý KHÔNG sửa `ThemeData.textTheme` trực tiếp vì
   sẽ đổi giao diện các dialog dùng `titleMedium` không đậm ngoài
   phạm vi.
5. **Không gộp mẫu bố cục có SỐ KHÁC NHAU THẬT giữa các nơi (breakpoint,
   max-width, mặc định) mà chưa có quyết định thiết kế rõ ràng chọn 1
   chuẩn** — bằng chứng: C5 (padding ngang responsive) có 3 tổ hợp số
   khác nhau, gộp mù quáng sẽ đổi hành vi hiển thị thật.
6. **Không xoá lớp/file gốc trong CÙNG commit với việc tạo widget dùng
   chung** — luôn giữ 2 phiên bản tồn tại song song ít nhất 1 chu kỳ
   test xanh trước khi dọn dẹp, cho phép rollback từng phần.

---

# Design System Principles

Nguyên tắc dài hạn cho người/AI đóng góp vào UI của dự án này —
KHÔNG áp dụng riêng cho kế hoạch Sprint 21.2, mà cho MỌI thay đổi UI
tương lai:

1. **Đọc trước, đoán sau.** Không bao giờ giả định 2 đoạn UI "trông
   giống" là tương đương — luôn đọc toàn văn cả 2 trước khi kết luận.
   Đây là kỷ luật đã chứng minh hiệu quả xuyên suốt Sprint 20-21 (audit
   → xác minh → gộp có chọn lọc, không gộp mù quáng).
2. **Màu LUÔN qua `Theme.of(context).colorScheme`, không bao giờ
   hard-code**, trừ khi màu đó về bản chất KHÔNG phụ thuộc theme (bảng
   màu cố định như `kHighlightColorValues`, `Colors.transparent`,
   bóng đổ đen tiêu chuẩn). Đây là điểm mạnh kiến trúc hiện tại — bảo
   vệ nó, không nới lỏng.
3. **Không dùng `elevation`/`Card` mặc định để tạo chiều sâu — dùng
   đối lập màu nền (surfaceContainerLow/primaryContainer/...) theo
   đúng ngôn ngữ thiết kế phẳng/tonal Material 3 đã thiết lập.** Nếu
   1 widget mới cần "nổi lên", tham khảo cách các thẻ hiện có làm
   (đối lập nền), không thêm `elevation: N` tuỳ ý.
4. **Widget dùng chung mới PHẢI giữ hoặc NÂNG accessibility, không bao
   giờ hạ thấp** — nếu 1 trong các bản gốc bị gộp có
   `Semantics`/`Tooltip`/`liveRegion`, widget dùng chung phải có ĐỦ
   những gì tốt nhất trong số đó (đúng cách `EmptyStateBanner` được
   nâng cấp thêm `liveRegion` khi consolidation ở Sprint 20 Phase 2,
   không phải hạ `LoadingState`/`SearchErrorState` xuống mức thấp
   hơn).
5. **Ưu tiên composition (tham số hoá 1-2 trục biến thiên rõ ràng,
   như `StatCard.accented`) hơn kế thừa hoặc tạo nhiều widget gần
   giống nhau.** NHƯNG nếu số trục biến thiên cần > 2-3, đó là dấu
   hiệu nên tách 2 widget riêng thay vì 1 widget với quá nhiều
   tham số điều kiện — xem Merge Rules mục "KHÔNG được gộp" #3.
6. **Mọi chuỗi hiển thị người dùng (kể cả `Semantics.label`) phải qua
   `l10n`, không hard-code** — kể cả trong widget dùng chung mới,
   nhận chuỗi qua tham số (như `LoadingState.semanticsLabel`,
   `EmptyStateBanner.text`) thay vì tự đọc `AppLocalizations` bên
   trong, giữ widget thuần trình bày.
7. **Tài liệu hoá LÝ DO KHÔNG gộp, không chỉ lý do gộp.** Mỗi lần 1
   ứng viên "trông giống" bị từ chối gộp, ghi rõ NGAY TẠI CHỖ (doc
   comment) vì sao — tránh người sau đọc code rồi lại thử gộp lần
   nữa mà không biết đã có người cân nhắc và từ chối có lý do.
8. **Mọi widget dùng chung mới đi kèm test trong CÙNG thay đổi** — tối
   thiểu: render đúng nội dung, giữ đúng ngữ nghĩa Semantics đã có ở
   bản gốc. Không gộp "để sau mới viết test".
9. **Không gộp các mẫu có số liệu (breakpoint/kích thước/thời lượng
   animation) khác nhau THẬT giữa các nơi mà chưa có quyết định thiết
   kế rõ ràng** — số liệu khác nhau CÓ THỂ là chủ đích, không phải
   luôn luôn là lỗi copy-paste; xác minh trước khi thống nhất.
10. **Thay đổi hợp nhất KHÔNG được đi kèm thay đổi hành vi nghiệp vụ
    trong CÙNG 1 thay đổi** — nếu 1 lần gộp "tiện thể" sửa luôn 1 vấn
    đề khác (thêm tính năng, đổi logic), tách thành 2 thay đổi riêng.

---

# AI Decision Checklist

Trước khi tạo BẤT KỲ widget mới nào (dùng chung hay riêng), AI phải tự
trả lời đủ 10 câu dưới đây — KHÔNG bỏ qua câu nào, KHÔNG suy đoán câu
trả lời từ tên file/tên biến.

1. **Đã có widget dùng chung nào làm việc này chưa?**
   → Tìm trong `lib/shared/widgets/` VÀ trong các file
   `docs/knowledge/design_system_audit.md`/
   `design_system_consolidation_plan.md` (tài liệu này) trước khi viết
   dòng code đầu tiên. Nếu CÓ → dùng lại, dừng ở đây. Nếu KHÔNG chắc
   → đọc trực tiếp mọi ứng viên nghi ngờ tương tự, không đoán.

2. **Đây có phải TRÙNG TỪNG DÒNG (byte-identical) với 1 đoạn UI đã có
   không?**
   → Đọc TOÀN VĂN cả 2 đoạn cạnh nhau. Nếu decoration/layout/tham số
   khớp 100% (hoặc khác đúng 1 tham số có thể hoá đơn giản) → PHẢI
   gộp, không tạo bản sao thứ 2. Nếu chỉ "trông giống" nhưng có ít
   nhất 1 khác biệt cấu trúc thật (bố cục Row/Column khác, có/không
   phần tử hình ảnh, kích thước cố định khác) → xem Merge Rules mục
   "KHÔNG được gộp" trước khi quyết định.

3. **Hành vi (behavior) có giống hệt không?**
   → Không chỉ giao diện tĩnh — kiểm tra trạng thái loading/error/
   empty, callback (`onTap`/`onRetry`/...), điều kiện hiển thị (vd
   nút chỉ hiện khi `onRetry != null`) có khớp không. Hành vi khác
   nhau dù giao diện giống → CÂN NHẮC kỹ, có thể vẫn gộp được nếu
   khác biệt tham số hoá được (xem Merge Rules #2), nhưng không mặc
   định.

4. **Semantics có giống hệt không?**
   → So sánh `Semantics(label:)`/`liveRegion`/`header`/
   `ExcludeSemantics`/`Tooltip` giữa các bản. Nếu KHÁC — widget dùng
   chung PHẢI lấy mức accessibility CAO HƠN, không bao giờ thấp hơn
   (Design System Principles #4).

5. **Tương tác (interaction) có giống hệt không?**
   → Tap target, gesture, trạng thái disabled/enabled, phản hồi
   hover/splash — nếu 1 bản có mà bản kia không, ghi rõ đây là khác
   biệt CÓ CHỦ Ý hay cần tham số hoá thêm.

6. **Nên ưu tiên composition (tham số hoá) hơn tạo widget mới không?**
   → Nếu khác biệt chỉ ở 1-2 giá trị (màu, có/không icon, có/không
   nút) → mở rộng tham số cho widget dùng chung SẴN CÓ (Merge Rules
   #5) thay vì viết widget mới song song.

7. **Có cần tài liệu hoá không?**
   → CÓ, LUÔN LUÔN — nếu tạo widget mới: doc comment giải thích đã
   xác nhận tương đương với NHỮNG file nào, dòng nào (theo mẫu
   `SectionHeader`/`StatCard`'s doc comment). Nếu QUYẾT ĐỊNH KHÔNG
   gộp 1 ứng viên trông giống: ghi rõ lý do NGAY TẠI chỗ (Design
   System Principles #7).

8. **Có cần test không?**
   → CÓ, LUÔN LUÔN, trong CÙNG thay đổi — tối thiểu render đúng nội
   dung + giữ đúng Semantics (Design System Principles #8). Nếu thay
   đổi 1 widget đang được nhiều nơi dùng, chạy lại TOÀN BỘ test của
   MỌI nơi gọi, không chỉ nơi vừa sửa.

9. **Có cần bản dịch (l10n) không?**
   → Nếu widget mới hiển thị/đọc BẤT KỲ chuỗi nào (kể cả chỉ dùng làm
   `Semantics.label`) — chuỗi đó phải tới từ tham số do nơi gọi
   truyền vào (đã qua `l10n` ở nơi gọi), KHÔNG tự đọc
   `AppLocalizations`/hard-code bên trong widget dùng chung. Nếu cần
   thêm khoá l10n mới — thêm vào ĐỦ cả 3 file `app_{vi,en,ar}.arb`
   trong CÙNG thay đổi.

10. **Accessibility có được bảo toàn không?**
    → Chạy lại (hoặc viết mới) test accessibility-focused (theo mẫu
    `test/shared_widgets_a11y_test.dart`, Sprint 20 Phase 2) xác nhận
    `Semantics`/`liveRegion`/`header`/tooltip không bị mất so với
    TRƯỚC khi hợp nhất. Nếu KHÔNG chắc chắn — không merge, hỏi lại
    người yêu cầu.

**Nếu bất kỳ câu nào trong 10 câu trên không trả lời được rõ ràng
("có" hoặc "không" kèm bằng chứng cụ thể) — DỪNG LẠI, đọc thêm mã
nguồn, KHÔNG đoán và tiếp tục tạo widget.**
