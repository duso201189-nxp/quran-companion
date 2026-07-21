# Accessibility checklist — Qur'an Companion

Viết ở Sprint 20 Phase 1 ("Accessibility & UX Audit Foundation").
KHÔNG gắn với 1 lần audit cụ thể — đây là checklist TÁI SỬ DỤNG cho
mọi màn hình/PR sau này (mới hoặc sửa). Điểm cụ thể tìm thấy khi áp
dụng checklist này lần đầu nằm ở
[accessibility_audit.md](accessibility_audit.md), không nằm ở đây.

Nếu tài liệu này lệch với code, code thắng — cập nhật lại checklist,
đừng tin nó mù quáng.

## Cách dùng

Trước khi coi 1 màn hình/widget mới là "xong", tự hỏi lần lượt từng
mục dưới đây. Ô "✅ mẫu đã có trong dự án" trỏ tới 1 file THẬT đã làm
đúng — copy cách làm đó, đừng phát minh lại.

## 1. Semantics bắt buộc

| Yêu cầu | Vì sao | ✅ Mẫu đã có trong dự án |
|---|---|---|
| Thẻ/card gộp nhiều Text+Icon con thành 1 nhãn duy nhất | Không để trình đọc màn hình đọc rời rạc icon → tiêu đề → mô tả → số liệu thành nhiều điểm dừng vô nghĩa | `Semantics(label: '$title. $detail. $priorityLabel', child: ExcludeSemantics(child: Row(...)))` — `tutor_suggestion_card.dart:63-65`, cùng mẫu ở `goal_card.dart`, `achievement_card.dart`, `tutor_header.dart`, `journey_header.dart`, `journey_progress_card.dart`, `smart_learning_header.dart`, `recommendation_card.dart`, `session_summary_card.dart` |
| Nút hành động BÊN TRONG 1 thẻ đã gộp nhãn phải nằm NGOÀI `ExcludeSemantics` | Nếu không, nút bị nuốt vào 1 nhãn tĩnh không bấm được — trình đọc màn hình không tiếp cận được hành động | `tutor_suggestion_card.dart:58-62` (comment giải thích rõ), :109-118 (nút `TextButton.icon` nằm sau khi `ExcludeSemantics` đã đóng) |
| Icon-only button PHẢI có `tooltip:` (không chỉ `icon:`) | `tooltip` vừa hiện chữ khi hover/long-press vừa TỰ ĐỘNG trở thành nhãn accessibility — thiếu nó, icon-only button không có tên cho trình đọc màn hình | `reading_screen.dart`/`audio_bar.dart` — MỌI `IconButton` đều có `tooltip:` (đã kiểm chứng bằng grep, 0 ngoại lệ trong 2 file này) |
| Icon-only nút TRẠNG THÁI (không phải hành động, vd 1 dot màu biểu thị trạng thái) vẫn cần `Semantics(label: ...)` mô tả trạng thái đó bằng CHỮ | Màu sắc đơn thuần không truyền đạt được gì cho trình đọc màn hình LẪN người dùng mù màu (WCAG 1.4.1 "Use of Color") | ❌ Chưa có mẫu đúng trong dự án — xem `accessibility_audit.md` mục "flashcard_tile.dart CircleAvatar" |
| Tiêu đề PHẦN/SECTION (không phải AppBar title) nên đánh dấu `Semantics(header: true)` | Cho phép trình đọc màn hình nhảy thẳng giữa các heading (thao tác điều hướng chuẩn của mọi trình đọc màn hình) thay vì phải lướt tuần tự | `search_screen.dart:332-333` (`SearchEmptyState` title), `search_result_section.dart:78-79` — DUY NHẤT 2 nơi trong toàn app dùng đúng `header: true`, xem backlog |
| Trạng thái loading/error xuất hiện ĐỘNG (sau khi load xong) cần `Semantics(liveRegion: true, ...)` | Không có `liveRegion`, trình đọc màn hình không tự thông báo nội dung mới xuất hiện — người dùng phải tự dò tìm | `loading_state.dart:24-26`, `search_error_state.dart:59-61` |

## 2. Tap target

| Yêu cầu | Vì sao | ✅ Mẫu đã có trong dự án |
|---|---|---|
| Mọi control TƯƠNG TÁC (không phải badge/dot trang trí) nên đạt tối thiểu 48×48dp | Chuẩn Material/WCAG 2.5.5 cho ngón tay chạm chính xác | Mặc định `IconButton`/`FilledButton`/`TextButton` của Material đã đạt — CHỈ cần cẩn thận khi override `visualDensity`/kích thước tường minh (xem mục dưới) |
| KHÔNG dùng `visualDensity: VisualDensity.compact` hay kích thước tường minh &lt; 48dp cho control THỰC SỰ TƯƠNG TÁC | Thu nhỏ dưới ngưỡng chuẩn dù để tiết kiệm không gian | ❌ Phản ví dụ đã biết: `reading_screen.dart` `_ActionIcon` dùng `visualDensity: VisualDensity.compact` cho hàng 6 icon/ayah — xem audit mục "Reading" |
| Nếu 1 control nhỏ (&lt; 48dp) BẮT BUỘC vì lý do bố cục (vd chấm chọn màu), phải có `Semantics(label:, button: true)` bù lại | Semantics không thay thế được kích thước vật lý cho người vận động khó khăn, nhưng vẫn đảm bảo tên/vai trò đúng cho trình đọc màn hình | `ayah_actions_sheet.dart:284-287` (`_ColorDot`, 34×34, có `Semantics(label: colorName, button: true, selected: selected)`) — kích thước vẫn nên nâng lên 48dp khi có dịp, xem backlog |

## 3. Yêu cầu trạng thái Loading

| Yêu cầu | Vì sao | ✅ Mẫu đã có trong dự án |
|---|---|---|
| Dùng `LoadingState` (`lib/shared/widgets/loading_state.dart`) thay vì tự viết `CircularProgressIndicator()` trần | `LoadingState` BẮT BUỘC `semanticsLabel` ở compile-time (tham số `required`) — không thể quên | `progress_dashboard_screen.dart` (5 lần), `tutor_home_screen.dart` (3 lần), `learning_journey_screen.dart`, `smart_learning_screen.dart` |
| `semanticsLabel` nên mô tả ĐÚNG phần đang tải, không dùng chung 1 câu chung chung cho mọi phần của cùng 1 màn hình | Người dùng trình đọc màn hình cần biết PHẦN NÀO đang tải khi có nhiều phần tải độc lập trên cùng màn hình | ⚠️ Phản ví dụ đã biết: `progress_dashboard_screen.dart` dùng ĐÚNG 1 chuỗi `l10n.progressDashboardLoading` cho cả 5 section khác nhau (Statistics/Goals/Achievements/History/Insights) — xem audit backlog |
| KHÔNG để loading state "biến mất im lặng" (vd `maybeWhen(orElse: () =&gt; SizedBox.shrink())`) trừ khi phần đó THỰC SỰ không cần phản hồi người dùng | Người dùng không phân biệt được "đang tải" với "app treo"/"không có gì ở đây" | ❌ Phản ví dụ đã biết: `home_screen.dart` `_TodaysVerseCard` — xem audit mục "Home" |

## 4. Yêu cầu trạng thái Empty

| Yêu cầu | Vì sao | ✅ Mẫu đã có trong dự án |
|---|---|---|
| Dùng `EmptyStateBanner` (`lib/shared/widgets/empty_state_banner.dart`) thay vì tự viết `Text` trần giữa màn hình | Nhất quán hình ảnh (icon + nền `secondaryContainer` nhạt) trên toàn app | `progress_dashboard_screen.dart`, `learning_journey_screen.dart`, `smart_learning_screen.dart`, `tutor_home_screen.dart` (suggestions) |
| MỌI danh sách/collection có thể rỗng phải có nhánh empty riêng — không để "rỗng" trông giống hệt "đang tải" hoặc render ra khoảng trắng | Người dùng cần phân biệt "chưa có gì" với "đang tải"/"lỗi" | ⚠️ Phản ví dụ đã biết: Goals/Achievements/Insights-tổng-quan trong `progress_dashboard_screen.dart`/`tutor_home_screen.dart` KHÔNG có nhánh empty — xem audit backlog |
| **Cân nhắc thêm `Semantics(liveRegion: true)` cho `EmptyStateBanner`** khi dùng lần sau — bản thân widget hiện CHƯA có, khác 2 widget dùng chung còn lại | Nhất quán với `LoadingState`/`SearchErrorState`, và đảm bảo trạng thái rỗng xuất hiện SAU khi tải xong cũng được thông báo | ❌ Chưa có — đây chính là điểm KHÁC BIỆT giữa `EmptyStateBanner` và 2 widget dùng chung còn lại, xem audit mục "EmptyStateBanner" |

## 5. Yêu cầu trạng thái Error

| Yêu cầu | Vì sao | ✅ Mẫu đã có trong dự án |
|---|---|---|
| MỌI phần dữ liệu bất đồng bộ có thể lỗi phải có: icon lỗi + thông điệp CHỮ + (nếu hành động lặp lại có ý nghĩa) nút "Thử lại" | Người dùng cần biết CÓ lỗi (không chỉ trống rỗng) và có đường thoát | `search_error_state.dart` — mẫu chuẩn, dùng lại được (dù tên gợi ý "chỉ cho Search", xem audit mục "Đặt tên lại") |
| KHÔNG hiện nút "Thử lại" nếu `onRetry` không thật sự làm gì (null) | 1 nút không hoạt động gây hiểu lầm nghiêm trọng hơn không có nút | `search_error_state.dart:39-42,72` — CHỈ render nút khi `onRetry != null` |
| Thông điệp lỗi + icon phải nằm trong `Semantics(liveRegion: true, label: ...)`, nút "Thử lại" nằm NGOÀI (như mục 1) | Trạng thái lỗi xuất hiện ĐỘNG cần tự thông báo; nút vẫn phải độc lập bấm được | `search_error_state.dart:59-79` |
| KHÔNG để lỗi "biến mất im lặng" (vd `.valueOrNull ?? []`, nuốt exception không hiện gì) | Cùng lý do mục Loading — người dùng không phân biệt được lỗi với "không có dữ liệu" | ❌ Phản ví dụ đã biết: `home_screen.dart` (surahsAsync + `_TodaysVerseCard`), xem audit mục "Home" |

## 6. Contrast — giả định & rủi ro

| Yêu cầu | Vì sao | Ghi chú dự án |
|---|---|---|
| LUÔN lấy màu từ `Theme.of(context).colorScheme`, KHÔNG hard-code `Colors.grey`/mã hex | `ColorScheme.fromSeed` (Material 3) được thiết kế để mỗi cặp on-X/X đạt tương phản đủ chuẩn — hard-code phá vỡ đảm bảo đó | `app_theme.dart:35-38` — seed color duy nhất, mọi ThemeData khác dẫn xuất từ đây; đã kiểm tra: KHÔNG có `Colors.grey`/hex trong bất kỳ file audit nào |
| CẨN THẬN khi giảm alpha (`.withValues(alpha: ...)`) của MÀU NỀN — không giảm alpha của MÀU CHỮ đặt trên nền đó | Giảm alpha nền làm nền pha trộn với bất kỳ thứ gì bên dưới nó (không cố định) — tỷ lệ tương phản thật giữa chữ (vẫn full-opacity) và nền hiển thị THỰC TẾ không còn được Material đảm bảo nữa | ⚠️ Đáng chú ý: `empty_state_banner.dart:26` giảm alpha NỀN còn 0.5 (chữ vẫn full-opacity, chấp nhận được); NHƯNG `reading_screen.dart:915-923` giảm alpha CHỮ transliteration còn 0.7 TRÊN NỀN ĐÃ `onSurfaceVariant` (vốn đã là màu phụ) — 2 lớp giảm tương phản chồng nhau, xem audit mục "Reading" |
| Text cỡ nhỏ (`labelSmall`/`bodySmall`) + màu phụ (`onSurfaceVariant`) là tổ hợp DÙNG NHIỀU trong dự án — chấp nhận được vì vẫn đúng cặp on-X/X, nhưng tránh cỡ nhỏ HƠN NỮA hoặc thêm alpha lên tổ hợp này | Cỡ chữ nhỏ càng cần tương phản cao hơn theo WCAG (Level AA yêu cầu tỷ lệ cao hơn cho chữ &lt; 18px không đậm) | Ví dụ chấp nhận được: `goal_card.dart`, `achievement_card.dart`, hầu hết caption trong dự án |

## 7. Focus order

| Yêu cầu | Vì sao |
|---|---|
| Thứ tự đọc/focus nên khớp thứ tự hiển thị trực quan (trên→dưới, trái→phải theo `Column`/`Row` tự nhiên) | Flutter tự suy ra thứ tự traversal từ cây widget — KHÔNG cần can thiệp thủ công NẾU bố cục dùng `Column`/`Row`/`ListView` tuần tự bình thường (đúng cách toàn bộ dự án đang làm — chưa phát hiện `FocusTraversalGroup`/`Positioned` phá vỡ thứ tự tự nhiên nào trong phạm vi audit này) |
| Dialog/BottomSheet mới mở nên tự nhận focus vào phần tử đầu tiên có ý nghĩa | Tránh người dùng bàn phím/switch-control "mất dấu" khi 1 sheet mới xuất hiện | Chưa kiểm chứng riêng trong audit này — xem backlog |

## 8. Trước khi merge — tự kiểm nhanh

1. Mọi `IconButton`/nút chỉ-có-icon có `tooltip:` chưa?
2. Mọi card gộp nhiều Text con có `Semantics(label:) + ExcludeSemantics` chưa? Nút hành động (nếu có) có nằm NGOÀI `ExcludeSemantics` không?
3. Loading dùng `LoadingState` (không phải `CircularProgressIndicator` trần) chưa? `semanticsLabel` có mô tả ĐÚNG phần đang tải không?
4. Empty dùng `EmptyStateBanner` chưa? Có nhánh empty cho MỌI danh sách có thể rỗng không?
5. Error có icon + chữ + (nếu hợp lý) nút thử lại chưa? Có dùng lại 1 trong các widget dùng chung thay vì viết mới không?
6. Có chuỗi hiển thị/đọc nào KHÔNG qua `l10n` không (kể cả chuỗi dùng làm `Semantics.label`)?
7. Màu có lấy từ `colorScheme` không? Có giảm alpha CHỮ (không phải chỉ nền) ở đâu không?
8. Có control tương tác nào bị thu nhỏ dưới 48dp (`visualDensity: compact`, `width`/`height` tường minh nhỏ) không? Nếu bắt buộc, đã bù bằng `Semantics(button: true, label:)` chưa?
9. Có trạng thái nào "biến mất im lặng" khi lỗi/đang tải (`orElse: () =&gt; SizedBox.shrink()`, `.valueOrNull ?? []` nuốt lỗi) không?
10. Nếu thêm 1 tiêu đề phần mới — đã cân nhắc `Semantics(header: true)` chưa (hiện mới có ở `search_screen.dart`)?
