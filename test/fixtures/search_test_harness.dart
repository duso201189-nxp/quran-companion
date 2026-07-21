import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'app_harness.dart';

/// Task 7.1.18 — nơi gom các helper/fixture Search dùng lại ở nhiều
/// file test (`search_screen_test.dart`, `result_card_test.dart`,
/// `search_error_state_test.dart`, `search_result_section_test.dart`,
/// `search_accessibility_test.dart`, `search_dark_mode_test.dart`,
/// `search_responsive_test.dart`) — trước task này, mỗi file tự định
/// nghĩa lại gần như y hệt: một `_app`/`_localizedApp`/`_themedApp`
/// bọc MaterialApp, một hàm mở SearchScreen, một hàm chọn dev
/// preview, một Ayah mẫu. Gom lại MỘT nơi, không đổi hành vi test
/// nào (mục 5/7 yêu cầu Task 7.1.18: không giảm coverage, giữ
/// nguyên hành vi).

/// Một Ayah mẫu dùng chung cho test chỉ cần MỘT kết quả đại diện.
/// KHÔNG dùng cho test cần nhiều mục (vd đếm số lượng/thứ tự) —
/// `search_result_section_test.dart` giữ `_sampleResults` riêng (3
/// mục) vì đó là dữ liệu có mục đích khác, không phải trùng lặp.
const sampleAyah = AyahSearchResult(
  ayahId: 2532,
  surahId: 55,
  ayahNumber: 1,
  surahNameLatin: 'Ar-Rahman',
  arabic: 'الرحمن',
  translation: 'The Most Merciful',
);

/// Đặt kích thước viewport ảo rồi tự khôi phục khi test kết thúc —
/// dùng để mô phỏng các bề rộng thiết bị khác nhau.
void setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Bọc [child] trong MaterialApp tối thiểu có đủ l10n + cuộn được —
/// dùng để test MỘT widget Search độc lập (ResultCard,
/// SearchErrorState, SearchResultSection, SearchLoadingSkeleton...)
/// mà không cần router/toàn bộ app. Luôn bọc `SingleChildScrollView`
/// (vô hại với nội dung đã vừa khung hình — chỉ đơn giản không cuộn;
/// cần thiết cho nội dung dài hơn viewport ảo, vd cỡ chữ 200%).
Widget localizedTestApp(
  Widget child, {
  Locale locale = const Locale('vi'),
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// Mở toàn bộ app thật (qua [makeApp]) rồi bấm biểu tượng tìm kiếm ở
/// Trang chủ để vào `SearchScreen` — điểm vào chuẩn cho test cần
/// SearchScreen bên trong router/shell thật (khác [localizedTestApp],
/// vốn cô lập một widget). [prefs] chuyển thẳng cho [makeApp] (vd
/// `ThemeController.prefsKey: 'dark'`); [viewSize] gọi [setViewSize]
/// trước khi dựng, nếu cần mô phỏng một bề rộng thiết bị cụ thể.
Future<void> openSearchScreen(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Size? viewSize,
}) async {
  if (viewSize != null) {
    setViewSize(tester, viewSize);
  }
  await tester.pumpWidget(await makeApp(prefs: prefs));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();
}

/// Mở menu xem trước dành cho dev (biểu tượng bọ trên AppBar) rồi
/// chọn [label] ("Off (real)" | "Empty" | "Loading" | "Results" |
/// "Error") — gọi SAU [openSearchScreen].
Future<void> pickDevPreview(WidgetTester tester, String label) async {
  await tester.tap(find.byIcon(Icons.bug_report_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
