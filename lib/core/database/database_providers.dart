import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'connection/connection.dart';

/// Database nội dung Qur'an — mở lazy: truy vấn đầu tiên mới chạm
/// tới file (không chặn khởi động app).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openContentConnection());
  ref.onDispose(db.close);
  return db;
});
