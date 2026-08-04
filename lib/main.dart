import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/audio/ayah_audio_player.dart';
import 'core/audio/background_audio_support.dart';
import 'core/audio/just_audio_player.dart';
import 'core/audio/quran_audio_handler.dart';
import 'core/storage/prefs_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo bộ lưu trữ cài đặt cục bộ TRƯỚC frame đầu tiên
  // để theme và ngôn ngữ đã lưu áp dụng ngay, không bị nháy.
  // SharedPreferences rất nhẹ, không ảnh hưởng mục tiêu mở app < 2s.
  final prefs = await SharedPreferences.getInstance();

  // Trình phát là MỘT, dùng chung cho mọi nền tảng. Sprint B2 chỉ thêm
  // một lớp quan sát ở trên nó trên các nền tảng có phát nền.
  final player = JustAudioAyahPlayer();

  if (backgroundAudioSupported(
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  )) {
    // `AudioService.init` phải chạy TRƯỚC runApp: nó dựng cầu nối tới
    // service gốc, và nếu app được mở lại từ chính thông báo media thì
    // cầu nối đó phải sẵn sàng trước khung hình đầu tiên.
    //
    // Không giữ giá trị trả về: handler chỉ quan sát [player] rồi
    // chuyển tiếp nút bấm xuống chính nó. Ứng dụng vẫn nói chuyện với
    // [player] qua `ayahAudioPlayerProvider` như trước B2 — không có
    // đường ghi thứ hai vào trạng thái.
    await AudioService.init(
      builder: () => QuranAudioHandler(player),
      config: const AudioServiceConfig(
        // Tiền tố theo applicationId để không đụng kênh thông báo của
        // ứng dụng khác trên cùng máy.
        androidNotificationChannelId: 'com.duso.qurancompanion.audio',
        androidNotificationChannelName: 'Phát Qur\'an',
        // Thông báo phát Qur'an không phải tin nhắn — không kêu, không
        // rung, không hiện đè lên màn hình.
        androidNotificationChannelDescription:
            'Điều khiển phát Qur\'an khi ứng dụng chạy nền',
        // Đang phát -> thông báo không vuốt bỏ được, đúng yêu cầu của
        // foreground service; tạm dừng -> gỡ khỏi trạng thái foreground
        // để hệ điều hành được phép thu hồi tài nguyên.
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ayahAudioPlayerProvider.overrideWithValue(player),
      ],
      child: const QuranCompanionApp(),
    ),
  );
}
