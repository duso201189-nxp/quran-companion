import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bộ lưu trữ key-value cục bộ, dùng chung toàn app
/// (theme, ngôn ngữ, cài đặt hiển thị...).
///
/// Được override trong main.dart với instance thật.
/// Test override bằng SharedPreferences.setMockInitialValues.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider phải được override trong main.dart',
  ),
);
