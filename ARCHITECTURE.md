# Kiến trúc hệ thống — Qur'an Companion

Tài liệu này đủ để một lập trình viên Flutter khác tiếp tục
phát triển dự án mà không cần hỏi lại.

## 1. Tổng quan

```
┌─────────────────────────────────────────┐
│ PRESENTATION  (Flutter + Riverpod)      │
│ Screens · Widgets · Controllers         │
├─────────────────────────────────────────┤
│ DOMAIN                                  │
│ Entities · UseCases · Repository (abst) │
├─────────────────────────────────────────┤
│ DATA                                    │
│ ├─ Local : Drift (SQLite) ← NGUỒN SỰ    │
│ │          THẬT DUY NHẤT CỦA UI         │
│ ├─ Remote: Supabase client              │
│ └─ SyncEngine (queue + last-write-wins) │
└─────────────────────────────────────────┘
```

Quy tắc phụ thuộc: Presentation → Domain ← Data.
Domain KHÔNG import Flutter, KHÔNG import Drift/Supabase.

## 2. Offline First (yêu cầu bất biến)

- UI chỉ đọc/ghi Drift local. Không màn hình nào chờ mạng.
- Mạng chỉ dùng cho: đồng bộ nền, tải audio. Cả hai fail im lặng
  và thử lại — mất Internet KHÔNG BAO GIỜ gây crash.
- Dữ liệu Qur'an tĩnh đóng gói sẵn trong assets/database/quran.sqlite.

## 3. Hai loại dữ liệu

| | Dữ liệu tĩnh (Qur'an) | Dữ liệu người dùng |
|---|---|---|
| Nội dung | Surah, Ayah, dịch, từ vựng | tiến độ, cờ, note, SRS |
| Nơi lưu | SQLite đóng gói, chỉ đọc | Drift local ↔ Supabase |
| Thay đổi | không bao giờ | liên tục |
| Cập nhật | phát hành phiên bản app mới | sync 2 chiều |

## 4. State management — Riverpod

- Controller = `Notifier` / `AsyncNotifier`, đặt cạnh screen
  trong `presentation/`.
- Provider hạ tầng dùng chung đặt trong `lib/core/` 
  (ví dụ `sharedPreferencesProvider`).
- Provider hạ tầng override trong `main.dart`; test override
  bằng mock — xem `test/app_test.dart` làm mẫu.

## 5. Điều hướng — go_router

- Route khai báo tập trung tại `lib/app/router.dart`
  (hằng số trong `AppRoutes`).
- `StatefulShellRoute.indexedStack`: 5 tab giữ trạng thái riêng.
- Web deep-link hoạt động sẵn nhờ path-based routing.

## 6. Responsive

`AppScaffold` (lib/shared/widgets/) quyết định theo bề rộng:
- < 800px: NavigationBar đáy (điện thoại)
- 800–1099px: NavigationRail thu gọn (tablet dọc)
- ≥ 1100px: NavigationRail mở rộng (tablet ngang / web / desktop)

## 7. Localization

- 3 ngôn ngữ: vi (mặc định) · en · ar (RTL tự động).
- File: `lib/l10n/app_{vi,en,ar}.arb`; template là app_vi.arb.
- CẤM hard-code chuỗi hiển thị trong widget.
- `LocaleController` lưu lựa chọn vào SharedPreferences.

## 8. Môi trường & Bảo mật

- 3 môi trường: dev / staging / prod, truyền qua
  `--dart-define-from-file=env/<env>.json`.
- `env/*.json` KHÔNG commit (env/.gitignore); chỉ commit *.example.json.
- Trên CI: nội dung env đặt trong GitHub Secrets, ghi ra file lúc build.
- gitleaks quét toàn bộ lịch sử git mỗi lần push.
- Key runtime (Supabase anon key...) đọc từ `AppEnv`
  (lib/core/env/app_env.dart) — không hard-code.
- Khi có Supabase (Bước 10-11): mọi bảng người dùng bật
  Row Level Security `user_id = auth.uid()`.
- API key AI của người dùng (v2.0): lưu flutter_secure_storage,
  không bao giờ đồng bộ lên server.

## 9. Chất lượng

- Lint: analysis_options.yaml, strict-casts/inference/raw-types,
  CI chạy `flutter analyze --fatal-infos`.
- Coverage tối thiểu 80% khi phát hành v1.0 (loại trừ main.dart và
  *.g.dart). CI gate hiện tạm ở 70% — coverage thật ~74% ở Bước 6/12;
  nâng ngưỡng dần khi Bước 7-9 có thêm test (xem TODO.md, MIN_COVERAGE
  trong ci.yml).
- Format: `dart format` bắt buộc (CI kiểm tra).
- Mỗi tính năng mới PHẢI kèm test trong cùng PR.

## 10. Quyết định kỹ thuật (ADR rút gọn)

| Quyết định | Lý do | Cân nhắc khác |
|---|---|---|
| Drift (SQLite) | type-safe, migration, chạy Web qua WASM | Isar: không hỗ trợ Web tốt, ít bảo trì |
| Riverpod | test dễ, không phụ thuộc BuildContext | Bloc: nhiều boilerplate hơn cho app này |
| go_router | chuẩn Flutter team, deep-link Web | Navigator 2 thô: quá phức tạp |
| Supabase | Postgres + Auth + RLS, mã nguồn mở | Firebase: khóa vào Google, NoSQL khó quan hệ |
| SM-2 cho SRS | đơn giản, đã kiểm chứng (Anki) | FSRS: tốt hơn nhưng phức tạp, để v2+ |
| AiProvider abstract | đổi OpenAI/Claude/Gemini/Ollama không sửa app | — |

## 11. Cấu trúc thư mục

```
lib/
├─ main.dart              # bootstrap, override providers
├─ app/                   # lắp ráp app-level
│  ├─ app.dart            # MaterialApp.router
│  ├─ router.dart         # go_router + AppRoutes
│  ├─ theme/              # Material 3 + ThemeController
│  └─ locale/             # LocaleController
├─ core/                  # hạ tầng dùng chung, KHÔNG chứa nghiệp vụ
│  ├─ storage/            # SharedPreferences provider
│  ├─ env/                # AppEnv (dev/staging/prod)
│  ├─ database/           # (Bước 2) Drift
│  ├─ sync/               # (Bước 11) SyncEngine
│  ├─ audio/              # (Bước 5) audio service
│  └─ ai/                 # (Bước 12) AiProvider + impls
├─ features/<tên>/        # mỗi tính năng 1 module độc lập
│  ├─ data/               # repository impl, DTO, mapper
│  ├─ domain/             # entity, use case, repo abstract
│  └─ presentation/       # screen, widget, controller
├─ shared/widgets/        # widget dùng chung nhiều feature
└─ l10n/                  # app_vi.arb · app_en.arb · app_ar.arb
```

## 12. Hiệu năng (mục tiêu mở app < 2s)

- Không I/O nặng trước frame đầu (chỉ SharedPreferences ~ms).
- Database Drift mở lazy khi màn hình đầu cần dữ liệu.
- Đo mỗi bước: `flutter run --profile --trace-startup`;
  kết quả ghi vào CHANGELOG của bước tương ứng.

## 12b. User Database (nhóm B) — v0.6.0

- File `user_data.sqlite` RIÊNG BIỆT với nội dung Qur'an; class
  `UserDatabase` (lib/core/database/user/).
- Mixin `SyncColumns` áp cho mọi bảng: id UUID client, user_id
  nullable (gán khi đăng nhập), updated_at epoch ms, deleted_at
  (soft delete), is_dirty (chưa đẩy cloud). SyncEngine Bước 11 chỉ
  cần quét is_dirty = true.
- Toggle/upsert giữ nguyên UUID khi hồi sinh bản ghi soft-deleted —
  phía cloud là UPDATE, không phải DELETE+INSERT (tránh nhân bản
  khi 2 thiết bị cùng thao tác).
- `UserContentRepository` (domain, không dính Drift) expose Stream —
  UI phản ứng realtime qua Drift watch + combineLatest tự viết
  (không thêm rxdart cho 1 hàm).
- Migration: schemaVersion + onUpgrade additive từng bước; test
  schema trong test/user_content_repository_test.dart.

## 13. Cache Manager (triển khai Bước 5 — Audio)

Module `lib/core/cache/` với interface:

```dart
abstract interface class CacheManager {
  Future<int> totalSizeBytes();            // dung lượng đang chiếm
  Future<int> sizeOfReciter(String code);  // theo từng Qari
  Future<void> clearAll();
  Future<void> clearReciter(String code);
  Stream<PrefetchProgress> prefetchSurah({  // tải trước cả Surah
    required String reciterCode,
    required int surahId,
  });
}
```

Quy tắc: audio cache theo cây `audio/<reciter>/<sss><aaa>.mp3`;
người dùng xem dung lượng + xóa theo Qari trong Cài đặt; tải trước
chạy nền, dừng được, hiển thị tiến độ; mất mạng giữa chừng -> giữ
phần đã tải, không lỗi.

## 14. Accessibility (chuẩn bắt buộc cho MỌI màn hình)

- **Dynamic type**: mọi Text theo `MediaQuery.textScaler`; layout
  không vỡ ở scale 200% (widget test kèm theo từng màn hình).
- **Screen reader**: mọi nút icon có `Semantics`/tooltip; thẻ Ayah
  có semantic label đọc được (số Ayah + bản dịch đang bật).
- **RTL**: đã hỗ trợ qua locale ar; văn bản Ả Rập luôn
  `TextDirection.rtl` bất kể locale UI.
- **High contrast**: không truyền màu tùy ý — chỉ dùng ColorScheme;
  kiểm tra `MediaQuery.highContrast`; độ tương phản chữ/nền ≥ 4.5:1.

## 15. Mã hóa dữ liệu người dùng (chuẩn bị cho Cloud Sync — Bước 11)

- Nội dung nhạy cảm (ghi chú cá nhân, về sau cả highlight/bookmark)
  được thiết kế để mã hóa PHÍA CLIENT trước khi đẩy lên Supabase:
  cột nội dung là opaque text, server không cần đọc được.
- Khóa: sinh từ passphrase người dùng (tùy chọn bật E2EE) hoặc khóa
  thiết bị; lưu trong `flutter_secure_storage`
  (Keychain/Keystore) — KHÔNG BAO GIỜ đồng bộ khóa lên server.
- SyncEngine xử lý bản ghi dạng bytes/base64 — bật mã hóa sau này
  không đổi schema (chỉ đổi nội dung cột), đã tính từ bây giờ.

## 16. Crash Reporting & Analytics (Bước 11)

- Firebase Crashlytics + Analytics, khởi tạo CHỈ KHI
  `AppEnv.crashReportingEnabled == true` (prod bật, dev tắt).
- Không thu thập nội dung học tập cá nhân (note, tiến độ) —
  chỉ crash log và sự kiện điều hướng ẩn danh.
