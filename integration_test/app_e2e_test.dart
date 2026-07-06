// E2E trên thiết bị thật (Windows/Android/iOS):
//   flutter test integration_test/app_e2e_test.dart -d windows
//
// Kiểm tra trọn luồng dữ liệu THẬT: mở app -> tab Qur'an ->
// danh sách Surah nạp từ SQLite (copy từ asset lần đầu) ->
// mở Surah 1 -> văn bản Arabic + bản dịch hiển thị.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_screen.dart';
import 'package:quran_companion/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

/// Pump tới khi [finder] xuất hiện — cần vì lần đầu app copy
/// database 21 MB từ asset (LazyDatabase), pumpAndSettle không đủ.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  // Chẩn đoán: liệt kê mọi Text đang hiển thị để biết màn hình nào đang mở.
  final visibleTexts = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .where((s) => s.isNotEmpty)
      .take(40)
      .toList();
  throw TestFailure(
    'Không tìm thấy sau $timeout: $finder\n'
    'Text đang hiển thị: $visibleTexts',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Surah list nạp từ SQLite và đọc Surah hoạt động',
      (tester) async {
    // Bật phiên âm bất kể cài đặt đã lưu trên máy — test cần
    // kiểm chứng phiên âm Unicode hiển thị đúng.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reading.show_transliteration', true);

    await app.main();
    await tester.pump();

    // 1. Vào tab Qur'an. Tìm theo ICON vì cửa sổ desktop rộng dùng
    // NavigationRail (không phải NavigationBar) — icon giống nhau
    // ở mọi layout, nhãn thì có thể bị ẩn khi rail mở rộng.
    final quranTab = find.byIcon(Icons.menu_book_outlined);
    await pumpUntilFound(tester, quranTab);
    await tester.tap(quranTab);
    await tester.pump();

    // 2. Danh sách Surah nạp từ SQLite (lần đầu: copy asset -> mở DB).
    await pumpUntilFound(tester, find.text('Al-Fatihah'));
    expect(find.byType(SurahTile), findsWidgets);
    expect(find.text('Al-Baqarah'), findsOneWidget); // Surah 2 cùng màn hình

    // 3. Mở Surah 1 — trang đọc hiển thị văn bản Arabic thật.
    // Không neo vào ayah cụ thể: app khôi phục vị trí đọc đã lưu,
    // list lười (lazy) chỉ build các ayah trong khung nhìn.
    await tester.tap(find.text('Al-Fatihah'));
    await tester.pump();
    final arabicText = find.textContaining(RegExp('[ء-ي]'));
    await pumpUntilFound(
      tester,
      arabicText,
      timeout: const Duration(seconds: 30),
    );

    // 4. Huy hiệu số Ayah (1..7 của Al-Faatiha) xác nhận đúng
    // Surah 1 đang mở với thiết kế thẻ mới.
    await pumpUntilFound(
      tester,
      find.textContaining(RegExp('^[1-7]\$')),
      timeout: const Duration(seconds: 10),
    );

    // 5. Bản dịch hiển thị kèm; KHÔNG còn thẻ HTML thô ở bất kỳ đâu.
    final allTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .toList();
    expect(
      allTexts.any(
        (s) => s.contains('Ngài') || s.contains('Allah'),
      ),
      isTrue,
      reason: 'Phải có bản dịch hiển thị kèm ayah',
    );
    expect(
      allTexts.any((s) => s.contains('<u>') || s.contains('<b>')),
      isFalse,
      reason: 'Phiên âm không được chứa thẻ HTML thô',
    );
    // Phiên âm Unicode chuẩn (có macron ā/ī/ū hoặc chấm dưới ḥ/ṣ).
    expect(
      allTexts.any((s) => RegExp('[āīūḥṣḍṭẓʿ]').hasMatch(s)),
      isTrue,
      reason: 'Phiên âm phải hiển thị dưới dạng Unicode chuẩn',
    );

    // 6. Audio: bấm phát từ Ayah -> thanh phát xuất hiện
    // (kiểm chứng backend just_audio_windows hoạt động thật).
    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await pumpUntilFound(
      tester,
      find.byIcon(Icons.pause_circle_filled),
      timeout: const Duration(seconds: 45),
    );

    // Dừng phát để tiến trình test thoát sạch.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
