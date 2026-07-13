import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import 'reading_position_store.dart';

/// Lưu vị trí đọc rồi mở đúng Ayah trên trang đọc — MỘT hàm dùng
/// chung cho mọi tính năng "nhảy tới một Ayah cụ thể" TỪ NGOÀI vỏ 5
/// tab (Tìm kiếm, Thư viện của tôi...), đúng mô hình điều hướng
/// chung đã thống nhất (`DR-2026-0002` mục 9: Audio/Reading/
/// Bookmark/Search dùng CHUNG một mô hình điều hướng — tính năng mới
/// PHẢI mở rộng hợp đồng này, không tự chế một đường điều hướng
/// song song).
///
/// Gói lại ĐÚNG hai bước [LibraryScreen._open] (`library_screen.dart`)
/// đã dùng — chính doc comment của hàm đó ghi: "cùng cơ chế với kết
/// quả tìm kiếm":
/// 1. Lưu qua [ReadingPositionStore.save].
/// 2. `push` [AppRoutes.read] — KHÔNG PHẢI [AppRoutes.surahReading].
///
/// Quan trọng — lý do KHÔNG dùng [AppRoutes.surahReading]: route đó
/// (`/quran/surah/:id`) nằm LỒNG trong nhánh Qur'an của
/// `StatefulShellRoute`. `SearchScreen` (giống `LibraryScreen`) là
/// route top-level, push NGOÀI vỏ 5 tab — gọi
/// `context.push(AppRoutes.surahReading(...))` từ đó khiến go_router
/// dựng lại toàn bộ Navigator của nhánh shell chồng lên
/// `GlobalKey` đã tồn tại, ném lỗi
/// `'!keyReservation.contains(key)': is not true` (tái hiện được khi
/// viết widget test cho Task 7.1.14). [AppRoutes.read] (`/read/:id`)
/// được `router.dart` định nghĩa RIÊNG cho đúng tình huống này — xem
/// doc comment của nó: "Trang đọc full-screen cho nơi gọi NGOÀI vỏ
/// tab (vd Thư viện của tôi)... tránh xung đột khi push chồng route
/// top-level." Không tạo route mới (mục 2 backlog Task 7.1.14) —
/// dùng lại route TOP-LEVEL đã có, đúng bản chất lời gọi.
///
/// KHÔNG tạo cơ chế lưu lịch sử đọc thứ hai (mục 1 backlog Task
/// 7.1.14) — vẫn là [ReadingPositionStore] duy nhất.
/// `ReadingScreen` đã tự đọc lại vị trí vừa lưu lúc `initState` để
/// cuộn tới đúng Ayah — không cần tham số "highlight" riêng ở đây.
Future<void> openAyahInReadingScreen(
  BuildContext context,
  WidgetRef ref, {
  required int surahId,
  required int ayahNumber,
}) async {
  await ref.read(readingPositionStoreProvider).save(
        surahId: surahId,
        ayahIndex: ayahNumber - 1,
      );
  if (context.mounted) {
    unawaited(context.push(AppRoutes.read(surahId)));
  }
}
