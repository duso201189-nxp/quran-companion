# Repository engineering standard — Qur'an Companion

Tài liệu THƯỜNG TRỰC (không phải báo cáo 1 lần) — quy tắc kỹ thuật mà
MỌI người đóng góp tương lai (con người hay AI) phải tuân theo. Viết ở
Sprint 21.3, TRƯỚC KHI bất kỳ refactor Design System nào bắt đầu, theo
đúng yêu cầu gốc.

Mọi quy tắc dưới đây bắt nguồn từ BẰNG CHỨNG đã có trong chính repo
này — `CLAUDE.md`, `ARCHITECTURE.md`, `PROJECT_CONSTITUTION.md`, và
lịch sử thực thi Sprint 14-21 (đặc biệt: chuỗi 5 tầng Repository,
tầng reliability Sprint 19, 2 đợt audit + kế hoạch hợp nhất Sprint
20-21). KHÔNG có yêu cầu sản phẩm mới nào được phát minh ở đây —
tài liệu này CHỈ hệ thống hoá lại điều đã được thực thi nhất quán.

Nếu tài liệu này lệch với `CLAUDE.md`/`ARCHITECTURE.md`, 2 file đó
thắng (đúng nguyên tắc "orients, does not restate" mà `CLAUDE.md` tự
đặt ra cho chính nó — tài liệu này áp dụng CÙNG nguyên tắc cho bản
thân nó).

---

## 1. Repository Philosophy

- **Từng bước nhỏ, có cổng kiến trúc (phase-gated).** Toàn bộ lịch sử
  Sprint 14-21 vận hành theo mẫu: 1 chỉ thị Sprint N / Phase M với
  Goal/Tasks/Requirements/Testing/Return rõ ràng, kết thúc bằng "STOP,
  wait for architecture review" — KHÔNG được tự ý tiến sang phase kế
  tiếp. Đây không phải phong cách viết prompt, mà là TRIẾT LÝ vận
  hành: mỗi thay đổi kiến trúc phải được xác nhận trước khi thay đổi
  tiếp theo dựa vào nó.
- **"Reuse everything" là mặc định, không phải ngoại lệ.** Mọi Sprint
  kể từ Sprint 15 đều lặp lại chỉ thị "KHÔNG redesign X, tái dùng toàn
  bộ" — điều này phản ánh 1 giả định nền: kiến trúc ĐÃ ĐƯỢC PHÊ DUYỆT
  ở phase trước là ỔN ĐỊNH, thay đổi nó cần lý do rõ ràng và được yêu
  cầu tường minh, không phải "tiện thể sửa luôn".
- **Tài liệu hoá quyết định NGAY TẠI CHỖ, không chỉ trong báo cáo.**
  Mọi lựa chọn không hiển nhiên (tại sao KHÔNG gộp `_AccuracyMetricCard`
  vào `StatCard`, tại sao `EmptyStateBanner` khác `LoadingState` ở 1
  điểm) đều có doc-comment giải thích NGAY tại class đó — không chỉ
  nằm trong Return report của phase đã hoàn tất và bị quên sau đó.
- **Không đoán — đọc.** Xuyên suốt lịch sử dự án, MỌI audit
  (accessibility, design system) và MỌI quyết định gộp/không gộp code
  đều dựa trên việc đọc TOÀN VĂN mã nguồn thật, không suy đoán từ tên
  biến/tên class/ảnh chụp màn hình. Đây là kỷ luật quan trọng nhất
  trong toàn bộ repo này.
- **Dự án chạy dưới EIS** (`​.claude/eis-profile.yaml` ghim EIS Core
  v0.1.0) nhưng **CHƯA có adapter Claude Code** (Phase 4b chưa xây,
  theo chính `CLAUDE.md`) — skill/prompt/workflow của EIS là đặc tả
  hợp lệ nhưng KHÔNG tự động chạy; áp dụng bằng tay khi liên quan,
  không giả định chúng tự vận hành.

## 2. Architecture Principles

- **3 tầng cố định**: Presentation (Flutter+Riverpod) → Domain (entity/
  use case/repository trừu tượng) → Data (Drift local là NGUỒN SỰ
  THẬT DUY NHẤT của UI; Supabase remote chỉ để đồng bộ nền) — quy tắc
  phụ thuộc `Presentation → Domain ← Data`, **Domain KHÔNG import
  Flutter/Drift/Supabase** (`ARCHITECTURE.md` §1, chính thức hoá thành
  `PROJ-P-003 domain-layer-purity` trong `PROJECT_CONSTITUTION.md`).
- **Offline-first bất biến** (`PROJ-P-001`): không màn hình nào chờ
  mạng; UI chỉ đọc/ghi Drift local; mạng chỉ dùng cho đồng bộ nền/tải
  audio, fail im lặng + thử lại (`ARCHITECTURE.md` §2).
- **Tách biệt 2 database** (`PROJ-P-002`): Group A = `AppDatabase`
  (nội dung Qur'an tĩnh, chỉ đọc, đóng gói sẵn) — Group B =
  `UserDatabase` (dữ liệu người dùng, đọc/ghi liên tục, mixin
  `SyncColumns`: id UUID, user_id nullable, updated_at, deleted_at
  soft-delete, is_dirty — `ARCHITECTURE.md` §3, §12b). KHÔNG bao giờ
  trộn 2 loại dữ liệu này vào cùng 1 bảng/connection.
- **Chuỗi Repository nhiều tầng — mỗi tầng CHỈ ghép tầng NGAY DƯỚI,
  không bao giờ với xuống sâu hơn.** Bằng chứng cụ thể: `AnalyticsRepository`
  (Sprint 14, ghép Scheduler+Flashcard+Lexicon+StudySession) →
  `AITutorRepository` (Sprint 15, ghép DUY NHẤT Analytics) →
  `LearningJourneyRepository` (Sprint 16, ghép DUY NHẤT AITutor) →
  `SmartLearningRepository` (Sprint 17, ghép DUY NHẤT LearningJourney)
  → `LearningSnapshotRepository` (Sprint 18, ghép DUY NHẤT
  SmartLearning). Quy tắc "compose ONLY the layer directly below" được
  nhắc lại và tuân thủ ở MỌI phase liên quan, không có ngoại lệ.
- **Repository là Dart thuần, độc lập Riverpod.** Mọi
  `*RepositoryImpl` nhận dependency qua constructor, KHÔNG bao giờ tự
  `ref.watch()` bên trong — cho phép gọi trực tiếp từ ngữ cảnh phi
  widget-tree trong tương lai (lý do công bố từ Sprint 15 Phase 1).
  Tầng Provider (`*_providers.dart`) là nơi DUY NHẤT được phép biết
  Riverpod.
- **Không cache xuyên lệnh gọi (no caching across calls).** Repository
  ĐƯỢC PHÉP tối ưu đọc trùng lặp TRONG 1 lệnh gọi public (vd snapshot
  nội bộ 1 hàm), nhưng KHÔNG BAO GIỜ cache kết quả GIỮA 2 lệnh gọi
  public riêng biệt — rủi ro trả dữ liệu cũ nếu trạng thái đổi giữa 2
  lần gọi (nguyên tắc công bố từ Sprint 14 Phase 3, tái khẳng định mọi
  phase sau). "Tái dùng" ở tầng Provider (Sprint 18 Phase 2) chỉ hợp
  lệ khi tận dụng cơ chế cache CÓ SẴN, TỰ QUẢN của chính Riverpod
  (`FutureProvider.autoDispose`), KHÔNG BAO GIỜ thêm biến toàn cục
  mutable làm cache thủ công.
- **Thay đổi entity chỉ được CỘNG THÊM (additive-only).** Mở rộng 1
  entity "đóng băng" bằng cách thêm trường MỚI (tham số tuỳ chọn hoặc
  bắt buộc ở CUỐI), không bao giờ đổi/xoá trường cũ, không đổi chữ ký
  phương thức hiện có. Bằng chứng: `updatedAtMs` thêm vào `SrsCard`
  (Sprint 14), `action` thêm vào `TutorSuggestion` (Sprint 15),
  `journey` thêm vào `SmartLearningSession` (Sprint 18) — luôn được
  công khai lý do trong Return report, không âm thầm.
- **Bộ tính toán thuần (pure calculator) tách khỏi Repository.** Mọi
  logic suy diễn (gợi ý, thứ tự kế hoạch, chiến lược phiên học, tổng
  hợp snapshot) là 1 hàm Dart thuần nhận dữ liệu ĐÃ CÓ SẴN, test được
  không cần DB/Provider (`computeTutorSuggestions`,
  `computeDailyLearningPlan`, `computeSmartLearningSession`,
  `computeLearningSnapshot`, v.v.).
- **Domain locale-purity.** Entity domain KHÔNG BAO GIỜ nhúng chuỗi
  hiển thị — tầng trình bày ánh xạ enum domain sang cặp icon+chuỗi
  l10n (mẫu `tutor_presentation.dart`, `session_strategy_presentation.dart`).
- **Tầng reliability (Sprint 19)**: `AppFailure`/`FailureCategory`/
  `FailureSeverity` (Dart thuần, `lib/core/error/`) +
  `mapToAppFailure()` (ánh xạ exception → AppFailure theo TYPE, không
  bắt/ném gì) + `Logger`/`CrashReporter` (interface thuần,
  `lib/core/logging/`, implementation cục bộ KHÔNG-cloud duy nhất:
  `ConsoleLogger`/`NoopCrashReporter`) + `withFailureLogging()`/
  `withFailureLoggingStream()` (helper DÙNG CHUNG áp dụng ở ranh giới
  9 Repository chạm Drift trực tiếp — KHÔNG áp cho 5 Repository
  orchestration thuần, vì chúng không tự I/O, tránh log trùng lặp cho
  cùng 1 lỗi gốc). Khớp đúng kế hoạch đã có sẵn ở `ARCHITECTURE.md`
  §16 (Crash Reporting qua Firebase Crashlytics, CHỈ bật khi
  `AppEnv.crashReportingEnabled == true`) — interface đã dựng SẴN SÀNG
  để cắm implementation cloud thật vào sau, không cần sửa nơi gọi.
- **Provider graph**: mẫu đồng nhất `xRepositoryProvider =
  Provider<XRepository>((ref) => XRepositoryImpl(ref.watch(...)))` +
  1+ `FutureProvider.autoDispose<T>` cho mỗi phương thức public.
  "Tái dùng output Provider" (Sprint 18 Phase 2) CHỈ an toàn khi: (a)
  Provider bị tái dùng vẫn là pass-through TRUNG THỰC của interface
  Repository (không "đường tắt" qua hàm thuần bỏ qua interface), VÀ
  (b) không phải mục tiêu `ref.invalidate()` trực tiếp của màn hình mà
  dependency của nó không được invalidate cùng lúc (nếu không, "kéo
  làm mới" sẽ âm thầm trả dữ liệu cũ) — xem `docs/knowledge/provider_read_flow.md`.
- **Responsive**: `AppScaffold` quyết định NavigationBar/NavigationRail
  theo 2 breakpoint 800/1100px (`ARCHITECTURE.md` §6) — NHƯNG các màn
  hình riêng lẻ hiện dùng breakpoint padding-ngang-responsive KHÔNG
  thống nhất (760/900/720 với mặc định 16/16/8 — xem
  `design_system_audit.md` mục Spacing patterns) — đây là nợ kỹ thuật
  ĐÃ BIẾT, chưa phải chuẩn, xem mục 9 (Refactoring Rules).

## 3. Shared Component Rules

Toàn bộ mục này rút ra trực tiếp từ `docs/knowledge/design_system_consolidation_plan.md`'s
"Merge Rules" (Sprint 21.2) — xem file đó để có bằng chứng chi tiết
từng dòng; ở đây chỉ nêu quy tắc:

- **CHỈ gộp sau khi đọc TOÀN VĂN mọi ứng viên**, không suy đoán từ
  tên/hình dạng bên ngoài. Bằng chứng thành công: `StatCard` (Sprint
  20 Phase 2) gộp ĐÚNG 1/4 ứng viên "trông giống thẻ chỉ số" sau khi
  đọc kỹ — 3 ứng viên còn lại (`_AccuracyMetricCard` có vòng tròn tiến
  độ; `TutorHeader`/`JourneyProgressCard`'s mục thống kê dùng bố cục
  Row khác Column) bị từ chối CÓ LÝ DO, không bị gộp cưỡng ép.
- **KHÔNG gộp nếu khác biệt cấu trúc thật** (có/không phần tử hình
  ảnh, Row vs Column, kích thước cố định vs co giãn) — dù nội dung
  hiển thị bề ngoài giống nhau.
- **Semantics/accessibility của widget dùng chung PHẢI ở mức CAO NHẤT**
  trong số các bản gốc bị gộp, không bao giờ thấp hơn — bằng chứng:
  `EmptyStateBanner` được NÂNG cấp thêm `Semantics(liveRegion:true)`
  khi nhận ra nó thiếu so với 2 widget dùng chung khác cùng vai trò
  (Sprint 20 Phase 2, Task 1).
- **Ưu tiên mở rộng tham số cho widget dùng chung SẴN CÓ** hơn tạo
  widget mới song song, khi khác biệt chỉ ở 1-2 giá trị (màu, kích
  thước, có/không hành động) — mẫu `StatCard.accented`.
- **Giữ 2 phiên bản (cũ + mới) tồn tại song song ít nhất 1 chu kỳ test
  xanh** trước khi xoá bản cũ — không xoá class gốc trong CÙNG commit
  tạo widget dùng chung.
- **Chuỗi số liệu (breakpoint, kích thước, thời lượng animation) khác
  nhau THẬT giữa các nơi KHÔNG được gộp mù quáng** — số khác nhau CÓ
  THỂ là chủ đích; cần xác nhận hoặc quyết định thiết kế rõ ràng trước.

## 4. Design System Rules

- Nguồn thẩm quyền: `docs/knowledge/design_system_audit.md` (Sprint
  21.1, kiểm kê hiện trạng) + `design_system_consolidation_plan.md`
  (Sprint 21.2, lộ trình 4 Phase A→D theo mức rủi ro). Bất kỳ ai định
  thêm 1 "thẻ"/"tiêu đề phần"/"trạng thái rỗng-lỗi-đang tải" MỚI PHẢI
  đọc 2 file này trước, không viết mới nếu đã có khuôn mẫu tương
  đương.
- **2 khuôn "thẻ" đã xác định**: (A) mặt phẳng TĨNH
  `Container(padding, BoxDecoration(color: 1 token, borderRadius:
  circular(16)))`; (B) mặt phẳng CHẠM ĐƯỢC `Material(color,
  borderRadius) + InkWell`. Widget "thẻ" mới PHẢI khớp 1 trong 2 khuôn
  này trừ khi có lý do hình ảnh thật (như vòng tròn tiến độ của
  `_AccuracyMetricCard`) — không phát minh khuôn thứ 3 tuỳ tiện.
- **3 widget trạng thái dùng chung đã có**: `LoadingState`
  (`Semantics(liveRegion:true, label: bắt buộc)`), `EmptyStateBanner`
  (cùng mẫu, thêm Sprint 20 Phase 2), `SearchErrorState`
  (`Semantics(liveRegion:true)+ExcludeSemantics`, nút thử lại NẰM
  NGOÀI vùng live-region, ẩn khi `onRetry == null`) — MỌI trạng thái
  loading/rỗng/lỗi MỚI PHẢI dùng 1 trong 3 widget này, không viết
  `CircularProgressIndicator()`/`Text(l10n.errorLoadData)` trần (dù
  audit Sprint 21.1 xác nhận ~21 nơi VẪN đang làm vậy — đó là nợ kỹ
  thuật CẦN SỬA theo lộ trình, không phải chuẩn cho code mới).
- **`SectionHeader`** (`Semantics(header:true)` tự động) là widget
  DUY NHẤT cho tiêu đề phần — không viết `Text(..., style:
  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))` tay
  lần nữa.
- **Màu LUÔN qua `Theme.of(context).colorScheme`.** Đây là điểm mạnh
  kiến trúc đã được audit xác nhận GẦN NHƯ HOÀN HẢO (0 vi phạm thật
  trong ~45 file, ngoại trừ 4 ngoại lệ có chủ đích đã ghi nhận ở
  `design_system_audit.md` mục 11) — BẢO VỆ nó, không nới lỏng.
- **Không dùng `elevation`/widget `Card` để tạo chiều sâu** — dùng đối
  lập màu nền (tonal surfaces), đúng ngôn ngữ Material 3 flat design
  đã thiết lập nhất quán trên toàn app (audit mục 13). LƯU Ý:
  `app_theme.dart`'s `cardTheme` đã khai báo `elevation`/`radius`/
  `margin` chuẩn nhưng KHÔNG widget nào dùng `Card(...)` — nếu dựng
  widget "thẻ" dùng chung mới, ĐỌC giá trị từ `cardTheme` thay vì lặp
  lại số, biến cấu hình chết thành sống.

## 5. Accessibility Standard

Chuẩn CHÍNH THỨC đã có ở `ARCHITECTURE.md` §14 ("chuẩn bắt buộc cho
MỌI màn hình"): dynamic type (không vỡ layout ở scale 200%), screen
reader (mọi icon-button có `Semantics`/tooltip; thẻ Ayah có semantic
label đọc được), RTL tự động theo locale `ar`, high-contrast (chỉ
`ColorScheme`, tỉ lệ tương phản chữ/nền ≥ 4.5:1). Sprint 20 (2 phase)
biến chuẩn này thành THỰC HÀNH CỤ THỂ, đúc kết ở
`docs/knowledge/accessibility_checklist.md` (dùng lại cho MỌI PR/audit
sau, không đọc lại report Sprint 20) — trích các quy tắc CỐT LÕI:

- **Thẻ/card gộp nhiều Text+Icon con → `Semantics(label: '...') +
  ExcludeSemantics`** thành 1 điểm dừng duy nhất cho trình đọc màn
  hình — mẫu dùng NHẤT QUÁN ở Analytics/AI Tutor/Learning Journey/
  Smart Learning.
- **Nút hành động BÊN TRONG 1 thẻ đã gộp nhãn PHẢI nằm NGOÀI
  `ExcludeSemantics`** — nếu không, nút bị nuốt vào nhãn tĩnh không
  bấm được (xem comment tường minh ở `tutor_suggestion_card.dart`).
- **Icon-only button PHẢI có `tooltip:`** — không chỉ `icon:`.
- **Tiêu đề phần dùng `Semantics(header: true)`** (qua `SectionHeader`)
  — cho phép điều hướng theo heading, chuẩn thao tác cơ bản của mọi
  trình đọc màn hình.
- **KHÔNG dùng MÀU SẮC làm cách truyền đạt thông tin DUY NHẤT** (WCAG
  1.4.1) — mọi chỉ báo trạng thái chỉ-dùng-màu PHẢI có thêm
  `Semantics(label:)`/`Tooltip` mô tả bằng chữ (bằng chứng sửa:
  `flashcard_tile.dart`'s chấm màu SRS state, Sprint 20 Phase 2 Task
  6).
- **Trạng thái loading/rỗng/lỗi xuất hiện ĐỘNG cần
  `Semantics(liveRegion: true)`** — để trình đọc màn hình tự thông
  báo, không cần người dùng tự dò tìm.
- **KHÔNG để trạng thái "biến mất im lặng"** (`orElse: () =>
  SizedBox.shrink()`, `.valueOrNull ?? []` nuốt lỗi) — người dùng
  không phân biệt được "đang tải" với "lỗi" với "không có dữ liệu".
- Checklist đầy đủ (10 mục tự kiểm trước khi merge) — xem
  `accessibility_checklist.md` mục 8.

## 6. Localization Standard

- **CẤM hard-code chuỗi hiển thị trong widget** (`ARCHITECTURE.md`
  §7, nhắc lại trong `CLAUDE.md`'s Definition of Done). 3 ngôn ngữ: vi
  (mặc định) · en · ar (RTL tự động theo locale) — file
  `lib/l10n/app_{vi,en,ar}.arb`, `app_vi.arb` là template.
- **Mọi khoá l10n MỚI phải thêm vào ĐỦ CẢ 3 file trong CÙNG 1 thay
  đổi** — không thêm 1 file rồi để 2 file kia thiếu khoá.
- Quy tắc áp dụng CẢ cho chuỗi chỉ dùng làm `Semantics.label` (không
  chỉ chuỗi hiển thị trực tiếp) — bằng chứng: tên màu highlight
  (`kHighlightColorValues`) dùng trực tiếp làm `Semantics.label` mà
  KHÔNG qua l10n đã bị audit Sprint 20 Phase 1 gắn cờ là thiếu sót cần
  sửa, không phải ngoại lệ hợp lệ.
- **Widget dùng chung nhận chuỗi qua THAM SỐ**, không tự đọc
  `AppLocalizations` bên trong (mẫu `LoadingState.semanticsLabel`,
  `EmptyStateBanner.text`) — giữ widget thuần trình bày, không phụ
  thuộc bộ khoá l10n cụ thể nào, tái dùng được ở ngữ cảnh khác.
- Văn bản Ả Rập LUÔN `TextDirection.rtl` bất kể locale UI đang chọn
  (`ARCHITECTURE.md` §14).

## 7. Testing Standard

- **Definition of Done bất biến** (`CLAUDE.md`, `README.md`):
  `dart format`, `flutter analyze --fatal-infos`, `flutter test
  --coverage` — TẤT CẢ sạch trước khi commit. Mọi tính năng mới PHẢI
  kèm test trong CÙNG thay đổi.
- **Ngưỡng coverage**: mục tiêu 80% khi phát hành v1.0 (loại trừ
  `main.dart`/`*.g.dart`); CI gate hiện tạm thấp hơn, nâng dần
  (`ARCHITECTURE.md` §9) — không hạ ngưỡng CI để "cho qua", chỉ nâng.
- **5 cạm bẫy widget-test ĐàBIẾT, phải chủ động tránh** (đúc kết
  xuyên suốt Sprint 15-17, áp dụng lại thành công không cần debug ở
  Sprint 17 Phase 2 trở đi):
  1. Gọi I/O Drift thật trong `testWidgets` mà KHÔNG bọc
     `tester.runAsync()` → TREO VÔ THỜI HẠN, không chỉ fail.
  2. `tester.pump()` KHÔNG truyền `Duration` không đẩy đồng hồ hoạt
     hình giả lập — animation chuyển trang go_router (~300ms) không
     bao giờ hoàn tất, widget render ở vị trí SAI.
  3. `ListView`/`GridView` chỉ dựng con trong viewport +
     `cacheExtent` — nội dung xa cần `tester.drag()` cuộn tới, scope
     qua `find.byType(ListView)` cụ thể (không phải
     `find.byType(Scrollable)` chung chung, tránh nhầm nested
     GridView).
  4. `context.push()` (khác `pushReplacement`) giữ màn hình cũ trong
     Navigator stack — `find.text(...)` trùng nội dung màn cũ PHẢI
     scope qua `find.descendant(of: find.byType(TargetScreen),
     matching: ...)`.
  5. `warnIfMissed: false` chỉ dùng khi ĐÃ xác nhận vị trí thật qua
     `tester.getRect()` — không dùng làm lối tắt che giấu lỗi định vị
     thật.
- **Test accessibility riêng, không lồng vào test chức năng** — mẫu
  `test/shared_widgets_a11y_test.dart`/`test/flashcard_tile_test.dart`
  (Sprint 20 Phase 2): dùng `tester.getSemantics(...)` +
  `semantics.flagsCollection.X`/`.label`/`.tooltip` để xác nhận
  `Semantics` MERGE đúng cách — LƯU Ý đã phát hiện thực nghiệm:
  `ListTile` GỘP `leading`+`title` thành 1 `SemanticsNode`, nên
  `find.bySemanticsLabel('New')` có thể KHÔNG khớp nếu nhãn thật là
  `"New\nContent unavailable"` — luôn dump semantics tree thật
  (`tester.binding.renderViewElement!.renderObject!.debugSemantics?.toStringDeep()`)
  khi assertion semantics thất bại ngoài dự đoán, đừng đoán.
  `Tooltip.message` là tín hiệu RIÊNG, KHÔNG bị gộp vào `label` — kiểm
  `semantics.tooltip` khi cần khẳng định chính xác 1 giá trị.
- **Không đoán providers cần override** — mọi test dựng
  `ProviderContainer`/`ProviderScope` phải override ĐỦ dependency thật
  sự bị chạm tới trong đường code test đi qua (kể cả gián tiếp qua
  provider khác), không chỉ override cái được nhắc tên trực tiếp —
  bằng chứng: `home_screen_test.dart` phải override CẢ
  `surahListProvider` LẪN `todaysVerseProvider` dù chỉ đang test 1
  trong 2 nhánh, vì nhánh kia vẫn bị build/watch nếu không kiểm soát.
- **`pumpAndSettle()` không bao giờ dừng nếu còn `CircularProgressIndicator`
  (indeterminate) hiển thị** — luôn override MỌI provider async liên
  quan tới trạng thái loading trước khi gọi `pumpAndSettle()`, không
  chỉ provider đang test.
- **Không chạy lại toàn bộ suite để debug 1 test treo** — cô lập bằng
  `flutter test --plain-name "..."`, tìm nguyên nhân thật (thường là
  cạm bẫy #1/#2 ở trên) trước khi chạy lại suite đầy đủ.

## 8. Documentation Standard

- **`CLAUDE.md`**: cố ý MỎNG — định hướng, không nhắc lại nội dung
  file khác. Nếu lệch với file nó trỏ tới, file đó thắng — nguyên tắc
  ÁP DỤNG CHO TÀI LIỆU NÀY TƯƠNG TỰ (xem đầu file).
- **`docs/knowledge/`**: tài liệu THAM CHIẾU TÁI SỬ DỤNG (checklist,
  audit hiện trạng, kế hoạch, chuẩn kỹ thuật) — chỉ tạo khi có thứ
  THẬT cần ghi lại, KHÔNG tạo trước (nguyên tắc gốc của `CLAUDE.md`,
  lần đầu áp dụng thực tế ở Sprint 19 Phase 1's `reliability_architecture.md`).
  File trong thư mục này ĐƯỢC PHÉP lỗi thời một phần theo thời gian —
  khi 1 phase sau cập nhật trạng thái ("đã sửa"/"còn intentional
  difference"), KHÔNG sửa lại số dòng/trích dẫn CŨ trong phần lịch sử
  — thêm mục MỚI ghi trạng thái hiện tại, giữ phần cũ làm biên bản
  (mẫu `accessibility_audit.md` mục 8 sau Sprint 20 Phase 2).
- **`docs/reports/`**: báo cáo tại 1 THỜI ĐIỂM, lưu trữ khi bị thay
  thế — khác `docs/knowledge/` (không phải tài liệu tái sử dụng lâu
  dài).
- **`docs/adr/`**: Decision Record cho quyết định kiến trúc — dùng khi
  1 lựa chọn kỹ thuật cần lý do LÂU DÀI (không chỉ trong Return report
  của 1 phase).
- **`docs/verification/`**: Verification Record — tạo khi Constitution
  dự án được kiểm chứng thật.
- **Mọi widget/hàm không hiển nhiên PHẢI có doc-comment giải thích LÝ
  DO (why), không phải MÔ TẢ (what)** — tên định danh tốt đã tự mô tả
  "làm gì"; comment chỉ cần khi có ràng buộc ẩn/bất biến tinh tế/quyết
  định không hiển nhiên (bằng chứng nhất quán: MỌI class dùng chung
  Sprint 15-21 đều có doc-comment kiểu "Sprint N Phase M — lý do X,
  đã xác nhận Y bằng cách đọc trực tiếp file Z").
- **Report cuối mỗi phase theo đúng khuôn Return đã yêu cầu** — không
  tự ý thêm/bớt mục, không tự ý mở rộng sang phase tiếp theo dù có vẻ
  "tiện thể".

## 9. Refactoring Rules

- **KHÔNG refactor nếu không được yêu cầu tường minh.** "Do NOT
  redesign X" là mặc định giữa các phase — chỉ được đổi kiến trúc khi
  chỉ thị NÊU RÕ đang mở khoá đúng phần đó.
- **Refactor CHỈ SAU KHI audit + kế hoạch đã hoàn tất VÀ được duyệt.**
  Bằng chứng: Design System audit (21.1) → kế hoạch hợp nhất (21.2) →
  chuẩn kỹ thuật này (21.3) → refactor thật (phase TƯƠNG LAI, CHƯA bắt
  đầu) — 3 bước tài liệu hoá trước 1 bước thực thi, không đảo thứ tự.
- **Mỗi lần hợp nhất là 1 thay đổi TÁCH BIỆT, dễ rollback** — không
  gộp nhiều candidate không liên quan vào 1 PR duy nhất (xem
  `design_system_consolidation_plan.md`'s Rollback strategy từng mục
  — luôn đề xuất chia theo nhóm nhỏ, KHÔNG 1 PR khổng lồ).
- **Hành vi/giao diện hiện có PHẢI giữ nguyên trừ khi thay đổi ĐÓ
  CHÍNH LÀ mục tiêu được giao** — phân biệt rõ 2 loại thay đổi trong
  MỌI PR: "hợp nhất code, giao diện y hệt" (rủi ro thấp, chỉ cần test
  hồi quy) và "cải thiện giao diện" (rủi ro cao hơn, cần xác nhận
  phạm vi trước) — KHÔNG trộn lẫn 2 loại trong 1 thay đổi không ghi
  chú rõ.
- **Không xoá code cũ trước khi code mới được xác nhận ổn định** — xem
  mục 3.
- **3 dòng giống nhau tốt hơn 1 trừu tượng hoá sớm** — không tạo lớp
  trừu tượng cho khả năng tương lai giả định; chỉ trích xuất khi CÓ
  BẰNG CHỨNG trùng lặp thật (đã xác nhận bằng đọc trực tiếp, không
  phải "có thể sẽ cần").

## 10. Merge Decision Rules

(Áp dụng CHUNG cho mọi loại hợp nhất code — không chỉ UI widget; mở
rộng từ `design_system_consolidation_plan.md`'s Merge Rules sang phạm
vi toàn repo.)

**ĐƯỢC gộp khi**:
1. Đã đọc TOÀN VĂN mọi bên liên quan, không suy đoán.
2. Cấu trúc lõi giống hệt hoặc khác biệt CHỈ ở 1-2 tham số hoá được
   đơn giản (như `StatCard.accented`, `AppFailure`'s category/severity).
3. Ngữ nghĩa (Semantics, l10n, hành vi lỗi/rỗng/đang tải) của bản gộp
   bảo toàn hoặc NÂNG mức của bản TỐT NHẤT trong các bản gốc.
4. API công khai không ép nơi gọi truyền tham số không dùng tới.

**KHÔNG được gộp khi**:
1. Có phần tử/khả năng mà 1 bên có, bên kia không (vòng tròn tiến độ,
   caching riêng, log riêng) — dù phần còn lại giống nhau.
2. Bố cục/luồng dữ liệu lõi khác nhau thật (Row vs Column; đọc trực
   tiếp Repository vs qua Provider trung gian).
3. Chỉ giống nhau ở "loại vai trò" (cùng là "thẻ", cùng là "repository
   đọc dữ liệu") mà không giống công thức/hợp đồng cụ thể.
4. Đòi hỏi sửa cấu hình TOÀN CỤC (ThemeData, Provider gốc) theo cách
   ảnh hưởng những nơi NGOÀI phạm vi đang xét.
5. Số liệu (breakpoint, ngưỡng, thời lượng) khác nhau THẬT giữa các
   nơi mà chưa có quyết định thiết kế/kỹ thuật rõ ràng chọn 1 chuẩn.
6. Việc gộp đòi hỏi 1 Repository "với" xuống dưới tầng ngay kế nó
   (vi phạm mục 2's "compose ONLY the layer directly below").

## 11. AI Review Checklist

Trước khi bất kỳ AI nào đề xuất/thực hiện 1 thay đổi trong repo này,
tự trả lời:

1. **Chỉ thị/phase hiện tại có nói rõ phạm vi này không?** — nếu mơ
   hồ, hỏi lại thay vì suy đoán rộng ra ("tiện thể sửa luôn X").
2. **Đã đọc TOÀN VĂN file liên quan chưa** — hay chỉ đọc trích đoạn/
   suy đoán từ tên? (mục 1's "không đoán — đọc").
3. **Kiến trúc có đang "đóng băng" ở phạm vi này không?** — kiểm tra
   chỉ thị có ghi "Do NOT redesign X" — nếu có, mọi thay đổi ở X đều
   SAI dù có vẻ hợp lý.
4. **Thay đổi có xuyên qua > 1 tầng Repository không?** — nếu có, SAI
   trừ khi chính là mục tiêu unfreeze rõ ràng.
5. **Có đang cache dữ liệu XUYÊN LỆNH GỌI (biến toàn cục/singleton
   mutable) không?** — nếu có, SAI, xem mục 2.
6. **Chuỗi hiển thị/`Semantics.label` có qua l10n đủ cả 3 file
   không?**
7. **Widget/thành phần dùng chung nào đã tồn tại làm việc này chưa?**
   — tra `lib/shared/widgets/` + `design_system_audit.md`/
   `consolidation_plan.md` trước khi viết mới.
8. **Accessibility (Semantics/tooltip/liveRegion/header) có được giữ
   nguyên hoặc nâng cấp không?**
9. **Test có đi kèm CÙNG thay đổi không** — bao gồm test cho MỌI nơi
   gọi bị ảnh hưởng, không chỉ nơi vừa sửa?
10. **Return report (nếu là kết thúc 1 phase) có đúng khuôn mục được
    yêu cầu, không tự ý thêm/bớt/mở rộng phạm vi không?**

Nếu BẤT KỲ câu nào không trả lời được rõ ràng kèm bằng chứng — DỪNG,
đọc thêm, hoặc hỏi lại; không đoán và tiếp tục.

## 12. Definition of Done

Một thay đổi được coi là HOÀN TẤT khi VÀ CHỈ KHI TẤT CẢ đúng:

- `dart format` sạch (0 file bị định dạng lại khi chạy kiểm tra).
- `flutter analyze --fatal-infos` — 0 issue (kể cả mức "info").
- `flutter test` (toàn bộ suite, không chỉ file vừa sửa) — 100% xanh.
- Coverage không giảm so với trước thay đổi (ngưỡng CI hiện tại, xem
  `ARCHITECTURE.md` §9 — không hạ ngưỡng để "cho qua").
- Mọi chuỗi hiển thị/Semantics.label mới có mặt ĐỦ ở
  `app_{vi,en,ar}.arb`.
- Mọi widget/hàm dùng chung MỚI có test riêng (không chỉ được phủ
  gián tiếp qua test màn hình gọi nó).
- Doc-comment giải thích LÝ DO cho mọi quyết định không hiển nhiên
  (gộp/không gộp, thêm trường, tối ưu Provider...).
- Return report (nếu kết thúc 1 phase) đúng khuôn mục được yêu cầu.
- KHÔNG dùng `--no-verify`/bỏ qua hook/`git push --force` trừ khi
  được yêu cầu tường minh.

## 13. Definition of Ready

Một phase/thay đổi được coi là SẴN SÀNG bắt đầu khi:

- Phạm vi kiến trúc "đóng băng" vs "mở khoá" của chỉ thị RÕ RÀNG,
  không cần suy đoán ("Do NOT redesign: [danh sách cụ thể]" hoặc
  tương đương).
- Return report của phase TRƯỚC đã đọc/hiểu — không bắt đầu phase mới
  dựa trên giả định về trạng thái repo, phải xác nhận qua đọc code
  thật.
- Yêu cầu Testing/Return cụ thể của chỉ thị đã hiểu rõ (định dạng
  Return report, gate nào cần chạy) — không đoán khuôn report.
- Nếu chỉ thị chạm 1 trong các mốc "Stop and ask before" của
  `CLAUDE.md` (schema DB, chính sách RLS Supabase, hướng thương mại
  hoá, nâng cấp dependency major, keystore/`key.properties`) — ĐÃ hỏi
  và nhận xác nhận, KHÔNG tự tiến hành.
- Với riêng công việc Design System (Phase A-D,
  `design_system_consolidation_plan.md`): Phase TRƯỚC ĐÓ trong lộ
  trình đã hoàn tất và ổn định (test xanh) — không nhảy thẳng vào
  Phase C khi Phase A/B chưa xong, đúng thứ tự rủi ro tăng dần đã lập.

## 14. Anti-patterns

Danh sách PHẢN VÍ DỤ đã xác nhận SAI qua thực tế dự án — tránh lặp
lại:

- **Cache biến toàn cục/singleton mutable** để "tối ưu" đọc lặp lại —
  VI PHẠM trực tiếp mục 2's "no caching across calls"; tối ưu ĐÚNG
  CÁCH là dùng cơ chế tự quản của Riverpod (`autoDispose`) hoặc tối ưu
  NỘI BỘ 1 lệnh gọi, không phải state ngoài vòng đời Provider.
- **Repository "với" xuống Repository không phải tầng ngay dưới nó** —
  vi phạm chuỗi 5 tầng đã thiết lập.
- **Gộp 2 đoạn UI/code chỉ vì "trông giống"** mà không đọc toàn văn —
  đã có ít nhất 3 lần trong lịch sử dự án (`_AccuracyMetricCard`,
  `TutorHeader`'s stat item, `JourneyProgressCard`'s stat item) nơi
  "trông giống" hoá ra SAI sau khi đọc kỹ.
- **Hard-code chuỗi hiển thị** (kể cả trong `Semantics.label`) — kể cả
  khi "chỉ 1 chuỗi nhỏ, không đáng thêm l10n".
- **Hard-code màu** (`Colors.X`/`Color(0xFF...)`) thay vì
  `colorScheme` — trừ 4 ngoại lệ ĐÃ ghi nhận có chủ đích
  (`kHighlightColorValues`, `Colors.transparent`, bóng đổ đen chuẩn
  Material, icon trắng trên nền tuỳ ý).
- **Trạng thái "biến mất im lặng"** khi loading/lỗi
  (`orElse: () => SizedBox.shrink()`, `.valueOrNull ?? fallback` nuốt
  lỗi) — người dùng không phân biệt được các trạng thái.
- **Chỉ báo trạng thái CHỈ dùng màu sắc** không có chữ/nhãn thay thế —
  vi phạm WCAG 1.4.1, đã xác nhận thực tế ở `flashcard_tile.dart`
  trước khi sửa.
- **Xoá code cũ trước khi code mới được xác nhận qua test** — mất khả
  năng rollback an toàn.
- **Bỏ qua hook/dùng `--no-verify`** để "cho xong việc" khi gặp lỗi —
  luôn sửa nguyên nhân gốc.
- **Mở rộng phạm vi "tiện thể"** khi đang sửa 1 việc khác — tách thay
  đổi hành vi khỏi thay đổi hợp nhất/dọn dẹp, dù "đằng nào cũng đang
  sửa file này".
- **Trừu tượng hoá sớm cho khả năng tương lai giả định** — 3 dòng
  giống nhau không tự động là "cần gộp", chỉ khi CÓ BẰNG CHỨNG trùng
  lặp thật và đã xác minh tương đương.
- **Test I/O thật trong `testWidgets` không bọc `runAsync()`**, hoặc
  `pump()` không truyền `Duration` trong vòng lặp chờ — 2 cạm bẫy gây
  treo/sai vị trí đã xác nhận thực tế, xem mục 7.

## 15. Future Extension Guidelines

- **Thêm 1 tầng Repository mới**: PHẢI ghép DUY NHẤT tầng hiện đang là
  "trên cùng" của chuỗi hiện tại (hiện là `LearningSnapshotRepository`)
  — không ghép nhiều tầng, không với xuống sâu hơn. Theo đúng mẫu Dart
  thuần + `*_providers.dart` riêng + hàm tính toán thuần tách biệt đã
  lặp lại ở 5 tầng hiện có.
- **Thêm ngôn ngữ l10n mới**: cập nhật `AppLocalizations.supportedLocales`
  + thêm file `app_<mã>.arb` đầy đủ MỌI khoá hiện có (không thiếu khoá
  nào so với `app_vi.arb`, file template) — kiểm tra RTL nếu ngôn ngữ
  mới viết phải-sang-trái.
- **Thêm widget dùng chung mới**: bắt buộc qua "AI Decision Checklist"
  ở `design_system_consolidation_plan.md` (10 câu hỏi) TRƯỚC khi viết
  dòng code đầu tiên.
- **Mở rộng `AppTheme`**: ưu tiên thêm getter/hằng số MỚI (như đề xuất
  `radiusCard`/`sectionTitleStyle` ở `design_system_consolidation_plan.md`
  Phase C6/D1) hơn sửa trực tiếp `ThemeData.textTheme`/`cardTheme`
  hiện có — sửa trực tiếp có nguy cơ đổi giao diện những nơi NGOÀI
  phạm vi đang xét (bằng chứng: `titleMedium` được dùng CẢ đậm (thẻ)
  LẪN không đậm (dialog) — đổi mặc định sẽ vỡ 1 trong 2 nhóm).
- **Cắm implementation cloud thật cho `CrashReporter`/`Logger`**
  (Firebase Crashlytics theo kế hoạch `ARCHITECTURE.md` §16): chỉ cần
  `overrideWithValue(...)` ở `main.dart`'s `loggerProvider`/
  `crashReporterProvider` — KHÔNG cần sửa bất kỳ nơi gọi nào khác, vì
  mọi nơi phụ thuộc ĐÚNG interface, không phụ thuộc
  `ConsoleLogger`/`NoopCrashReporter` trực tiếp (thiết kế đã sẵn sàng
  từ Sprint 19 Phase 1).
- **Khi EIS Core Phase 4b (Claude Code adapter) được xây**: skill/
  workflow EIS hiện áp dụng BẰNG TAY sẽ có khả năng chạy tự động — tài
  liệu này và các file `docs/knowledge/` khác vẫn là nguồn thẩm quyền
  cho NỘI DUNG quy tắc, bất kể quy tắc được THỰC THI bằng tay hay tự
  động.
- **Khi thực thi Design System Phase A-D**: LUÔN theo đúng thứ tự rủi
  ro tăng dần đã lập ở `design_system_consolidation_plan.md` (A trước
  D), cập nhật lại chính `design_system_audit.md`/
  `consolidation_plan.md` sau mỗi Phase hoàn tất theo mẫu đã thiết lập
  ở `accessibility_audit.md` mục 8 (thêm mục MỚI ghi trạng thái, giữ
  nguyên phần lịch sử cũ).
