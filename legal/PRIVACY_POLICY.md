# Privacy Policy — Qur'an Companion

**Effective date:** `2026-07-26`
**Applies to:** Qur'an Companion for Android and iOS, application ID
`com.duso.qurancompanion`, version 0.8.1 and later.
**Publisher:** `Du So`
**Contact:** `qurancompanionhq@gmail.com`

> **Published.** This policy is live at
> <https://duso201189-nxp.github.io/quran-companion/privacy.html>.
> Every statement in it describes behaviour verified in the source code
> at Sprint 34.0 (2026-07-26), not an aspiration. The HTML page and this
> file must be edited together — see the Website section of `README.md`.

---

## 1. Summary

Qur'an Companion does not have accounts, does not have analytics, and
does not send your reading data anywhere. Everything you create in the
app — notes, bookmarks, highlights, favourites, reading progress,
flashcards, review schedules — is stored **only** on your device.

The app makes exactly one kind of network request: downloading a
recitation audio file when you press play.

## 2. Information we collect

**None.** The app has no sign-up, no user profile, no telemetry, no
advertising identifier, no crash reporting service, and no analytics
SDK.

Technical basis for that statement, checkable in the repository:

| Claim | Where to verify |
|---|---|
| No crash reporting | `crashReporterProvider` returns `NoopCrashReporter` |
| No remote logging | `loggerProvider` returns `ConsoleLogger` (device console only) |
| No analytics SDK | `pubspec.yaml` — 13 third-party packages, none analytics |
| Only one network host | grep for `https://` in `lib/` returns only `everyayah.com` |

## 3. Information stored on your device

Stored locally in the app's private storage, never transmitted by the
app:

- Reading position, reading streaks and session history
- Bookmarks, favourites, notes, highlights and collections
- Flashcards, quiz results and spaced-repetition schedules
- Khatm (completion cycle) progress
- Settings: theme, interface language, which text sources are shown,
  selected reciter, playback speed

This data is removed when you uninstall the app.

**Android automatic backup.** Android's system-level "Backup by Google
One" may copy an app's private files to the user's own Google account.
Qur'an Companion does not disable this. The backup is made by Android,
belongs to the user's Google account, and is governed by Google's
privacy policy, not this one. To prevent it, turn off backup for this
app in Android Settings → System → Backup.

## 4. Audio streaming — the only data leaving your device

When you play a recitation, the app requests an MP3 file directly from
**everyayah.com**. That request necessarily reveals to that server:

- your device's IP address
- which recitation file was requested (therefore which Surah and Ayah)
- standard HTTP headers your device sends

The app sends no identifier, no account, and no other information.
Qur'an Companion does not control everyayah.com and does not receive
any data back other than the audio file itself.

Audio is only requested when you press play. If you never play audio,
the app makes no network requests at all.

## 5. Permissions

| Permission | Why |
|---|---|
| `INTERNET` | download recitation audio |
| `ACCESS_NETWORK_STATE` | detect being offline, to fail quietly instead of hanging |

The app requests no other permission — no location, no contacts, no
microphone, no camera, no storage outside its own sandbox.

## 6. Children

The app collects no personal information from anyone, including
children. It contains no advertising, no in-app purchases, no social
features and no user-generated content shared between users.

## 7. Your rights

Because no personal data is collected or transmitted, there is nothing
for us to access, export, correct or delete on your behalf. All your
data is in your hands: uninstalling the app deletes it.

If you have a question about this policy, contact
`qurancompanionhq@gmail.com`.

## 8. Changes to this policy

If a future version of the app introduces cloud synchronisation,
accounts, analytics or crash reporting, this policy will be updated
**before** that version is released, and the change will be described
in the app's release notes. The version of the policy in force is the
one published at `https://duso201189-nxp.github.io/quran-companion/privacy.html`.

---
---

# Chính sách quyền riêng tư — Qur'an Companion

**Ngày hiệu lực:** `2026-07-26`
**Áp dụng cho:** Qur'an Companion trên Android và iOS, mã ứng dụng
`com.duso.qurancompanion`, phiên bản 0.8.1 trở lên.
**Nhà phát hành:** `Du So`
**Liên hệ:** `qurancompanionhq@gmail.com`

## 1. Tóm tắt

Qur'an Companion không có tài khoản, không có phân tích hành vi, và
không gửi dữ liệu đọc của bạn đi đâu cả. Mọi thứ bạn tạo trong ứng
dụng — ghi chú, dấu trang, tô sáng, yêu thích, tiến độ đọc, thẻ ghi
nhớ, lịch ôn tập — chỉ nằm **trên máy của bạn**.

Ứng dụng chỉ thực hiện đúng một loại yêu cầu mạng: tải file âm thanh
khi bạn bấm phát.

## 2. Thông tin chúng tôi thu thập

**Không có.** Ứng dụng không có đăng ký, không có hồ sơ người dùng,
không có telemetry, không có mã quảng cáo, không có dịch vụ báo lỗi và
không có SDK phân tích nào.

## 3. Dữ liệu lưu trên máy bạn

Lưu trong vùng riêng của ứng dụng, không bao giờ được ứng dụng truyền
đi: vị trí đọc, chuỗi ngày đọc, lịch sử phiên học, dấu trang, yêu
thích, ghi chú, tô sáng, bộ sưu tập, thẻ ghi nhớ, kết quả quiz, lịch
ôn tập, tiến độ Khatm, và các cài đặt (giao diện, ngôn ngữ, nguồn văn
bản hiển thị, Qari, tốc độ phát).

Gỡ ứng dụng là xoá toàn bộ dữ liệu này.

**Sao lưu tự động của Android.** Cơ chế "Sao lưu bằng Google One" của
hệ điều hành có thể chép các tệp riêng của ứng dụng lên tài khoản
Google của chính bạn. Bản sao lưu đó do Android tạo, thuộc tài khoản
Google của bạn, và chịu sự điều chỉnh của chính sách quyền riêng tư
của Google. Muốn tắt: Cài đặt → Hệ thống → Sao lưu.

## 4. Phát âm thanh — thứ duy nhất rời khỏi máy bạn

Khi bạn phát một bản tụng đọc, ứng dụng tải file MP3 trực tiếp từ
**everyayah.com**. Yêu cầu đó tất yếu để lộ với máy chủ ấy: địa chỉ IP
của thiết bị, file nào được yêu cầu (tức Surah/Ayah nào), và các HTTP
header tiêu chuẩn. Ứng dụng không gửi kèm bất kỳ định danh nào.

Chỉ khi bạn bấm phát mới có yêu cầu mạng. Không phát âm thanh thì ứng
dụng không kết nối mạng lần nào.

## 5. Quyền truy cập

`INTERNET` (tải âm thanh) và `ACCESS_NETWORK_STATE` (nhận biết mất
mạng để báo lỗi thay vì treo). Không có quyền nào khác.

## 6. Trẻ em

Ứng dụng không thu thập thông tin cá nhân của bất kỳ ai, kể cả trẻ em.
Không quảng cáo, không mua trong ứng dụng, không tính năng mạng xã
hội, không nội dung do người dùng chia sẻ với nhau.

## 7. Quyền của bạn

Vì không có dữ liệu cá nhân nào được thu thập hay truyền đi, chúng tôi
không giữ gì để bạn yêu cầu truy cập, xuất, sửa hay xoá. Toàn bộ dữ
liệu nằm trong tay bạn.

## 8. Thay đổi chính sách

Nếu một phiên bản sau có đồng bộ đám mây, tài khoản, phân tích hay báo
lỗi, chính sách này sẽ được cập nhật **trước** khi phiên bản đó phát
hành.
