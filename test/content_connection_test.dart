// Kiểm tra ensureContentFileCopied() (lib/core/database/connection/native.dart)
// — đường copy asset lần đầu phải atomic: không bao giờ để lại file đích
// bị chép dở, dùng file .tmp rồi đổi tên. Test này chưa từng tồn tại
// trước đây (connection.dart trước giờ chỉ được test gián tiếp qua
// AppDatabase(NativeDatabase(assetFile)) — bỏ qua hẳn logic copy asset).
//
// Test qua ensureContentFileCopied trực tiếp (không mở NativeDatabase
// thật): NativeDatabase.createInBackground spawn isolate riêng, treo
// vĩnh viễn nếu gọi trong flutter_test's testWidgets — đã xác nhận
// bằng debug print (in "db created" nhưng không bao giờ in "query
// done"). rootBundle.load() một mình thì chạy bình thường trong
// testWidgets (xác nhận riêng) — vấn đề nằm ở isolate, không phải
// asset loading, nên tách hàm để test đúng phần logic đã sửa mà không
// đụng tới isolate.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/connection/native.dart';
import 'package:quran_companion/core/database/database_constants.dart';

void main() {
  // rootBundle cần binding đã khởi tạo để đọc asset, nhưng bài test
  // không đụng tới widget nào — dùng test() thường + init binding thủ
  // công thay vì testWidgets(), vì testWidgets() treo vĩnh viễn ở
  // đúng bước ghi file (đã xác nhận bằng debug print: in xong
  // "after rootBundle.load" nhưng không bao giờ in bước kế tiếp,
  // dù CPU idle — có gì đó trong vòng đời pump/frame của testWidgets
  // không hợp với 1 Future dài không pump kèm theo).
  TestWidgetsFlutterBinding.ensureInitialized();

  final assetExists = File(DatabaseConstants.contentAssetPath).existsSync();
  // assets/database/quran.sqlite chưa build -> bỏ qua (chạy
  // tool/build_quran_db.py trước để tạo file).
  final skip = !assetExists;

  group('ensureContentFileCopied — copy asset atomic', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('quran_content_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'chép atomic: file đích đầy đủ, không còn file .tmp sót lại',
      () async {
        final file = await ensureContentFileCopied(tempDir);

        final tempFile = File('${file.path}.tmp');
        final versionMarker = File('${file.path}.version');

        expect(file.existsSync(), isTrue);
        expect(tempFile.existsSync(), isFalse);
        expect(file.lengthSync(), greaterThan(0));
        expect(versionMarker.existsSync(), isTrue);
        expect(
          versionMarker.readAsStringSync().trim(),
          DatabaseConstants.expectedDataVersion,
        );
      },
      skip: skip,
    );

    test(
      'lần gọi thứ 2 (version khớp) không copy lại',
      () async {
        final file1 = await ensureContentFileCopied(tempDir);
        final firstCopyModified = file1.lastModifiedSync();

        final file2 = await ensureContentFileCopied(tempDir);

        expect(file2.path, file1.path);
        expect(file2.lastModifiedSync(), firstCopyModified);
      },
      skip: skip,
    );

    test(
      'version marker cũ -> copy lại đè bản mới',
      () async {
        final file = await ensureContentFileCopied(tempDir);
        final versionMarker = File('${file.path}.version');
        versionMarker.writeAsStringSync('0');

        final reCopied = await ensureContentFileCopied(tempDir);

        expect(
          versionMarker.readAsStringSync().trim(),
          DatabaseConstants.expectedDataVersion,
        );
        expect(reCopied.existsSync(), isTrue);
        expect(File('${reCopied.path}.tmp').existsSync(), isFalse);
      },
      skip: skip,
    );
  });
}
