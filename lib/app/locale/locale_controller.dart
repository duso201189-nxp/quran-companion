import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/prefs_provider.dart';

/// Quản lý ngôn ngữ hiển thị của app.
///
/// Hỗ trợ: vi · en · ar. Tiếng Ả Rập tự động bật bố cục RTL
/// nhờ cơ chế Directionality có sẵn của Flutter.
///
/// Sprint 5.1 — thứ tự chọn ngôn ngữ lúc [build]: (1) người dùng đã
/// từng chọn -> dùng lại đúng lựa chọn đó, không bao giờ ghi đè; (2)
/// chưa từng chọn -> thử ngôn ngữ thiết bị, nếu nằm trong
/// [supportedCodes]; (3) thiết bị dùng ngôn ngữ khác -> [defaultCode]
/// (tiếng Việt) là phương án cuối cùng, không phải mặc định đầu tiên.
class LocaleController extends Notifier<Locale> {
  static const String prefsKey = 'settings.locale';
  static const List<String> supportedCodes = ['vi', 'en', 'ar'];
  static const String defaultCode = 'vi';

  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(prefsKey);
    if (saved != null && supportedCodes.contains(saved)) {
      return Locale(saved);
    }

    // Chưa từng chọn -> thử ngôn ngữ thiết bị trước khi rơi về
    // defaultCode. Đọc qua WidgetsBinding.instance.platformDispatcher
    // (không phải PlatformDispatcher.instance trực tiếp): đây là điểm
    // Flutter cố ý dựng để test ghi đè được (TestPlatformDispatcher).
    // Đọc thẳng singleton dart:ui vẫn đúng lúc chạy thật nhưng không
    // test được — WidgetsBinding đã sẵn sàng ở đây vì main.dart gọi
    // WidgetsFlutterBinding.ensureInitialized() trước runApp, và
    // provider chỉ build() sau khi cây widget đã dựng.
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final code = supportedCodes.contains(deviceCode) ? deviceCode : defaultCode;
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
