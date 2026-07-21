# Accessibility & UX audit — Sprint 20

Phase 1: kiểm toán TOÀN DIỆN đầu tiên trên 8 màn hình chính — THUẦN
tài liệu, không đổi code (xem Requirements gốc Phase 1: "Documentation
and audit only"). Mọi phát hiện ở mục 1-7 trỏ tới file:line THẬT tại
thời điểm audit, đã đọc trực tiếp, không suy đoán.

Phase 2 ("Shared UX & Accessibility Consolidation"): SỬA những phát
hiện có tác động cao nhất, ưu tiên cải thiện widget dùng chung hơn vá
từng nơi riêng lẻ — xem mục 8. Sau Phase 2, vài trích dẫn file:line ở
mục 1-7 đã LỖI THỜI (code đã đổi) — mục 8 là nguồn đúng cho TRẠNG THÁI
HIỆN TẠI của từng phát hiện, mục 1-7 giữ nguyên làm biên bản LỊCH SỬ
(không sửa lại số dòng cũ, tránh việc "sửa audit" biến thành che giấu
đã tìm thấy gì lúc đầu).

Checklist tái sử dụng tách riêng tại
[accessibility_checklist.md](accessibility_checklist.md) — dùng nó
cho lần audit/PR tiếp theo, đừng đọc lại report này mỗi lần.

Nếu tài liệu này lệch với code, code thắng.

## 1. Phạm vi & phương pháp

8 màn hình: Home, Reading, Search, Flashcards, Analytics, AI Tutor,
Learning Journey, Smart Learning — cùng các widget dùng chung mà
chúng gọi tới (`LoadingState`, `EmptyStateBanner`, `SearchErrorState`,
`AppScaffold`). Đọc trực tiếp TOÀN BỘ mã nguồn liên quan (không suy
đoán từ tên hàm/biến), trích dẫn nguyên văn kèm file:line cho mọi phát
hiện. Không chạy công cụ audit tự động (`flutter_lints`'
accessibility-adjacent rule hiện có: không có rule a11y chuyên biệt
nào được bật trong `analysis_options.yaml` ở phase này — xem backlog
mục cuối).

## 2. Phát hiện xuyên suốt (áp dụng &gt; 1 màn hình)

Đây là các phát hiện QUAN TRỌNG NHẤT — lặp lại ở nhiều nơi nên sửa 1
lần đúng cách sẽ có tác động rộng nhất.

### 2.1 `Semantics(header: true)` gần như không được dùng

Toàn app CHỈ có 2 nơi đánh dấu heading đúng cách:
`search_screen.dart:332-333` (tiêu đề trạng thái rỗng) và
`search_result_section.dart:78-79` (tiêu đề mỗi nhóm kết quả). MỌI
tiêu đề phần khác trong 8 màn hình — `_SectionTitle` (Home),
`_SectionHeader` (Analytics, dùng 5 lần), tiêu đề Suggestions/Insights
(AI Tutor), `journeyStepsTitle` (Learning Journey),
`otherRecommendationsTitle` (Smart Learning), tiêu đề nhóm thể động từ
(Flashcards `smart_deck_screen.dart:145-153`) — đều là `Text` thường,
KHÔNG có `Semantics(header: true)`. Người dùng trình đọc màn hình
không thể nhảy giữa các phần bằng thao tác "điều hướng theo heading"
chuẩn ở bất kỳ đâu ngoài Search.

**Mức độ**: Cao — ảnh hưởng thao tác điều hướng cơ bản của MỌI người
dùng trình đọc màn hình, trên MỌI màn hình trừ Search.

### 2.2 `EmptyStateBanner` thiếu `Semantics`/`liveRegion`

`lib/shared/widgets/empty_state_banner.dart` KHÔNG có bất kỳ
`Semantics`/`liveRegion` nào, khác biệt với 2 widget trạng thái dùng
chung còn lại:

| Widget | `Semantics` | `liveRegion` |
|---|---|---|
| `LoadingState` | ✅ (`loading_state.dart:24-26`) | ✅ |
| `SearchErrorState` | ✅ (`search_error_state.dart:59-61`) | ✅ |
| `EmptyStateBanner` | ❌ | ❌ |

Khi 1 phần chuyển từ loading → rỗng (KHÔNG phải lỗi), trình đọc màn
hình không được chủ động thông báo — người dùng phải tự dò tìm xem
tải xong chưa. Đây là bất nhất API RÕ RÀNG giữa 3 widget cùng vai trò
"trạng thái đặc biệt dùng chung".

**Mức độ**: Trung bình — Cao. Widget này được 4+ màn hình dùng
(`progress_dashboard_screen.dart`, `learning_journey_screen.dart`,
`smart_learning_screen.dart`, `tutor_home_screen.dart`), sửa 1 nơi lan
tỏa ngay.

### 2.3 `RefreshIndicator` không có phương án thay thế phi cử chỉ

`learning_journey_screen.dart:56-57`, `smart_learning_screen.dart:52-53`,
và `progress_dashboard_screen.dart:57` đều dùng `RefreshIndicator`
(kéo-để-làm-mới) làm CÁCH DUY NHẤT để chủ động tải lại. Không có nút
làm mới hiện diện thay thế nào. Người dùng dùng switch-control/không
thực hiện được cử chỉ kéo (drag) không có cách nào kích hoạt làm mới
thủ công — chỉ có thể chờ nút "Thử lại" xuất hiện KHI có lỗi, không
giúp gì khi muốn chủ động làm mới lúc không có lỗi.

**Mức độ**: Trung bình. Ảnh hưởng nhóm người dùng hẹp hơn (vận động,
không phải thị giác), nhưng lặp lại ở 3 màn hình.

### 2.4 Trạng thái Empty thiếu ở 1 số phần trong CÙNG 1 màn hình đã xử lý phần khác

`progress_dashboard_screen.dart`: mục Statistics (119-121) và History
(441-445) CÓ kiểm tra rỗng + `EmptyStateBanner`; mục Goals (217-244) và
Achievements (315-341) KHÔNG — danh sách rỗng chỉ render `Column`/`Wrap`
0 phần tử, im lặng. `tutor_home_screen.dart`: mục Suggestions
(207-209) CÓ kiểm tra rỗng; mục Insights (250-306) và Summary (85-122)
KHÔNG.

**Mức độ**: Trung bình — bất nhất ngay trong 1 màn hình, không phải
lỗi tổng thể nghiêm trọng (danh sách rỗng không gây crash), nhưng dễ
gây hiểu lầm "màn hình bị vỡ" khi 1 mục có empty state đẹp còn mục kế
bên chỉ là khoảng trắng.

### 2.5 Chỉ báo trạng thái CHỈ dùng màu sắc, không có chữ/nhãn thay thế

`flashcard_tile.dart:58-63` — `CircleAvatar(backgroundColor:
_stateColor(...), radius: 6)` là DẤU HIỆU DUY NHẤT cho trạng thái SRS
của thẻ (mới/đang học/đang ôn/quá hạn — 4 màu khác nhau qua
`_stateColor`, dòng 80-85). Không `Text`, không `Icon.semanticLabel`,
không `Semantics` bao quanh. Vi phạm trực tiếp nguyên tắc "không dùng
MÀU SẮC làm cách truyền đạt thông tin duy nhất" (WCAG 1.4.1) — ảnh
hưởng CẢ người dùng trình đọc màn hình LẪN người mù màu (không phân
biệt được đỏ/xanh lá của `scheme.error`/`scheme.primary`).

**Mức độ**: Cao — vi phạm tiêu chí WCAG Level A cụ thể, không chỉ là
"thiếu sót nhỏ".

### 2.6 Icon-only button thiếu `tooltip`

Rải rác vài nơi (khác biệt với Reading/Audio — 2 khu vực có kỷ luật
`tooltip` 100%):
- `flashcard_browse_screen.dart:100-106` — nút xóa ô tìm kiếm
  (`Icons.clear_rounded`), không `tooltip`.
- `add_flashcard_screen.dart:78-86` — cùng mẫu nút xóa tìm kiếm.
- `flashcard_decks_screen.dart:88-100`, `flashcard_tile.dart:64-76` —
  `PopupMenuButton` không set `tooltip:` tường minh (dùng mặc định
  "Show menu" của Flutter, chấp nhận được nhưng không tuỳ biến theo
  ngữ cảnh app).

**Mức độ**: Thấp — Trung bình. `PopupMenuButton` vẫn có tooltip mặc
định hợp lệ; 2 nút xoá tìm kiếm thực sự thiếu nhãn hoàn toàn.

## 3. Phát hiện theo màn hình

### 3.1 Home (`home_screen.dart`)

- **Lỗi/loading bị NUỐT IM LẶNG** — phát hiện nghiêm trọng nhất của
  toàn bộ audit này. `surahsAsync` chỉ được đọc qua
  `surahsAsync.valueOrNull ?? const []` (dòng 61-67) — không loading
  indicator, không thông báo lỗi, danh sách chỉ rỗng nếu load chậm
  hoặc lỗi. `_TodaysVerseCard` dùng
  `verse.maybeWhen(data: ..., orElse: () =&gt; const SizedBox.shrink())`
  (dòng ~528) — loading VÀ lỗi đều render ra... KHÔNG GÌ CẢ. Người
  dùng (mọi người dùng, không riêng ai dùng công nghệ hỗ trợ) không
  có cách nào biết app đang tải, đã lỗi, hay đơn giản không có nội
  dung.
- Tốt: nút tìm kiếm (`IconButton`, dòng 74-78) có `tooltip`; các thẻ
  điều hướng (Continue reading, Daily Goal, Recent surahs) đều dùng
  `InkWell` bọc nội dung có chữ hiển thị — không có gap kiểu "icon
  trần không nhãn".
- `_SectionTitle` (dòng 165-180, dùng 2 lần) — `Text` thường, không
  heading marker (xem 2.1).
- Không dùng `LoadingState`/`EmptyStateBanner` ở đâu trong file này.

### 3.2 Reading (`reading_screen.dart`, `audio_bar.dart`, `ayah_actions_sheet.dart`, `mushaf_builder.dart`)

- Tốt: `AyahCard` gộp `Semantics(label: l10n.ayahSemanticLabel(...))`
  bao trọn nội dung (dòng 735-736); sajdah icon có `Tooltip` VÀ
  `Icon.semanticLabel` cùng lúc (dòng 814-822) — cẩn thận hơn mức tối
  thiểu; MỌI `IconButton` trong cả 2 file (`reading_screen.dart`,
  `audio_bar.dart`) đều có `tooltip` (đã kiểm chứng, 0 ngoại lệ).
- `_ActionIcon` (dòng 1104-1142, dùng cho bookmark/favorite/copy/
  share/play/more trên mỗi ayah) đặt `visualDensity:
  VisualDensity.compact` — thu nhỏ tap target dưới chuẩn 48dp cho 1
  HÀNG 6 icon liền nhau, nơi độ chính xác chạm càng quan trọng hơn vì
  các nút liền kề nhau.
- Loading dùng `CircularProgressIndicator()` trần (dòng 263), KHÔNG
  phải `LoadingState` — không có `semanticsLabel`.
- Empty (`_ReadingEmptyState`, dòng 1251-1265) và Error
  (`_ReadingErrorState`, dòng 1207-1249) đều TỰ VIẾT thay vì dùng
  `EmptyStateBanner`/`SearchErrorState` — `_ReadingErrorState` có
  icon+chữ+nút thử lại (tốt) nhưng KHÔNG bọc `Semantics(liveRegion:
  true)`.
- Chữ phiên âm (`transliteration`, dòng 915-923) giảm alpha CHỮ còn
  0.7 TRÊN NỀN `onSurfaceVariant` (vốn đã là màu phụ) — 2 lớp giảm
  tương phản chồng nhau, đáng xem lại (mục 6 checklist).
- `ayah_actions_sheet.dart`: `_ColorDot` (34×34, dưới 48dp) NHƯNG có
  `Semantics(label: colorName, button: true, selected: selected)` bù
  lại (dòng 284-309) — mẫu ĐÚNG dù kích thước chưa lý tưởng. Tên màu
  (`'amber'`, `'green'`...) dùng làm `Semantics.label` KHÔNG qua
  `l10n` (dòng 10-17) — người dùng trình đọc màn hình luôn nghe tên
  màu tiếng Anh bất kể ngôn ngữ app.

### 3.3 Search (`search_screen.dart` + widgets)

Màn hình được instrument TỐT NHẤT trong toàn app — điểm chuẩn
(baseline) nên nhân rộng, không phải nơi cần sửa nhiều nhất:
- DUY NHẤT nơi dùng `Semantics(header: true)` đúng cách (3 lần: dòng
  332-333, 347-348, 361-362).
- `SearchLoadingSkeleton` (dòng 421-484) và `SearchEmptyState`
  (311-377) tự viết (không dùng `LoadingState`/`EmptyStateBanner`)
  NHƯNG vẫn tự bọc `Semantics(liveRegion: true, label: ...)` đúng tinh
  thần — chỉ khác component dùng chung, không khác về CHẤT LƯỢNG
  accessibility.
- `ResultCard` dùng `Semantics(..., excludeSemantics: true, button:
  onTap != null)` gộp toàn bộ nội dung + đúng vai trò `button` — mẫu
  rất chuẩn (dòng 111-129).
- 1 điểm nhỏ: tooltip debug-only hardcode tiếng Anh
  (`'Dev preview (debug only)'`, dòng 220) không qua `l10n` — chấp
  nhận được vì bị `kDebugMode` chặn, không xuất hiện ở bản release.

### 3.4 Flashcards (5 màn hình + `flashcard_tile.dart`)

**Khu vực có mật độ phát hiện cao nhất.** Cả 5 màn hình
(`flashcard_decks_screen.dart`, `flashcard_browse_screen.dart`,
`smart_deck_screen.dart`, `flashcard_review_screen.dart`,
`add_flashcard_screen.dart`) — **KHÔNG file nào dùng bất kỳ widget
nào trong 3 widget dùng chung** (`LoadingState`/`EmptyStateBanner`/
`SearchErrorState`). Mọi loading là `CircularProgressIndicator()`
trần không nhãn; mọi empty là `Text` giữa màn hình không icon không
`Semantics`; **mọi error là `Text` không icon, KHÔNG CÓ NÚT THỬ LẠI
NÀO Ở BẤT KỲ MÀN HÌNH NÀO trong cả 5 màn hình.** Đây là feature DUY
NHẤT trong 8 màn hình audit hoàn toàn không có đường thoát khi 1 lệnh
tải lỗi — người dùng chỉ có thể rời màn hình và quay lại.

Thêm: `flashcard_tile.dart`'s chỉ báo trạng thái chỉ-dùng-màu (mục
2.5); `smart_deck_screen.dart`'s tiêu đề nhóm thể động từ (dòng
145-153) dùng CÙNG kiểu chữ đậm như `SearchResultSection`'s tiêu đề
nhưng KHÔNG có `Semantics(header: true)` — bằng chứng trực tiếp cùng
1 mẫu hình ảnh được sao chép nhưng phần accessibility bị bỏ sót.

### 3.5 Analytics (`progress_dashboard_screen.dart` + widgets)

- Mẫu `Semantics(label:) + ExcludeSemantics` được áp dụng ĐẦY ĐỦ và
  NHẤT QUÁN — `_MetricCard`, `_AccuracyMetricCard`, mỗi cột biểu đồ
  lịch sử, `GoalCard`, `AchievementCard` đều đúng mẫu.
- `_HistoryChart` (dòng 418-504): mỗi cột có `Semantics(label:
  '$date: $minutes')` (456-459) — TỐT ở mức từng điểm dữ liệu, nhưng
  KHÔNG có 1 node tổng hợp mô tả cả biểu đồ (vd "Biểu đồ phút đọc theo
  tuần") — trình đọc màn hình phải duyệt qua từng cột rời rạc, không
  có điểm vào tổng quan.
- Xem 2.4 (Goals/Achievements thiếu empty state), 2.6 (SearchErrorState
  dùng lại 5 lần trong file — xem mục 4 UX Đặt tên lại).
- `LoadingState(semanticsLabel: l10n.progressDashboardLoading)` dùng
  ĐÚNG 1 chuỗi cho cả 5 section khác nhau (Statistics/Goals/
  Achievements/History/Insights) — hợp lệ về kỹ thuật nhưng không mô
  tả ĐÚNG phần nào đang tải khi 2+ phần cùng loading 1 lúc.
- `reading_stats_section.dart` (Stats feature, hiển thị trên Home) —
  **outlier tệ nhất được tìm thấy**: không `LoadingState` (bare
  `CircularProgressIndicator` x2, không semantics), không
  `EmptyStateBanner` (tự viết Row giống hệt nhưng thiếu `Semantics`),
  và lỗi hiển thị bằng `Icon(Icons.error_outline_rounded,
  color: scheme.error)` TRẦN — không chữ, không nút thử lại, không
  `semanticLabel`, không `Semantics` bao quanh (dòng 98-101). Đây là
  trường hợp DUY NHẤT trong toàn bộ audit nơi 1 trạng thái lỗi hoàn
  toàn CÂM LẶNG với trình đọc màn hình.

### 3.6 AI Tutor (`tutor_home_screen.dart` + widgets)

- Cùng mẫu tốt như Analytics (`Semantics + ExcludeSemantics` nhất
  quán ở `TutorHeader`, `TutorSuggestionCard`, `TutorInsightCard`).
  `tutor_suggestion_card.dart` có comment TƯỜNG MINH giải thích lý do
  nút hành động nằm ngoài `ExcludeSemantics` (dòng 58-62) — mẫu tham
  khảo tốt nhất cho quy tắc này.
- `TutorHeader`'s Row tiêu đề (icon + `title`, dòng 33-50) KHÔNG có
  `Semantics` bao quanh, khác các mục thống kê con NGAY BÊN DƯỚI nó
  (57-88) — bất nhất nội bộ trong cùng 1 widget.
- Xem 2.4 (Insights + Summary thiếu empty state, chỉ Suggestions có).
- `_JourneyEntryCard` (dòng 138-178) — `InkWell` điều hướng sang
  Learning Journey, không `Semantics` bao quanh (dựa vào `Text` con
  hiển thị tự nhiên) — so sánh với `_SmartLearningEntryCard` tương tự
  bên Learning Journey (mục 3.7) — CẢ HAI đều thiếu, không phải lỗi
  cá biệt.

### 3.7 Learning Journey (`learning_journey_screen.dart` + widgets)

- `journey_header.dart`, `journey_progress_card.dart`,
  `journey_step_card.dart`'s `_StepBadge` — đều đúng mẫu `Semantics +
  ExcludeSemantics`.
- `_SmartLearningEntryCard` (dòng 167-202, `InkWell` điều hướng sang
  Smart Learning) — KHÔNG có `Semantics` bao quanh, khác mọi widget
  khác trong cùng file/feature — điểm bất nhất cụ thể, dễ sửa.
- Dùng `RefreshIndicator` không thay thế (mục 2.3).
- Loading/Error dùng đúng `LoadingState`/`SearchErrorState`; Empty
  dùng đúng `EmptyStateBanner`.

### 3.8 Smart Learning (`smart_learning_screen.dart` + widgets)

- `smart_learning_header.dart`, `recommendation_card.dart`,
  `session_summary_card.dart` — đều đúng mẫu `Semantics +
  ExcludeSemantics`. Đây là feature accessibility NHẤT QUÁN NHẤT
  trong 8 màn hình (không phát hiện bất nhất nội bộ nào).
- Dùng `RefreshIndicator` không thay thế (mục 2.3) — điểm trừ DUY
  NHẤT của feature này.
- Loading/Error/Empty đều dùng đúng 3 widget dùng chung.

## 4. Phát hiện UX trùng lặp (Task 4 — CHỈ ghi nhận, CHƯA refactor)

| Mẫu | Số nơi cài lại độc lập | Đã tách widget dùng chung? |
|---|---|---|
| "Tiêu đề phần" (icon tuỳ chọn + `Text` đậm `titleSmall`/`titleMedium`) | `_SectionTitle` (Home), `_SectionHeader` (Analytics, ×5 lệnh gọi), tiêu đề Suggestions/Insights (AI Tutor, 2 nơi inline KHÔNG tái dùng `_SectionHeader`), `journeyStepsTitle` (Learning Journey), `otherRecommendationsTitle` (Smart Learning), tiêu đề nhóm thể động từ (Flashcards) | ❌ Chưa — 6+ cài đặt độc lập của CÙNG 1 khái niệm |
| "Thẻ chỉ số" (icon/giá trị/nhãn trong `Semantics(label:)+ExcludeSemantics`, khung bo góc) | `_MetricCard`/`_AccuracyMetricCard` (Analytics), `TutorHeader`'s stat item, `JourneyProgressCard`'s stat item, `TutorInsightCard` | ❌ Chưa — 4 lớp riêng biệt cùng 1 hình dạng |
| Loading/Empty/Error dùng chung | `LoadingState`/`EmptyStateBanner` (Sprint 15 Phase 2), `SearchErrorState` (Sprint 7.1, tên gợi ý sai phạm vi) | ✅ Đã tách 3/3 — nhưng Flashcards + `reading_stats_section.dart` KHÔNG dùng bất kỳ cái nào (mục 3.4/3.5) |
| "Empty hint" hàng Icon+Text | `EmptyStateBanner` (dùng chung) VÀ `stats_screen.dart`'s `_EmptyHint` (đã tự nhận trùng lặp trong chính doc-comment của `empty_state_banner.dart:6-9`, "chưa gộp ở phase này") VÀ `reading_stats_section.dart`'s Row tự viết (mục 3.5) | ⚠️ Đã biết từ Sprint 15 Phase 2, CHƯA gộp — giờ có thêm 1 bản sao thứ 3 |
| Icon+chữ+nút thử lại (retry) | `SearchErrorState` (dùng chung), `_ReadingErrorState` (Reading, tự viết), lỗi audio inline (`audio_bar.dart`, tự viết, KHÔNG có nút thử lại) | ⚠️ 1/3 cài đặt được tái sử dụng |

### Đặt tên lại đáng cân nhắc

`SearchErrorState` (định nghĩa tại
`lib/features/search/presentation/widgets/search_error_state.dart`)
tự mô tả trong doc-comment là "dùng chung cho Tìm kiếm" nhưng THỰC TẾ
được import/dùng ở `learning_journey_screen.dart`,
`tutor_home_screen.dart` (×3), `progress_dashboard_screen.dart` (×5),
`smart_learning_screen.dart` — 10 lệnh gọi NGOÀI phạm vi Search, chỉ 1
lệnh gọi (`search_screen.dart:181`) thực sự thuộc Search, và đó là
đường debug-only. Tên gọi hiện tại gây hiểu lầm về vị trí/phạm vi sở
hữu của widget. Đặt lại tên (vd `AsyncErrorState`/`RetryErrorState`)
và di chuyển sang `lib/shared/widgets/` là ứng viên refactor rõ ràng
— KHÔNG làm ở phase này (chỉ ghi nhận, đúng "Do NOT refactor yet").

## 5. Release blockers (trạng thái GỐC — Phase 1, xem mục 8 để biết trạng thái hiện tại)

**Không có blocker cứng** (không có gì crash, không vi phạm chính sách
store, luồng chính vẫn dùng được). Tuy nhiên 3 phát hiện dưới đây nên
được coi là **blocker MỀM cho bất kỳ tuyên bố "đã kiểm tra
accessibility"/tuân thủ WCAG AA nào** — nên sửa trước khi công bố mức
độ hỗ trợ tiếp cận của app, dù không cần chặn 1 bản release tính năng
thông thường:

1. **`home_screen.dart` nuốt lỗi/loading im lặng** (mục 3.1) — ảnh
   hưởng MỌI người dùng (không riêng công nghệ hỗ trợ), trên chính
   màn hình đầu tiên người dùng thấy. ✅ ĐÃ SỬA — xem mục 8.5.
2. **`flashcard_tile.dart` dùng màu làm dấu hiệu trạng thái duy nhất**
   (mục 2.5) — vi phạm WCAG 1.4.1 (Level A) cụ thể. ✅ ĐÃ SỬA — xem
   mục 8.6.
3. **Flashcards feature không có nút thử lại ở bất kỳ đâu** (mục 3.4)
   — 5/5 màn hình cùng 1 feature thiếu đường thoát khi lỗi. ⚠️ CHƯA
   SỬA — mục 2.5's phần MÀU đã sửa (blocker #2), nhưng việc đưa 5 màn
   hình Flashcards dùng `LoadingState`/`EmptyStateBanner`/1 widget lỗi
   dùng chung KHÔNG nằm trong 7 Task của Phase 2 (Task 6 chỉ giao "màu
   sắc", không giao "trạng thái loading/empty/error của Flashcards") —
   vẫn là blocker mềm, đẩy sang backlog Phase 3 (xem mục 8.7).

## 6. Mẫu accessibility đáng giữ lại & nhân rộng (điểm tích cực)

Không phải mọi thứ đều là thiếu sót — các mẫu sau đã ĐÚNG và nên là
chuẩn bắt buộc cho mọi widget mới (đã đưa vào
[accessibility_checklist.md](accessibility_checklist.md)):

- `Semantics(label:) + ExcludeSemantics` gộp thẻ phức hợp — áp dụng
  nhất quán ở Analytics/AI Tutor/Learning Journey/Smart Learning (trừ
  2 ngoại lệ đã nêu ở 3.6/3.7).
- Nút hành động luôn nằm NGOÀI `ExcludeSemantics` — có comment tường
  minh giải thích lý do trong `tutor_suggestion_card.dart`.
- `tooltip` bắt buộc trên `IconButton` — kỷ luật 100% ở Reading/Audio.
- `LoadingState`/`SearchErrorState` bắt buộc `semanticsLabel`/dùng
  `liveRegion` — thiết kế đúng ngay từ constructor.
- `Semantics(header: true)` ở Search — cần NHÂN RỘNG, không phải giữ
  nguyên hiện trạng "chỉ 1 nơi".
- Toàn app lấy màu từ `ColorScheme.fromSeed`, không hard-code — bảo vệ
  tương phản bằng kiến trúc, không phải kỷ luật thủ công.

## 8. Sprint 20 Phase 2 — Đã sửa (completed improvements)

Nguyên tắc xuyên suốt Phase 2: **ưu tiên 1 chỗ sửa dùng chung hơn
nhiều chỗ vá riêng lẻ** (đúng Goal gốc) — mọi mục dưới đây, trừ 8.5/
8.6 (đặc thù Home/Flashcards), đều là thay đổi Ở WIDGET DÙNG CHUNG,
tự động lan toả tới mọi màn hình đang gọi nó mà KHÔNG cần sửa từng nơi
gọi thêm lần nữa.

### 8.1 `EmptyStateBanner` — thêm `Semantics(liveRegion: true)` (giải quyết mục 2.2)

`lib/shared/widgets/empty_state_banner.dart` giờ bọc
`Semantics(liveRegion: true, label: text) + ExcludeSemantics`, ĐÚNG
mẫu `LoadingState`/`SearchErrorState` đã có. Giao diện KHÔNG đổi (yêu
cầu Task 1 "Do not change visual appearance unless required for
accessibility" — thay đổi này CHỈ thêm semantics, không đổi 1 pixel
nào). Lan toả tự động tới mọi nơi gọi `EmptyStateBanner`
(`progress_dashboard_screen.dart`, `learning_journey_screen.dart`,
`smart_learning_screen.dart`, `tutor_home_screen.dart`) — không cần
sửa các file đó.

`LoadingState`/`SearchErrorState` được rà soát lại, xác nhận ĐÃ đạt
chuẩn từ trước (không cần sửa) — chỉ thêm doc-comment ghi nhận việc rà
soát.

### 8.2 `SectionHeader` dùng chung mới — giải quyết phần lớn mục 2.1

Widget mới `lib/shared/widgets/section_header.dart` — tự bọc
`Semantics(header: true)`. Xác nhận TỪNG DÒNG 6 cài đặt độc lập trước
đó THỰC SỰ tương đương (cùng
`textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)`) trước
khi gộp — đúng yêu cầu Task 2 "Extract only if... functionally
equivalent":

- `progress_dashboard_screen.dart`'s `_SectionHeader` (lớp riêng, 5
  lệnh gọi) — XOÁ lớp riêng, thay bằng `SectionHeader` dùng chung.
- `tutor_home_screen.dart` (2 tiêu đề inline — Suggestions/Insights).
- `learning_journey_screen.dart` (`journeyStepsTitle`).
- `smart_learning_screen.dart` (`otherRecommendationsTitle`).
- `smart_deck_screen.dart` (tiêu đề nhóm thể động từ, Flashcards).

`home_screen.dart`'s `_SectionTitle` CỐ Ý KHÔNG gộp — dùng
`titleMedium` (không phải `titleSmall`), khác thật sự về hình ảnh (xem
doc-comment tại chỗ) — thay vào đó tự thêm `Semantics(header: true)`
trực tiếp, đạt cùng chuẩn accessibility mà KHÔNG đổi giao diện Home
("Preserve existing UI").

`search_screen.dart`/`search_result_section.dart` giữ nguyên (đã đúng
từ Phase 1, có thêm `color: scheme.primary` riêng nên KHÔNG tương
đương — không gộp, đúng nguyên tắc "chỉ gộp khi tương đương").

**Kết quả mục 2.1**: từ "2 nơi có heading semantics" lên "9 nơi" (2 cũ
+ 6 nơi gộp qua `SectionHeader` + 1 nơi Home tự thêm riêng) trên tổng
8 màn hình — chỉ còn thiếu ở những tiêu đề KHÔNG thuộc danh sách audit
gốc (vd tiêu đề phụ trong dialog/sheet, ngoài phạm vi "major section
titles" của Task 4).

### 8.3 `StatCard` dùng chung mới — giải quyết Task 3

Đọc trực tiếp, so khớp TỪNG DÒNG 5 cài đặt "thẻ chỉ số" trước khi
quyết định gộp cái nào:

- **`_MetricCard` (Analytics, nhánh `accented: false`) TRÙNG HOÀN
  TOÀN với `TutorInsightCard`** (cùng padding 14, bo góc 16,
  `Icon(size:22)`, `FittedBox(titleLarge+w700)`, `labelSmall`
  `onSurfaceVariant`, `Semantics+ExcludeSemantics`) — XÁC NHẬN tương
  đương, gộp:
  - Widget mới `lib/shared/widgets/stat_card.dart` (`StatCard`, tham
    số `accented` tái tạo đúng nhánh `_MetricCard(accented: true)`
    dùng cho nhóm chỉ số nổi bật).
  - `progress_dashboard_screen.dart`'s `_MetricCard` — XOÁ lớp riêng,
    6 lệnh gọi thay bằng `StatCard`.
  - `TutorInsightCard` (`tutor_insight_card.dart`) — GIỮ NGUYÊN tên
    lớp/constructor (được `test/tutor_insight_card_test.dart` và
    `tutor_home_screen.dart` phụ thuộc), thân hàm đổi thành gọi lại
    `StatCard` — loại trùng lặp mà KHÔNG đổi API công khai/test nào.
- **`_AccuracyMetricCard`** (Analytics) — CÓ vòng tròn tiến độ, bố cục
  Row khác hẳn — XÁC NHẬN KHÔNG tương đương, giữ riêng, đã thêm
  doc-comment giải thích tại chỗ.
- **`TutorHeader`'s mục thống kê** (inline, lồng trong 1 `Row` chia
  đều) — bố cục Row icon-CẠNH-text, luôn `onPrimaryContainer` cố định,
  không có khái niệm accented — XÁC NHẬN KHÔNG tương đương, giữ riêng,
  đã thêm doc-comment giải thích tại chỗ.
- **`JourneyProgressCard`'s mục thống kê** (inline, lồng trong
  `Wrap`) — bố cục Row icon-CẠNH-text, chiều rộng cố định 132, không
  nền/bo góc riêng từng mục — XÁC NHẬN KHÔNG tương đương, giữ riêng,
  đã thêm doc-comment giải thích tại chỗ.

**Kết quả**: 1 trong 5 cặp là trùng lặp thật (đã gộp), 3 còn lại có
khác biệt bố cục thật sự (đã ghi nhận, KHÔNG cưỡng ép gộp — đúng yêu
cầu "If not equivalent: leave separate and document why").

### 8.4 `Semantics(header: true)` áp dụng rộng — giải quyết Task 4

Đạt được HOÀN TOÀN như tác dụng phụ của 8.2 (mọi nơi thay bằng
`SectionHeader` tự động có) + 1 chỗ sửa trực tiếp riêng
(`home_screen.dart`'s `_SectionTitle`). KHÔNG thêm `header: true` vào
bất kỳ Text trang trí/phụ nào khác (đúng "Avoid unnecessary semantics
on decorative text") — CHỈ áp dụng cho các tiêu đề phần đã xác định ở
Phase 1 mục 2.1/3.x.

### 8.5 Home screen — hết loading/error câm lặng (giải quyết mục 3.1, release blocker mềm #1)

`home_screen.dart`:
- `surahsAsync` (trước: `.valueOrNull ?? []`, không nhánh loading/
  error) — chuyển toàn bộ `body` sang `surahsAsync.when(loading:,
  error:, data:)`, tái sử dụng `LoadingState`/`SearchErrorState` có
  sẵn. Nhánh `data:` giữ NGUYÊN VẸN nội dung/bố cục cũ (chỉ đổi nguồn
  `surahById` từ `.valueOrNull` sang tham số `surahs` đã resolve) —
  đúng "Do not redesign Home".
- `_TodaysVerseCard` (trước: `maybeWhen(orElse: () =>
  SizedBox.shrink())`, loading VÀ lỗi đều vô hình) — chuyển sang
  `.when()` đầy đủ, thêm 2 nhánh loading/error còn thiếu. `data == null`
  (không tìm thấy Surah/Ayah hợp lệ — KHÔNG phải lỗi) vẫn ẩn thẻ như
  cũ, không đổi.
- Thêm 2 khoá l10n mới (`homeLoading`, `homeTodaysVerseLoading`) vào
  cả 3 file `app_{vi,en,ar}.arb` — mô tả ĐÚNG phần đang tải cho từng
  chỗ, tránh lặp lại vấn đề "1 chuỗi loading dùng chung cho nhiều phần
  khác nhau" đã ghi nhận ở mục 3.5 (`progressDashboardLoading`).
- `currentStreakProvider`'s `.valueOrNull ?? 0` KHÔNG sửa — 1 số liệu
  đơn lẻ trong hàng 3 chip, mặc định về "0" khi đang tải là suy biến
  hợp lý (KHÁC hẳn 1 phần render ra HOÀN TOÀN trống rỗng) — thêm
  spinner riêng cho đúng 1 con số sẽ là thay đổi bố cục, vi phạm "Do
  not redesign Home".

### 8.6 Flashcards — thêm nhãn chữ cho chỉ báo trạng thái SRS (giải quyết mục 2.5, release blocker mềm #2)

`flashcard_tile.dart`'s `CircleAvatar` (chấm màu trạng thái SM-2) —
GIỮ NGUYÊN giao diện (đúng "Preserve visual design"), bọc thêm
`Tooltip(message:) + Semantics(label:)` với nhãn tái sử dụng NGUYÊN
VẸN 4 chuỗi l10n đã có sẵn (`flashcardFilterNew/Learning/Review/
Lapsed`, vốn dùng cho bộ lọc trạng thái ở `flashcard_browse_screen.dart`)
— KHÔNG thêm khoá l10n mới, đúng "Reuse existing widgets whenever
possible" áp dụng cả cho chuỗi dịch, không chỉ widget.

### 8.7 Chưa sửa — khác biệt/vấn đề CỐ Ý còn lại (không phải sót, có lý do)

- **Flashcards' loading/empty/error vẫn KHÔNG dùng
  `LoadingState`/`EmptyStateBanner`/1 widget lỗi-thử-lại dùng chung**
  (mục 3.4) — Task 6 của Phase 2 CHỈ giao "màu sắc → thêm chữ", không
  giao "đưa Flashcards về 3 widget dùng chung". Vẫn là release blocker
  mềm #3 (mục 5), CHƯA giải quyết — cần 1 Task riêng ở phase sau.
- **`reading_stats_section.dart`** (mục 3.5) — chưa gộp, cùng lý do
  (ngoài phạm vi 7 Task được giao).
- **`RefreshIndicator` không có thay thế phi cử chỉ** (mục 2.3) —
  chưa sửa, cần thêm UI (nút làm mới hiện diện) — có khả năng đụng
  "No feature redesign"/"Do not redesign Home", cần quyết định phạm
  vi rõ ràng hơn ở 1 phase sau trước khi làm.
- **`SearchErrorState`'s tên gọi** — chưa đổi (mục 4 "Đặt tên lại"),
  đã ghi thêm 1 đoạn doc-comment giải thích tại chỗ vì sao chưa đổi
  (đổi tên 1 class được 10+ nơi import là thay đổi diện rộng, ngoài
  phạm vi "cải thiện accessibility" của Task 1).
- **Goals/Achievements/Insights/Summary thiếu nhánh empty** (mục 2.4)
  — chưa sửa, không nằm trong 7 Task được giao.
- **`_ActionIcon` (Reading) dùng `visualDensity: compact`** (mục 3.2)
  — chưa sửa, không nằm trong 7 Task được giao.
- Mọi mục backlog khác ở mục 9 dưới đây chưa thuộc phạm vi Phase 2.

**Vấn đề MỚI phát hiện trong lúc sửa Phase 2**: không có — mọi thay
đổi đều xác nhận đúng như Phase 1 đã mô tả, không phát sinh phát hiện
accessibility mới nào ngoài dự kiến.

## 9. Backlog (cập nhật sau Phase 2 — ✅ = đã xong, còn lại là Phase 3+)

Thứ tự theo mức độ ảnh hưởng ước tính, không phải thứ tự bắt buộc:

1. ✅ Thêm `Semantics(header: true)` cho mọi tiêu đề phần (mục 2.1) —
   xong ở mục 8.2/8.4 (9/9 tiêu đề phần chính đã có).
2. ✅ Sửa `home_screen.dart` để loading/error không còn im lặng (mục
   3.1) — xong ở mục 8.5.
3. ✅ Thêm chữ/nhãn thay thế cho chỉ báo trạng thái SRS trong
   `flashcard_tile.dart` (mục 2.5) — xong ở mục 8.6.
4. Đưa Flashcards (5 màn hình) dùng `LoadingState`/`EmptyStateBanner`/
   1 widget lỗi-có-thử-lại dùng chung (mục 3.4) — release blocker mềm
   #3, CHƯA xong (ngoài phạm vi 7 Task Phase 2, xem mục 8.7).
5. ✅ Thêm `Semantics(liveRegion: true)` cho `EmptyStateBanner` (mục
   2.2) — xong ở mục 8.1.
6. Gộp `reading_stats_section.dart` vào cùng bộ widget dùng chung
   (mục 3.5).
7. Thêm nhánh empty cho Goals/Achievements (Analytics) và Insights/
   Summary (AI Tutor) (mục 2.4).
8. Đặt tên lại + di chuyển `SearchErrorState` ra khỏi
   `features/search/` (mục 4, "Đặt tên lại").
9. ⚠️ Một phần đã xong: "Tiêu đề phần" đã tách (`SectionHeader`, mục
   8.2). "Thẻ chỉ số" đã tách phần TRÙNG THẬT (`StatCard`, mục 8.3) —
   3 cài đặt còn lại (`_AccuracyMetricCard`/`TutorHeader`/
   `JourneyProgressCard`) CỐ Ý giữ riêng, đã ghi lý do, không còn là
   backlog "chưa xem xét" nữa.
10. Thêm nút làm mới thay thế cho `RefreshIndicator` (mục 2.3), hoặc
    ít nhất `Semantics.onLongPress`/action tuỳ biến kích hoạt refresh.
11. Nâng `_ActionIcon` (Reading) khỏi `visualDensity: compact`, hoặc
    xác nhận khoảng cách giữa các icon đủ bù trừ.
12. Bật thêm rule lint liên quan accessibility nếu `flutter_lints`/
    `package:flutter_lints` phiên bản dùng có hỗ trợ (hiện
    `analysis_options.yaml` không bật rule a11y chuyên biệt nào) —
    cần khảo sát riêng, ngoài phạm vi phase này.
13. `l10n` hoá tên màu highlight dùng làm `Semantics.label` trong
    `ayah_actions_sheet.dart`.
14. Thêm node tổng hợp cho `_HistoryChart` (Analytics) ngoài các node
    từng cột.
15. Kiểm tra Focus order cho Dialog/BottomSheet mới mở (mục 7 checklist
    — chưa kiểm chứng trong phạm vi audit này, cần 1 lượt riêng bằng
    trình đọc màn hình thật, không chỉ đọc mã nguồn).
