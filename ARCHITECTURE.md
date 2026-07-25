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

## 6b. Reading sources (data-driven)

Ayah text layers — transliteration, translations, Tafsir — are **data,
not code**. Nothing in `lib/` names a source code on the render path.

```
translation_sources (group A, read-only)
        │  getEnabledSources()
        ▼
translationSourcesProvider     ← one query per app run, shared
        │
        ├─ AyahCard            visibility × text present, sorted by display_order
        └─ ReadingSettingsSheet one switch per source, label = source.name
```

- **Visibility** is keyed by `TranslationSource.code`, persisted as one
  JSON entry (`reading.source_visibility`). A source the user has never
  touched falls back to a default derived from `SourceType` + language:
  transliteration on, translation on when its language matches the app
  locale, Tafsir off.
- **Presentation** (text style, direction, alignment) derives *only*
  from `SourceType` and language — see `reading_source_style.dart`.
  Direction comes from `TranslationSource.isRtl`, so an Arabic-language
  Tafsir renders RTL without any widget change.
- **Adding a source** = one row in `translation_sources` + its text in
  `translations`. No Dart change. See `DR-2026-0006` decision D3.

### Reading Boundary vs Tafsir Boundary

Reading carries **Arabic + transliteration + translation. Never Tafsir.**

```
Reading boundary            Tafsir boundary (not built)
─────────────────           ───────────────────────────
getAyahsOfSurah()           a dedicated per-ayah fetch
  WHERE is_enabled          keyed by ayahId
    AND type NOT IN         (DR-2026-0006 D4)
        (tafsir)
      │                              │
readingSourcesProvider      a Tafsir view over the SAME
  (filters the catalogue)   translationSourcesProvider result
      │                              │
AyahCard · settings sheet   a Tafsir surface
```

The boundary is enforced in **three** places, deliberately:

1. **SQL** — `getAyahsOfSurah` excludes non-reading types in its
   `WHERE`. Filtering after the read would still pay the disk and
   allocation cost for every commentary in the Surah.
2. **Domain** — `kReadingSourceTypes` / `TranslationSource.isReadingLayer`
   define what "reading" means, once. The SQL exclusion list is derived
   from `kSourceTypeByCode`, so the filter cannot drift from the row
   mapping.
3. **Provider** — `readingSourcesProvider` filters the catalogue so the
   settings sheet never offers a Tafsir switch that would toggle text
   the reading query will never load.

**Why eager loading was rejected.** `getAyahsOfSurah` is one join for
the whole Surah — correct for translations, which are one or two lines.
Tafsir entries run one to three orders of magnitude longer; Al-Baqarah
is 286 ayahs. Enabling a single Tafsir source would have turned opening
a Surah into a multi-megabyte read, held in memory, for text that is
not on screen — with no code change to signal it. The failure mode was
silent, data-triggered, and would have shipped as "the app got slow".

**Extension strategy.** A Tafsir surface adds a per-ayah repository
method plus an `autoDispose.family` provider keyed by `ayahId`, and
derives its own source view from the *same* `translationSourcesProvider`
result — no new query, no change to Reading. Neither exists yet: a
provider without a consumer is speculation (`DR-2026-0006` D4). The
catalogue therefore stays complete (`getEnabledSources` still returns
Tafsir); only the reading *view* filters.

Why not per-feature booleans (`showVietnamese`…)? They cannot express
*multiple* Tafsir sources, and every new source forced edits to
`ReadingSettings`, `AyahCard` and the settings sheet at once. Why not
derive visibility from `is_enabled`? That column is a packaging
decision by the data pipeline; visibility is a per-user preference —
collapsing them makes one of the two unchangeable.

## 6c. Study Boundary (feature ownership)

Reading presents Qur'an text. **Study** owns deep-learning features.
The Tafsir loading boundary (§6b) is the first instance of a general
rule: Reading never loads, and never knows how to load, study data.

| Area | Owns | Must not own |
|---|---|---|
| **Reading** | Layout modes, fonts, scroll position, focus mode, reading-layer rendering | Learning artifacts or their loading |
| **Study** | Per-ayah learning artifacts: Tafsir, notes, highlights, cross references, word analysis | Qur'an text layout; cross-ayah lists |
| **Library** | Collections and lists across ayahs | Per-ayah editing surfaces |
| **Search** | Discovery and ranking | Rendering study content |
| **Audio** | Playback, playlist, transport | Reading layout |
| **Navigation** | Routes and nesting rules | Feature logic |

**Navigation flow.** Study is a per-ayah surface reached by a top-level
route `/study/:ayahId`, opened from the existing `AyahActionsSheet`
(long-press → "Study"). Top-level because Library, Search and AI Tutor
must link to it directly, and pushing a shell-nested route from a
top-level screen crashes go_router (see `reading_navigation.dart`).
`ayahId` is the global 1..6236 id already used by every user-artifact
table.

**Data flow.** Reading passes only an `ayahId`. Study loads everything
itself through `autoDispose.family` providers, one per panel, fanning
out to the repositories that already own each kind of data — there is
no `StudyRepository` (`DR-2026-0006` D5).

```
ReadingScreen ──ayahId──▶ /study/:ayahId ──▶ per-panel providers ──▶ render
```

**Extension strategy.** One panel = one widget + one provider. Going
from 1 Tafsir to 10 changes nothing: the Tafsir panel iterates a Tafsir
view over the same `translationSourcesProvider` result, mirroring
`readingSourcesProvider`. Multiple notes, additional highlight systems
and future modules each add a panel; Reading's files are not opened.

**Tafsir is the reference panel.** It was built first because it is the
only planned feature that exercises every part of the architecture at
once: it crosses the Reading/Study boundary (its data is excluded from
the reading query by §6b), it is inherently multi-source (1 or 10), it
needs source metadata for names and RTL, and it needs a repository read
that Reading must never make. A panel that only touched user data would
have validated far less. Copy `sections/tafsir_section.dart` to add a
panel:

```
StudySection(id: …, builder: …)        ← one value in kStudySections
FutureProvider.autoDispose.family(…)   ← its own loading, keyed by ayahId
a ConsumerWidget wrapping StudyPanel   ← renders, or SizedBox.shrink()
```

**Panels own their own header.** A section that has nothing to show
renders `SizedBox.shrink()` and disappears entirely — header included.
The shell only positions sections; it deliberately does *not* draw
titles, because only the panel knows (after its provider resolves)
whether it has content. `StudyPanel` supplies the uniform title styling.

**Enforced, not just documented.** `test/architecture_boundaries_test.dart`
freezes Reading's cross-feature dependency budget and forbids importing
any feature Study will own. Full rationale, rejected alternatives and
the current debt list: `DR-2026-0007`.

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
