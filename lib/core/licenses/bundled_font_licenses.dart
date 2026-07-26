import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Font đóng gói kèm app -> file giấy phép tương ứng trong
/// `assets/licenses/`.
///
/// KHOÁ là `family` khai báo trong `pubspec.yaml`. Test
/// `font_licenses_test.dart` đọc chính `pubspec.yaml` và đối chiếu với
/// map này, nên thêm font mà quên thông báo giấy phép sẽ làm hỏng test
/// — đó là toàn bộ lý do map này tồn tại thay vì một danh sách rời.
const Map<String, String> kBundledFontLicenseAssets = {
  'UthmanicHafs': 'assets/licenses/UthmanicHafs-KFGQPC-EULA.txt',
  'Amiri': 'assets/licenses/Amiri-OFL.txt',
  'NotoNaskhArabic': 'assets/licenses/NotoNaskhArabic-OFL.txt',
  'Inter': 'assets/licenses/Inter-OFL.txt',
};

/// Đăng ký giấy phép font vào [LicenseRegistry] để `showLicensePage`
/// hiển thị chúng cạnh giấy phép của các package Dart/Flutter.
///
/// TẠI SAO phải làm: OFL 1.1 buộc "the above copyright notice and this
/// license notice shall be included in all copies of one or more of the
/// Font Software typefaces". App phân phối 4 file .ttf; trước Sprint
/// 33.0 nó không kèm một dòng thông báo nào. `LicenseRegistry` là cơ
/// chế SẴN CÓ của Flutter cho đúng việc này — không cần màn hình riêng.
///
/// TÁCH KHỎI màn hình Attribution một cách có chủ ý: Attribution nói về
/// NGUỒN NỘI DUNG (do dữ liệu trong database mô tả, thay đổi theo bản
/// dữ liệu); còn đây là giấy phép của TỆP NHỊ PHÂN đóng gói trong app
/// (thay đổi theo pubspec.yaml). Hai vòng đời khác nhau, hai nguồn sự
/// thật khác nhau.
///
/// [bundle] cho phép test bơm nội dung giả mà không cần asset thật.
void registerBundledFontLicenses({AssetBundle? bundle}) {
  final assets = bundle ?? rootBundle;
  LicenseRegistry.addLicense(() async* {
    for (final entry in kBundledFontLicenseAssets.entries) {
      final text = await assets.loadString(entry.value);
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}
