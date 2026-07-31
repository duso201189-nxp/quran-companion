# Qur'an Companion

Ứng dụng học Kinh Qur'an chuyên nghiệp — người thầy đồng hành.
Nền tảng: **Android · iOS · iPad · Web · Desktop (tương lai)**.

![CI](https://github.com/<tài-khoản>/quran_companion/actions/workflows/ci.yml/badge.svg)

## Kiến trúc tổng quan

Flutter, tổ chức theo tính năng (`lib/features/<tên>/`), mỗi tính năng
tự chia 3 lớp `domain/` (entity + interface repository, thuần Dart,
không import Flutter/Riverpod/Drift) → `data/` (implementation +
provider Riverpod) → `presentation/` (màn hình, widget, controller).
Hai database SQLite (Drift) tách biệt hoàn toàn: `AppDatabase` (nội
dung Qur'an tĩnh, chỉ đọc, đóng gói sẵn) và `UserDatabase` (dữ liệu
người dùng, chuẩn bị sẵn cho đồng bộ đám mây sau này). Riverpod vừa
quản lý state vừa làm dependency injection — mỗi repository có đúng 1
provider dựng nó từ các dependency của nó.

Chi tiết đầy đủ, đã xác minh trực tiếp từ code hiện tại (không suy
đoán): xem **[docs/architecture/MASTER_ARCHITECTURE.md](docs/architecture/MASTER_ARCHITECTURE.md)**.

## Tài liệu

**Điểm vào chính: [PROJECT_INDEX.md](PROJECT_INDEX.md)** — bản đồ đầy
đủ mọi tài liệu trong repo này, thứ tự đọc khuyến nghị, và tài liệu nào
là "nguồn sự thật" cho từng chủ đề (một số tài liệu cũ đã lỗi thời so
với code hiện tại — `PROJECT_INDEX.md` nói rõ cái nào còn đúng, cái nào
chỉ còn giá trị lịch sử).

| File | Nội dung |
|---|---|
| [PROJECT_INDEX.md](PROJECT_INDEX.md) | **Bắt đầu từ đây** — bản đồ toàn bộ tài liệu |
| [docs/architecture/](docs/architecture/) | Kiến trúc hiện tại: tổng quan, danh mục tính năng, schema database, provider map, luồng dữ liệu, quyết định kiến trúc |
| [docs/testing/TESTING_GUIDE.md](docs/testing/TESTING_GUIDE.md) | Chiến lược kiểm thử, quy ước, ví dụ thật |
| [docs/release/](docs/release/) | Kế hoạch v1.0, nợ kỹ thuật đang mở, lộ trình sản phẩm |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Chuẩn code, quy ước commit, checklist PR |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Tài liệu kiến trúc gốc (lịch sử — xem `docs/architecture/` cho trạng thái hiện tại) |
| [DATABASE.md](DATABASE.md) | Sơ đồ cơ sở dữ liệu gốc + lý do thiết kế (lịch sử — xem `docs/architecture/DATABASE_REFERENCE.md` cho schema hiện tại) |
| [CHANGELOG.md](CHANGELOG.md) | Lịch sử thay đổi theo phiên bản |
| [ROADMAP.md](ROADMAP.md) | Lộ trình 12 bước gốc (lịch sử — xem `docs/release/PRODUCT_ROADMAP.md` cho lộ trình hiện tại) |
| [TODO.md](TODO.md) | Việc treo tới Sprint 10 (lịch sử — xem `docs/release/RELEASE_PLAN_V1.md` cho việc còn mở hiện tại) |

## Onboarding cho lập trình viên mới

1. Đọc [PROJECT_INDEX.md](PROJECT_INDEX.md) rồi
   [docs/architecture/MASTER_ARCHITECTURE.md](docs/architecture/MASTER_ARCHITECTURE.md).
2. Làm theo "Cài đặt lần đầu" và "Chạy ứng dụng" bên dưới.
3. Đọc [docs/architecture/MODULE_CATALOG.md](docs/architecture/MODULE_CATALOG.md)
   để biết tính năng mình sắp đụng vào phụ thuộc gì, ai phụ thuộc nó.
4. Đọc [CONTRIBUTING.md](CONTRIBUTING.md) trước khi mở PR đầu tiên.
5. Chạy được `flutter test` xanh toàn bộ trước khi sửa bất cứ gì — xem
   mục "Kiểm tra chất lượng" bên dưới.

## Cấu trúc thư mục

```
lib/
├─ main.dart              # điểm khởi động — chỉ 2 provider cần override thủ công
├─ app/                   # MaterialApp.router, go_router, theme, locale
├─ core/                  # hạ tầng dùng chung — không chứa logic nghiệp vụ
│  ├─ database/           # AppDatabase (nhóm A) + database/user/ (UserDatabase, nhóm B)
│  ├─ error/, logging/    # AppFailure/Logger/CrashReporter — xem docs/architecture/ARCHITECTURE_DECISIONS.md mục 8
│  ├─ storage/, audio/, cache/, env/
├─ features/<tên>/        # 18 tính năng, mỗi cái tự có presentation/domain/data
├─ shared/widgets/, shared/utils/  # widget/helper dùng chung nhiều tính năng
└─ l10n/                  # app_vi.arb (mặc định) / app_en.arb / app_ar.arb (RTL)
test/                     # ~104 file test — xem docs/testing/TESTING_GUIDE.md
docs/                     # tài liệu hiện tại + lịch sử — xem PROJECT_INDEX.md
```

Chi tiết đầy đủ từng tính năng: [docs/architecture/MODULE_CATALOG.md](docs/architecture/MODULE_CATALOG.md).

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
