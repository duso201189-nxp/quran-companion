import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection.dart';
import 'user_database.dart';

final userDatabaseProvider = Provider<UserDatabase>((ref) {
  final db = UserDatabase(openUserConnection());
  ref.onDispose(db.close);
  return db;
});
