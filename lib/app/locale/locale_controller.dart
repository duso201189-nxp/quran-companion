import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/prefs_provider.dart';

/// Quản lý ngôn ngữ hiển thị của app.
///
/// Ngôn ngữ chính là tiếng Việt (mặc định).
/// Hỗ trợ: vi · en · ar. Tiếng Ả Rập tự động bật bố cục RTL
/// nhờ cơ chế Directionality có sẵn của Flutter.
class LocaleController extends Notifier<Locale> {
  static const String prefsKey = 'settings.locale';
  static const List<String> supportedCodes = ['vi', 'en', 'ar'];
  static const String defaultCode = 'vi';

  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(prefsKey);
    final code = supportedCodes.contains(saved) ? saved! : defaultCode;
    return Locale(code);
  }

  Future<void> setLanguage(String code) async {
    if (!supportedCodes.contains(code)) return; // bỏ qua mã không hợp lệ
    state = Locale(code);
    await ref.read(sharedPreferencesProvider).setString(prefsKey, code);
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
