# Qur'an Companion

Ứng dụng học Kinh Qur'an chuyên nghiệp — người thầy đồng hành.
Nền tảng: **Android · iOS · iPad · Web · Desktop (tương lai)**.

![CI](https://github.com/<tài-khoản>/quran_companion/actions/workflows/ci.yml/badge.svg)

## Tài liệu

| File | Nội dung |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Kiến trúc hệ thống, quyết định kỹ thuật |
| [DATABASE.md](DATABASE.md) | Sơ đồ cơ sở dữ liệu đầy đủ |
| [CHANGELOG.md](CHANGELOG.md) | Lịch sử thay đổi theo phiên bản |
| [TODO.md](TODO.md) | Lộ trình 12 bước + checklist phát hành |

## Cài đặt lần đầu

Yêu cầu: Flutter **3.44.4** (khớp với CI — xem `FLUTTER_VERSION` trong
`.github/workflows/ci.yml`).

```bash
# 1. Tạo vỏ project đủ nền tảng (chỉ làm 1 lần)
flutter create quran_companion \
  --platforms=android,ios,web,windows,macos,linux --org=com.jusoo

# 2. Chép đè lib/, test/, pubspec.yaml, analysis_options.yaml,
#    l10n.yaml, env/, .github/, *.md từ gói này vào project

# 3. Tải dependencies (tự sinh code l10n)
flutter pub get
```

## Chạy ứng dụng

```bash
# Development (mặc định)
flutter run -d chrome --dart-define-from-file=env/dev.json

# Tạo env/dev.json từ file mẫu trước:
cp env/dev.example.json env/dev.json
```

File `env/*.json` chứa cấu hình môi trường và **không được commit**
(đã chặn trong `env/.gitignore`). Chi tiết: ARCHITECTURE.md mục Bảo mật.

## Kiểm tra chất lượng (chạy trước mỗi commit)

```bash
dart format lib test        # format code
flutter analyze             # phải 0 cảnh báo
flutter test --coverage     # phải 100% pass
```

## CI/CD

Mỗi push/PR tự chạy: secret scan (gitleaks) → format → analyze
→ `pub outdated` (thông tin) → test → **coverage gate ≥ 70%**
(mục tiêu 80% khi phát hành v1.0 — xem ARCHITECTURE.md mục 9)
→ build song song Android APK + Web + iOS (no-codesign).

- Nhánh `main` được bảo vệ: chỉ merge khi CI xanh toàn bộ.
- APK/Web build đính kèm mỗi lần chạy (tab Actions → Artifacts).
- **Chi phí:** runner macOS (job iOS) tính phút ×10 trên repo private.
  Nếu vượt hạn mức miễn phí, sửa job `build-ios` thêm điều kiện
  `if: github.ref == 'refs/heads/main'`.

## Quy trình cập nhật dependency (hằng tháng)

1. Xem log bước "Kiểm tra package lỗi thời" trong CI.
2. `flutter pub upgrade --major-versions` trên nhánh riêng.
3. Chạy đủ test, đọc CHANGELOG của package trước khi merge.
4. Package ngừng bảo trì → tìm thay thế ngay, ghi vào TODO.md.

## Ngôn ngữ

Ứng dụng hỗ trợ Tiếng Việt (mặc định) · English · العربية (RTL).
Mọi chuỗi hiển thị nằm trong `lib/l10n/app_*.arb` — cấm hard-code
chuỗi trong widget. Thêm chuỗi mới: thêm key vào **cả 3 file** ARB,
chạy `flutter gen-l10n` (hoặc `flutter pub get`).
