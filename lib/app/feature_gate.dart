import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/lexicon/data/lexicon_providers.dart';

/// Tính năng chỉ được hiện khi DỮ LIỆU của nó có thật (RC-1).
///
/// VẤN ĐỀ NÓ GIẢI: bản build trước RC-1 có 5 màn hình Flashcard đầy
/// đủ — duyệt, thêm, deck, smart deck, ôn — nối vào một bộ sưu tập
/// KHÔNG THỂ có phần tử nào: [add_flashcard_screen] chỉ dựng được
/// `FlashcardType.lemma`, mà bảng `lemmas` trong database phát hành
/// có 0 dòng. Người dùng bấm vào ô đầu tiên của tab Học và tới một
/// tính năng vĩnh viễn rỗng. Mã nguồn đúng; dữ liệu không có.
///
/// TẠI SAO KHÔNG DÙNG CỜ BOOLEAN: một hằng `kFlashcardsEnabled` sẽ
/// nói dối ngay khi dữ liệu thay đổi theo chiều ngược lại — nạp
/// morphology vào mà quên bật cờ thì tính năng vẫn ẩn, và không có
/// gì báo. Cổng ở đây HỎI THẲNG kho dữ liệu, nên nó không thể lệch
/// với sự thật: nạp dữ liệu là tính năng tự hiện, rút dữ liệu là tính
/// năng tự ẩn, không sửa một dòng mã nào.
///
/// ĐẶT Ở `lib/app/` vì đây là tầng LẮP GHÉP: nó phải biết tới nhiều
/// feature cùng lúc, đúng như `router.dart` bên cạnh. Đặt trong
/// `lib/core/` sẽ tạo phụ thuộc ngược core -> features.
enum GatedFeature {
  /// Flashcard — cần bảng `lemmas` (nhóm A, chỉ đọc) có dữ liệu.
  ///
  /// Toàn bộ chuỗi Flashcard (duyệt/thêm/deck/smart deck/ôn) treo trên
  /// đúng một điều kiện này, nên cổng đặt ở LỐI VÀO (ô trong tab Học):
  /// chặn ở đó là chặn cả năm màn hình, không cần năm lần kiểm tra.
  flashcards,
}

/// Tính năng [feature] có dữ liệu để hoạt động hay không.
///
/// KHÔNG `autoDispose`: dữ liệu nhóm A chỉ đọc, cố định theo bản phát
/// hành — đúng một lần dò cho cả phiên chạy, cùng lý lẽ với
/// `translationSourcesProvider`.
///
/// Phép dò dùng LẠI phương thức repository đã có với `limit: 1` — chỉ
/// cần biết "có dòng nào không", không cần đếm, và không thêm SQL
/// trùng lặp ở tầng nào.
final featureAvailabilityProvider =
    FutureProvider.family<bool, GatedFeature>((ref, feature) async {
  switch (feature) {
    case GatedFeature.flashcards:
      final lemmas =
          await ref.watch(lexiconRepositoryProvider).searchLemmas(limit: 1);
      return lemmas.isNotEmpty;
  }
});
