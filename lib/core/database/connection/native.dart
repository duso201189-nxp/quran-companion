import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database_constants.dart';

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
    final file = File(p.join(dir.path, DatabaseConstants.contentFileName));
    final versionMarker = File('${file.path}.version');

    final installedVersion = await versionMarker.exists()
        ? (await versionMarker.readAsString()).trim()
        : null;
    final needsCopy = !await file.exists() ||
        installedVersion != DatabaseConstants.expectedDataVersion;

    if (needsCopy) {
      final data = await rootBundle.load(DatabaseConstants.contentAssetPath);
      await file.create(recursive: true);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      await versionMarker.writeAsString(
        DatabaseConstants.expectedDataVersion,
        flush: true,
      );
    }

    // createInBackground: chạy SQLite trên isolate riêng,
    // giữ UI thread mượt khi truy vấn nặng.
    return NativeDatabase.createInBackground(file);
  });
}
