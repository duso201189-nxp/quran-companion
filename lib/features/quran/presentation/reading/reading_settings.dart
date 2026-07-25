import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/prefs_provider.dart';
import '../../domain/entities/translation_source.dart';

/// Chế độ hiển thị trang đọc.
enum ReadingMode {
  /// Danh sách Ayah kèm các lớp dịch.
  list,

  /// Nguyên trang như Mushaf (hỗ trợ Hifz ghi nhớ vị trí).
  mushaf,
}

/// Cài đặt hiển thị của trang đọc — người dùng chỉnh một lần,
/// áp dụng mọi Surah, lưu bền qua các phiên.
///
/// Sprint 30.1 — LỚP VĂN BẢN KHOÁ THEO MÃ NGUỒN, không theo tên tính
/// năng. Ba cờ `showTransliteration` / `showVietnamese` / `showEnglish`
/// trước đây khoá cứng đúng ba nguồn: thêm một Tafsir (hoặc bản dịch
/// thứ hai) buộc phải thêm cờ thứ tư, khoá prefs thứ tư, sửa
/// `AyahCard` và sửa bảng cài đặt — mà vẫn KHÔNG hỗ trợ được NHIỀU
/// nguồn Tafsir. Xem `DR-2026-0006` quyết định D3.
class ReadingSettings {
  const ReadingSettings({
    this.arabicScale = 1.0,
    this.sourceVisibility = const <String, bool>{},
    this.mode = ReadingMode.list,
  });

  /// Hệ số cỡ chữ Ả Rập (0.8 – 1.6), nhân với cỡ gốc 28.
  final double arabicScale;

  /// Lựa chọn hiện/ẩn do NGƯỜI DÙNG đặt, khoá theo `TranslationSource.code`.
  ///
  /// Không có khoá = người dùng chưa từng chạm tới nguồn đó -> dùng
  /// [defaultVisibilityFor]. Phân biệt "đã tắt" với "chưa từng thấy"
  /// là điều kiện cần để một nguồn mới nhập vào có mặc định hợp lý mà
  /// không ghi đè lựa chọn cũ của người dùng.
  final Map<String, bool> sourceVisibility;

  final ReadingMode mode;

  static const double minScale = 0.8;
  static const double maxScale = 1.6;
  static const double baseArabicFontSize = 28;

  double get arabicFontSize => baseArabicFontSize * arabicScale;

  /// Mặc định cho nguồn người dùng chưa từng chạm tới — suy ra CHỈ TỪ
  /// [SourceType] và ngôn ngữ, đúng hợp đồng `DR-2026-0006` D3.
  ///
  /// - Phiên âm: bật (công cụ hỗ trợ đọc, không phụ thuộc ngôn ngữ).
  /// - Bản dịch: bật khi cùng ngôn ngữ với giao diện app. Quy tắc này
  ///   tái tạo CHÍNH XÁC mặc định cũ cho người dùng tiếng Việt (hiện
  ///   bản Việt, ẩn bản Anh) mà không cần biết mã nguồn nào.
  /// - Tafsir: tắt. Chú giải dài, không tự chen vào mạch đọc khi người
  ///   dùng chưa yêu cầu.
  static bool defaultVisibilityFor(
    SourceType type,
    String sourceLanguage,
    String appLanguage,
  ) {
    return switch (type) {
      SourceType.transliteration => true,
      SourceType.translation => sourceLanguage == appLanguage,
      SourceType.tafsir => false,
    };
  }

  /// Nguồn này có được hiển thị không, với ngôn ngữ giao diện hiện tại.
  bool isSourceVisible(TranslationSource source, String appLanguage) {
    return sourceVisibility[source.code] ??
        defaultVisibilityFor(source.type, source.language, appLanguage);
  }

  ReadingSettings copyWith({
    double? arabicScale,
    Map<String, bool>? sourceVisibility,
    ReadingMode? mode,
  }) {
    return ReadingSettings(
      arabicScale: arabicScale ?? this.arabicScale,
      sourceVisibility: sourceVisibility ?? this.sourceVisibility,
      mode: mode ?? this.mode,
    );
  }
}

class ReadingSettingsController extends Notifier<ReadingSettings> {
  static const _kScale = 'reading.arabic_scale';
  static const _kMode = 'reading.mode';

  /// Khoá mới: toàn bộ lựa chọn hiện/ẩn trong MỘT mục JSON.
  static const String kSourceVisibilityKey = 'reading.source_visibility';

  /// Khoá cũ (Sprint ≤ 30.0). CHỈ dùng để di trú và CỐ Ý KHÔNG XOÁ —
  /// xem [_migrateLegacyVisibility].
  static const String kLegacyTranslitKey = 'reading.show_transliteration';
  static const String kLegacyVietnameseKey = 'reading.show_vietnamese';
  static const String kLegacyEnglishKey = 'reading.show_english';

  /// Mã nguồn tương ứng ba cờ cũ. Bản đồ này là TOÀN BỘ phần "biết tên
  /// nguồn" còn lại trong mã, và nó nằm đúng chỗ nên nằm: bên trong
  /// hàm di trú. Đường dựng giao diện không còn biết mã nguồn nào.
  static const Map<String, String> _legacyKeyToSourceCode = {
    kLegacyTranslitKey: 'translit_latin',
    kLegacyVietnameseKey: 'vi_main',
    kLegacyEnglishKey: 'en_sahih',
  };

  /// Giá trị mặc định CŨ, giữ nguyên từng cờ — nhờ vậy máy cài mới
  /// (chưa có khoá nào) vẫn ra đúng cấu hình trước đây: phiên âm bật,
  /// bản Việt bật, bản Anh tắt.
  static const Map<String, bool> _legacyDefaults = {
    kLegacyTranslitKey: true,
    kLegacyVietnameseKey: true,
    kLegacyEnglishKey: false,
  };

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
      sourceVisibility: _readVisibility(prefs),
      mode: ReadingMode.values.asNameMap()[prefs.getString(_kMode)] ??
          ReadingMode.list,
    );
  }

  /// Đọc lựa chọn hiện/ẩn, di trú từ định dạng cũ nếu cần.
  Map<String, bool> _readVisibility(SharedPreferences prefs) {
    final stored = prefs.getString(kSourceVisibilityKey);
    if (stored != null) {
      final decoded = _decode(stored);
      if (decoded != null) return decoded;
      // Chuỗi hỏng (sửa tay, ghi lỗi) -> rơi xuống di trú, không ném.
    }
    final migrated = _migrateLegacyVisibility(prefs);
    // Ghi MỘT LẦN: lần chạy sau đã có khoá mới nên không vào lại nhánh
    // này. Không `await` trong `build()` — SharedPreferences có bộ nhớ
    // đệm đồng bộ nên giá trị đọc lại được ngay, ghi đĩa chạy nền.
    unawaited(prefs.setString(kSourceVisibilityKey, jsonEncode(migrated)));
    return migrated;
  }

  /// Chuyển ba cờ cũ thành bản đồ theo mã nguồn.
  ///
  /// CỐ Ý KHÔNG XOÁ ba khoá cũ: (1) hạ cấp về bản app trước vẫn đọc
  /// đúng lựa chọn của người dùng — không mất dữ liệu; (2) di trú trở
  /// thành thao tác CHỈ-THÊM, không thể hỏng giữa chừng. Ba khoá đó từ
  /// nay là dữ liệu chết vô hại.
  Map<String, bool> _migrateLegacyVisibility(SharedPreferences prefs) {
    final result = <String, bool>{};
    for (final entry in _legacyKeyToSourceCode.entries) {
      result[entry.value] =
          prefs.getBool(entry.key) ?? _legacyDefaults[entry.key]!;
    }
    return result;
  }

  static Map<String, bool>? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is bool)
            entry.key as String: entry.value as bool,
      };
    } on FormatException {
      return null;
    }
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

  /// Bật/tắt một lớp văn bản theo MÃ NGUỒN.
  ///
  /// Một hàm duy nhất thay cho ba hàm `setShowX` cũ: thêm nguồn mới
  /// không phát sinh phương thức nào.
  Future<void> setSourceVisible(String sourceCode, bool visible) async {
    final next = Map<String, bool>.from(state.sourceVisibility)
      ..[sourceCode] = visible;
    state = state.copyWith(sourceVisibility: next);
    await ref
        .read(sharedPreferencesProvider)
        .setString(kSourceVisibilityKey, jsonEncode(next));
  }
}

final readingSettingsProvider =
    NotifierProvider<ReadingSettingsController, ReadingSettings>(
  ReadingSettingsController.new,
);
