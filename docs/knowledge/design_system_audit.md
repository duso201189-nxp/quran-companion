# Design system audit — Sprint 21.1

Kiểm toán KIẾN TRÚC UI toàn diện đầu tiên — 13 hạng mục, phủ TOÀN BỘ
`lib/features/**/presentation/`, `lib/shared/`, `lib/app/theme/`,
`lib/app/app.dart`, `lib/app/router.dart` (~45 file). Thuần tài liệu
— **KHÔNG có dòng code sản phẩm nào bị đổi, KHÔNG widget nào được
tạo** (đúng yêu cầu gốc: "Do NOT modify any runtime code yet... Do not
refactor anything. Do not create widgets."). Mọi phát hiện dưới đây
trỏ tới file:line THẬT, đọc trực tiếp, không suy đoán.

Nếu tài liệu này lệch với code, code thắng.

## Phương pháp

Đọc toàn văn từng file trong 4 nhóm song song (Home/Reading/Search;
Library/Khatm/Stats; Flashcards/Quiz/Study/Review; Analytics/AI Tutor/
Learning Journey/Smart Learning/Learning Session/Profile) cộng với
tầng `lib/shared/`/`lib/app/theme/`/`lib/app/app.dart` đọc trực tiếp,
trích dẫn nguyên văn kèm file:line. Không chạy công cụ phân tích UI tự
động — toàn bộ đối chiếu bằng mắt trên mã nguồn thật.

## Tóm tắt điều hành

Phát hiện lớn nhất: **2 khuôn mẫu "thẻ" (card)** — (A) mặt phẳng tĩnh
`Container(padding, BoxDecoration(color: 1 token màu, borderRadius:
circular(16)))` và (B) mặt phẳng chạm được `Material(color, borderRadius) +
InkWell` — được cài đặt ĐỘC LẬP hơn **30 lần** trên toàn app, trong đó
1 nhóm con 4 file (`tutor_header.dart`/`journey_header.dart`/
`smart_learning_header.dart`/`session_summary_card.dart`) và 1 cặp
(`_JourneyEntryCard`/`_SmartLearningEntryCard`) là **giống hệt từng
dòng**. Phát hiện lớn thứ hai: **trạng thái lỗi** — widget dùng chung
`SearchErrorState` đã tồn tại và được 6 file dùng, nhưng **3 file khác
tự cài lại GIỐNG HỆT hình dạng của nó** (icon 56 + text + nút thử lại)
thay vì import nó, cộng thêm 13+ biến thể rút gọn (chỉ chữ, không
icon, không nút thử lại). Tin tốt: **kỷ luật color-token gần như hoàn
hảo** (0 màu hex hard-code thật sự trong ~45 file, ngoại trừ 1 bảng
màu highlight CÓ CHỦ Ý) và **elevation gần như không dùng** (thiết kế
phẳng nhất quán, tuân thủ Material 3 tonal design) — cả hai là điểm
mạnh cần GIỮ NGUYÊN, không phải vấn đề cần sửa.

---

## 1. Typography

**Current implementations**: Kỷ luật tốt — hầu hết mọi nơi dùng
`Theme.of(context).textTheme.X?.copyWith(...)`, không tự đặt
`fontFamily`. 3 nhóm:
- **"Tiêu đề đậm"**: `textTheme.titleSmall` hoặc `titleMedium`
  `?.copyWith(fontWeight: FontWeight.w700)` — quy ước ngầm định cho
  MỌI tiêu đề thẻ/phần trong app, xuất hiện ĐỘC LẬP ước tính **25+
  lần** (vd `stats_screen.dart:189`, `active_khatm_card.dart:38`,
  `study_screen.dart:168-169`, `tutor_header.dart:54-57`,
  `journey_header.dart:43-46`, `smart_learning_header.dart:40-43`,
  `session_summary_card.dart:56-59`, `learning_summary_screen.dart:207`,
  `home_screen.dart:205-208`, `progress_dashboard_screen.dart:555-557`
  — và nhiều hơn nữa) — `FontWeight.w700` chưa bao giờ được đặt tên
  thành 1 token, dù dùng nhất quán TUYỆT ĐỐI cùng 1 giá trị.
- **`quranTextStyle(fontSize: N, ...)`** (hàm dùng chung ở
  `app_theme.dart`) — gọi với cỡ chữ literal RẤT khác nhau tuỳ màn
  hình: 20 (`quiz_session_screen.dart:238`, nhánh Ả Rập), 22
  (`library_ayah_tile.dart:75`, `surah_list_screen.dart:347-350`), 24
  (`quiz_session_screen.dart:178-181`), 26
  (`home_screen.dart:539-542`, `review_session_screen.dart:138-139`),
  28 (`reading_screen.dart:600-604`, Basmalah), 30
  (`flashcard_review_screen.dart:124-125`) — cộng cỡ ĐỘNG
  `quranBaseFontSize(width) * scale` ở chính màn Đọc
  (`reading_screen.dart:691-694`). KHÔNG có thang cỡ chữ Qur'an dùng
  chung cho ngữ cảnh "phụ" (kết quả tìm kiếm/ôn tập/quiz/trang chủ) —
  mỗi nơi tự chọn 1 số.
- **`TextStyle` viết tay hoàn toàn** (bỏ qua `textTheme`): 3 khối ở
  `reading_screen.dart:915-950` (phiên âm/vi/en — tự đặt
  `fontFamily: AppTheme.latinFont`, `fontSize`, `height`,
  `letterSpacing` từng dòng).

**Duplicate count**: ~25+ (mẫu "tiêu đề đậm"); ~10 (cỡ `quranTextStyle`
literal khác nhau); 3 khối `TextStyle` viết tay.

**Can consolidate?**: Yes (mẫu "tiêu đề đậm" — có thể đặt trực tiếp
`fontWeight: FontWeight.w700` vào `titleSmall`/`titleMedium` trong
`ThemeData.textTheme` ở `app_theme.dart`, loại bỏ hàng chục
`.copyWith(fontWeight: FontWeight.w700)`); Partial (thang cỡ
`quranTextStyle` — cần 1 bộ hằng số đặt tên theo NGỮ CẢNH, không phải
1 giá trị chung, vì kích cỡ khác nhau CÓ ý nghĩa thị giác thật — màn
Đọc cần chữ lớn hơn 1 dòng kết quả tìm kiếm).

**Evidence**: Trích dẫn ở trên, phủ Home/Reading/Search/Stats/Analytics/
AI Tutor/Learning Journey/Smart Learning/Flashcards/Quiz/Review — có
mặt ở MỌI nhóm audit.

**Risk**: Thấp cho mẫu "tiêu đề đậm" NẾU đặt trong `ThemeData` (thay
đổi cộng dồn, không đổi số lần gọi `.copyWith` hiện có — chúng vẫn
hoạt động, chỉ trở nên dư thừa) — nhưng CẨN THẬN: `titleMedium`/
`titleSmall` cũng được dùng KHÔNG đậm ở vài nơi (vd
`assign_to_collection_sheet.dart:40-43`, `move_to_deck_sheet.dart:46-48`,
`ayah_actions_sheet.dart:59`, `add_flashcard_screen.dart:163` —
tiêu đề dialog/sheet, không đậm) — đặt đậm mặc định vào TOÀN BỘ
`titleMedium` sẽ đổi giao diện những nơi này ngoài ý muốn. Cần audit
kỹ hơn XEM tách `titleSmall`/`titleMedium` (đậm) khỏi 1 style dialog
riêng trước khi đổi ThemeData.

**Recommended shared component**: KHÔNG phải widget — mở rộng
`AppTheme` bằng 1-2 getter `TextStyle` được đặt tên (vd
`AppTheme.sectionTitleStyle(context)`) thay vì sửa `ThemeData.textTheme`
trực tiếp (an toàn hơn, không ảnh hưởng ngược các nơi dùng
`titleMedium` không đậm). Với `quranTextStyle`: thêm hằng số
`QuranTextScale.secondary/compact/hero` cạnh `quranBaseFontSize()`
hiện có.

**Priority**: Medium.

---

## 2. Card patterns

**Current implementations** — 2 khuôn mẫu rõ rệt:

**(A) Mặt phẳng TĨNH** — `Container(padding: EdgeInsets.all(N),
decoration: BoxDecoration(color: 1 token màu, borderRadius:
BorderRadius.circular(16)))`, N ∈ {12,14,16,18,20}:
- `StatCard` (dùng chung, đã gộp Sprint 20 Phase 2)
- `active_khatm_card.dart:26-32` (padding 20)
- `stats_screen.dart`: `_MetricCard` (174-179), `_WeeklyChartCard`
  (224-229), `_CompletionCard` (315-320) — 3 lớp trong CÙNG 1 file
- `reading_stats_section.dart`: `_StreakCard` (75-80),
  `_TodaySummaryCard` (127-133)
- `progress_dashboard_screen.dart`: `_HistorySection` container
  (344-349), `_AccuracyMetricCard` (606-611, nền `primaryContainer`)
- `goal_card.dart:38-43`, `achievement_card.dart:48-54` (biến thể
  width cố định 148 + màu điều kiện)
- `tutor_header.dart:35-40`, `journey_header.dart:27-32`,
  `smart_learning_header.dart:24-29`, `session_summary_card.dart:34-39`
  — **4 file, CÙNG 1 hình dạng hệt nhau**: `padding: all(20)`,
  `color: scheme.primaryContainer`, `borderRadius: circular(16)`,
  chứa Row(icon+title) rồi nội dung phụ
- `tutor_suggestion_card.dart:49-54`, `recommendation_card.dart:31-36`
  — cùng hình dạng `padding(14) + surfaceContainerLow + circular(16)`
- `journey_progress_card.dart:33-38` (padding 16)
- `learning_summary_screen.dart`: `_SummaryStatsCard` (117-123),
  `_ActivitiesCard` (195-201) — padding 18
- `flashcard_browse_screen.dart:383-389` (`_FirstFlashcardNudge`,
  padding 14, `primaryContainer.withValues(alpha: 0.5)`, radius 12 —
  gần khớp nhưng lệch alpha/radius)

**(B) Mặt phẳng CHẠM ĐƯỢC** — `Material(color: 1 token màu,
borderRadius: circular(N)) + InkWell(borderRadius: cùng N, onTap:)`,
N ∈ {14,16}:
- `home_screen.dart`: `_DailyGoalCard` (426-430, radius 16),
  `_RecentSurahCard` (591-599, radius 16)
- `result_card.dart:130-137` (radius 14)
- `surah_list_screen.dart`'s `SurahTile` dùng `ListTile` +
  `shape: RoundedRectangleBorder(borderRadius: circular(14))` (159) —
  biến thể thứ 3 của "chạm được" dùng `ListTile.shape` thay vì
  `Material`/`InkWell` trực tiếp
- `study_screen.dart:140-159` (`_StudyToolCard`, radius 16)
- `quiz_session_screen.dart:225-246` (`_OptionButton`, radius 14)
- `tutor_home_screen.dart:139-144` (`_JourneyEntryCard`) VÀ
  `learning_journey_screen.dart:162-167` (`_SmartLearningEntryCard`) —
  **GIỐNG HỆT TỪNG DÒNG**: `color: scheme.secondaryContainer.withValues(alpha: 0.6)`,
  `borderRadius: circular(16)`, dùng làm "thẻ điều hướng chéo tính
  năng" (AI Tutor → Learning Journey, Learning Journey → Smart
  Learning)
- `library_ayah_tile.dart:35-40` (radius 14)

**Đầu mối quan trọng**: `app_theme.dart`'s `cardTheme` ĐÃ khai báo
đúng hình dạng "thẻ" chuẩn (`elevation: isDark?1:0`,
`shape: RoundedRectangleBorder(borderRadius: circular(16))`,
`margin: EdgeInsets.symmetric(horizontal:16, vertical:6)`) — NHƯNG
**không màn hình nào trong ~45 file dùng widget `Card(...)` của
Flutter** (xác nhận bằng grep 0 kết quả ở 2/4 nhóm). Toàn bộ "thẻ" bị
tự tay dựng lại bằng `Container`/`Material` — cấu hình theme cho
`Card` hiện là CẤU HÌNH CHẾT (không widget nào tiêu thụ nó).

**Duplicate count**: (A) ~20 cài đặt độc lập; (B) ~9 cài đặt độc lập —
tổng **~30 lần** dựng lại 1 trong 2 hình dạng cơ bản.

**Can consolidate?**: Yes — mạnh mẽ, chia làm 2 mức ưu tiên:
1. **An toàn tuyệt đối, làm ngay được**: gộp 4 file
   `tutor_header.dart`/`journey_header.dart`/`smart_learning_header.dart`/
   `session_summary_card.dart` (đã xác nhận CÙNG 1 hình dạng
   `Container` bên ngoài) và gộp cặp `_JourneyEntryCard`/
   `_SmartLearningEntryCard` (đã xác nhận GIỐNG HỆT) — cả hai đã được
   CHỨNG MINH tương đương bằng cách đọc trực tiếp, đúng tinh thần
   "chỉ gộp khi tương đương" đã áp dụng ở `StatCard` (Sprint 20 Phase
   2).
2. **Cần xác minh từng cặp trước khi gộp rộng hơn**: phần còn lại của
   (A)/(B) — nhiều nơi gần giống nhưng KHÔNG được xác nhận giống hệt
   trong audit này (vd padding 14 vs 16 vs 18 vs 20 khác nhau CÓ CHỦ
   Ý ở vài nơi) — cần đọc từng cặp kỹ như đã làm với `StatCard`/
   `_AccuracyMetricCard` ở Sprint 20 Phase 2, KHÔNG gộp cưỡng ép.

**Risk**: Thấp cho 2 mục "an toàn tuyệt đối" ở trên (đã xác nhận
tương đương). Trung bình cho phần còn lại — rủi ro chính là ép các
biến thể padding/radius/alpha khác nhau vào 1 khuôn, làm mất tinh
chỉnh thị giác có chủ đích của từng nơi (bài học từ Sprint 20 Phase
3's quyết định KHÔNG gộp `_AccuracyMetricCard`/`TutorHeader`/
`JourneyProgressCard` vào `StatCard` dù "trông giống").

**Recommended shared component**: `lib/shared/widgets/surface_card.dart`
(khuôn A — tĩnh, tham số `padding`/`color token`/`child`) và
`lib/shared/widgets/tappable_surface_card.dart` (khuôn B — chạm được,
thêm `onTap`). Cân nhắc riêng: đổi cách dựng để 2 widget mới này ĐỌC
GIÁ TRỊ từ `Theme.of(context).cardTheme` (radius/margin) thay vì lặp
lại số 16 lần nữa — biến `cardTheme` từ cấu hình chết thành cấu hình
sống.

**Priority**: **Critical** (2 mục đã xác nhận tương đương — điểm khởi
đầu rõ ràng, rủi ro gần 0); **High** (phần mở rộng còn lại, cần thêm 1
lượt xác minh).

---

## 3. Section patterns

**Current implementations** — 2 khuôn:
- **`SectionHeader` dùng chung** (Sprint 20 Phase 2): `titleSmall +
  fontWeight.w700`, tự có `Semantics(header:true)`. Dùng ở
  `progress_dashboard_screen.dart` (5 lần: dòng 64,68,72,363,508),
  `tutor_home_screen.dart` (2 lần: 194,256), `learning_journey_screen.dart:111`,
  `smart_learning_screen.dart:120`, `smart_deck_screen.dart:148` — 5
  file, 10 lệnh gọi.
- **"Tiêu đề màu chủ đạo"** — `titleSmall?.copyWith(color:
  scheme.primary, fontWeight: FontWeight.w700)` — KHÁC `SectionHeader`
  (thêm màu) — cài đặt độc lập ở `search_result_section.dart:82-85`
  (tự nhận trong doc-comment là COPY từ `surah_list_screen.dart`),
  `surah_list_screen.dart:252-255` (bản gốc được copy), VÀ
  `profile_screen.dart`'s `_SectionLabel` (144-161, cùng công thức
  `titleSmall` + `colorScheme.primary`, không đậm tường minh nhưng
  cùng họ) — **3 cài đặt độc lập của CÙNG 1 biến thể màu**, chưa bao
  giờ gộp với nhau HAY với `SectionHeader`.

**Còn dùng dạng thô, TƯƠNG ĐƯƠNG `SectionHeader` nhưng chưa chuyển**:
`progress_dashboard_screen.dart:555-557` (tiêu đề trong
`ExpansionTile`, đúng công thức `titleSmall+w700` không màu — có thể
đổi sang `SectionHeader` ngay); `home_screen.dart`'s `_SectionTitle`
(165-190, CỐ Ý không gộp — dùng `titleMedium`, đã ghi rõ lý do trong
code, KHÔNG phải thiếu sót).

**Duplicate count**: 3 (biến thể màu); 1 (tương đương chưa chuyển).

**Can consolidate?**: Yes, cả hai, rủi ro thấp — biến thể màu có thể
trở thành 1 tham số tuỳ chọn mới trên `SectionHeader` hiện có (vd
`SectionHeader(text:, color: scheme.primary)`) thay vì widget mới;
`ExpansionTile` title có thể đổi thẳng sang `SectionHeader` (dù
`ExpansionTile.title` không nhận `Semantics(header:true)` một cách tự
nhiên — cần kiểm tra tương thích trước khi đổi, không giả định).

**Evidence**: Trích dẫn ở trên.

**Risk**: Thấp — mở rộng tham số cho widget dùng chung sẵn có, không
đổi 6 lệnh gọi hiện tại của `SectionHeader`.

**Recommended shared component**: Mở rộng `SectionHeader` hiện có
(`lib/shared/widgets/section_header.dart`) với tham số `Color?
color`.

**Priority**: High (khối lượng công việc nhỏ, hoàn tất 1 việc đã làm
80% ở Sprint 20 Phase 2).

---

## 4. Button patterns

**Current implementations**:
- **`_GradeButton`** (`FilledButton.tonal`, `backgroundColor:
  color.withValues(alpha:0.15)`, `foregroundColor: color`, `padding:
  EdgeInsets.symmetric(vertical:14)`) — định nghĩa **GẦN NHƯ Y HỆT** ở
  `flashcard_review_screen.dart:200-228` VÀ
  `review_session_screen.dart:203-231` — cùng 4 lần gọi cho
  Again/Hard/Good/Easy, cùng ánh xạ màu `scheme.error/tertiary/
  primary/secondary`.
- **Nút "Thử lại" hình dạng `SearchErrorState`** (`FilledButton.icon`,
  `icon: Icons.refresh`, `label: Text(l10n.retry)`) — tự cài lại ở
  `reading_screen.dart:1239-1243`, `library_tab_view.dart:112-116`,
  `surah_list_screen.dart:396-400` — xem thêm mục 7 (Error state).
- `SegmentedButton<T>` — 7 lần (`progress_dashboard_screen.dart`,
  `add_flashcard_screen.dart`, `search_screen.dart`,
  `surah_list_screen.dart`, `ayah_actions_sheet.dart`,
  `profile_screen.dart` ×2) — MỖI lần dùng enum/nội dung khác nhau,
  KHÔNG phải trùng lặp thật, chỉ là dùng đúng 1 widget Flutter nhiều
  nơi.
- `PopupMenuButton<T>` cho hành động dòng (đổi tên/xoá, chuyển deck/
  gỡ) — 6+ nơi (`flashcard_decks_screen.dart`, `collections_screen.dart`,
  `flashcard_tile.dart`, `flashcard_browse_screen.dart` ×3 cho bộ lọc)
  — hình dạng tương tự ("nút 3 chấm trailing mở menu") nhưng nội dung
  action luôn khác — giá trị gộp thấp hơn `_GradeButton`.
- `FloatingActionButton.extended` — 3 lần
  (`collections_screen.dart:50-54`, `flashcard_decks_screen.dart:51-55`,
  `flashcard_browse_screen.dart:194-198`) — cùng hình dạng "tạo mới",
  đã ngắn gọn, giá trị gộp thấp.

**Duplicate count**: 2 (`_GradeButton`); 3 (nút thử lại ad hoc, trùng
mục 7); ~6 (PopupMenuButton hành động dòng, giá trị gộp thấp).

**Can consolidate?**: Yes cho `_GradeButton` (2 file, đã xác nhận gần
như y hệt) — rủi ro thấp nhất trong toàn bộ audit này. No/Low value
cho `SegmentedButton`/`PopupMenuButton`/`FloatingActionButton.extended`
— đây là dùng ĐÚNG 1 widget Flutter tiêu chuẩn ở nhiều nơi, không
phải "trùng lặp" theo nghĩa cần gộp.

**Risk**: Thấp cho `_GradeButton` (2 điểm gọi, hành vi tách biệt qua
tham số `color`/`label`/`onPressed` đã có sẵn ở cả 2 bản).

**Recommended shared component**: `lib/shared/widgets/grade_button.dart`
(trích xuất `_GradeButton` dùng chung cho Flashcard Review + Review
Session).

**Priority**: **Critical** (`_GradeButton` — thắng nhanh, rủi ro gần
0); Low cho phần còn lại của hạng mục này (đã là dùng đúng widget
chuẩn, không cần thêm lớp bọc).

---

## 5. Loading patterns

**Current implementations**:
- **`LoadingState` dùng chung**: `home_screen.dart` (2), `progress_dashboard_screen.dart`
  (5), `tutor_home_screen.dart` (3), `learning_journey_screen.dart` (1),
  `smart_learning_screen.dart` (1) = **5 file, 12 lệnh gọi**.
- **`CircularProgressIndicator()` trần, KHÔNG `LoadingState`**:
  `reading_screen.dart:263`, `audio_bar.dart:116-126,193-196` (2 chỗ),
  `collections_screen.dart:27`, `assign_to_collection_sheet.dart:45-49`,
  `library_tab_view.dart:33`, `flashcard_decks_screen.dart:29`,
  `flashcard_browse_screen.dart:63`, `smart_deck_screen.dart:73,123`
  (2 chỗ), `flashcard_review_screen.dart:32`, `add_flashcard_screen.dart:122`,
  `quiz_session_screen.dart:44`, `review_session_screen.dart:34`,
  `move_to_deck_sheet.dart:54-58`, `surah_list_screen.dart:42,259-262`
  (2 chỗ), `reading_stats_section.dart:93-97,172-181` (2 chỗ, cỡ nhỏ
  22×22), `active_khatm_card.dart:45-54` (cỡ nhỏ 22×22),
  `learning_session_screen.dart:115-124` — **~21 lệnh gọi**, NHIỀU HƠN
  số lệnh gọi dùng `LoadingState`.

**Duplicate count**: ~21 (không dùng widget dùng chung dù đã có sẵn từ
Sprint 15 Phase 2).

**Can consolidate?**: Yes, phần lớn — thay thế trực tiếp, đúng khuôn
mẫu Sprint 20 Phase 2 đã áp dụng cho `home_screen.dart`. Ngoại lệ cần
cân nhắc riêng: các biến thể "cỡ nhỏ 22×22" (`reading_stats_section.dart`,
`active_khatm_card.dart`) dùng trong ngữ cảnh chật hẹp (1 chip nhỏ) —
`LoadingState` mặc định `height: 96`, có tham số `height` tuỳ chỉnh
nên VẪN dùng được, nhưng cần xác nhận 22px hợp lý về mặt UX trước khi
đổi (khác biệt chủ đích hay chỉ là code cũ).

**Evidence**: Trích dẫn ở trên — phủ 15+ file trên toàn app.

**Risk**: Thấp — `LoadingState` là thay thế "cắm vào là chạy", đã
được kiểm chứng an toàn qua Sprint 20 Phase 2. Cần thêm 1 khoá l10n
`semanticsLabel` mới cho MỖI màn hình/phần chưa có (việc máy móc,
không rủi ro thiết kế).

**Recommended shared component**: KHÔNG cần widget mới —
`LoadingState` đã tồn tại, chỉ cần đợt "adoption sweep" áp dụng rộng,
đúng mẫu Sprint 20 Phase 2's Task 5 (Home) nhưng áp dụng cho ~15 file
còn lại.

**Priority**: High (khối lượng lớn, rủi ro thấp, hạ tầng đã có sẵn —
không Critical vì đây là khoảng trống ĐỒNG NHẤT/ACCESSIBILITY, không
phải lỗi chức năng — hầu hết vẫn HIỂN THỊ spinner đúng, chỉ thiếu nhãn
accessibility).

---

## 6. Empty state patterns

**Current implementations**:
- **`EmptyStateBanner` dùng chung**: `progress_dashboard_screen.dart`
  (2: dòng 104-106, 426-429), `tutor_home_screen.dart:202-204`,
  `learning_journey_screen.dart:113-114`, `smart_learning_screen.dart:99-100`
  = 4 file, 5 lệnh gọi.
- **"Rỗng đầy đủ" ad hoc — Icon(56) + SizedBox + Text, giữa màn hình,
  padding 24, KHÔNG nền màu** (khác hình dạng `EmptyStateBanner` —
  banner có icon nhỏ(20)+nền màu+dạng Row ngang, nhóm này Icon lớn+
  Column dọc, không nền): `surah_list_screen.dart:408-434`
  (`_EmptyState`), `library_tab_view.dart:68-91` (`_EmptyState`, GẦN
  NHƯ Y HỆT `surah_list_screen`'s bản), `flashcard_browse_screen.dart:325-369`
  (`_NoFlashcardsEmptyState`, có thêm CTA button).
- **Chỉ chữ, KHÔNG icon**: `flashcard_decks_screen.dart:32-42`,
  `smart_deck_screen.dart:76-83,126-133` (2 chỗ, cùng
  `l10n.smartDeckEmpty`), `add_flashcard_screen.dart:125-135`,
  `collections_screen.dart:30-39`.
- **Đã tự nhận trùng lặp từ trước** (Sprint 15 Phase 2's doc-comment):
  `stats_screen.dart`'s `_EmptyHint` (122-157) — hình Row giống
  `EmptyStateBanner` gần như y hệt, CHƯA gộp qua nhiều sprint.
- **Thiếu hoàn toàn** (đã ghi nhận ở accessibility_audit.md, còn
  nguyên): Goals/Achievements (`progress_dashboard_screen.dart`),
  Insights (`tutor_home_screen.dart`), stats của
  `JourneyProgressCard`.

**Duplicate count**: 3 (nhóm "rỗng đầy đủ" Icon+Column); 5 (nhóm chỉ
chữ); 1 (đã biết từ trước, `_EmptyHint`).

**Can consolidate?**: Partial — nhóm "chỉ chữ" CÓ THỂ chuyển thẳng
sang `EmptyStateBanner` (tương đương, chỉ thiếu icon/nền — chấp nhận
được, `EmptyStateBanner` có icon mặc định hợp lý). Nhóm "rỗng đầy đủ"
KHÔNG nên ép vào `EmptyStateBanner` — trọng lượng thị giác khác hẳn
(chiếm giữa màn hình vs 1 dải ngang gọn) — cần 1 widget MỚI riêng cho
trường hợp "màn hình/tab rỗng hoàn toàn" (khác "1 phần trong màn hình
lớn hơn bị rỗng").

**Risk**: Thấp (nhóm chỉ chữ → `EmptyStateBanner`, dù đây có thể là
CẢI THIỆN giao diện chứ không chỉ hợp nhất code — nên xác nhận với
người có thẩm quyền thiết kế trước khi coi là "an toàn tuyệt đối như
cũ"). Trung bình (thiết kế widget "rỗng đầy đủ" mới — cần xác nhận 3
cài đặt hiện tại THỰC SỰ tương đương trước khi gộp, tương tự cách
`StatCard` đã làm).

**Recommended shared component**: (1) Áp dụng `EmptyStateBanner` cho
nhóm "chỉ chữ" (5 file). (2) Tạo MỚI (ở phase sau, không phải audit
này) `lib/shared/widgets/full_empty_state.dart` cho nhóm "rỗng đầy đủ"
sau khi xác nhận tương đương giữa `surah_list_screen._EmptyState` và
`library_tab_view._EmptyState`.

**Priority**: High.

---

## 7. Error state patterns

**Đây là phát hiện lớn nhất của toàn bộ audit.**

**Current implementations**:
- **`SearchErrorState` dùng chung**: `home_screen.dart` (2),
  `tutor_home_screen.dart` (3), `progress_dashboard_screen.dart` (5),
  `learning_journey_screen.dart` (1), `smart_learning_screen.dart`
  (1), `search_screen.dart` (1, chỉ đường debug) = 6 file, **13 lệnh
  gọi**.
- **Tự cài lại GIỐNG HỆT hình dạng `SearchErrorState`** (Icon size 56
  color error + SizedBox 12 + Text + SizedBox 16 + `FilledButton.icon`
  refresh+retry) mà KHÔNG import nó:
  - `reading_screen.dart:1207-1249` (`_ReadingErrorState`)
  - `surah_list_screen.dart:378-406` (`_ErrorState`)
  - `library_tab_view.dart:93-122` (`_ErrorState`)
  
  Cả 3 đọc trực tiếp cho thấy cấu trúc GIỐNG HỆT `search_error_state.dart:34-97`'s
  `Column(Icon(size:56,color:scheme.error), SizedBox(12), Text(...),
  SizedBox(16), FilledButton.icon(refresh, retry))` — chỉ khác Ở CHỖ
  không đi qua widget dùng chung.
- **Chỉ chữ, KHÔNG icon, KHÔNG nút thử lại**:
  `collections_screen.dart:28`, `flashcard_decks_screen.dart:30`,
  `flashcard_browse_screen.dart:64`, `smart_deck_screen.dart:74,124`
  (2), `add_flashcard_screen.dart:123`,
  `assign_to_collection_sheet.dart:50-53`,
  `move_to_deck_sheet.dart:59-62` — **8+ lệnh**.
- **Chữ có màu `colorScheme.error`, KHÔNG icon, KHÔNG nút thử lại**:
  `flashcard_review_screen.dart:33-38`, `quiz_session_screen.dart:45-50`,
  `review_session_screen.dart:35-40`, `active_khatm_card.dart:55-58`,
  `reading_stats_section.dart:182-185` — **5 lệnh**.
- **Icon TRẦN, KHÔNG chữ, KHÔNG nút** (đã ghi nhận là điểm tệ nhất ở
  accessibility_audit.md, còn nguyên): `reading_stats_section.dart:98-101`.
- **Hình dạng khác biệt CÓ CHỦ Ý** (banner ngang cố định ở cuối màn
  hình, không phải trạng thái toàn phần): `audio_bar.dart:47-76` —
  hợp lý giữ riêng (ngữ cảnh khác: lỗi phát audio khi đang đọc, không
  che nội dung).

**Duplicate count**: **3 bản GIỐNG HỆT** `SearchErrorState` + **13+
biến thể rút gọn** = tổng **~17 cài đặt độc lập** so với 13 lệnh gọi
widget dùng chung — nghĩa là ĐA SỐ các trạng thái lỗi trong app KHÔNG
đi qua widget dùng chung dù nó đã tồn tại và phù hợp.

**Can consolidate?**: Yes, mạnh mẽ.
1. 3 bản giống hệt → thay thế trực tiếp bằng `SearchErrorState`, rủi
   ro gần 0 (đã xác nhận tương đương).
2. Nhóm chỉ-chữ/có-màu → `SearchErrorState(onRetry: null_hoặc_callback)`
   — widget đã hỗ trợ ẩn nút khi `onRetry == null`, chỉ cần xác nhận
   THÊM 1 icon vào các màn hình hiện chưa có (cải thiện, cần xác nhận
   phạm vi trước khi coi là "chỉ hợp nhất, không đổi giao diện").
3. Icon-trần (`_StreakCard`) → đã là blocker mềm ghi nhận từ Sprint
   20, ưu tiên sửa cùng đợt.

**Risk**: Thấp cho mục (1). Thấp-Trung bình cho mục (2)/(3) — thêm
icon là thay đổi giao diện dù nhỏ, không phải "chỉ refactor code".

**Recommended shared component**: `SearchErrorState` đã tồn tại,
KHÔNG cần widget mới — chỉ cần đợt "adoption sweep" áp dụng rộng.
Đồng thời nhắc lại đề xuất đã ghi ở `accessibility_audit.md`: đổi tên
+ di chuyển `SearchErrorState` ra khỏi `features/search/` (tên gọi
không còn khớp phạm vi dùng thực tế — giờ có tới ~20 điểm gọi tiềm
năng ngoài Search).

**Priority**: **Critical** (3 bản giống hệt); **High** (phần còn
lại).

---

## 8. List item patterns

**Current implementations**:
- **`ListTile` tiêu chuẩn** (không tuỳ biến): `profile_screen.dart` ×6
  (93-136), `assign_to_collection_sheet.dart:62-67` (dòng "tạo mới"),
  `ayah_actions_sheet.dart` ×3 (copy Ả Rập/copy dịch/note) +
  `SwitchListTile` ×2 (bookmark/favorite), `reading_screen.dart` ×3
  `SwitchListTile` (cài đặt hiển thị), `audio_bar.dart:222-226`
  (`RadioListTile`, chọn giọng đọc), `move_to_deck_sheet.dart:75-80,100-123`
  (`_DeckChoiceTile` + dòng "tạo mới"),
  `assign_to_collection_sheet.dart:104-116` (`CheckboxListTile`).
- **`ListTile` tuỳ biến "thẻ sưu tập có tên"** — `leading:
  CircleAvatar(...)`, `title: Text(name)`, `subtitle: Text(số lượng)`,
  `trailing: PopupMenuButton(rename/delete)`:
  `flashcard_decks_screen.dart:79-101` (`_DeckTile`) VÀ
  `collections_screen.dart:85-107` (`_CollectionTile`) — **CẤU TRÚC Y
  HỆT**, chỉ khác nội dung icon/tên field.
- **`ListTile` tuỳ biến "thẻ tuỳ chỉnh"**:
  `add_flashcard_screen.dart:159-189` (`_LemmaResultTile`),
  `flashcard_tile.dart:34-83` (`FlashcardTile`, có
  `Tooltip`+`Semantics`+`CircleAvatar` chấm màu trạng thái — đã sửa ở
  Sprint 20 Phase 2 Task 6), `surah_list_screen.dart:156-213`
  (`SurahTile`, dùng thêm `shape`/`hoverColor`/`splashColor`).
- **KHÔNG dùng `ListTile`, tự dựng hàng tuỳ biến**:
  `library_ayah_tile.dart`, `result_card.dart`,
  `surah_list_screen.dart:289-376` (`_AyahResultTile`),
  `study_screen.dart:140-159`... (`_StudyToolCard`, dạng lưới không
  phải danh sách nhưng cùng hình "icon+title+subtitle+trailing").

**Duplicate count**: 2 (`_DeckTile`/`_CollectionTile` — CẤU TRÚC y
hệt); phần còn lại là dùng widget Flutter tiêu chuẩn đúng cách, KHÔNG
phải trùng lặp cần gộp.

**Can consolidate?**: Yes cho cặp `_DeckTile`/`_CollectionTile`
(phạm vi nhỏ, 2 file, rủi ro thấp). No/không cần cho phần còn lại —
mỗi `ListTile` phục vụ nội dung miền khác nhau thật sự, ép vào 1 wrapper
chung sẽ chỉ thêm tầng gián tiếp không cần thiết.

**Risk**: Thấp cho cặp Deck/Collection.

**Recommended shared component**: `lib/shared/widgets/named_entity_tile.dart`
(icon/emoji avatar + tên + phụ đề số lượng + menu đổi tên/xoá) dùng
chung cho Flashcard Decks và Bookmark Collections.

**Priority**: Medium.

---

## 9. Animation patterns

**Current implementations** — RẤT hạn chế trên toàn app (xác nhận
bằng grep 0 kết quả `AnimatedOpacity`/`AnimatedSwitcher`/`Hero`/
`TweenAnimationBuilder`/`AnimationController` tường minh ở 2/4 nhóm,
0 kết quả tuyệt đối ở nhóm Analytics/AI Tutor/Learning
Journey/Smart Learning/Profile):
- **`AnimatedContainer` "cột biểu đồ"** — `progress_dashboard_screen.dart:458-469`
  (biểu đồ lịch sử học tập, 300ms,
  `height: maxMinutes==0?4:4+76*(minutes/maxMinutes)`, màu điều kiện
  `scheme.primary`/`scheme.surfaceContainerHighest`, `borderRadius:
  circular(6)`) VÀ `stats_screen.dart:264-276` (biểu đồ tuần, CÙNG
  300ms, CÙNG công thức chiều cao dạng `4 + N*(value/max)`, CÙNG
  `borderRadius: circular(6)`) — **2 cài đặt độc lập của CÙNG 1 khái
  niệm "cột biểu đồ hoạt hình"**.
- `reading_screen.dart:743-767` — `AnimatedContainer` 250ms (hiệu ứng
  hover thẻ Ayah, đổi màu/viền/bóng đổ) — không có bản sao ở nơi khác.
- `reading_screen.dart:1129-1132` — `AnimatedScale` 120ms (icon hành
  động phóng to khi hover) — không có bản sao.
- `reading_screen.dart:186-191` — cuộn lập trình
  `ItemScrollController.scrollTo(duration: 350ms, curve:
  easeOutCubic)` — không có bản sao.
- `quiz_session_screen.dart:143-150` — `SnackBar(duration: 700ms)` —
  không phải animation thật sự, chỉ 1 UI tạm thời có hẹn giờ.

**Duplicate count**: 2 (cột biểu đồ hoạt hình).

**Can consolidate?**: Yes cho cặp "cột biểu đồ" — công thức chiều cao
+ thời lượng + bo góc giống nhau đủ để trích thành 1 widget
`ChartBar`/`AnimatedBarChart` dùng chung.

**Risk**: Thấp-Trung bình — cần xác nhận công thức `4 + K*(value/max)`
có hằng số `K` giống nhau thật (76 ở Analytics, cần đối chiếu số ở
Stats trước khi gộp — audit này KHÔNG xác nhận số đó có khớp
`76`).

**Recommended shared component**: `lib/shared/widgets/animated_chart_bar.dart`.
Đồng thời ghi nhận: KHÔNG có hằng số thời lượng animation dùng chung
(120/250/300/350/700ms rải rác, không đặt tên) — cân nhắc
`AppDurations.fast/medium/slow` ở 1 phase tương lai, giá trị thấp hơn
việc gộp widget.

**Priority**: Medium (nhân bản thật nhưng nhỏ, ít rủi ro chức năng).

---

## 10. Spacing patterns

**Current implementations**:
- Bộ giá trị `SizedBox`/`EdgeInsets` lặp lại xuyên suốt TOÀN BỘ ~45
  file: `2,3,4,6,8,10,12,14,16,18,20,24,28,32` — nhất quán cao (gần
  như luôn là bội số của 2, thường của 4) nhưng KHÔNG được đặt tên
  thành hằng số ở bất kỳ đâu — mỗi nơi tự viết số literal.
- **Mẫu "padding ngang responsive theo bề rộng"** —
  `constraints.maxWidth > N ? (constraints.maxWidth - M) / 2 :
  default` — xuất hiện ĐỘC LẬP với các cặp (N, M) KHÁC NHAU:
  - `home_screen.dart` — (760, 720), mặc định 16.0
  - `progress_dashboard_screen.dart:54-56` — (900, 860), mặc định 16.0
  - `tutor_home_screen.dart` — cùng công thức (chưa xác nhận số chính
    xác trong audit này, cần đối chiếu)
  - `study_screen.dart:73-75` — (900, 860), mặc định 16.0
  - `library_tab_view.dart:44-46` — (720, 704), mặc định **8.0** (khác
    hẳn 16.0 ở nơi khác)
  - `learning_journey_screen.dart`/`smart_learning_screen.dart` — cùng
    công thức, số cần đối chiếu thêm

  Đây là **CÙNG 1 khái niệm bố cục** ("giới hạn bề rộng nội dung, căn
  giữa trên màn hình rộng") bị viết tay LẶP LẠI với các ngưỡng breakpoint
  KHÔNG THỐNG NHẤT (760 vs 900, mặc định 8 vs 16) — nhiều khả năng là
  trôi dạt do copy-paste hơn là chủ đích thiết kế khác nhau cho từng
  màn hình.

**Duplicate count**: ~7+ cài đặt độc lập của mẫu responsive-padding,
với ít nhất 3 tổ hợp số khác nhau.

**Can consolidate?**: Yes cho mẫu responsive-padding — trích thành 1
hàm/widget dùng chung. **NHƯNG cần 1 quyết định thiết kế trước
(ngưỡng/mặc định nào là "đúng")** — không phải việc trích xuất cơ học
đơn thuần, vì các con số hiện KHÁC nhau thật.

**Risk**: Trung bình — khác mọi mục khác trong audit này, đây là
trường hợp DUY NHẤT nơi "gộp lại" chắc chắn sẽ ĐỔI hành vi hiển thị ở
ít nhất vài màn hình (vd `library_tab_view.dart`'s padding mặc định 8
sẽ đổi thành 16 nếu áp 1 chuẩn chung) — cần người có thẩm quyền thiết
kế quyết định GIÁ TRỊ chuẩn trước khi bất kỳ ai trích xuất.

**Recommended shared component**: `lib/shared/layout/responsive_content_width.dart`
— NHƯNG khuyến nghị: audit tiếp theo (không phải phase này) nên trước
tiên liệt kê ĐẦY ĐỦ mọi cặp (N, M, mặc định) hiện có trên toàn app rồi
mới quyết định 1 chuẩn.

**Priority**: High (đây là bất nhất CÓ THỂ NHÌN THẤY được bằng mắt
thường khi đổi cỡ màn hình, gần với "lỗi" hơn các mục thẩm mỹ khác
trong audit này) nhưng gắn cờ rõ: cần quyết định thiết kế trước khi
thực thi, không tự động hoá mù quáng.

---

## 11. Color token usage

**Current implementations**: Kỷ luật GẦN NHƯ HOÀN HẢO trên toàn bộ
~45 file khảo sát — `Theme.of(context).colorScheme.X` (hoặc biến cục
bộ `scheme.X`) được dùng ở MỌI nơi cần màu, không có ngoại lệ đáng kể.
4 trường hợp "không qua token" tìm được, TẤT CẢ đều hợp lý có chủ ý:
1. `ayah_actions_sheet.dart:10-17` — `kHighlightColorValues`, bảng 6
   màu hex CỐ ĐỊNH (`Color(0xFFFFC107)` v.v.) cho tính năng đánh dấu
   màu — ĐÚNG bản chất (màu highlight cần cố định, không đổi theo
   theme sáng/tối, giống bảng màu highlighter thật).
2. `Colors.transparent` — `home_screen.dart:233`
   (`_ContinueReadingCard`'s `Material.color`),
   `progress_dashboard_screen.dart:551` (`dividerColor` override cho
   `ExpansionTile`) — ngữ nghĩa "trong suốt" không cần token màu.
3. `Colors.black.withValues(alpha:...)` — `reading_screen.dart:760-761`
   (bóng đổ thẻ Ayah khi hover) — quy ước Material tiêu chuẩn (bóng đổ
   luôn đen, không theo theme), đáng lưu ý cho dark mode nhưng KHÔNG
   phải lỗi.
4. `Colors.white` — `ayah_actions_sheet.dart:305` (icon dấu tick trên
   chấm màu highlight tuỳ ý) — cần luôn tương phản với màu NỀN TUỲ Ý
   (không phải nền theme), hợp lý.

**Duplicate count**: N/A (hạng mục nhất quán, không phải trùng lặp).

**Can consolidate?**: No — không cần hành động, đã đạt chuẩn. Việc
DUY NHẤT đáng làm: ghi chú rõ 4 ngoại lệ trên là CÓ CHỦ Ý, để lần
review sau không nhầm là vi phạm.

**Evidence**: Xác nhận bằng grep `Colors.`/`Color(0x` chéo cả 4 nhóm
audit — chỉ đúng 4 vị trí liệt kê trên trong TOÀN BỘ ~45 file.

**Risk**: N/A.

**Recommended shared component**: Không cần.

**Priority**: Low (không phải vì không quan trọng — ngược lại, đây là
điểm mạnh kiến trúc CẦN GIỮ NGUYÊN — mà vì không có việc gì cần làm).

---

## 12. Border radius usage

**Current implementations** — bảng tần suất `BorderRadius.circular(N)`
quan sát được trên toàn app:

| N | Vai trò quan sát được | Số nơi (ước tính, không đếm hết) |
|---|---|---|
| 6 | "Cột biểu đồ" (mục 9) | 3 (chart bar, search skeleton bar) |
| 10 | Hộp ghi chú/annotation nhỏ | 2 (`library_ayah_tile.dart`, `reading_screen.dart`) |
| 12 | Banner/gợi ý nhỏ gọn | 3+ (`EmptyStateBanner`, `_EmptyHint`, `_FirstFlashcardNudge`) |
| 14 | Thẻ "chạm được" (mục 2, khuôn B) | 8+ |
| 16 | Thẻ "tĩnh" (mục 2, khuôn A) — **giá trị phổ biến NHẤT app** | 20+ |
| 20 | Thẻ hero/nổi bật lớn | 2-3 (`home_screen._TodaysVerseCard`, `_ContinueReadingCard`) |
| 24 | Thẻ hero/nổi bật lớn (thay thế) | 1 (`reading_screen._SurahHeader`) |
| 999 | Hình viên thuốc/chip tròn | 8+ (nhất quán tốt) |

**Điểm bất nhất đáng chú ý**: 20 VÀ 24 CÙNG được dùng cho cùng 1 vai
trò "thẻ lớn/hero" ở các màn hình khác nhau — không rõ có chủ đích hay
trôi dạt.

**Duplicate count**: N/A trực tiếp (đây là hạng mục "đặt tên giá trị
đã nhất quán", không phải "sửa trùng lặp") — NGOẠI TRỪ cặp 20/24 cần
đối chiếu.

**Can consolidate?**: Yes (đặt tên) — các giá trị ĐÃ nhất quán cao độ
(đặc biệt 16 và 999), chỉ thiếu tên gọi chính thức. Cặp 20/24 cần 1
quyết định (chọn 1 trong 2) trước khi đặt tên.

**Risk**: Thấp — đặt tên hằng số không đổi giá trị hiện tại (trừ khi
đồng thời quyết định thống nhất 20/24).

**Recommended shared component**: Hằng số trong `AppTheme` (vd
`AppTheme.radiusChart = 6`, `radiusCompact = 12`, `radiusTappable =
14`, `radiusCard = 16`, `radiusHero = 20`, `radiusPill = 999`) — nên
làm ĐỒNG THỜI với việc dựng 2 widget thẻ dùng chung ở mục 2, không
làm riêng lẻ.

**Priority**: Medium (tốt nhất gộp chung với công việc mục 2).

---

## 13. Elevation usage

**Current implementations** — gần như KHÔNG dùng trên toàn app (xác
nhận bằng grep `elevation:` cho kết quả 0 ở 2/4 nhóm, và chỉ 3 vị trí
tổng cộng ở 2 nhóm còn lại):
- `audio_bar.dart:33` — `elevation: 3` trên `Material` bọc thanh phát
  audio cuối màn hình (**DUY NHẤT** nơi dùng elevation dương trong
  toàn bộ ~45 file khảo sát).
- `search_screen.dart:203`, `surah_list_screen.dart:84` —
  `elevation: const WidgetStatePropertyAll(0)` trên `SearchBar` — chủ
  động dẹp phẳng elevation MẶC ĐỊNH của Material, không phải dùng
  elevation.
- `app_theme.dart`'s `appBarTheme`: `elevation: 0, scrolledUnderElevation: 2`
  — mặc định toàn app (AppBar phẳng, chỉ nổi nhẹ khi cuộn).
- `app_theme.dart`'s `cardTheme`: `elevation: isDark ? 1 : 0` — **cấu
  hình CHẾT** (xem mục 2 — không màn hình nào dùng widget `Card` để
  tiêu thụ giá trị này).

**Toàn bộ "chiều sâu thị giác" của app đạt được qua ĐỐI LẬP MÀU NỀN
(surfaceContainerLow/primaryContainer/secondaryContainer trên nền
surface) — KHÔNG qua elevation/bóng đổ Material** — ngoại lệ DUY NHẤT
là `reading_screen.dart`'s `boxShadow` viết tay cho hiệu ứng hover thẻ
Ayah (mục 2/9).

**Duplicate count**: N/A (hạng mục nhất quán).

**Can consolidate?**: No hành động code cần thiết — đây là 1 lựa chọn
thiết kế NHẤT QUÁN (thiết kế phẳng/tonal Material 3), không phải thiếu
sót. DUY NHẤT đáng làm: xoá hoặc ghi chú rõ `cardTheme.elevation` là
cấu hình dự phòng cho TƯƠNG LAI (nếu widget `Card` dùng chung ở mục 2
được dựng và THỰC SỰ dùng `Card(...)` thay vì `Container` viết tay).

**Risk**: N/A.

**Recommended shared component**: Không cần widget mới. Ghi chú tài
liệu: xác nhận `cardTheme` là "cấu hình sẵn sàng, chờ mục 2's widget
thẻ dùng chung tiêu thụ" thay vì xoá nó đi (giữ cho tương lai).

**Priority**: Low.

---

## Tổng hợp ưu tiên (toàn bộ 13 hạng mục)

| Ưu tiên | Hạng mục | Vì sao |
|---|---|---|
| **Critical** | Card patterns (nhóm đã xác nhận tương đương: 4-file header trio + entry-card pair) | Rủi ro gần 0, đã chứng minh giống hệt bằng cách đọc trực tiếp |
| **Critical** | Error state patterns (3 bản giống hệt `SearchErrorState`) | Rủi ro gần 0, widget dùng chung đã tồn tại và đã chứng minh phù hợp |
| **Critical** | Button patterns (`_GradeButton`) | 2 file, gần như y hệt, rủi ro thấp nhất toàn audit |
| High | Section patterns | Hoàn tất phần việc Sprint 20 Phase 2 đã làm 80% |
| High | Loading patterns | Khối lượng lớn (~21 nơi), hạ tầng đã sẵn sàng |
| High | Empty state patterns | Khối lượng lớn, cần 1 widget mới cho nhóm "rỗng đầy đủ" |
| High | Error state patterns (13+ biến thể rút gọn còn lại) | Cùng vấn đề gốc, số lượng lớn hơn |
| High | Spacing patterns (responsive padding) | Bất nhất NHÌN THẤY ĐƯỢC, nhưng cần quyết định thiết kế trước |
| High | Card patterns (phần mở rộng, ~28 nơi còn lại) | Giá trị lớn nhất toàn audit nhưng cần xác minh từng cặp |
| Medium | Typography | Khối lượng lớn nhưng rủi ro cần cẩn thận (titleMedium dùng cho cả dialog không đậm) |
| Medium | List item patterns (Deck/Collection tile) | Phạm vi nhỏ, giá trị vừa phải |
| Medium | Animation patterns | Nhân bản thật nhưng quy mô nhỏ |
| Medium | Border radius usage | Tốt nhất làm cùng đợt với Card patterns |
| Low | Color token usage | Đã đạt chuẩn — không có việc phải làm |
| Low | Elevation usage | Đã nhất quán — không có việc phải làm |

## Điều KHÔNG nên làm (ghi nhận rõ, tránh hiểu lầm)

- **KHÔNG** ép `_AccuracyMetricCard`/`TutorHeader`'s mục thống kê/
  `JourneyProgressCard`'s mục thống kê vào `StatCard` — đã được xác
  nhận KHÔNG tương đương ở Sprint 20 Phase 2, quyết định đó vẫn đúng.
- **KHÔNG** tự động thống nhất mọi giá trị padding/radius/breakpoint
  khác nhau thành 1 số — 1 số khác biệt (vd width cố định 132 ở
  `JourneyProgressCard`, padding 148 ở `AchievementCard`) có khả năng
  là chủ đích bố cục, không phải lỗi — CẦN xác minh từng trường hợp
  như đã làm ở Sprint 20 Phase 2, không suy đoán từ audit này.
- **KHÔNG** đổi `home_screen.dart`'s `_SectionTitle` — đã ghi rõ lý do
  cố ý khác biệt trong chính mã nguồn.
- **KHÔNG** coi kỷ luật color-token/elevation là "cần cải thiện" — đây
  là 2 điểm mạnh kiến trúc, mục tiêu là GIỮ NGUYÊN, không phải sửa.

## Phạm vi CHƯA khảo sát (ngoài audit này)

- Widget test coverage cho các thành phần UI hiện có — không thuộc
  phạm vi "design system audit".
- Dark mode / độ tương phản thực tế qua ảnh chụp màn hình — audit này
  chỉ đọc mã nguồn, không render/so sánh hình ảnh.
- RTL (tiếng Ả Rập) layout mirroring cho các widget mới ĐỀ XUẤT (chưa
  tồn tại, không có gì để kiểm).
- `lib/shared/utils/` (simple_markdown.dart, text_folding.dart,
  highlight.dart, transliteration.dart) — các hàm xử lý văn bản thuần,
  không thuộc phạm vi "design system" (không phải widget/style).
