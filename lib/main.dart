import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/audio/ayah_audio_player.dart';
import 'core/audio/just_audio_player.dart';
import 'core/storage/prefs_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo bộ lưu trữ cài đặt cục bộ TRƯỚC frame đầu tiên
  // để theme và ngôn ngữ đã lưu áp dụng ngay, không bị nháy.
  // SharedPreferences rất nhẹ, không ảnh hưởng mục tiêu mở app < 2s.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ayahAudioPlayerProvider.overrideWithValue(JustAudioAyahPlayer()),
      ],
      child: const QuranCompanionApp(),
    ),
  );
}
