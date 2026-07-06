import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database_constants.dart';

/// Đảm bảo file nội dung đã có mặt và đúng phiên bản trong [dir], trả
/// về [File] đích. Tách khỏi [openContentConnection] để logic copy
/// atomic test được độc lập, không cần mở NativeDatabase/isolate thật.
@visibleForTesting
Future<File> ensureContentFileCopied(Directory dir) async {
  final file = File(p.join(dir.path, DatabaseConstants.contentFileName));
  final versionMarker = File('${file.path}.version');

  final installedVersion = versionMarker.existsSync()
      ? (await versionMarker.readAsString()).trim()
      : null;
  final needsCopy = !file.existsSync() ||
      installedVersion != DatabaseConstants.expectedDataVersion;

  if (needsCopy) {
    // Không có API stream cho asset đóng gói của Flutter — rootBundle
    // luôn nạp nguyên file vào bộ nhớ dạng ByteData, dù file lớn.
    final data = await rootBundle.load(DatabaseConstants.contentAssetPath);
    // Ghi file tạm rồi đổi tên (atomic): nếu tiến trình bị ngắt giữa
    // chừng (crash, mất điện), file đích vẫn nguyên vẹn — không bao
    // giờ để lại 1 quran.sqlite chép dở bị nhận nhầm là hợp lệ.
    final tempFile = File('${file.path}.tmp');
    await tempFile.create(recursive: true);
    await tempFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    await tempFile.rename(file.path);
    await versionMarker.writeAsString(
      DatabaseConstants.expectedDataVersion,
      flush: true,
    );
  }

  return file;
}

/// Mở database nội dung trên Android/iOS/desktop.
///
/// LazyDatabase: việc copy asset chỉ xảy ra khi truy vấn ĐẦU TIÊN
/// chạm tới database — không chặn khởi động app (mục tiêu mở < 2s).
///
/// File `.version` cạnh database ghi phiên bản dữ liệu đã cài;
/// khác với [DatabaseConstants.expectedDataVersion] -> chép đè bản
/// mới (cơ chế cập nhật nội dung không cần migration).
QueryExecutor openContentConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = await ensureContentFileCopied(dir);

    // createInBackground: chạy SQLite trên isolate riêng,
    // giữ UI thread mượt khi truy vấn nặng.
    return NativeDatabase.createInBackground(file);
  });
}
