import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/prefs_provider.dart';

/// Quản lý chế độ giao diện: Sáng / Tối / Theo hệ thống.
/// Tự động lưu lựa chọn và khôi phục khi mở lại app.
class ThemeController extends Notifier<ThemeMode> {
  static const String prefsKey = 'settings.theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.read(sharedPreferencesProvider).getString(prefsKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(prefsKey, mode.name);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
