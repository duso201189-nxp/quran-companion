import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/prefs_provider.dart';

/// Chế độ hiển thị trang đọc.
enum ReadingMode {
  /// Danh sách Ayah kèm các lớp dịch.
  list,

  /// Nguyên trang như Mushaf (hỗ trợ Hifz ghi nhớ vị trí).
  mushaf,
}

/// Cài đặt hiển thị của trang đọc — người dùng chỉnh một lần,
/// áp dụng mọi Surah, lưu bền qua các phiên.
class ReadingSettings {
  const ReadingSettings({
    this.arabicScale = 1.0,
    this.showTransliteration = true,
    this.showVietnamese = true,
    this.showEnglish = false,
    this.mode = ReadingMode.list,
  });

  /// Hệ số cỡ chữ Ả Rập (0.8 – 1.6), nhân với cỡ gốc 28.
  final double arabicScale;
  final bool showTransliteration;
  final bool showVietnamese;
  final bool showEnglish;
  final ReadingMode mode;

  static const double minScale = 0.8;
  static const double maxScale = 1.6;
  static const double baseArabicFontSize = 28;

  double get arabicFontSize => baseArabicFontSize * arabicScale;

  ReadingSettings copyWith({
    double? arabicScale,
    bool? showTransliteration,
    bool? showVietnamese,
    bool? showEnglish,
    ReadingMode? mode,
  }) {
    return ReadingSettings(
      arabicScale: arabicScale ?? this.arabicScale,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showVietnamese: showVietnamese ?? this.showVietnamese,
      showEnglish: showEnglish ?? this.showEnglish,
      mode: mode ?? this.mode,
    );
  }
}

class ReadingSettingsController extends Notifier<ReadingSettings> {
  static const _kScale = 'reading.arabic_scale';
  static const _kTranslit = 'reading.show_transliteration';
  static const _kVi = 'reading.show_vietnamese';
  static const _kEn = 'reading.show_english';
  static const _kMode = 'reading.mode';

  @override
  ReadingSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final rawScale = prefs.getDouble(_kScale) ?? 1.0;
    return ReadingSettings(
      // clamp: giá trị lưu hỏng không thể phá layout
      arabicScale: rawScale.clamp(
        ReadingSettings.minScale,
        ReadingSettings.maxScale,
      ),
      showTransliteration: prefs.getBool(_kTranslit) ?? true,
      showVietnamese: prefs.getBool(_kVi) ?? true,
      showEnglish: prefs.getBool(_kEn) ?? false,
      mode: ReadingMode.values.asNameMap()[prefs.getString(_kMode)] ??
          ReadingMode.list,
    );
  }

  Future<void> setArabicScale(double scale) async {
    final clamped = scale.clamp(
      ReadingSettings.minScale,
      ReadingSettings.maxScale,
    );
    state = state.copyWith(arabicScale: clamped);
    await ref.read(sharedPreferencesProvider).setDouble(_kScale, clamped);
  }

  /// Pinch-zoom: cập nhật LIVE khi đang kéo (chỉ state, không ghi
  /// đĩa — tránh hàng trăm lần ghi prefs mỗi giây).
  void previewArabicScale(double scale) {
    state = state.copyWith(
      arabicScale: scale.clamp(
        ReadingSettings.minScale,
        ReadingSettings.maxScale,
      ),
    );
  }

  /// Pinch-zoom: nhấc tay -> ghi giá trị cuối xuống đĩa.
  Future<void> commitArabicScale() =>
      ref.read(sharedPreferencesProvider).setDouble(
            _kScale,
            state.arabicScale,
          );

  Future<void> setMode(ReadingMode mode) async {
    state = state.copyWith(mode: mode);
    await ref.read(sharedPreferencesProvider).setString(_kMode, mode.name);
  }

  Future<void> setShowTransliteration(bool value) async {
    state = state.copyWith(showTransliteration: value);
    await ref.read(sharedPreferencesProvider).setBool(_kTranslit, value);
  }

  Future<void> setShowVietnamese(bool value) async {
    state = state.copyWith(showVietnamese: value);
    await ref.read(sharedPreferencesProvider).setBool(_kVi, value);
  }

  Future<void> setShowEnglish(bool value) async {
    state = state.copyWith(showEnglish: value);
    await ref.read(sharedPreferencesProvider).setBool(_kEn, value);
  }
}

final readingSettingsProvider =
    NotifierProvider<ReadingSettingsController, ReadingSettings>(
  ReadingSettingsController.new,
);
