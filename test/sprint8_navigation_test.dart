import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/khatm/presentation/active_khatm_card.dart';
import 'package:quran_companion/features/library/presentation/collections/collections_screen.dart';
import 'package:quran_companion/features/library/presentation/library_screen.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';

import 'fixtures/app_harness.dart';

/// Sprint 8 Phase 5 — xác nhận 2 đường điều hướng mới (Bộ sưu tập,
/// Tiếp tục đọc từ Khatm) hoạt động đúng qua ROUTER THẬT của app
/// (không phải GoRouter cô lập trong test khác) — cùng mức độ
/// nghiêm ngặt đã phát hiện lỗi Navigator key thật ở Sprint 7.1.
///
/// Dùng bơm nhịp có giới hạn (_settle) thay vì pumpAndSettle(): tab
/// Thống kê giữ nhiều StreamProvider Drift luôn sống (Active Khatm +
/// Phiên đọc) trong nhánh IndexedStack không bị huỷ khi đổi tab —
/// điều này khiến heuristic "không còn frame nào" của pumpAndSettle
/// không bao giờ thấy màn hình "đã yên", dù UI trên thực tế đã ổn
/// định (xác nhận bằng debug: ReadingScreen xuất hiện và đứng yên
/// chỉ sau 1-2 nhịp bơm). Đây là giới hạn đã biết của
/// pumpAndSettle với nhiều stream Drift cùng sống trong 1 tab được
/// giữ trạng thái, không phải lỗi điều hướng.
Future<void> _settle(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
      'Hồ sơ -> Thư viện của tôi -> biểu tượng Bộ sưu tập -> '
      'CollectionsScreen mở đúng, quay lại được', (tester) async {
    await tester.pumpWidget(await makeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hồ sơ').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thư viện của tôi'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CollectionsScreen), findsOneWidget);
    expect(find.byType(LibraryScreen), findsNothing);

    // Quay lại không crash, không mất LibraryScreen bên dưới.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(find.byType(CollectionsScreen), findsNothing);

    // Dispose sớm ngay trong thân test — tránh assertion "Timer is
    // still pending" của flutter_test khi Drift đóng stream bằng
    // Timer(0) lúc cây widget bị dọn tự động sau khi test kết thúc.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
      'Thống kê -> Bắt đầu Khatm -> Tiếp tục đọc -> mở đúng '
      'ReadingScreen qua router thật, không xung đột Navigator key',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thống kê').last);
    await tester.pumpAndSettle();

    // ActiveKhatmCard nằm dưới màn hình đầu (sau lưới chỉ số + biểu
    // đồ + thanh hoàn thành trong ListView lười) — cuộn xuống trước
    // khi tìm, giống thao tác thật của người dùng.
    await tester.scrollUntilVisible(
      find.byType(ActiveKhatmCard),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await _settle(tester);

    expect(find.byType(ActiveKhatmCard), findsOneWidget);
    expect(find.text('Bắt đầu Khatm'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Bắt đầu Khatm'));
    await _settle(tester);

    expect(find.text('Tiếp tục đọc'), findsOneWidget);
    expect(find.byType(ReadingScreen), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Tiếp tục đọc'));
    await _settle(tester);

    // currentAyahId mặc định = 1 -> Al-Fatihah, Surah 1. Không xung
    // đột Navigator key: /read/:id là route top-level ngoài mọi
    // nhánh shell, giống cơ chế LibraryScreen._open (Task 7.1.14).
    expect(find.byType(ReadingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
