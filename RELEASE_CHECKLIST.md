# Checklist phát hành App Store & Google Play

Cập nhật qua các đợt chuẩn bị phát hành Phase 2–4 (xem CHANGELOG.md/git
log cho chi tiết từng commit). Mục đã ✅ là đã XÁC MINH THẬT (chạy lệnh,
đọc log build/CI thật) — không phải suy đoán.

## Tài sản
- [x] Font UthmanicHafs đặt vào assets/fonts (đã có sẵn,
      assets/fonts/UthmanicHafs.ttf, docs/FONTS.md)
- [ ] App Icon 1024×1024 (adaptive Android + iOS set)
- [ ] Splash Screen (flutter_native_splash, khớp Light/Dark)
- [ ] Screenshot: iPhone 6.7"/5.5", iPad 12.9", Android phone/tablet

## Pháp lý & chính sách
- [x] Attribution Tanzil + QuranEnc + everyayah trong màn Giới thiệu
      (đã có: l10n `aboutSourcesDetail` trong Hồ sơ > Nguồn dữ liệu)
- [x] Privacy Policy (URL công khai) — **ĐÃ LÊN SÓNG.** PR Session 137
      đã merge vào `main`; `curl` thật thấy **HTTP 200** (Session 138,
      xác minh lại ở Session 139, 2026-08-27). Chính sách chính thức
      DUY NHẤT tại `privacy/index.md`, ngày hiệu lực **27/08/2026**.
      URL chuẩn tắc:
      <https://duso201189-nxp.github.io/quran-companion/privacy/>
      Bản nháp cũ `docs/release/PRIVACY_POLICY_DRAFT.md` đã được đánh
      dấu SUPERSEDED, không còn là chính sách hiệu lực.
- [x] Liên kết Chính sách quyền riêng tư TRONG app (Session 139) — Hồ
      sơ > Giới thiệu có một liên kết chạm được, mở đúng URL chuẩn tắc
      ở trên bằng `url_launcher` (cùng cơ chế liên kết Tanzil, không
      thêm package/abstraction mới). Nhãn dịch đủ vi/en/ar (khoá ARB
      `privacyPolicy`), lộ ra cây semantics như ĐÚNG MỘT node có cờ
      `isLink` + hành động tap (không đọc trùng). Bằng chứng:
      `test/profile_screen_privacy_policy_link_test.dart`.
- [ ] Rà soát pháp lý NỘI DUNG Chính sách quyền riêng tư — chưa có
      luật sư/chuyên gia nào rà soát. Hai ô đã tick ở trên chỉ nói
      chính sách đã công bố và đã có liên kết trong app; chúng KHÔNG
      phải kết luận về tính đầy đủ hay tuân thủ pháp lý.
- [ ] Terms of Use
- [ ] Apple Privacy Manifest (`ios/Runner/PrivacyInfo.xcprivacy`) —
      **ĐÃ SOẠN + ĐÃ NỐI VÀO pbxproj, CHƯA XÁC MINH BẰNG XCODE.**
      (Tách khỏi ô "App Privacy labels" ở Session 142, 2026-08-28: hai
      việc khác nhau, không được tick chung.) File có thật, khai
      `NSPrivacyTracking = false` và ba mảng `NSPrivacyTrackingDomains`
      / `NSPrivacyCollectedDataTypes` / `NSPrivacyAccessedAPITypes`
      đều RỖNG (Session 107); đã nối vào
      `ios/Runner.xcodeproj/project.pbxproj` tại 4 điểm — PBXBuildFile
      (dòng 10), PBXFileReference (dòng 63), nhóm Runner (dòng 124),
      và Resources build phase của target Runner (dòng 235) —
      Session 109. Ô này VẪN ĐỂ TRỐNG: dự án chưa từng build bằng
      Xcode/CocoaPods (không có `ios/Podfile.lock`, môi trường không
      có macOS), nên bước manifest-merge lúc archive của Xcode CHƯA
      HỀ CHẠY và phần `NSPrivacyAccessedAPITypes` chưa thể kết luận.
      Sự tồn tại của file KHÔNG phải căn cứ để tick. Chỉ tick sau khi
      `flutter build ios`/archive thật chạy sạch trên máy macOS.
- [ ] Apple App Privacy labels (bảng "nutrition label" trong App Store
      Connect) — **MỞ, CẦN THAO TÁC TRÊN CONSOLE.** Không có phần nào
      của việc này nằm trong repo: phải do người giữ tài khoản App
      Store Connect điền và nộp trực tiếp. Bản nháp câu trả lời (chưa
      nộp, chưa rà soát pháp lý) ở
      `docs/release/STORE_PRIVACY_FORM_DRAFT.md`. Việc Privacy
      Manifest đã tồn tại KHÔNG hoàn thành ô này.
- [ ] Google Play Data Safety form
- [ ] Xác nhận điều khoản phi-thương-mại của bản dịch Tanzil với mô
      hình phát hành (app miễn phí)

## Kỹ thuật — Đã xác minh (Phase 2)
- [x] CI xanh toàn bộ (format, analyze --fatal-infos, test, coverage
      gate, build Android/Web/iOS) — xem .github/workflows/ci.yml,
      chạy thật trên GitHub Actions
- [x] `flutter analyze --fatal-infos`: 0 lỗi
- [x] `flutter test`: 136/136 pass
- [x] Dead code & asset không dùng đã dọn (placeholder_body.dart,
      assets/database.zip 6.4MB, font Inter-Medium không dùng)
- [x] Copy asset database lần đầu đã atomic (file .tmp + rename,
      tránh corrupt nếu bị ngắt giữa chừng) — có test riêng
      (test/content_connection_test.dart)
- [x] `flutter build apk --release` build sạch, không lỗi — APK debug-
      signed (signingConfigs.getByName("debug"), CHƯA phải bản ký thật
      cho Play Store — xem mục "Ký thật" bên dưới) — ĐÃ THAY THẾ ở
      Phase 4, xem mục Phase 4 bên dưới
- [x] `flutter build appbundle --release` build sạch — AAB debug-signed
      (cùng lưu ý như trên) — ĐÃ THAY THẾ ở Phase 4
- [x] Kiến trúc khởi động đã xác minh đúng thiết kế lazy-I/O
      (ARCHITECTURE.md §12): không I/O nặng trước frame đầu, cả 2
      database mở lazy, provider async trên Trang chủ không chặn frame
      đầu — xác minh bằng đọc code trực tiếp, không chỉ tin tài liệu

## Kỹ thuật — Đã xác minh (Phase 3, kiểm thử thật trên emulator)
- [x] Chạy toàn bộ tính năng chính bằng tay trên Android emulator thật
      (adb, không phải chỉ widget test): cả 5 tab (Trang chủ, Đọc,
      Bookmark, Thống kê, Hồ sơ), 3 chế độ đọc, phát âm thanh, ghi
      chú/bookmark/yêu thích, đổi giao diện sáng/tối + ngôn ngữ
- [x] Phát hiện + sửa 2 lỗi UI thật (RenderFlex overflow) mà
      `flutter analyze`/test/code review trước đó KHÔNG bắt được:
      1) header thẻ Ayah tràn ngang khi đủ 6 nút hành động + badge +
      trạng thái + icon sujud — sửa bằng `Wrap` 2 hàng thay `Row`+
      `Spacer` (lib/features/quran/presentation/reading/reading_screen.dart)
      2) biểu đồ tuần Thống kê tràn dọc 2px — sửa bằng tăng chiều cao
      SizedBox 120→132 (lib/features/stats/presentation/stats_screen.dart)
- [x] Regression cuối: `flutter analyze` 0 lỗi, `flutter test` 136/136
      pass, `integration_test/app_e2e_test.dart` pass trên emulator thật
      (không phải mock) sau khi sửa cả 2 lỗi trên
- [x] Cài đặt APK **release** (R8-minified) thật lên emulator, mở lại
      từ đầu, chụp màn hình Trang chủ + màn Đọc để xác nhận bản build
      minified chạy đúng — không chỉ "build thành công" mà còn "chạy
      đúng" dưới điều kiện release thật
- [x] CI xanh trên commit cuối cùng đã build release (xác minh qua
      GitHub Actions API, không suy đoán)
- [x] TalkBack trên Android emulator: ĐÃ audit + xác minh thật (Session
      119, PR #39 — 3 lỗi accessibility đã sửa, xác nhận bằng
      uiautomator dump trên Pixel 8 API 37 emulator; Session 122, PR
      #40 — sửa lỗi SurahTile không kích hoạt được bằng TalkBack). Xem
      chi tiết đầy đủ ở mục "Accessibility audit" bên dưới.
- [ ] TalkBack trên thiết bị Android vật lý thật — CHƯA kiểm thử, vẫn
      còn treo (chỉ mới xác minh trên emulator, xem mục trên).
- [ ] VoiceOver trên iOS — CHƯA kiểm thử, vẫn còn treo (không có môi
      trường build macOS/Xcode).

## Kỹ thuật — Đã xác minh (Phase 4, ký thật + tối ưu release)
- [x] **Keystore upload thật đã tạo**: `keytool -genkeypair` (RSA 2048,
      PKCS12, hiệu lực 10000 ngày → hết hạn 2053-11-22), alias `upload`.
      File tại `android/app/upload-keystore.jks` — nằm trong
      `android/.gitignore` (`**/*.jks`), KHÔNG bao giờ vào Git. Xem
      mục "Bảo mật keystore" ngay dưới đây để biết cách sao lưu.
- [x] `android/key.properties` (storePassword/keyPassword ngẫu nhiên
      32 ký tự, keyAlias, storeFile) — cũng nằm trong
      `android/.gitignore` (`key.properties`), KHÔNG vào Git.
      `git check-ignore -v` xác nhận cả 2 file đều bị bỏ qua.
- [x] `android/app/build.gradle.kts`: đọc `key.properties` lúc build,
      cấu hình `signingConfigs.create("release")` dùng keystore thật;
      nếu máy build (vd. CI) không có `key.properties`, tự rơi về ký
      debug để không chặn `flutter build`/CI — không bắt buộc bí mật
      phải có mặt ở mọi máy.
- [x] Tối ưu bản release: `isMinifyEnabled = true` +
      `isShrinkResources = true` bật lần đầu (trước đó TẮT hoàn toàn ở
      Phase 2!) + `proguard-android-optimize.txt` +
      `android/app/proguard-rules.pro` mới. Xác nhận R8 chạy thật qua
      `build/app/outputs/mapping/release/mapping.txt` (17.8MB, hàng
      nghìn class bị đổi tên/rút gọn) — không chỉ tin cờ bật, mà đọc
      output thật.
      Lưu ý trung thực: dung lượng file APK/AAB gần như không đổi so
      với Phase 2 (68.5MB / 67.8MB) vì phần lớn dung lượng đến từ Dart
      AOT native code + asset (font, database nội dung) — R8 chỉ rút
      gọn lớp embedding Java/Kotlin mỏng, vốn đã nhỏ. Tối ưu thật sự
      cho người dùng cuối đến từ định dạng AAB: Play Console tự tách
      theo ABI/mật độ màn hình/ngôn ngôn ngữ khi cài trên máy thật,
      dung lượng tải về sẽ nhỏ hơn đáng kể so với 67.8MB của file .aab
      gốc (chứa đủ mọi ABI).
- [x] Đã xác minh chữ ký thật bằng công cụ độc lập (không chỉ tin
      Gradle): `apksigner verify --print-certs` trên APK và
      `jarsigner -verify -verbose:summary -certs` trên AAB — cả 2 đều
      trả về đúng DN đã khai báo (CN=Du So, OU=Personal, O=Qur'an
      Companion, L=Ho Chi Minh City, ST=Ho Chi Minh, C=VN) và "jar
      verified", KHÔNG phải chứng chỉ debug mặc định của Android SDK.
- [x] Cài APK release ký thật lên emulator thật (gỡ bản cũ trước vì
      đổi chứng chỉ ký → Android từ chối update tại chỗ, đúng như dự
      kiến), mở lại, xác nhận Trang chủ + màn Đọc hiển thị đúng —
      không chỉ build thành công mà còn chạy đúng dưới chữ ký thật.
- [ ] **Google Play App Signing**: quyết định của người dùng ở Phase 4
      là dùng keystore này làm **upload key**, KHÔNG phải khóa ký phân
      phối cuối cùng. Bước còn lại (chỉ làm được trong Play Console,
      không phải trên máy): khi tạo app mới trong Play Console và tải
      lên `app-release.aab` lần đầu, xác nhận mục "Play App Signing"
      đang bật (mặc định cho app mới) — Google sẽ giữ khóa ký phân phối
      thật và tự ký lại AAB bạn tải lên bằng key upload này. Lợi ích:
      nếu sau này mất `upload-keystore.jks`, có thể yêu cầu Google reset
      upload key qua quy trình xác minh danh tính chủ tài khoản, KHÔNG
      mất khả năng cập nhật app vĩnh viễn như khi tự quản lý toàn bộ.

### ⚠️ Bảo mật keystore — hành động NGAY, không thể để sau
- File `android/app/upload-keystore.jks` và `android/key.properties`
  CHỈ tồn tại cục bộ trên máy này. KHÔNG có ở đâu khác — không trong
  Git, không trong CI, không có bản sao nào khác được tạo ra trong
  phiên làm việc này.
- **Nếu mất file này VÀ chưa từng tải AAB lên Play Console**: phải tạo
  lại keystore mới từ đầu, không có cách khôi phục (chứng chỉ tự ký,
  không ai giữ bản sao).
- **Nếu đã tải lên Play Console rồi** (và đã bật Play App Signing như
  trên): vẫn có đường khôi phục qua Google, nhưng vẫn nên tránh mất.
- Việc cần làm ngay: mở 2 file `android/app/upload-keystore.jks` và
  `android/key.properties` trên máy này, sao chép nội dung
  storePassword/keyPassword vào một trình quản lý mật khẩu, và sao lưu
  bản thân file `.jks` vào nơi lưu trữ an toàn ngoài máy này (ví dụ ổ
  cứng ngoài mã hoá, cloud storage riêng tư có mã hoá) — KHÔNG gửi qua
  email/chat không mã hoá.

## Kỹ thuật — Còn thiếu / đã biết, chưa xử lý
- [ ] Android applicationId `com.duso.qurancompanion` — xác nhận đã
      đăng ký đúng trên Play Console khớp package này
- [ ] iOS: Apple Developer Program, certificate + profile, TestFlight
- [ ] Google Play Console, internal testing track
- [x] Phát nền audio: audio_service + AndroidManifest + Info.plist
      (docs/AUDIO.md) — **đã triển khai (Phase 4 Sprint B1–B3,
      RELEASE_DASHBOARD.md §2)**: `AudioService.init()` đã nối, manifest
      Android + `Info.plist` đã khai báo, 14/16 kịch bản Android emulator
      pass trực tiếp. **iOS chưa xác minh — 0%** (không có môi trường
      build macOS). Sửa lại trong đợt rà soát tài liệu Session 83 — mục
      này trước đó ghi "chưa triển khai", vốn nhầm lẫn giữa "chưa build"
      và "chưa xác minh trên iOS".
- [ ] UI quản lý cache audio trong Cài đặt (engine đã có:
      IoCacheManager, nhưng chưa nối vào AudioController/UI — xem
      TODO.md)
- [x] Web: sqlite3.wasm + drift_worker.js vào web/ (docs/DATA_PIPELINE.md)
      — **đã có (Phase 3 Sprint R3a.1–R3a.3, 2026-08-03)**: cả 2 file đã
      được vendor vào `web/`, khớp phiên bản `pubspec.lock`
      (`sqlite3-3.3.4`, `drift-2.34.0`), có SHA-256 trong
      `docs/DATA_PIPELINE.md`, và đã xác minh chạy thật trên trình
      duyệt (RELEASE_DASHBOARD.md §2/§3). Một CI guard chặn `build-web`
      nếu 2 file này bị xoá. Sửa lại trong đợt rà soát tài liệu
      Session 83 — mục này trước đó ghi "CHƯA có trong web/", đã lỗi thời.
- [x] TalkBack trên Android emulator thật: ĐÃ audit xong (Session 119 —
      PR #39 sửa 3 lỗi: tooltip thiếu ở nút "xoá tìm kiếm" trong
      FlashcardBrowseScreen/AddFlashcardScreen, 3 _StatChip trên Trang
      chủ bị gộp sai thành 1 node TalkBack; Session 122 — PR #40 sửa
      SurahTile thiếu `onTap` nên TalkBack focus được nhưng double-tap
      không kích hoạt được hàng Surah nào). Xác minh bằng uiautomator
      dump thật trên Pixel 8 (API 37) emulator, không chỉ code review
      tĩnh. Widget semantics test pass trong CI
      (`test/surah_list_screen_test.dart`).
- [ ] TalkBack trên thiết bị Android vật lý thật — CHƯA kiểm thử, vẫn
      còn treo (chỉ mới xác minh trên emulator, xem mục trên).
- [ ] VoiceOver trên iOS (thiết bị thật hoặc simulator) — CHƯA kiểm
      thử, vẫn còn treo (không có môi trường build macOS/Xcode ở các
      phiên làm việc đến nay).
- [ ] Contrast, font scale 200% trên thiết bị thật — CHƯA đo/audit
      (code có nền tảng theo ARCHITECTURE.md §14, nhưng chưa xác minh
      trên thiết bị thật).
- [ ] PERFORMANCE.md: cột "Android tầm trung" vẫn "chưa đo" — cột
      "Máy dev" đã điền số thật (161.6 ms, đo trên Windows desktop
      bằng `flutter run --profile --trace-startup`, KHÔNG thay thế
      cho số đo Android thật). getAyahsOfSurah/FTS MATCH vẫn chưa đo
      trên cả 2 môi trường
- [x] Coverage gate CI — **đã nâng lên 80% (Sprint R3.2, `DR-2026-0015`)**,
      không còn 70% như mục này trước đó ghi. Coverage đo được 81.54%
      tại thời điểm Sprint R3.2; lần chạy CI xanh gần nhất trên `main`
      (commit `efd73e6`, 2026-08-22) đo được **84.1%** trên **1.317**
      test pass, vẫn trên ngưỡng 80%. Sửa lại trong đợt rà soát tài liệu
      Session 83 — số "70%"/"~74%" đã lỗi thời từ lâu.
- [ ] 16 package outdated (bao gồm 2 major version: flutter_riverpod
      2→3, go_router 14→17) + `sqlite3_flutter_libs` có bản mới đánh
      dấu `+eol` — CHƯA nâng cấp, cần một đợt test riêng trước khi bump
      (xem README.md mục "Quy trình cập nhật dependency")
- [ ] Cảnh báo `javac`: "source/target value 8 is obsolete" xuất hiện
      khi build release sạch (flutter clean + build apk --release),
      đến từ compileOptions Java 8 của một plugin thư viện (không phải
      :app — :app đã dùng Java 17). Đã thử ép Java 17 lên toàn bộ
      module thư viện qua root build.gradle.kts nhưng KHÔNG loại bỏ
      được cảnh báo (có thể đến từ một compile task khác ngoài
      compileOptions DSL chuẩn); không chặn build, APK/AAB vẫn ra đúng
      — cần điều tra sâu hơn ở mức Gradle task nếu muốn loại bỏ hẳn

## Metadata
- [ ] Tên, mô tả ngắn/dài (vi + en), từ khóa ASO
- [ ] Danh mục Education/Reference, content rating
