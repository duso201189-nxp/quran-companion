# Checklist phát hành App Store & Google Play

Cập nhật sau đợt chuẩn bị phát hành (Phase 2 — xem CHANGELOG.md/git log
cho chi tiết từng commit). Mục đã ✅ là đã XÁC MINH THẬT (chạy lệnh,
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
- [ ] Privacy Policy (URL công khai)
- [ ] Terms of Use
- [ ] Apple Privacy Manifest (PrivacyInfo.xcprivacy) + App Privacy labels
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
      cho Play Store — xem mục "Ký thật" bên dưới)
- [x] `flutter build appbundle --release` build sạch — AAB debug-signed
      (cùng lưu ý như trên)
- [x] Kiến trúc khởi động đã xác minh đúng thiết kế lazy-I/O
      (ARCHITECTURE.md §12): không I/O nặng trước frame đầu, cả 2
      database mở lazy, provider async trên Trang chủ không chặn frame
      đầu — xác minh bằng đọc code trực tiếp, không chỉ tin tài liệu

## Kỹ thuật — Còn thiếu / đã biết, chưa xử lý
- [ ] **Ký thật cho phát hành**: hiện release build dùng
      signingConfigs debug (quyết định của người dùng ở Phase 2, chỉ
      để xác minh pipeline build). CẦN tạo keystore thật + lưu an toàn
      (GitHub Secrets hoặc tương đương) trước khi nộp Play Store/App
      Store — xem android/app/build.gradle.kts
- [ ] Android applicationId `com.duso.qurancompanion` — xác nhận đã
      đăng ký đúng trên Play Console khớp package này
- [ ] iOS: Apple Developer Program, certificate + profile, TestFlight
- [ ] Google Play Console, internal testing track
- [ ] Phát nền audio: audio_service + AndroidManifest + Info.plist
      (docs/AUDIO.md) — chưa triển khai, AudioController hiện chỉ
      chạy foreground
- [ ] UI quản lý cache audio trong Cài đặt (engine đã có:
      IoCacheManager, nhưng chưa nối vào AudioController/UI — xem
      TODO.md)
- [ ] Web: sqlite3.wasm + drift_worker.js vào web/ (docs/DATA_PIPELINE.md)
      — xác nhận lại lần này: 2 file này CHƯA có trong web/, build Web
      hiện tại sẽ lỗi khi mở database trên trình duyệt thật
- [ ] Accessibility audit thật trên thiết bị: TalkBack/VoiceOver,
      contrast, font scale 200% (code đã có nền tảng theo
      ARCHITECTURE.md §14, nhưng chưa audit trên thiết bị/screen reader
      thật)
- [ ] PERFORMANCE.md: cột "Android tầm trung" vẫn "chưa đo" — cột
      "Máy dev" đã điền số thật (161.6 ms, đo trên Windows desktop
      bằng `flutter run --profile --trace-startup`, KHÔNG thay thế
      cho số đo Android thật). getAyahsOfSurah/FTS MATCH vẫn chưa đo
      trên cả 2 môi trường
- [ ] Coverage gate CI hiện tạm 70% (không phải 80% như tài liệu gốc)
      — coverage thật ~74% ở Bước 6/12; xem TODO.md + ARCHITECTURE.md
      mục 9 để biết kế hoạch nâng dần về 80% khi Bước 7-9 landing
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
