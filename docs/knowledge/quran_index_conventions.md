# Quy ước chỉ số Ayah trong Qur'an Companion

Tài liệu này trả lời đúng một câu hỏi: **khi mã nguồn nói "Ayah số 5",
đó là số thứ mấy?**

Viết ở Sprint F0 (Phase 4). Nguồn quyết định: `docs/adr/DR-2026-0017-universal-quran-address.md`.

---

## 1. Có BA hệ số cùng tồn tại — và đó không phải lỗi

Ứng dụng dùng ba hệ số khác nhau cho ba việc khác nhau. Cả ba đều hợp
lý ở chỗ của nó; vấn đề trước F0 là chúng **cùng được gọi là "index"**
và phép quy đổi giữa chúng nằm rải rác dưới dạng `+ 1` / `- 1` trần.

| # | Hệ số | Gốc | Ví dụ | Dùng ở đâu |
|---|---|---|---|---|
| **A** | **Số Ayah** | **1-based** | Al-Baqarah 255 → `255` | `Ayah.ayahNumber`, `AyahSearchResult.ayahNumber`, `openAyahInReadingScreen(ayahNumber:)`, giao diện, `QuranAddress` |
| **B** | **Chỉ số Ayah trong Surah** | **0-based** | Al-Baqarah 255 → `254` | `AudioState.currentIndex`, `ReadingPositionStore`, `study_sessions.ayah_from/ayah_to`, `AudioController.playSurah(startIndex:)` |
| **C** | **Chỉ số dòng trong danh sách** | **0-based, +1 vì header** | Ayah đầu → dòng `1` | `ReadingRows` (Sprint F2) — dùng bởi `ScrollablePositionedList` trong `ReadingScreen` |

**Hệ C không phải là hệ B cộng một.** Nó là vị trí trong một danh sách
có phần tử header ở đầu, tức là một khái niệm của TRÌNH BÀY, không phải
của nội dung. Đừng quy đổi thẳng B ↔ C ngoài chỗ dựng danh sách.

## 2. Quy tắc

1. **Ở tầng domain và giao diện, dùng hệ A (1-based).** Đó là con số
   người đọc thấy và là con số `QuranAddress` mang.
2. **Chỉ dùng hệ B khi nói chuyện với API đã có sẵn hệ B** — playlist
   audio, `ReadingPositionStore`, bảng `study_sessions`.
3. **Không tự viết `+ 1` / `- 1` để quy đổi A ↔ B.** Dùng
   `QuranAddress.fromZeroBasedAyahIndex(surah, index)` và
   `QuranAddress.zeroBasedAyahIndex`. Lý do không phải là thẩm mỹ: phép
   quy đổi có tên thì kiểm chứng được bằng test, phép trừ trần thì
   không.
4. **Hệ C chỉ tồn tại bên trong `ReadingScreen`.** Không để nó rò ra
   ngoài widget đó, và không tự viết `+ 1` / `- 1` để vào ra hệ C —
   dùng `ReadingRows` (Sprint F2). Khi Basmalah 2.0 cho phần mở đầu một
   HÀNG riêng, `ReadingRows.leadingRows` là con số duy nhất phải đổi.

## 3. Hai chỗ đã lưu xuống đĩa theo hệ B — cần biết trước khi sửa

### `study_sessions.ayah_from` / `ayah_to`

⚠️ **Đây là chỗ nguy hiểm nhất trong toàn bộ tài liệu này.**

Mọi dòng đã lưu là 0-based, và **không có cột nào ghi lại hệ số của
chính nó**. Nếu đổi bên ghi sang 1-based mà không bump `data_version`:

- dòng cũ và dòng mới không phân biệt được;
- streak và tổng phút được tính TRÊN TRUY VẤN từ bảng này
  (`DR-2026-0003` mục A — thiết kế dẫn xuất-khi-đọc, không có bảng
  `streaks` riêng);
- nên toàn bộ thống kê sai âm thầm, **và không khôi phục được** vì dữ
  liệu thô để tính lại không tồn tại.

Hướng đang chọn (`DR-2026-0017` quy tắc 2): **giữ 0-based ở tầng lưu
trữ, quy đổi ở ranh giới repository.** Không migrate dữ liệu người dùng
chỉ vì lý do biểu diễn.

### `ReadingPositionStore` (SharedPreferences)

`reading.pos.$surahId` → chỉ số Ayah 0-based. Cùng lý do, cùng quy tắc.
Rủi ro thấp hơn (mất vị trí đọc chỉ gây khó chịu, không sai thống kê).

## 4. `QuranAddress` — chỗ quy đổi duy nhất

`lib/core/quran/quran_address.dart`. Thuần Dart: không Flutter, không
Drift, không database. Dựng và test được ở bất cứ đâu.

```
QuranAddress.ayah(2, 255)                      // hệ A — 1-based
QuranAddress.fromZeroBasedAyahIndex(2, 254)    // hệ B → A
address.zeroBasedAyahIndex                     // A → hệ B
address.toString()                             // "2:255"
QuranAddress.tryParse('2:255')                 // đọc lại
```

Phạm vi F0 **chỉ có mức Surah và Ayah**. Chưa có mức Word/Segment, chưa
có `Range`, chưa có trục ấn bản — cả ba nằm trong `DR-2026-0017` nhưng
chưa có nơi tiêu thụ, và thêm sau không tốn di trú vì F0 không lưu địa
chỉ xuống đĩa ở bất cứ đâu.

**Đúng dạng ≠ tồn tại.** `QuranAddress.ayah(2, 300)` dựng được và không
tồn tại (Al-Baqarah có 286 Ayah). Kiểm tra tồn tại cần dữ liệu và là
việc của tầng repository — chính sự tách bạch này giữ cho kiểu địa chỉ
thuần Dart.

## 5. Đã quy đổi qua `QuranAddress` (F0)

| Nơi | Trước | Sau |
|---|---|---|
| `AyahCard` (đang phát) | `s.currentIndex == ayahNumber - 1` | `s.currentAddress == thisAyah` |
| `AudioBar` (tham chiếu) | `'${surahId}:${currentIndex + 1}'` | `'$address'` |

## 5b. Đã đặt tên cho hệ C (F2)

Năm chỗ viết tay phép quy đổi hệ B ↔ hệ C, giờ đi qua `ReadingRows`:

| Nơi | Trước | Sau |
|---|---|---|
| `itemCount` | `ayahs.length + 1` | `ReadingRows.rowCountFor(...)` |
| `itemBuilder` | `index == 0` / `ayahs[index - 1]` | `ayahIndexForRow(row)`, `null` = header |
| `initialScrollIndex` | `min(i + 1, ayahs.length)` | `min(rowForAyahIndex(i), lastRowFor(...))` |
| `_onPositionsChanged` | `max(0, minItemIndex - 1)` | `ayahIndexForRow(...) ?? 0` |
| cuộn theo audio | `scrollTo(index: currentIndex + 1)` | `scrollTo(index: rowForAyahIndex(...))` |

Không chỗ nào trong năm chỗ đó từng phát biểu hợp đồng "hàng 0 là
header" — cả năm chỉ cùng giả định. Khi Basmalah 2.0 thêm một hàng dẫn
đầu, bốn trong năm chỗ sẽ hỏng **lặng lẽ** (vị trí đọc lưu xuống đĩa
lệch một Ayah, không ném lỗi).

## 6. Còn dùng số trần — có chủ ý, và vì sao

| Nơi | Vì sao chưa đổi |
|---|---|
| `HomeScreen` `ayahIndex + 1` | Dùng cho nhãn accessibility và phân số tiến độ; phân số là phép TÍNH, không phải địa chỉ. Đổi sẽ dài hơn mà không rõ hơn. |
| `AudioController.playSurah(startIndex:)` | API playlist, hệ B đúng chỗ. Sẽ nhận địa chỉ khi `DR-2026-0018` S2 tách vị trí phát. |
| `QuizSessionState.currentIndex` | Chỉ số câu hỏi, không phải Ayah. Không mơ hồ. |
