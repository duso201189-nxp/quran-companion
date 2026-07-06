# Checklist phát hành App Store & Google Play

## Tài sản
- [ ] App Icon 1024×1024 (adaptive Android + iOS set)
- [ ] Splash Screen (flutter_native_splash, khớp Light/Dark)
- [ ] Screenshot: iPhone 6.7"/5.5", iPad 12.9", Android phone/tablet
- [ ] Font UthmanicHafs đặt vào assets/fonts (docs/FONTS.md)

## Pháp lý & chính sách
- [ ] Privacy Policy (URL công khai)
- [ ] Terms of Use
- [ ] Apple Privacy Manifest (PrivacyInfo.xcprivacy) + App Privacy labels
- [ ] Google Play Data Safety form
- [ ] Attribution Tanzil + QuranEnc + everyayah trong màn Giới thiệu
- [ ] Xác nhận điều khoản phi-thương-mại của bản dịch Tanzil với mô
      hình phát hành (app miễn phí)

## Kỹ thuật
- [ ] Android: keystore release (GitHub Secrets), .aab, targetSdk mới nhất
- [ ] iOS: Apple Developer Program, certificate + profile, TestFlight
- [ ] Google Play Console, internal testing track
- [ ] Phát nền audio: audio_service + AndroidManifest + Info.plist
      (docs/AUDIO.md)
- [ ] UI quản lý cache audio trong Cài đặt (engine đã có:
      IoCacheManager)
- [ ] Web: sqlite3.wasm + drift_worker.js vào web/ (docs/DATA_PIPELINE.md)
- [ ] Accessibility audit: TalkBack/VoiceOver, contrast, font scale 200%
- [ ] PERFORMANCE.md điền số đo thật trên thiết bị tầm trung
      (startup < 2s, query < 50ms)

## Metadata
- [ ] Tên, mô tả ngắn/dài (vi + en), từ khóa ASO
- [ ] Danh mục Education/Reference, content rating
