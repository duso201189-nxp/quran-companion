# Changelog

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).
Phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

## [Unreleased]

### Added — D7.8: Công cụ quan sát khả năng ghi nhớ (dormant, chỉ đọc) (2026-08-18)

Một quyết định kiến trúc (`DR-2026-0027`, đã `accepted`) và một lần
triển khai, đưa vào công cụ *quan sát khả năng ghi nhớ* (retention
observation) đầu tiên của sản phẩm — nội bộ, chỉ chẩn đoán, cố ý CHƯA
có nơi nào gọi tới:

- **D7.8 — Retention observation instrument**: đọc CHỈ-ĐỌC từ
  `review_events` (không đổi schema — `schemaVersion` vẫn 8, không
  migration, không cột mới, không index mới), ghép mỗi cặp sự kiện ôn
  liên tục cùng `(item_type, item_id)` thành một "quan sát ghi nhớ"
  (khoảng thời gian đã trôi qua thực tế + kết quả nhớ lại thô, chưa
  quy đổi thành điểm số), phạm vi CHỈ `ayah`/`hifz` (`lemma` vẫn không
  có dữ liệu). Sống trong `lib/features/learning/`:
  `domain/entities/retention_observation.dart`,
  `domain/repositories/retention_event_source_repository.dart`,
  `domain/retention_instrument.dart`,
  `data/retention_event_source_repository_impl.dart`,
  `data/retention_instrument_providers.dart` — đúng ranh giới
  `DR-2026-0027` đã duyệt (`37facdd`, 2026-08-18). KHÔNG có consumer,
  KHÔNG UI, KHÔNG tích hợp Analytics, KHÔNG rollup/score/mastery/
  streak/gamification nào được xây hay cấp phép — dormant có chủ đích,
  đúng tinh thần "logging first; reporting deferred" của Sprint 7.8
  gốc.

### Added — D6.6–D6.11: SRS review event storage & Hifz historical review metrics (2026-08-15 → 2026-08-16)

Sáu quyết định kiến trúc (`DR-2026-0024`, `DR-2026-0025`, `DR-2026-0026`,
tất cả `accepted`) và ba lần triển khai, tách biệt rõ lưu trữ / ranh
giới governance / tính năng đã hiện ra màn hình:

- **D6.6 — `review_events`**: bảng bất biến, chỉ thêm không sửa,
  ghi lại mỗi lần ôn SRS đã cam kết cho `item_type` `ayah`/`hifz`
  (`lemma` cố ý CHƯA ghi). `schemaVersion` 7→8, migration hoàn toàn
  cộng thêm. Ghi diễn ra atomic trong cùng transaction với cập nhật
  `srs_cards` (`DR-2026-0024`, đã `accepted`).
- **D6.7 — Ranh giới tiêu thụ Analytics**: MỘT quyết định governance,
  KHÔNG phải tích hợp — xác nhận Analytics CÓ THỂ một ngày nào đó đọc
  `review_events`, nhưng KHÔNG cấp phép bất kỳ code nào ngay bây giờ;
  mọi tiêu thụ thật trong tương lai cần một quyết định riêng, mới
  (`DR-2026-0025`, đã `accepted`). Không có `AnalyticsRepository`,
  `LearningStatistics`, hay bất kỳ tầng nào trong chuỗi 5 tầng
  (AI Tutor/Learning Journey/Smart Learning/Study Summary/`read_model`)
  bị đụng tới.
- **D6.11 — Lịch sử ôn Hifz**: tổng số lượt ôn đã ghi + phân bố 7 ngày
  gần nhất cho MỘT kế hoạch Hifz, đọc CHỈ-ĐỌC từ `review_events` qua
  một ranh giới đọc riêng của `hifz/` (không đi qua Analytics). Hiện
  trên màn hình Tiến độ Hifz đã có sẵn, phần "Lịch sử ôn tập" mới
  (`DR-2026-0026`, đã `accepted`).

### Added — Milestone 7: Study Roadmap Sprints 7.1–7.7 (2026-08-06 → 2026-08-13)

Bảy sprint theo `docs/release/MILESTONE_7_STUDY_ROADMAP.md`, đối chiếu
trực tiếp source — Sprint 7.7 dưới đây CHỈ gồm phạm vi cốt lõi đã
duyệt gốc; phần mở rộng D6.6–D6.11 ở trên là quyết định governance
RIÊNG, không phải một phần nguyên thuỷ của sprint này:

- **7.1 — Assessment Scoping**: Trắc nghiệm chỉ sinh câu hỏi từ nội
  dung người dùng ĐÃ ĐỌC (trước đây lấy ngẫu nhiên từ toàn bộ 114
  Surah, không quan tâm đã đọc chưa).
- **7.2 — Foundation-First Session Default**: "Bắt đầu buổi học"
  không còn tự động vào Trắc nghiệm cho người dùng chưa từng đọc gì —
  giờ đưa vào màn Đọc (Al-Fatihah) trước.
- **7.3 — Automatic Retention Seeding**: Đọc tự động đưa vào hàng chờ
  Ôn tập theo mặc định — gắn thẻ thủ công trở thành ngoại lệ, không
  còn là yêu cầu (`DR-2026-0021`, đã `accepted`).
- **7.4 — Boundary-Triggered Revision Moments**: Hoàn thành một
  Surah/Juz/Khatm mời một lượt ôn tập tổng hợp (`DR-2026-0023`, đã
  `accepted`).
- **7.5 — Reflection Practice (dạng đi kèm phiên đọc)**: Reflection
  có bản sắc riêng, đi kèm phiên đọc — CHỈ dạng gắn với phiên đọc; dạng
  gắn với hoàn thành Surah/Juz/Khatm còn phụ thuộc 7.4, chưa xây.
- **7.6 — Sequencing Consolidation**: Hợp nhất quyền sở hữu logic sắp
  xếp giữa AI Tutor / Learning Journey / Smart Learning về đúng MỘT
  năng lực như Study Architecture Constitution §13 đã đặt tên.
- **7.7 — Hifz Mode (phạm vi cốt lõi)**: Chế độ học thuộc tự chọn —
  quản lý kế hoạch, thuật toán lên lịch riêng cho Hifz, ôn tập theo
  SRS có chấm điểm.

### Added — Basmalah 2.0 BM4: Kiểm chứng cuối + sửa lỗi trên máy thật (2026-08-04)

Kiểm chứng BM1–BM3 ở ba tầng: thuần, dữ liệu thật (asset
`quran.sqlite`, cả 114 Surah), và thiết bị thật (Pixel 8, Android
17/API 37). Tìm thấy và sửa **một lỗi thật**.

- **Lỗi: màn hình khoá hiện chữ "Ayah null"** trong lúc Basmalah đang
  phát. `mediaItemFor` (viết ở Sprint B1, lúc mọi mục playlist đều là
  Ayah) ghép chuỗi `'Ayah ${item.address.ayah}'`; mục mở đầu (BM1) có
  địa chỉ mức Surah, `.ayah` là `null`, và Dart nội suy `null` thành
  đúng chữ "null". Sửa: mức Surah hiện "Bismillah" thay vì số Ayah.
  Xác nhận lại trên máy: `description=Bismillah`, không còn "null".
- **Kiểm chứng dữ liệu thật, không chỉ fixture**: `basmalah_real_data_test.dart`
  mở thẳng `assets/database/quran.sqlite`, chạy đúng hàm production
  cho cả 114 Surah — đúng một Basmalah mỗi Surah (trừ At-Tawbah),
  Al-Fatihah không có hàng mở đầu, và **An-Naml 27:30 (Basmalah trong
  thư Sulayman) giữ nguyên từng byte** — bằng chứng phần mở đầu là một
  VAI TRÒ theo vị trí, không phải khớp chuỗi.
- **Kiểm chứng trên máy thật**: hàng đợi Al-Kahf đúng 111 mục (110 Ayah
  + 1 mở đầu); vị trí đọc lưu trên đĩa (`reading.pos.18`) vẫn là chỉ số
  Ayah, không lệch sang chỉ số playlist; tô sáng, thông báo, và vị trí
  đều đúng khi bước qua lại giữa phần mở đầu và Ayah 1.
- **930 test** (+10). Coverage giữ nguyên 82.04% (test mới chạy qua
  code đã có, đúng vai trò của một sprint kiểm chứng).

Rủi ro còn lại: **iOS hoàn toàn chưa kiểm chứng** — mọi kết quả trên
đều từ Android; cần macOS mới chạy được. Xem
`docs/release/PHASE4_SPRINT_BM4_REPORT.md`.

### Added — Basmalah 2.0 BM3: Tương tác — phát từ phần mở đầu (2026-08-04)

Cho hàng mở đầu một nút phát riêng, và sửa một mập mờ do BM1 để lại.

- **Lỗi BM1 để lại, nay đã sửa**: `playSurah` trước đây nhận chỉ số
  Ayah rồi ĐOÁN ý định từ `ayahIndex == 0` — nên bấm nút phát trên thẻ
  Ayah 1 lại nghe Basmalah trước, dù nút chỉ hứa Ayah 1. Giờ `playSurah`
  nhận thẳng `QuranAddress`, và MỨC của địa chỉ mang ý định: mức Surah
  = đọc từ đầu (có phần mở đầu), mức Ayah = phát đúng Ayah đó. Mỗi nút
  giờ làm đúng điều nó hứa.
- **Hàng mở đầu có nút phát riêng**, dùng lại đúng `_ActionIcon` và
  nhãn `playFromHere` của thẻ Ayah — không thêm khái niệm mới.
- **920 test** (+5). Coverage 81.98% → 82.04%.

### Added — Basmalah 2.0 BM2: Phần mở đầu thành một hàng đọc thật (2026-08-04)

Basmalah rời khỏi header trang trí, trở thành một hàng đọc có địa chỉ,
có trang trí, có nhãn accessibility riêng.

- **`ReadingRows.leadingRows` (hằng số)** → `leadingRowsFor(SurahOpening)`
  (hàm) — số hàng dẫn đầu giờ phụ thuộc Surah (header, hoặc header +
  phần mở đầu). Cả năm chỗ dùng chỉ số hàng mà Sprint F2 đã gom về một
  module được đổi trong một lần, đúng như F2 dự tính.
  `hasSeparateOpening` là NGUỒN DUY NHẤT cho câu hỏi "Surah này có phần
  mở đầu tách rời không" — cả `ReadingRows` lẫn `ReadingPlaylist`
  (BM1) cùng hỏi ở đó.
- **Basmalah chỉ còn hiện MỘT lần**: header bỏ hẳn phần Basmalah trang
  trí; hàng mở đầu thay thế nó.
- **Tô sáng dùng lại nguyên vẹn tầng F1** (`resolveAyahDecoration`) —
  không thêm nhánh nào; phần mở đầu tô màu bằng cùng công thức
  "đang phát" như thẻ Ayah.
- **Nhãn accessibility**: trước BM2 Basmalah là `Text` trần, trình đọc
  màn hình đọc ra tiếng Ả Rập thô không rõ là gì. Giờ là một node
  semantics có tên (`"Lời mở đầu Surah — Bismillah\n..."`), cùng dạng
  `AyahCard` tạo ra.
- **915 test** (+11). Coverage 81.89% → 81.98%.

### Added — Basmalah 2.0 BM1: Nền tảng audio (2026-08-04)

Với 112/114 Surah, Basmalah TRƯỚC ĐÂY hiện trên màn hình nhưng KHÔNG
BAO GIỜ được phát — đo trực tiếp trên file audio: `002001.mp3`
(Al-Baqarah 2:1) chỉ dài ~7.7 giây, không đủ chứa 9.2 giây của chính
Basmalah. Sprint này chữa đúng khoảng trống đó.

- **`ReadingPlaylist`** (mới) — song sinh với `ReadingRows`, quy đổi
  Ayah ↔ mục phát khi playlist có thêm phần mở đầu. Đây là chỗ chặn
  RỦI RO LỚN NHẤT của cả chuỗi Basmalah 2.0: thêm một mục vào playlist
  làm chỉ số playlist và chỉ số Ayah tách đôi, mà hai nơi tiêu thụ chỉ
  số Ayah (`ReadingPositionStore`, `study_sessions`) GHI XUỐNG ĐĨA. Cả
  hai giữ nguyên thuần hệ Ayah, không đổi gì — **không schema, không
  migration**.
- **Audio Basmalah không tốn tài nguyên mới**: Ayah 1 của Al-Fatihah
  CHÍNH LÀ Basmalah, nên `001001.mp3` là bản ghi Basmalah có sẵn cho
  MỌI Qari, cùng CDN, cùng bitrate. Xác nhận HTTP 200 cho cả 5 Qari.
  Không tải mới, không giấy phép mới.
- **Địa chỉ phần mở đầu là `QuranAddress.surah(N)`** (Sprint F0) — vai
  trò của nó, không phải văn bản của nó — nên KHÔNG cần Word Address.
  Ba tính chất sẵn có của F0 gánh toàn bộ thiết kế: mức Surah khác mức
  Ayah 1 (tô sáng không nhầm), mức Surah không có `zeroBasedAyahIndex`
  (dấu hiệu "chưa tới Ayah nào"), mức Surah sắp trước mọi Ayah của nó
  (đúng thứ tự playlist mà không cần luật riêng).
- **Al-Fatihah và At-Tawbah không có `if` số Surah nào** — kiểu
  `sealed SurahOpening` (Sprint F2) tự loại cả hai: Al-Fatihah vì
  Ayah 1 CHÍNH LÀ Basmalah (thêm mục là phát hai lần), At-Tawbah vì
  không có Basmalah.
- **904 test** (+17). Coverage 81.86% → 81.89%.

Chi tiết kiến trúc đầy đủ: `docs/release/PHASE4_BASMALAH_2_0_PLAN.md`
và bốn báo cáo sprint `PHASE4_SPRINT_BM{1,2,3,4}_REPORT.md`.

### Fixed — Sprint B3: Kiểm chứng phát nền trên máy thật + sửa lỗi (2026-08-04)

Chạy được emulator Pixel 8 (Android 17/API 37) — điều môi trường phát
triển trước đó không có. Tìm thấy và sửa **một lỗi thật khi chạy trên
máy**.

- **Lỗi: nghe hết một Surah để đó thì thông báo bị kẹt.** Sau khi
  playlist phát xong, `just_audio` vẫn báo `playing == true` (cờ này
  nghĩa là "đã được lệnh phát", không phải "đang ra tiếng"). Thông báo
  vì thế còn nút "Tạm dừng" cho thứ đã im, **không vuốt bỏ được**
  (`NO_DISMISS`), và ứng dụng giữ foreground service **vô thời hạn**.
  `AudioController` đã tự chữa từ lâu; adapter thông báo (B1) thì chưa
  — hai bên nói khác nhau về cùng một trình phát. Sửa: `playbackStateFor`
  giờ coi `processing == completed` là KHÔNG còn phát, đồng bộ với
  `AudioController`.
- **14/16 kịch bản Android PASS trực tiếp trên máy**: phát khi khoá
  màn hình, nút trên màn hình khoá (qua đường phím media), nút trên
  thông báo, cuộc gọi đến làm tạm dừng và tự phát lại, chạm thông báo
  mở đúng lại activity đang giữ phiên phát (không mất trạng thái),
  chặn biên `skipToNext`/`skipToPrevious` (xác nhận sửa lỗi B2), không
  crash trong suốt phiên. Bluetooth/tai nghe dây: chỉ xác nhận được
  đường mã nguồn (`MediaButtonReceiver`), không xác nhận được phần
  cứng thật (không có thiết bị).
- **887 test** (+3). Coverage giữ nguyên 81.86%.

Rủi ro còn lại: **iOS chưa kiểm chứng — 0%**, cần macOS. Chi tiết:
`docs/release/PHASE4_SPRINT_B3_REPORT.md`.

### Added — Phase 4 Sprint B2: Phát nền hoàn chỉnh (2026-08-04)

Nối nốt phần Sprint B1 cố ý dừng lại: `AudioService.init()` giờ được gọi
thật, và cấu hình nền tảng đã khai báo.

- **Android** — `AndroidManifest.xml` thêm `WAKE_LOCK`,
  `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (bắt buộc từ
  API 34), khai báo `<service>` của `audio_service` với
  `foregroundServiceType="mediaPlayback"`, và `<receiver>`
  `MediaButtonReceiver` cho phím media trên tai nghe/Bluetooth.
  `MainActivity` kế thừa `AudioServiceActivity` để chạm vào thông báo
  mở lại đúng engine đang giữ phiên phát, thay vì dựng engine mới và
  làm mất trạng thái.
- **iOS** — `Info.plist` khai `UIBackgroundModes: audio`. Đúng một mode:
  App Review có kiểm tra mode đã khai có thực sự được dùng không.
- **Chọn nền tảng có kiểm chứng** — `backgroundAudioSupported`. Web bị
  loại KỂ CẢ khi `defaultTargetPlatform` báo android/iOS, vì trên web nó
  trả về hệ điều hành của TRÌNH DUYỆT; không tách hai chiều đó là bản
  web đang chạy tốt sẽ chết ngay lúc khởi động.
- **Hàng đợi** — `QuranAudioHandler` publish `queue`. Đây cũng là nguồn
  DUY NHẤT biết playlist dài bao nhiêu, nên không có trường `_length`
  riêng để lệch pha.
- **Sửa lỗi: nút "Ayah kế" nhảy ra ngoài playlist.** Trước B2,
  `skipToNext` cộng 1 vô điều kiện và `seekToIndex` cũng không chặn, nên
  ở Ayah cuối, nút trên màn hình khoá tìm một mục không tồn tại. Giờ hết
  danh sách thì không làm gì — kẹp về mục cuối sẽ phát lại chính Ayah
  đang nghe từ đầu.
- **`AyahAudioItem` có test bằng-nhau-theo-giá-trị.** B1 khai `==`/
  `hashCode` mà không test dòng nào (độ phủ 1/11). Ngữ nghĩa này có tải
  trọng thật: "Thử lại" sau lỗi mạng dùng lại đúng danh sách cũ.
- **884 test** (+18). Coverage 81.71% → 81.86%. Hành vi phát khi app
  đang mở giữ nguyên.

Lúc viết entry này chưa kiểm được trên thiết bị thật. Đã kiểm ở Sprint
B3 (xem phía trên) — Android PASS 14/16 kịch bản qua emulator; iOS vẫn
chưa kiểm.

### Added — Sprint B1 (Phase 0–1): Nền móng phát nền (2026-08-03)

Hai phần đầu của phát-nền. **Người dùng chưa thấy gì đổi**: audio vẫn
phát khi app mở, y như trước.

- **`AyahAudioItem`** — mục playlist mang theo mô tả. `setPlaylist` nhận
  `List<AyahAudioItem>` thay cho `List<Uri>`: một URL không trả lời được
  "người dùng đang nghe gì", mà khi màn hình đã khoá thì thông báo là
  toàn bộ giao diện còn lại. Danh tính của mục là `QuranAddress` (Sprint
  F0) chứ không phải URL — URL đổi theo Qari, địa chỉ thì không.
- **`QuranAudioHandler`** — `BaseAudioHandler` **bọc quanh**
  `AyahAudioPlayer` chứ không thay thế nó. Đổi lại được hai điều:
  Windows/Linux (nơi `audio_service` không hỗ trợ) dùng
  `JustAudioAyahPlayer` không sửa gì; và `AudioController` không phải
  đổi một dòng, vì nút trên thông báo gọi thẳng xuống trình phát mà
  controller vốn đã lắng nghe — không có đường ghi thứ hai vào state,
  tức không có vòng lặp như chỗ audio/cuộn mà `DR-2026-0019` E3 phải gỡ.
- **`audio_service: ^0.18.19`**. Sàn Dart nâng 3.4 → 3.6 theo yêu cầu
  của gói: `pub get` phân giải theo SDK đang cài nên không báo lỗi,
  nhưng khai báo cũ là sai.
- **+21 test**. Hoá ra ranh giới "cần thiết bị thật" hẹp hơn dự đoán:
  `BaseAudioHandler` dựng được trong test thường, nên nội dung màn hình
  khoá, nút nào sáng, VÀ việc nút có nối đúng xuống trình phát đều kiểm
  được. Coverage 81.72% → 81.71%.

**Chưa nối, có chủ ý (Phase 2).** `AudioService.init()` chưa được gọi ở
`main.dart`, AndroidManifest chưa khai báo service, Info.plist chưa có
`UIBackgroundModes`. Gọi `init()` khi manifest chưa khai báo service là
lỗi lúc chạy, nên nối sớm sẽ làm hỏng app trên Android. Bộ quyền là một
cam kết với cửa hàng ứng dụng, không phải một thay đổi mã — nên phần đó
chờ quyết định. Điều này khiến `QuranAudioHandler` tạm thời chưa có nơi
tiêu thụ trên đường chạy thật; đánh đổi được ghi nhận, không giấu.

**Chưa kiểm được:** audio có thực sự tiếp tục phát khi khoá màn hình
không — cần thiết bị thật (roadmap B4).

### Changed — Phase 4 Sprint F2: Khai báo phần mở đầu Surah + đặt tên cho hàng danh sách (2026-08-03)

Nền móng cuối cùng trước Basmalah 2.0. Hành vi người dùng **không đổi
một điểm ảnh nào**; F2 chỉ gỡ hai chỗ mập mờ sẽ cản đường.

- **`SurahOpening`** (`lib/features/quran/domain/basmalah.dart`) thay
  cho `surahHasLeadingBasmalah`. Hàm cũ trả `false` cho CẢ Al-Fatihah
  lẫn At-Tawbah — vì hai lý do ngược nhau: Al-Fatihah CÓ Basmalah (nó
  chính là Ayah 1), At-Tawbah thì KHÔNG có. Một `false` mang hai nghĩa
  chạy đúng hôm nay và sai lặng lẽ ngay khi có ai hỏi "Surah này có
  phần mở đầu để phát / tô / tính tiến độ không?" — đúng câu hỏi
  Basmalah 2.0 sẽ hỏi. Kiểu `sealed` ba nhánh tách hai nghĩa đó ra, và
  nhánh của Al-Fatihah mang địa chỉ thật `1:1` (dùng `QuranAddress` của
  F0). Số Surah 1 và 9 giờ chỉ còn xuất hiện ở đúng một hàm.
- **`ReadingRows`**
  (`lib/features/quran/presentation/reading/reading_rows.dart`) gom
  NĂM chỗ viết tay phép quy đổi Ayah ↔ hàng danh sách (`itemCount`,
  `itemBuilder`, `initialScrollIndex`, `_onPositionsChanged`, cuộn theo
  audio). Không chỗ nào từng phát biểu hợp đồng "hàng 0 là header"; cả
  năm chỉ cùng giả định. Khi Basmalah 2.0 cho phần mở đầu một hàng
  riêng, bốn trong năm chỗ sẽ hỏng **lặng lẽ** — vị trí đọc lưu xuống
  đĩa lệch một Ayah, không ném lỗi, không test nào đỏ. Giờ chỉ còn
  `ReadingRows.leadingRows` phải đổi.
- **Kiểm chứng lại dữ liệu**, không chép từ tài liệu: 112 Surah có
  Basmalah là 4 token đầu của Ayah 1 (110 giống hệt từng byte + 2 biến
  thể chính tả ở 95/97), Ayah 1 ngắn nhất trong nhóm có 5 token nên
  phần còn lại không bao giờ rỗng; Al-Fatihah 1:1 đúng 4 token và không
  gì thêm; At-Tawbah không có.
- **851 test** (+17), trong đó một test đối chiếu kết quả của 114 Surah
  × 2 Ayah với công thức nguyên văn trước F2 — cổng "byte-identical"
  của `DR-2026-0019` E2 phát biểu ở dạng thuần. Coverage 81.60% →
  81.72%. Không đổi schema, không di trú dữ liệu, không thêm giao diện.

Chưa làm, có chủ ý: `_basmalahWordCount = 4` vẫn là một sự thật về ấn
bản nằm trong logic. Chữa thật cần chỉ mục từ có trong DỮ LIỆU
(`DR-2026-0017` M4/M5, kèm đổi schema và `PROJ-P-002`); chuyển sang
`Range(s:1:1 – s:1:4)` lúc này chỉ dời con số 4 sang chỗ khác chứ không
xoá nó. Con số ở nguyên chỗ cũ, kèm cảnh báo nói rõ vì sao.

### Changed — Phase 4 Sprint F1: Tầng trang trí + cuộn theo audio lịch sự (2026-08-03)

Bước nền móng thứ hai của Phase 4 (`DR-2026-0019` E1 và §7.3).

- **Tầng trang trí** (`lib/features/quran/domain/ayah_decoration.dart`)
  — luật quyết định nền thẻ Ayah (đang phát > người dùng tô màu > không
  gì) trước đây nằm trong một biểu thức ba ngôi lồng nhau giữa
  `AyahCard.build()`, nên muốn kiểm chứng phải dựng cả database, cả
  provider, cả khung hình. Giờ là `resolveAyahDecoration`, một hàm thuần
  trả về kiểu `sealed`. Tầng domain gọi tên một DẤU HIỆU, không bao giờ
  gọi tên một màu; đổi dấu hiệu thành màu vẫn là việc của tầng trình
  bày. Kiểu `sealed` là chủ ý: thêm một loại trang trí mới sau này (dấu
  chiêm nghiệm, trích dẫn AI Tutor, kết quả tìm kiếm) sẽ thành lỗi biên
  dịch ở mọi nhánh, thay vì một nhánh bị quên âm thầm.
- **Cuộn theo audio lịch sự** — thay đổi DUY NHẤT người dùng thấy được.
  Trước F1, cuộn đi đọc bản dịch thì Ayah kế chuyển là màn hình giật
  ngược về chỗ đang phát, mỗi Ayah một lần. Giờ sau mỗi lần người dùng
  tự kéo có 10 giây để yên (`shouldFollowPlayback`). Khoảng lặng tự hết
  hạn, nên không cần thêm nút "về chỗ đang phát" và người dùng không thể
  tự đưa mình vào trạng thái kẹt.
- **Hành vi còn lại KHÔNG đổi**: 834 test qua hết, +21 test mới (17
  thuần + 4 widget). Bốn test widget so màu nền THẬT của thẻ ở cả bốn
  trạng thái ưu tiên — trước F1 không có test nào chạm tới màu đó, nên
  lần tách tầng này lẽ ra chỉ được bảo vệ bằng lập luận. Không đổi
  schema, không đổi l10n, không thêm giao diện.

Chưa làm, có chủ ý: cắt vòng lặp cấu trúc giữa audio và cuộn (mỗi bên
vừa là nguồn vừa là đích của vị trí) — thuộc `DR-2026-0019` E3.

### Added — Phase 4 Sprint F0: Địa chỉ Qur'an (mức Surah/Ayah) (2026-08-03)

Nền móng đầu tiên của Phase 4 (`DR-2026-0017`). Trước F0, "vị trí một
Ayah" được biểu diễn bằng BA hệ số khác nhau trong cùng một ứng dụng —
số Ayah 1-based, chỉ số Ayah 0-based, và chỉ số dòng trong danh sách —
và việc quy đổi giữa chúng nằm rải rác dưới dạng `+ 1` / `- 1` trần.

- **`QuranAddress`** (`lib/core/quran/quran_address.dart`) — kiểu giá
  trị bất biến, **thuần Dart** (không Flutter, không Drift, không
  database, dựng và test được ở bất cứ đâu). Dựng theo mức Surah hoặc
  Ayah, so sánh theo giá trị, sắp theo thứ tự đọc, chứa-theo-tiền-tố,
  tuần tự hoá dạng quen thuộc `2:255`. **Bảo đảm ĐÚNG DẠNG, không bảo
  đảm TỒN TẠI** — `2:300` dựng được và không tồn tại; kiểm tra tồn tại
  cần dữ liệu và là việc của tầng repository. Chính sự tách bạch đó giữ
  cho kiểu này thuần Dart. +21 test.
- **`AudioState.currentAddress`** — điểm quy đổi DUY NHẤT giữa
  `currentIndex` (0-based, hệ của playlist) và số Ayah 1-based. Trả
  `null` thay vì ném khi trạng thái chưa dựng được địa chỉ đúng dạng:
  getter này chạy trong `select()` lúc build, nơi một ngoại lệ là màn
  hình trắng cho người dùng.
- **Gỡ mơ hồ tại 2 nơi, hành vi KHÔNG đổi**: `AyahCard` (đang phát) từ
  `s.currentIndex == ayahNumber - 1` thành so sánh hai `QuranAddress`;
  `AudioBar` từ chuỗi ghép tay `'${surahId}:${currentIndex + 1}'` thành
  `QuranAddress.toString()`. Toàn bộ 792 test cũ qua nguyên vẹn.
- **`docs/knowledge/quran_index_conventions.md`** — mô tả cả ba hệ số,
  nơi dùng từng hệ, và quy tắc quy đổi.
- **Cảnh báo dữ liệu tại `study_sessions.ayah_from/ayah_to`**: cột lưu
  0-based và KHÔNG có cột nào ghi lại hệ số của chính nó. Đổi bên ghi
  sang 1-based mà không bump `data_version` sẽ khiến dòng cũ/mới không
  phân biệt được, và vì streak/tổng phút tính TRÊN TRUY VẤN từ bảng này
  nên toàn bộ thống kê sai âm thầm, **không khôi phục được**. Đã ghi
  cảnh báo tại chỗ.

Phạm vi cố ý nhỏ: **chỉ mức Surah và Ayah**. Chưa có mức Word/Segment,
chưa có `Range`, chưa có trục ấn bản — cả ba nằm trong `DR-2026-0017`
nhưng chưa có nơi tiêu thụ (tiền lệ `DR-2026-0006` D4 / `DR-2026-0007`
D5), và thêm sau không tốn di trú vì F0 KHÔNG lưu địa chỉ xuống đĩa ở
bất cứ đâu. Không đổi schema, không đổi dữ liệu, không thêm tính năng
người dùng thấy được. Coverage 81.52% → 81.58%.

### Fixed — Phase 3 Sprint R3b: Bề mặt sản phẩm trung thực (2026-08-03)

Đợt review sản phẩm (`PRODUCT_READINESS_REVIEW.md`) phát hiện chất
lượng mã không còn là điểm nghẽn cho beta công khai — ba điểm giao diện
hứa hẹn tính năng mà tầng dữ liệu không thực hiện được mới là điểm
nghẽn. Đóng dứt điểm qua 3 sprint con + 1 đợt review cuối, mỗi bước đều
qua `flutter analyze --fatal-infos` / `flutter test` / `dart format`,
không commit cho tới khi review cuối duyệt:

- **R3b.1**: chip phạm vi tìm kiếm "Ghi chú của tôi" trước đây bấm
  chọn được nhưng thân màn hình render trống — sửa bằng cách khoá chip
  (đúng mẫu đã dùng cho "Hỏi AI"). Hai ô Hồ sơ ("Thông tin cá nhân",
  "Đồng bộ") đổi nhãn nội bộ `"Coming in Step N"` thành "Sắp ra mắt"
  chung. Ô "Mục tiêu" bị **gỡ hẳn**, không đổi nhãn — vì tính năng
  (Mục tiêu ngày) đã xây và đang chạy thật, đổi nhãn chỉ đổi loại câu
  sai, không sửa được câu sai.
- **R3b.2**: gỡ hẳn nút "Hỏi AI" và toàn bộ hàng chip phạm vi tìm kiếm
  (cả 3 chip, không chỉ chip đã khoá ở R3b.1) — sau khi review kiến
  trúc xác nhận không còn chip nào tạo ra khác biệt hành vi thật:
  "Tất cả" và "Qur'an" luôn chạy chung một truy vấn, "Ghi chú của tôi"
  chưa từng có nguồn dữ liệu.
- **R3b.3**: ô tìm Lemma trong Thêm Flashcard — luồng bế tắc DUY NHẤT
  còn thật sự chạm tới được hôm nay (Smart Deck "Gốc từ yếu"/"Theo thể
  động từ" đã được rà soát và xác nhận KHÔNG thể chạm tới trong ứng
  dụng hiện tại, không phải đã sửa) — giờ kiểm tra Lexicon có dữ liệu
  thật trước khi vẽ ô tìm kiếm, thay vì mời gõ vào một bảng luôn rỗng
  rồi báo "Không tìm thấy kết quả." (câu ngụ ý một tìm kiếm thật đã
  chạy và thất bại, sai bản chất với "chưa có dữ liệu").

Chi tiết: `docs/release/PHASE3_SPRINT_R3B_PLAN.md`,
`_DESIGN_REVIEW.md`, `_1_REPORT.md` đến `_3_REPORT.md`,
`_FINAL_REVIEW.md`. Hai hạng mục cố ý để ngoài phạm vi 3 sprint con này
(2 hàng chip xám giữ chỗ, 2 nhóm khoá l10n không còn tham chiếu) — đóng
dứt điểm ngay bên dưới, mục "R3b Close-out Patch".

### Fixed — Phase 3 R3b Close-out Patch: dọn nốt 2 hạng mục còn lại (2026-08-03)

Hai hạng mục "Bề mặt trung thực" cố ý để ngoài phạm vi R3b.1–3 (đã ghi
nhận ở mục ngay trên), đóng dứt điểm ở đợt patch này:

- Gỡ hẳn `_PlaceholderChipRow` VÀ 2 tiêu đề "Gần đây"/"Gợi ý" cùng lúc
  — chỉ gỡ khối chip mà giữ lại tiêu đề sẽ để lại 1 heading thật trỏ
  vào khoảng trống, một kiểu bề mặt không trung thực MỚI, không phải
  bản sửa cho kiểu cũ. `SearchEmptyState` giờ chỉ còn icon + tiêu đề +
  gợi ý cách gõ.
- Xoá 4 khoá l10n `placeholder*` (0 nơi gọi thật) — đúng phạm vi đã
  định. Xoá thêm 2 khoá `searchEmptyRecentSectionTitle`/
  `searchEmptySuggestedSectionTitle` — không cùng tiền tố `placeholder*`
  nhưng trở nên không còn nơi gọi ĐÚNG VÌ việc gỡ 2 tiêu đề ở trên, nên
  cùng thuộc diện xoá theo tiêu chí đã áp dụng xuyên suốt R3b ("0 nơi
  gọi", không phải "khớp tên").

Không đụng `l10n.comingInStep` (mồ côi từ R3b.1, khác nguyên nhân, vẫn
mở — xem `RELEASE_DASHBOARD.md` §3). 1 test gỡ hẳn (mất đúng lý do so
sánh trực quan của nó, không còn gì để so sánh), 2 test khác chỉ bớt
assertion, giữ nguyên test. 792 test qua (802 mốc R3.2 → 793 sau R3b.1–3
→ 792). Chi tiết: `docs/release/PHASE3_R3B_CLOSEOUT_PATCH_REPORT.md`.

### Fixed — Phase 3 Sprint R3a: Web platform hoàn thiện (2026-08-03)

Nền tảng Web trước đây build được nhưng mở database lỗi runtime (thiếu
2 file WASM/JS bắt buộc) — CI vẫn xanh vì `flutter build web` không tự
mở database thật. Đã đóng dứt điểm qua 3 sprint con:

- **R3a.1**: vendor `web/sqlite3.wasm` (từ release `sqlite3-3.3.4` của
  `sqlite3.dart`) và `web/drift_worker.js` (từ release `drift-2.34.0`)
  — khớp CHÍNH XÁC với version khoá trong `pubspec.lock`, không phải
  bản mới nhất. Nguồn gốc + SHA-256 từng file ghi lại trong
  `docs/DATA_PIPELINE.md` mục "Web runtime".
- **R3a.2**: xác minh THẬT trong trình duyệt (không chỉ build): cả 2
  database (nội dung + người dùng) đều mở được, danh sách Surah hiển
  thị đúng, Tìm kiếm FTS5 trả về 40 kết quả thật xếp hạng đúng, bookmark
  ghi vào vẫn còn sau khi tải lại trang, console sạch hoàn toàn (không
  lỗi WASM/worker/drift). Backend lưu trữ xác nhận là IndexedDB
  (tầng `sharedIndexedDb`).
- **R3a.3**: thêm bước kiểm tra trong CI (`build-web`) — fail NGAY nếu
  thiếu 1 trong 2 file, trước khi tốn thời gian cài Flutter, tránh tái
  diễn tình trạng CI xanh nhưng runtime lỗi.

Chi tiết: `docs/release/PHASE3_SPRINT_R3A1_REPORT.md` đến
`_R3A3_REPORT.md`. Còn mở: chưa chọn nơi lưu trữ (hosting) cho bản
Web, nên tầng lưu trữ nhanh nhất (OPFS, cần header COOP/COEP) chưa được
xác minh trong thực tế — không phải lỗi đúng/sai, chỉ là hiệu năng chưa
tối ưu; tầng IndexedDB đã xác minh hoạt động đầy đủ.

### Fixed — Phase 3 Sprint R3.2: Chính sách đo coverage (2026-08-01)

Đo lại coverage lần đầu tiên kể từ khi P1–P4/F1–F8 merge, và điều
chỉnh ngưỡng CI theo đúng số đo thật (`DR-2026-0015`). Bốn số đo công
khai đầy đủ (`flutter test --coverage` trên `main`, 802 test, sau
Sprint R3.1):

| Cách đo | Coverage | Số dòng |
|---|--:|--:|
| Thô — không loại trừ gì | 51.96% | 8816/16968 |
| Đã lọc — chính sách CI cũ (`main.dart`, `*.g.dart`, stub kết nối db) | 76.25% | 6584/8635 |
| **Đã lọc + loại cả bảng chuỗi l10n sinh tự động — chính sách mới** | **81.54%** | **6141/7531** |

Thay đổi duy nhất: thêm 1 mẫu lcov (`lib/l10n/app_localizations_*.dart`)
vào cạnh mẫu `**/*.g.dart` đã có sẵn — `app_localizations.dart` (chứa
`LocalizationsDelegate` thật, đạt 94.7%) CỐ Ý giữ lại trong phạm vi đo.
`MIN_COVERAGE` nâng 70 → 80. Đây là một điều chỉnh MẪU SỐ, không phải
coverage mới — trạng thái qua/chưa qua test của từng dòng tay viết
không đổi. Một mất mát thật, ghi nhận lại chứ không giấu đi: tiếng Ả
Rập từng chỉ đạt 4.3% coverage (so với 69.3% tiếng Anh, cùng 1 cấu
trúc file) — đó là dấu hiệu RTL gần như chưa được test tới, giờ
chuyển sang theo dõi tường minh ở `RELEASE_PLAN_V1.md` §2 "Verification
gaps", KHÔNG coi là đã đóng chỉ vì bị loại khỏi số đo. Chi tiết:
`docs/adr/DR-2026-0015-coverage-measurement-policy.md`,
`RELEASE_DASHBOARD.md` §2.

### Fixed — Phase 3 Sprint R2: Màn hình Read Model (Study Summary) (2026-07-31)

`StudySummaryScreen` ra mắt (route `/study-summary`): hiển thị đủ 4
mục của `LearningSnapshot` (bối cảnh/nhận định/kế hoạch ngày/phiên học
đề xuất) bằng cách dùng lại nguyên widget và hàm trình bày thuần đã có
từ `ai_tutor`/`learning_journey`/`smart_learning` — không viết lại
logic hiển thị nào. Kéo để làm mới + nút Thử lại đều chỉ invalidate
`smartLearningSessionProvider` (KHÔNG BAO GIỜ invalidate
`learningSnapshotProvider` trực tiếp — xem "Refresh Strategy" trong
`docs/release/PHASE3_SPRINT_R2_DESIGN_REVIEW.md`). Đóng **D3** — Read
Model (F7, merge từ đợt khôi phục phát hành nhưng chưa từng có màn
hình dùng tới) giờ có quyết định sản phẩm rõ ràng: xây UI, không phải
hoãn lại. 799 test qua, `flutter analyze --fatal-infos` sạch, CI xanh
trên `main` (commit `275204b`). Còn mở, cố ý chưa làm trong sprint
này: chưa có điểm vào (CTA) từ `SmartLearningScreen` (route đã có,
chưa nơi nào dẫn tới) — đóng ở Sprint R3.1 ngay sau đó. Chi tiết:
`docs/release/PHASE3_SPRINT_R2_1_REPORT.md` đến `_R2_3_REPORT.md`.

### Fixed — Phase 3 Sprint R1: Nối engine tìm kiếm FTS5 thật (2026-07-31)

Ba sprint con, commit `0f3f751`. Đóng khoảng trống đã ghi nhận từ
`RELEASE_PLAN_V1.md`: màn Tìm kiếm có đủ giao diện từ Sprint 7.1
nhưng chưa nối engine thật — gõ gì cũng không ra kết quả.

- **R1.1**: nối `SearchScreen` vào engine FTS5 đã có qua một cặp
  provider MỚI, độc lập (`searchQueryProvider`/`searchResultsProvider`
  trong `search/data/search_providers.dart` mới) — cố ý KHÔNG dùng lại
  `ayahSearchProvider` của `SurahListScreen` để tránh 2 màn hình dùng
  chung 1 state tìm kiếm. Gọi thẳng `QuranRepository.searchAyahs()`
  không sửa gì — không thêm phương thức repository, không đổi schema.
- **R1.2**: thêm `SearchNoResultsState` — tìm xong mà không khớp gì
  giờ tách biệt rõ (hình ảnh lẫn accessibility) khỏi "chưa gõ đủ" và
  "lỗi tải".
- **R1.3**: đợt rà soát — 5/6 khu vực rà soát (gõ nhanh/debounce, xoá,
  chuyển trạng thái tải/lỗi/không kết quả, focus) đã đúng sẵn, chỉ ghi
  lại chứ không sửa; 1 lỗi accessibility thật được tìm thấy và sửa
  (`SearchResultSection` thiếu `liveRegion: true` khi công bố kết
  quả — bất đối xứng duy nhất trong 4 trạng thái thân màn hình). Thêm
  1 test hồi quy: gõ 5 lần liên tiếp không đợi nhau chỉ gọi repository
  ĐÚNG 1 LẦN, với truy vấn cuối cùng.

`search_index_content` (FTS5) có 43.652 dòng thật, xác minh xuyên suốt
trong đợt kiểm tra trình duyệt Sprint R3a.2. 786 test qua tại thời
điểm R1.3 đóng. **Đây là mục hoàn thành lớn nhất bị bỏ sót khỏi
CHANGELOG lâu nhất** — phát hiện tại `PRODUCT_READINESS_REVIEW.md` §5,
bổ sung tại đợt dọn dẹp theo dõi phát hành này. Chi tiết:
`docs/release/PHASE3_SPRINT_R1_PLAN.md`, `_DESIGN_REVIEW.md`,
`_1_REPORT.md` đến `_3_REPORT.md`.

### Ghi chú — khoảng trống backfill

Các mục "Sprint 10" trở xuống trong phần `[Unreleased]` này được viết
tại thời điểm đó (trước đợt khôi phục phát hành). Mục "Đợt khôi phục
phát hành" ngay bên dưới backfill toàn bộ những gì đã merge SAU Sprint
10 — P1–P4, F1–F8, và Sprint S1/S2 — được viết muộn hơn nhiều (Phase
2.1, Documentation Integration), tóm tắt ở mức PR chứ không chi tiết
từng phase như các mục cũ hơn. Chi tiết đầy đủ từng nhóm:
[`docs/reports/release-recovery/`](docs/reports/release-recovery/).

### Added — Đợt khôi phục phát hành: P1–P4, F1–F8 (PR #3–#19)

Một mega-commit lớn (`d4976b0`) được tách lại thành 12 nhóm PR độc
lập, xác minh và merge lần lượt vào `main`:

- **P1 — Lớp tin cậy (Reliability layer)**: `AppFailure`/
  `FailureCategory`/`FailureSeverity`, `Logger`/`CrashReporter`
  (interface, `ConsoleLogger`/`NoopCrashReporter` mặc định),
  `withFailureLogging`/`withFailureLoggingStream` — điểm bọc lỗi DUY
  NHẤT ở ranh giới Repository (PR #3).
- **P2 — Widget accessibility dùng chung**: `EmptyStateBanner`,
  `LoadingState`, `SectionHeader`, `StatCard` (PR #5).
- **P3 — Schema database cho Lexicon/Flashcards/Analytics**:
  `UserDatabase` schemaVersion 3→6 (`srs_cards` tổng quát hoá,
  `quiz_results`, `flashcard_decks`, `flashcards`); 8 bảng Lexicon mới
  trong `AppDatabase` (PR #11).
- **P4 — Áp dụng lớp tin cậy vào 9 repository hiện có** (PR #12).
- **F1 — Lexicon**: domain/repository đọc Root/Lemma/Lexeme/
  WordInstance/GrammarFeature/Phrase/LexiconRelation (PR #13, gộp
  cùng F2/F3).
- **F2 — Flashcards**: duyệt/thêm/xoá/gộp Smart Deck, gắn vào
  Scheduler qua cầu nối ở tầng Provider (PR #13).
- **F3 — Analytics (Phân tích học tập)**: thống kê, lịch sử, insight,
  mục tiêu, thành tích — tổng hợp thuần từ 4 repository lá, không lưu
  trữ riêng (PR #13).
- **F4 — AI Tutor**: gợi ý/insight dựa trên luật từ Analytics — CHƯA
  gọi AI/LLM thật (PR #14).
- **F5 — Learning Journey**: kế hoạch học hằng ngày, tổng hợp từ AI
  Tutor (PR #15).
- **F6 — Smart Learning**: xếp hạng chiến lược học từ Learning
  Journey (PR #16).
- **F7 — Read Model**: `LearningSnapshot` bất biến, tổng hợp cả chuỗi
  5 tầng — CHƯA có màn hình dùng tới (PR #17).
- **F8 — Learning Session wiring**: hợp nhất Review/Quiz/Flashcard
  vào một luồng phiên học duy nhất, một route (PR #18).

### Fixed — Sprint S1 (audit) → S2 (Quality & Polish, PR #19)

Sau khi cả 12 nhóm trên merge, một đợt audit toàn diện
(`docs/reports/release-recovery/PROJECT_AUDIT_REPORT.md`) tìm ra và
ưu tiên hoá nợ kỹ thuật; Sprint S2 sửa các mục Critical/High:

- `learning_session` không có xử lý lỗi nào (Notifier trần, không
  bắt exception) — thêm trạng thái `failed` + `retry()`, dùng lại
  đúng `LoadingState`/`SearchErrorState` mọi tính năng khác đã dùng.
- `CrashReporter` được xây từ Sprint 19 nhưng chưa từng được gọi —
  nối vào `ConsoleLogger` để mọi lỗi qua ranh giới Repository đều tới
  được nó (vẫn no-op cho tới khi có implementation thật).
- Dọn 1 provider chết hoàn toàn (`statsRefreshProvider`), gộp 2 widget
  trùng lặp trong `stats_screen.dart` vào `StatCard`/`EmptyStateBanner`
  dùng chung, trích 1 helper dùng chung cho 4 generator câu hỏi Quiz.
- Thêm test cho 4 khoảng trống coverage (session_strategy_rules,
  daily_goal store/providers, 2 provider DI chưa từng qua
  `container.read()` trực tiếp).

Bộ test đầy đủ: 767/767 qua tại thời điểm PR #19 merge (từ mốc 375 ở
cuối Sprint 10). Chi tiết đầy đủ: `docs/reports/release-recovery/`.

### Added — Sprint 10: Learning Engine — Scheduler SM-2 + Quiz (Bước 9 phần 1)

Thực hiện theo [DR-2026-0005](docs/adr/DR-2026-0005.md) (5 phase:
Architecture Freeze -> Scheduler Foundation -> Provider Layer ->
Review Session UI -> Quiz System; ADR chính thức được ghi thành file
ở bước Finalization). Amend một phần định hướng ban đầu của
[DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md) về
`srs_cards` (không "thay thế" Revision Queue như dự định gốc — xem
bên dưới).

- **Kiến trúc Learning Engine**: khái niệm tổ chức (không phải 1
  class cụ thể) gồm Revision Queue + Scheduler + Quiz, sẽ mở rộng
  thêm Flashcard/Hifz/AI Tutor sau này — mọi thành phần phía trên chỉ
  phụ thuộc `SchedulingAlgorithm` (giao diện trừu tượng), không phụ
  thuộc SM-2 cụ thể.
- **Scheduler SM-2** (`lib/features/learning/domain/`, thuần Dart —
  không import Flutter/Riverpod/Drift): `SchedulingAlgorithm` (giao
  diện) + `SM2SchedulingAlgorithm` (SuperMemo-2 cổ điển, 4 mức đánh
  giá kiểu Anki: Again/Hard/Good/Easy, ease factor mặc định 2.5, sàn
  1.3) + `SchedulerRepository`/`SchedulerRepositoryImpl` (bảng mới
  `srs_cards`, `schemaVersion` 3->4, hoàn toàn additive).
  **Quyết định 1-2 của DR-2026-0005**: Revision Queue
  (`ayah_statuses.status='review'`) giữ nguyên ĐỘC LẬP, KHÔNG bị thay
  thế — khác định hướng ban đầu ở `DR-2026-0003` ("sẽ thay thế Revision
  Queue đơn giản khi cần SM-2"). Scheduler chỉ TIÊU THỤ Revision Queue
  làm nguồn thành viên qua `schedulerSyncProvider` (orchestration ở
  tầng Provider, không phải Repository) — tạo/xoá mềm thẻ tự động khi
  Ayah vào/rời Queue, không backfill lúc migration.
- **Màn hình "Lặp lại ngắt quãng"** (route `/review-session`, nối từ
  tab Học): đọc `dueReviewCardsProvider` (lọc+sắp+khử trùng lặp thẻ
  đến hạn — hàm thuần `selectDueCardsOrdered`), trình bày từng thẻ,
  đánh giá qua `SchedulerRepository.applyReview` rồi tự chuyển thẻ kế
  tiếp (phản ứng theo stream, không tự quản lý hàng đợi trong widget),
  "Mở trong Kinh" dùng chung `openAyahInReadingScreen()`.
- **Quiz** (`lib/features/quiz/`): `QuestionGenerator` (giao diện
  trừu tượng, thuần Dart) + 4 loại câu hỏi, mỗi loại cắm được vào
  `QuizQuestionFactory` mà không cần sửa code cũ (Surah identification,
  Ayah continuation, Translation matching, Verse recognition). **Không có
  Question Bank** — câu hỏi sinh động mỗi phiên từ nhóm A
  (`QuranRepository`, qua `quizContentPoolProvider`) rồi bỏ đi, không
  bao giờ ghi xuống nhóm B. Bảng mới `quiz_results` (`schemaVersion`
  4->5, hoàn toàn additive) CHỈ lưu điểm/loại/thời điểm — không lưu
  câu hỏi/nội dung Ayah. Màn hình "Trắc nghiệm" (route `/quiz-session`,
  nối từ tab Học) dùng `AsyncNotifier` (`QuizSessionController`) tự
  sinh 10 câu khi mở, ghi điểm, lưu kết quả khi hoàn thành, "Làm lại"
  sinh phiên mới.
- **2 lệch có chủ đích so với sketch SQL thô trong `DATABASE.md`**,
  ghi rõ lý do tại chỗ (xem DATABASE.md mục Nhóm B): `srs_cards`
  dùng `UNIQUE(item_type, item_id)` thay vì
  `UNIQUE(user_id, item_type, item_id)` (user_id nullable khiến ràng
  buộc gốc không có tác dụng thật, theo đúng tiền lệ mọi bảng khác
  trong file); `quiz_results.surah_id` nullable (quiz 'mixed' trộn
  nhiều Surah trong 1 phiên, không gắn 1 Surah).
- **Flashcard hoãn lại có chủ đích** (Quyết định 4): không có dữ liệu
  từ vựng (`lemmas`/`word_instances` vẫn chỉ là schema dự định, chưa
  có importer/nguồn dữ liệu — xem TODO.md), không thiết kế giải pháp
  tạm. Hifz và "Nhật ký" không nằm trong 6 quyết định của Sprint 10 —
  chưa xây.

### Tests
- +70 test mới (305 -> 375), một test mỗi phase như DR-2026-0005 Quyết
  định 6 yêu cầu (khác Sprint 9 — không có test mới phase nào):
  SM-2 math (13), SchedulerRepository (8), scheduler provider layer —
  đồng bộ/due/thứ tự/khử trùng lặp (11 hàm thuần + provider), Review
  Session UI (6 widget test), 4 generator câu hỏi Quiz + factory (14),
  QuizRepository (5), Quiz provider layer — sinh câu hỏi/điểm/lưu kết
  quả/restart (7), Quiz Session UI (4 widget test), 2 migration test
  mới (v3->v4, v4->v5).

### Chưa làm (ngoài phạm vi DR-2026-0005)
- Flashcard (khoá "Sắp ra mắt" trên tab Học) — chờ nguồn dữ liệu từ
  vựng, xem TODO.md.
- Hifz, "Nhật ký" — chưa từng được định nghĩa cụ thể trong Sprint 10,
  chỉ nêu tên như nhánh tương lai của Learning Engine.
- Coverage% thật chưa đo lại sau Sprint 10 (`flutter test --coverage`
  ngoài phạm vi Phase 5) — xem TODO.md mục MIN_COVERAGE.

## [0.8.1] — Sprint 9: Daily Goal, Revision Queue, Streak canonical (Bước 8 phần còn lại)

### Added

Thực hiện theo [DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md)
(6 phase: Architecture Freeze -> Foundation -> Provider -> UI ->
Integration & Polish -> hoàn tất Quyết định 1). Cả 3 quyết định của
DR-2026-0004 đã triển khai đủ. Amend một phần
[DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md)
(streak canonical, Daily Goal storage) — không thay thế, phần còn
lại của DR-2026-0003 vẫn nguyên hiệu lực.

- **Kiến trúc**: backfill `DR-2026-0003` vào `docs/adr/` (chưa từng
  có file thật trước Sprint 9) + `DR-2026-0004` mới + `docs/adr/README.md`
  (index ADR, lần đầu có). Không đổi schema/migration — `schemaVersion`
  vẫn là 3 xuyên suốt cả Sprint 9.
- **Daily Goal**: `DailyGoalStore` (SharedPreferences, cùng kiến
  trúc `ThemeController`/`LocaleController`) lưu chỉ tiêu phút/ngày +
  Ayah/ngày; `dailyGoalProgressProvider` ghép thuần
  `todayStudySummaryProvider` (Sprint 8) với chỉ tiêu, không tính lại
  gì, không có bảng `profiles` mới. Dialog đặt chỉ tiêu (2 ô số,
  không route riêng) + thẻ gọn trên Trang chủ, chạm để mở dialog.
- **Revision Queue**: `UserContentRepository.watchAllReviewAyahs()`
  (đối xứng với 4 `watchAllX()` có sẵn) + `LibraryKind.review` +
  màn hình riêng (route `/revision-queue`, push full-screen giống
  Thư viện của tôi/Tìm kiếm/Bộ sưu tập) — tái dùng nguyên vẹn
  `LibraryTabView`/`LibraryAyahTile`, không có list/tile/repository
  riêng. Nối từ thẻ "Ôn tập hằng ngày" trên tab Học (3 công cụ còn
  lại vẫn khoá, chờ Bước 9).
- **Dọn nợ kỹ thuật điều hướng**: `LibraryScreen._open` và
  `ActiveKhatmCard._continueReading` (Sprint 8) từng tự lặp lại 2
  bước `openAyahInReadingScreen()` đã gói sẵn (vi phạm hợp đồng dùng
  chung `DR-2026-0002` mục 9) — cả hai giờ gọi thẳng hàm dùng chung,
  hành vi xác nhận không đổi (bộ test cũ 305/305 vẫn qua nguyên vẹn).
- **Streak canonical (DR-2026-0004 mục 1) triển khai xong**:
  `HomeScreen` (`_StatChipsRow`) và `StatsScreen` (lưới chỉ số) đọc
  `currentStreakProvider`/`longestStreakProvider` (Drift) — không
  còn nơi nào trong `lib/` đọc `stats.currentStreak`/`longestStreak`
  (`StatsStore`, xác nhận bằng grep toàn project). `StatsScreen` vẫn
  hiện streak ở 2 vị trí (lưới chỉ số cũ + mục "Phiên đọc") — không
  gộp lại (ngoài phạm vi, chỉ đổi nguồn đọc) — nhưng cả hai giờ LUÔN
  khớp số vì cùng một nguồn duy nhất.

### Tests
- Không có test mới trong Sprint 9 (đúng phạm vi được giao từng
  phase) — 305 test hiện có xác nhận không hồi quy sau mỗi phase,
  kể cả sau khi đổi nguồn streak.

### Chưa làm (ngoài phạm vi DR-2026-0004)
- "Journey" (Trang chủ tổng hợp) chưa hiện tóm tắt Khatm — vẫn chỉ ở
  tab Thống kê. Không thuộc 3 quyết định của DR-2026-0004.
- Ngưỡng "ngày đủ điều kiện tính streak" (>=5 phút HOẶC >=5 Ayah)
  vẫn chưa triển khai — `DR-2026-0004` chỉ quyết định nguồn dữ liệu,
  không đổi công thức ngưỡng.
- `CollectionItem` tổng quát vẫn cố ý chưa xây.
- `docs/adr/DR-2026-0002-*.md` (Search, Sprint 7.1) vẫn chưa tồn tại
  trong repo — phát hiện lại lúc backfill DR-2026-0003, ngoài phạm vi
  Sprint 9.

## [0.8.0] — Sprint 8: Streak, Khatm %, Bookmark Collections

### Added

Thực hiện theo [DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md)
(5 phase: Schema -> Repository -> Provider -> UI -> Integration &
Polish).

- **Kiến trúc**: Drift schema files là Source of Truth cho schema
  hiện tại; `DATABASE.md` là Design Specification 3 tầng (Đã triển
  khai / Đã định / Ý tưởng tương lai). Streak tính TRÊN TRUY VẤN từ
  `study_sessions` — không có bảng `streaks` riêng (dẫn xuất-khi-đọc).
  Bookmark Collections chỉ áp dụng cho Ayah ở tầng database (tránh
  bảng chưa dùng đến); mô hình domain giữ mở cho tổng quát hoá sau
  này nhưng chưa xây `CollectionItem`.
- **Schema (Nhóm B, `UserDatabase` schemaVersion 2 -> 3)**: 3 bảng
  mới — `study_sessions` (phiên đọc: ngày, Surah, khoảng Ayah, thời
  lượng), `khatm_cycles` (chu kỳ đọc trọn Qur'an: tên, vị trí hiện
  tại, ngày hoàn thành) — cùng cột mới `bookmarks.collection_id`
  (nullable, không khai báo FK ở tầng Drift — không có tiền lệ FK
  trong schema này, toàn vẹn do tầng repository đảm nhiệm) và bảng
  `bookmark_collections` (tên, emoji, thứ tự hiển thị).
- **Migration**: hoàn toàn additive — `onUpgrade` thêm 3 bảng +
  1 cột, không đổi/xoá gì. Test cả hai đường nâng cấp thật (v1->v3
  và v2->v3) trên dữ liệu mẫu dựng thủ công, xác nhận dữ liệu cũ
  còn nguyên sau khi nâng cấp.
- **Repository**: `StudySessionRepository`, `KhatmCycleRepository`,
  `BookmarkCollectionRepository` (interface tách khỏi Drift, đúng
  quy ước `UserContentRepository` có sẵn). `BookmarkCollectionRepositoryImpl`
  tự kiểm tra toàn vẹn khi gán/xoá bộ sưu tập (vì database không có
  ràng buộc FK): ném lỗi khi gán vào collection không tồn tại, gỡ
  `collection_id` khỏi mọi bookmark liên quan trước khi xoá mềm một
  collection (trong 1 transaction).
- **Provider**: 3 provider repository (kiểu interface, đúng mẫu
  `quranRepositoryProvider`/`userContentRepositoryProvider`) + 7
  provider ứng dụng (`currentStreakProvider`, `longestStreakProvider`,
  `todayStudySummaryProvider`, `activeKhatmCycleProvider`,
  `khatmProgressProvider`, `bookmarkCollectionsProvider`,
  `collectionBookmarksProvider`) — không trùng lặp logic nghiệp vụ:
  `khatmProgressProvider` đọc thẳng `KhatmCycle.progressPercent` có
  sẵn ở domain model, không tính lại công thức.
- **UI**: mục "Phiên đọc" (Streak hiện tại/dài nhất, tổng kết hôm
  nay) + thẻ "Khatm đang đọc" (tiến độ %, thanh tiến độ, Tiếp tục
  đọc) thêm vào màn Thống kê (cộng thêm, không đụng lưới chỉ số
  SharedPreferences hiện có). Màn hình "Bộ sưu tập" mới (tạo/đổi
  tên/xoá), mở từ biểu tượng trên AppBar "Thư viện của tôi"; nút
  "Sắp xếp vào bộ sưu tập" mới trên mỗi thẻ Bookmark. 24 khoá l10n
  mới, đủ cả vi/en/ar.
- **Tích hợp**: `ReadingScreen` giờ ghi 1 `study_session` thật khi
  rời trang đọc (ngưỡng >=5 giây, khớp `StatsStore.addSeconds` hiện
  có) — cùng lúc với lời gọi `StatsStore.addSeconds` cũ, không thay
  thế. Đóng khoảng trống "chưa có nơi nào ghi vào study_sessions"
  từng ghi nhận cuối Phase 4.

### Tests
- +61 test cho Sprint 8 (repository + provider + widget + tích hợp +
  điều hướng qua router thật) — tổng dự án 305 test, tất cả qua
  `dart format` / `flutter analyze --fatal-infos` / `flutter test`.

### Chưa làm (Bước 8 CHƯA hoàn tất)
- "Journey" (tổng hợp dashboard Trang chủ: tiếp tục đọc, tiến độ hôm
  nay, streak, verse of the day) — chưa xây, xem `placeholderHome`.
- Daily Goal thật — chưa có UI/luồng. Kiến trúc lưu trữ đã đóng băng
  cho Sprint 9 (chỉ tiêu SharedPreferences qua `DailyGoalStore` mới,
  tiến độ dẫn xuất từ `study_sessions` — xem
  [DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md)),
  chưa triển khai.
- Revision Queue chưa có màn hình riêng — vẫn dùng cơ chế đơn giản
  có sẵn từ Bước 6 (`ayah_statuses.status='review'`), đúng quyết
  định "Simple Revision Queue" của
  [DR-2026-0003](docs/adr/DR-2026-0003-sprint8-data-architecture.md),
  tái khẳng định ở
  [DR-2026-0004](docs/adr/DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md).
- Ngưỡng "ngày đủ điều kiện tính streak" (tổng thời lượng/Ayah trong
  ngày >=5 phút HOẶC >=5 Ayah, từng ghi ở DATABASE.md) chưa triển
  khai — hiện chỉ cần 1 phiên >=5 giây là streak-day được tính. Xem
  TODO.md để biết khuyến nghị.
- `CollectionItem` — hợp đồng domain tổng quát cho bộ sưu tập ngoài
  Ayah — cố ý chưa xây, ngoài phạm vi 5 deliverable của Phase 4.

## [0.7.1] — Sprint 7.1: Nền tảng UI Tìm kiếm

### Added
- Màn hình Tìm kiếm (`/search`) — route top-level push full-screen,
  cùng mẫu với "Thư viện của tôi" (không phải tab thứ 6). Điểm vào từ
  nút tìm kiếm trên Trang chủ và tab Qur'an.
- Ô nhập từ khoá thay tiêu đề AppBar (gợi ý placeholder, nút xoá khi
  có chữ); chuyển đổi Tìm kiếm / Hỏi AI ("Hỏi AI" hiển thị khoá sẵn —
  Sắp ra mắt); Scope Chips (Tất cả / Qur'an / Ghi chú của tôi) — Mode
  và Scope là hai trục độc lập hoàn toàn.
- Bốn trạng thái thân màn hình, mỗi trạng thái là một component dùng
  chung cho MỌI domain tương lai (Qur'an hôm nay; Hadith/Ghi chú/Trả
  lời AI sau này — xem ADR `DR-2026-0002`): `SearchEmptyState` (tiêu
  đề + gợi ý cách gõ + 2 khu vực placeholder cho Recent/Suggestions),
  `SearchLoadingSkeleton`, `SearchErrorState`, `ResultCard` +
  `SearchResultSection` (factory `.fromAyah`/`.ayahs` dùng lại đúng
  entity domain có sẵn, không bịa shape mới).
- Chạm một kết quả lưu vị trí đọc (dùng lại `ReadingPositionStore` có
  sẵn, không tạo cơ chế lưu trữ mới) và mở đúng Ayah trên trang đọc
  qua route top-level `/read/:id` — hàm dùng chung mới
  `openAyahInReadingScreen` (`reading_navigation.dart`), theo đúng
  cơ chế `LibraryScreen` đã dùng (không phải route lồng trong shell
  `/quran/surah/:id`, vốn gây xung đột Navigator khi push từ ngoài
  vỏ tab — phát hiện và sửa trong sprint này).
- Bộ chuyển trạng thái dành cho dev (biểu tượng bọ trên AppBar) để
  xem trước cả 4 trạng thái không cần gõ hay có dữ liệu thật — CHỈ
  tồn tại ở debug build (`kDebugMode`), xác nhận bằng build
  `--release` thật + kiểm tra bundle không còn dấu vết.
- ADR `DR-2026-0002` (9 quyết định kiến trúc cho Search, kèm đánh
  đổi/phương án đã loại/mở rộng tương lai) viết trước khi code.

### Đã kiểm tra toàn diện (không đổi giao diện hiện có)
- Accessibility: header semantics cho tiêu đề khu vực, vùng chạm
  ≥ 48dp, RTL (mirror layout + hướng chữ đúng theo nội dung), cỡ chữ
  200% không tràn, thứ tự đọc khớp thứ tự hiển thị.
- Dark mode: rà soát không còn màu hard-code trong tính năng Search;
  đo tương phản chữ tô đậm (WCAG) ở cả 2 theme — đều vượt ngưỡng.
- Responsive: 320–1300px (điện thoại hẹp đến desktop), không tràn
  layout kể cả khi kết hợp cỡ chữ 200%.

### Tests
- +87 test cho tính năng Search (widget + unit), gộp bộ helper/
  fixture dùng chung (`test/fixtures/search_test_harness.dart`) —
  tổng dự án 244 test, tất cả qua `dart format` /
  `flutter analyze --fatal-infos` / `flutter test`.

### Chưa làm (Sprint 7.2 trở đi — Bước 7 CHƯA hoàn tất)
- Search engine thật: chưa nối `QuranRepository.searchAyahs` (FTS5
  `search_index`) vào UI đã xây — kết quả hiện chỉ xem được qua bộ
  chuyển trạng thái dành cho dev với dữ liệu mẫu tĩnh.
- Recent Searches, Suggestions, Filters, Ask AI thật — khung UI đã có
  chỗ (2 khu vực placeholder trong Empty State, nút Mode "Hỏi AI" đã
  khoá) nhưng chưa nối dữ liệu/logic.
- Danh sách `source_code` hardcode trong
  `quran_repository_impl.searchAyahs` chưa sửa thành đọc động từ
  `translation_sources` (nợ kỹ thuật đã ghi nhận từ lúc review kiến
  trúc, xem TODO.md).

## [0.6.0] — Sprint 6: Chú thích người dùng + User Database

### Added
- UserDatabase (file riêng, Drift): bookmarks, highlights, notes,
  ayah_statuses — UUID client, soft delete, updated_at, is_dirty
  (Sync Ready), migration strategy + test schema.
- Bookmark 1 chạm (icon trên mỗi Ayah) — toggle hồi sinh cùng UUID.
- Highlight 6 màu, một Ayah nhiều màu, nền Ayah nhuộm màu đã chọn.
- Ghi chú Markdown cơ bản (**đậm**, *nghiêng* — parser thuần có
  test, cú pháp hỏng giữ nguyên văn), hiện dưới Ayah.
- Trạng thái học 4 mức: Chưa đọc / Đang học / Đã học / Cần ôn —
  chip hiển thị trên thẻ Ayah.
- Sheet thao tác Ayah (nhấn giữ): bookmark, 6 màu, trạng thái,
  ghi chú — realtime qua Stream repository.
- UserContentRepository interface (domain tách hoàn toàn khỏi Drift).

### Changed
- AyahCard: nền ưu tiên trạng thái đang phát audio > màu highlight.

### Tests
- +15 unit (repository UUID/soft-delete/watch/reactive + markdown)
  và +3 widget (bookmark 1 chạm, sheet nhấn giữ, ghi chú end-to-end)
  — tổng dự kiến ~100.

## [0.5.0] — Bước 5: Audio

### Added
- Trình phát Ayah: play/pause, Ayah trước/kế, tốc độ xoay vòng
  0.75–2.0x, lặp (1 Ayah / cả Surah / tắt), chọn Qari (5 Qari từ
  bảng reciters, lựa chọn lưu bền).
- AudioBar mini dính đáy trang đọc; nút "Nghe từ Ayah này" trên
  từng Ayah.
- Ayah đang phát: highlight nền nhẹ + màn hình TỰ CUỘN theo
  (ScrollablePositionedList, animate 350ms).
- Kiến trúc AyahAudioPlayer interface (just_audio impl + fake cho
  test — logic phát test được 100% không cần thiết bị).
- IoCacheManager: tải offline theo Qari, ghi file tạm chống hỏng,
  mất mạng giữ phần đã tải, xóa theo Qari / toàn bộ, đo dung lượng.
- docs/AUDIO.md (kiến trúc + cấu hình phát nền khi phát hành).
- 13 test mới (8 controller + 4 cache + 1 widget luồng đầy đủ)
  — tổng ~82 test.

## [0.4.5] — Trải nghiệm đọc nâng cao

### Added
- Focus Mode: ẩn AppBar + mọi bản dịch, thuần văn bản Qur'an với
  dấu kết Ayah ﴿n﴾; chạm một lần để thoát.
- Mushaf Mode: gom Ayah theo trang Mushaf Madani (cột page trong
  data), văn bản liền mạch căn justify, lật trang PHẢI-SANG-TRÁI
  như bản in, hiện số trang — hỗ trợ Hifz ghi nhớ vị trí.
- Gesture: pinch 2 ngón đổi cỡ chữ Ả Rập live (chỉ ghi đĩa khi
  nhấc tay); vuốt ngang đổi Surah (chế độ danh sách).
- Tự lưu vị trí đọc theo TỪNG Surah + Surah gần nhất
  (ScrollablePositionedList theo dõi Ayah đầu khung nhìn);
  mở lại app quay về đúng chỗ. Nền tảng cho auto-scroll theo
  audio ở Bước 5 và nút "Tiếp tục đọc" ở Bước 8.
- Chế độ đọc lưu bền qua các phiên.
- 15 test mới (unit mushaf/position/settings + widget focus/
  mushaf/khôi phục vị trí) — tổng ~69 test.

### Deferred (đúng thứ tự bước)
- Auto-scroll + highlight Ayah theo audio -> Bước 5.
- Double-tap bookmark, long-press highlight/note -> Bước 6.
- Reading statistics + Khatm -> Bước 6/8/9b.

## [0.4.0] — Bước 4: Trang đọc Qur'an

### Added
- ReadingScreen (/quran/surah/:id): chữ Ả Rập lớn RTL (line-height
  2.0, font Uthmani + fallback), 3 lớp văn bản bật/tắt
  (phiên âm / Việt / Anh), số Ayah, biểu tượng sajdah.
- Bottom sheet Hiển thị: slider cỡ chữ Ả Rập (22–45, áp dụng live,
  clamp an toàn), 3 công tắc lớp văn bản — mọi cài đặt lưu bền.
- Nội dung giới hạn 700px căn giữa trên màn rộng (typography đọc lâu).
- Danh sách Surah điều hướng thật vào trang đọc (bỏ SnackBar tạm).
- Deep link an toàn: id sai -> màn "Không tìm thấy" thay vì crash.
- Đủ loading / error (not-found riêng, lỗi khác có Thử lại) / empty.
- 12 test mới (4 unit cài đặt + 8 widget) — tổng ~54 test.

## [0.3.0] — Bước 3: Danh sách 114 Surah

### Added
- Màn hình danh sách Surah thật (thay placeholder): số thứ tự,
  tên Latin, tên Ả Rập (chuẩn bị font Uthmani, có fallback),
  số câu, nơi mặc khải.
- Tìm kiếm không phân biệt dấu (foldDiacritics — tiếng Việt +
  transliteration) theo tên Latin/Việt/Anh/Ả Rập/số Surah.
- Lọc Tất cả / Mecca / Madinah (SegmentedButton M3).
- Đủ 3 state: loading, error (kèm nút Thử lại hoạt động thật),
  empty khi tìm không thấy.
- Accessibility: Semantics đọc trọn thông tin mỗi Surah,
  widget test text scale 200% không vỡ layout.
- 9 chuỗi l10n mới × 3 ngôn ngữ; docs/FONTS.md.
- 16 test mới (9 unit lọc/bỏ dấu + 7 widget) — tổng ~42 test.

## [0.2.1] — Gia cố lớp dữ liệu theo tiêu chuẩn chất lượng

### Added
- ayahs: cột hizb, sajdah (tính từ Tanzil metadata) + 9 index phủ
  mọi trục truy vấn (surah, juz, hizb, page, sajdah, nguồn dịch,
  reciter).
- FTS: lớp bỏ dấu Latin (vi_main_plain, translit_latin_plain) —
  gõ không dấu vẫn tìm được.
- 5 Qari trong seed reciters (Alafasy, Abdul Basit, Minshawi,
  Husary, Sudais) — thêm Qari mới chỉ là thêm dòng dữ liệu.
- PERFORMANCE.md: phương pháp đo + bảng kết quả từng bước;
  CI tự in kích thước APK/Web bundle vào summary.
- ARCHITECTURE: thiết kế CacheManager (dung lượng/xóa/tải trước
  theo Qari), chuẩn Accessibility bắt buộc, thiết kế mã hóa
  client-side cho dữ liệu người dùng trước Cloud Sync.
- Test ánh xạ juz/hizb/page/sajdah.

## [0.2.0] — Bước 2: Lớp dữ liệu Qur'an

### Added
- Schema Drift nhóm A: surahs, ayahs, translation_sources (kèm
  metadata license/source_url/version/updated_at), translations,
  reciters, meta — tên bảng/cột khai báo tường minh.
- Kết nối database đa nền tảng: native (copy asset + isolate riêng),
  web (drift WASM + nạp asset), chọn lúc compile.
- Cơ chế cập nhật nội dung bằng data_version — thay file data
  không đụng dữ liệu người dùng.
- Domain layer: entities (Surah, Ayah, TranslationSource, AyahContent)
  + QuranRepository interface; data layer: QuranRepositoryImpl
  (join 1 truy vấn, tránh N+1).
- Pipeline tool/build_quran_db.py: Tanzil (Uthmani + translit +
  Sahih International) + QuranEnc (tiếng Việt, tự phát hiện key),
  kiểm tra toàn vẹn 6 lớp, FTS5 (kèm Arabic bỏ dấu), seed 2 Qari.
- CI: build + cache dữ liệu, chạy build_runner trước analyze/test.
- 11 test repository (in-memory database).

### Changed (thiết kế)
- Nhóm B chuyển sang khóa chính UUID sinh phía client — loại bỏ
  đụng độ id khi sync đa thiết bị (phát hiện qua review điểm 9).
- Thêm bảng `reciters` (audio nhiều Qari, URL theo mẫu) và
  FTS5 `search_index` (tìm kiếm toàn văn hiệu năng cao) vào nhóm A.
- Migration: nguyên tắc additive 2 phiên bản, tách file data
  Qur'an khỏi database người dùng.
- `srs_cards` tổng quát hóa (item_type: lemma|ayah) để dùng chung
  cho Từ vựng và Hifz — tránh migration về sau.
- Thêm bảng `khatm_cycles` (Khatm Tracker) và `hifz_plans` (Hifz)
  vào thiết kế nhóm B; triển khai ở Bước 9b/9c.

### Sắp tới (Bước 2)
- Database Drift + import dữ liệu Qur'an (114 Surah, 6.236 Ayah).

## [0.1.0] — Bước 1: Nền móng

### Added
- Khung project Flutter đa nền tảng (Android, iOS, Web, Desktop).
- Material Design 3, seed color #1B7A43, Light/Dark Mode
  (lưu và khôi phục lựa chọn).
- Điều hướng go_router + StatefulShellRoute 5 tab, giữ trạng thái
  từng tab; responsive 3 breakpoint (NavigationBar / Rail / Rail mở rộng).
- Localization ARB: Tiếng Việt (mặc định) · English · العربية (RTL);
  không còn chuỗi hard-code.
- Hệ thống môi trường Dev/Staging/Prod qua --dart-define-from-file;
  file env không commit.
- CI GitHub Actions: gitleaks secret scan, format check,
  analyze --fatal-infos, pub outdated, test, coverage gate ≥ 80%,
  build Android APK + Web + iOS no-codesign.
- Bộ lint nghiêm ngặt (analysis_options.yaml).
- 14 unit/widget test.
- Bộ tài liệu: README, ARCHITECTURE, DATABASE, CHANGELOG, TODO.
