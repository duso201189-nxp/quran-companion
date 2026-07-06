import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database_constants.dart';

/// Mở database nội dung trên Web (drift WASM).
///
/// YÊU CẦU RUNTIME: 2 file phải nằm trong thư mục web/ của project
/// (hướng dẫn tải trong docs/DATA_PIPELINE.md):
///   - sqlite3.wasm   (từ package sqlite3.dart releases)
///   - drift_worker.js (từ drift releases)
///
/// Lần đầu mở, drift gọi [initializeDatabase] để nạp nội dung từ
/// asset vào bộ nhớ trình duyệt (OPFS/IndexedDB) — các lần sau mở
/// trực tiếp, không nạp lại.
QueryExecutor openContentConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'quran_content_v${DatabaseConstants.expectedDataVersion}',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
        initializeDatabase: () async {
          final data =
              await rootBundle.load(DatabaseConstants.contentAssetPath);
          return data.buffer.asUint8List();
        },
      );
      return result.resolvedExecutor;
    }),
  );
}
