import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Sprint 34.0 — metadata mà CỬA HÀNG đọc, không phải người dùng.
///
/// Những giá trị này nằm ngoài Dart nên `flutter analyze` và toàn bộ
/// widget test không bao giờ chạm tới. Chúng hỏng âm thầm: bản build
/// vẫn chạy, test vẫn xanh, và tên gói thô hiện dưới biểu tượng trên
/// máy người dùng — đúng thứ `aapt2 dump badging` phát hiện ở Sprint
/// 34.0 (`application-label:'quran_companion'` cho cả 84 locale).
///
/// Test đọc thẳng file cấu hình gốc, không nhận giá trị truyền vào.

const _expectedName = "Qur'an Companion";

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('Android', () {
    test('manifest lấy nhãn từ string resource, không viết thẳng', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(
        manifest,
        contains('android:label="@string/app_name"'),
        reason: 'nhãn viết thẳng vào manifest thì không bản địa hoá được',
      );
    });

    test('app_name là tên người đọc được, không phải tên gói', () {
      final strings = _read('android/app/src/main/res/values/strings.xml');
      // Dấu nháy đơn bắt buộc escape trong strings.xml -> so sánh trên
      // bản đã bỏ escape.
      final match = RegExp(
        r'<string name="app_name">(.*?)</string>',
      ).firstMatch(strings);
      expect(match, isNotNull, reason: 'thiếu string app_name');
      final value = match!.group(1)!.replaceAll(r'\', '');
      expect(value, _expectedName);
      expect(
        value,
        isNot('quran_companion'),
        reason: 'đây là tên gói, không phải tên ứng dụng',
      );
    });

    test('chỉ xin đúng hai quyền, không hơn', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      final permissions = RegExp(r'uses-permission android:name="([^"]+)"')
          .allMatches(manifest)
          .map((m) => m.group(1))
          .toSet();
      // Mọi quyền thêm vào đều phải được khai báo lại trong biểu mẫu
      // Data safety của Play và trong legal/PRIVACY_POLICY.md §5.
      expect(permissions, {
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
      });
    });
  });

  group('iOS', () {
    test('tên hiển thị khớp Android', () {
      final plist = _read('ios/Runner/Info.plist');
      final match = RegExp(
        r'<key>CFBundleDisplayName</key>\s*<string>(.*?)</string>',
      ).firstMatch(plist);
      expect(match, isNotNull);
      expect(match!.group(1), _expectedName);
    });

    test('đã khai báo miễn trừ mã hoá xuất khẩu', () {
      final plist = _read('ios/Runner/Info.plist');
      // Thiếu khoá này thì App Store Connect hỏi lại ở MỌI lần nộp,
      // và bản build bị treo cho tới khi có người trả lời.
      expect(plist, contains('ITSAppUsesNonExemptEncryption'));
    });

    test('privacy manifest tồn tại và tuyên bố không theo dõi', () {
      final file = File('ios/Runner/PrivacyInfo.xcprivacy');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Apple bắt buộc từ 2024-05; thiếu -> từ chối bản tải lên',
      );
      final xml = file.readAsStringSync();
      expect(
        RegExp(r'<key>NSPrivacyTracking</key>\s*<false/>').hasMatch(xml),
        isTrue,
      );
      // Rỗng = không thu thập gì. Nếu đồng bộ đám mây bật lên mà quên
      // sửa file này, tuyên bố với Apple sẽ thành sai sự thật.
      expect(
        RegExp(r'<key>NSPrivacyCollectedDataTypes</key>\s*<array/>')
            .hasMatch(xml),
        isTrue,
      );
    });
  });

  group('Đường ống phát hành', () {
    // Sprint 35.0 — CI từng chỉ build `apk --debug`. Bản artifact được
    // kiểm thử phải là bản artifact được phát hành, nếu không thì mọi
    // hành vi riêng của bản release (R8, resource shrinking, đóng gói
    // asset) không có ai canh.
    test('CI build đúng thứ được phát hành và giữ mapping.txt', () {
      final ci = _read('.github/workflows/ci.yml');
      expect(
        ci,
        contains('flutter build appbundle --release'),
        reason: 'CI không build AAB thì không ai kiểm bản release',
      );
      expect(
        ci,
        contains('mapping/release/mapping.txt'),
        reason: 'mất mapping.txt = mọi stack trace của bản đó vô nghĩa',
      );
      expect(
        ci,
        contains("tags: ['v*']"),
        reason: 'tag phát hành phải chạy pipeline và để lại artifact',
      );
    });

    test('khoá cache database phủ mọi đầu vào của nó', () {
      final ci = _read('.github/workflows/ci.yml');
      // Băm mỗi build_quran_db.py thì đổi tool/data/*.json sẽ dùng lại
      // database CŨ từ cache, và test smoke đỏ vì một lý do không liên
      // quan tới thay đổi thật.
      final key = RegExp(r'key: quran-db-\S*\$\{\{ hashFiles\(([^)]*)\)')
          .firstMatch(ci)
          ?.group(1);
      expect(key, isNotNull, reason: 'không tìm thấy khoá cache database');
      expect(key, contains('tool/build_quran_db.py'));
      expect(key, contains('tool/data/*.json'));
    });

    test('tài liệu phát hành tồn tại', () {
      for (final path in [
        'RELEASE_NOTES.md',
        'KNOWN_ISSUES.md',
        'RELEASE_CHECKLIST.md',
        'docs/release/PUBLISHER_CHECKLIST.md',
        'docs/release/SUPPORT_CHECKLIST.md',
        'docs/release/POST_RELEASE_CHECKLIST.md',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: 'thiếu $path');
      }
    });
  });

  group('Hồ sơ pháp lý', () {
    test('bốn tài liệu bắt buộc đều tồn tại', () {
      for (final path in [
        'legal/PRIVACY_POLICY.md',
        'legal/TERMS_OF_USE.md',
        'legal/THIRD_PARTY_NOTICES.md',
        'legal/STORE_COMPLIANCE.md',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: 'thiếu $path');
      }
    });

    test('mọi nguồn nội dung đang phát hành đều có mặt trong bản ghi công', () {
      final notices = _read('legal/THIRD_PARTY_NOTICES.md');
      for (final host in [
        'tanzil.net',
        'QuranEnc.com',
        'Quran.com',
        'everyayah.com',
      ]) {
        expect(notices, contains(host), reason: '$host không được ghi công');
      }
      for (final font in ['KFGQPC', 'Amiri', 'Noto Naskh Arabic', 'Inter']) {
        expect(notices, contains(font), reason: 'font $font thiếu ghi công');
      }
    });
  });
}
