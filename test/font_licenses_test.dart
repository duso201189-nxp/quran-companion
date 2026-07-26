import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/licenses/bundled_font_licenses.dart';

/// Sprint 33.0 — app phân phối 4 file font. OFL 1.1 buộc thông báo bản
/// quyền + giấy phép đi kèm MỌI bản sao; EULA của KFGQPC cũng đòi giữ
/// nguyên thông báo. Trước sprint này app không kèm dòng nào.
///
/// Test đọc thẳng `pubspec.yaml` chứ không nhận một danh sách font
/// truyền vào: chỉ như vậy thì "thêm font mà quên giấy phép" mới hỏng
/// được. Một test tự liệt kê font sẽ luôn xanh và chẳng bảo vệ gì.

/// Các `family:` khai báo trong phần `fonts:` của pubspec.yaml.
Set<String> _declaredFontFamilies() {
  final lines = File('pubspec.yaml').readAsLinesSync();
  final families = <String>{};
  var inFonts = false;
  for (final line in lines) {
    if (line.startsWith('  fonts:')) {
      inFonts = true;
      continue;
    }
    // Rời khỏi khối `fonts:` khi gặp một khoá cùng cấp khác.
    if (inFonts && line.startsWith('  ') && !line.startsWith('   ')) break;
    final match = RegExp(r'^\s*-\s*family:\s*(\S+)').firstMatch(line);
    if (inFonts && match != null) families.add(match.group(1)!);
  }
  return families;
}

void main() {
  test('mọi font đóng gói đều có file giấy phép được khai báo', () {
    final declared = _declaredFontFamilies();
    expect(declared, isNotEmpty, reason: 'không đọc được font từ pubspec.yaml');
    expect(
      kBundledFontLicenseAssets.keys.toSet(),
      declared,
      reason: 'thêm/bỏ font phải kèm thêm/bỏ thông báo giấy phép',
    );
  });

  test('mỗi file giấy phép tồn tại và mang đúng thông báo bản quyền', () {
    // Dòng bản quyền phải khớp bảng `name` của chính file .ttf — không
    // phải một giấy phép chung chung dán vào cho có.
    const expectedNotice = {
      'UthmanicHafs': 'King Fahd Glorious Quran Printing Complex',
      'Amiri': 'The Amiri Project Authors',
      'NotoNaskhArabic': 'The Noto Project Authors',
      'Inter': 'The Inter Project Authors',
    };

    for (final entry in kBundledFontLicenseAssets.entries) {
      final file = File(entry.value);
      expect(file.existsSync(), isTrue, reason: 'thiếu ${entry.value}');
      final text = file.readAsStringSync();
      expect(
        text.length,
        greaterThan(500),
        reason: '${entry.value} quá ngắn để là một giấy phép đầy đủ',
      );
      expect(
        text,
        contains(expectedNotice[entry.key]),
        reason: '${entry.value} không mang thông báo bản quyền của font',
      );
    }
  });

  test('thư mục giấy phép được khai báo trong assets của pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/licenses/'));
  });

  testWidgets('đăng ký xong thì LicenseRegistry trả về đủ 4 mục font',
      (tester) async {
    LicenseRegistry.reset();
    addTearDown(LicenseRegistry.reset);

    registerBundledFontLicenses(bundle: rootBundle);
    final packages = <String>{};
    await for (final entry in LicenseRegistry.licenses) {
      packages.addAll(entry.packages);
    }

    for (final family in kBundledFontLicenseAssets.keys) {
      expect(packages, contains(family));
    }
  });
}
