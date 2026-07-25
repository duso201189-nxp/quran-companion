import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_settings.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_source_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 30.1 — mô hình nguồn văn bản KHOÁ THEO DỮ LIỆU.
///
/// Bài kiểm quan trọng nhất của cả sprint là bài cuối: một nguồn
/// Tafsir mà KHÔNG dòng mã nào trong `lib/` biết tên vẫn hiển thị
/// đúng chỗ, đúng thứ tự, đúng hướng chữ.

// ---------------------------------------------------------------
// Nguồn dùng chung cho các bài kiểm
// ---------------------------------------------------------------

const _translit = TranslationSource(
  id: 1,
  code: 'translit_latin',
  name: 'Phien am Latin',
  language: 'en',
  type: SourceType.transliteration,
  displayOrder: 1,
);
const _vi = TranslationSource(
  id: 2,
  code: 'vi_main',
  name: 'Ban dich tieng Viet',
  language: 'vi',
  type: SourceType.translation,
  displayOrder: 2,
);
const _en = TranslationSource(
  id: 3,
  code: 'en_sahih',
  name: 'English',
  language: 'en',
  type: SourceType.translation,
  displayOrder: 3,
);

/// Nguồn KHÔNG hề tồn tại khi Sprint 30.1 được viết — đại diện cho
/// "một Tafsir nhập vào sau này".
const _tafsirAr = TranslationSource(
  id: 4,
  code: 'tafsir_muyassar',
  name: 'Tafsir Al-Muyassar',
  language: 'ar',
  type: SourceType.tafsir,
  displayOrder: 4,
);

final _scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F5E));

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
  addTearDown(c.dispose);
  return c;
}

String? _storedVisibility(ProviderContainer c) => c
    .read(sharedPreferencesProvider)
    .getString(ReadingSettingsController.kSourceVisibilityKey);

void main() {
  // -------------------------------------------------------------
  // Di trú tuỳ chọn
  // -------------------------------------------------------------
  group('Di trú tuỳ chọn hiển thị', () {
    test('ba cờ cũ được giữ NGUYÊN Ý NGHĨA sau khi đổi mô hình', () async {
      // Người dùng cũ: tắt phiên âm, bật cả hai bản dịch.
      final c = await _container(
        prefs: {
          ReadingSettingsController.kLegacyTranslitKey: false,
          ReadingSettingsController.kLegacyVietnameseKey: true,
          ReadingSettingsController.kLegacyEnglishKey: true,
        },
      );

      final s = c.read(readingSettingsProvider);
      expect(s.isSourceVisible(_translit, 'vi'), isFalse);
      expect(s.isSourceVisible(_vi, 'vi'), isTrue);
      expect(s.isSourceVisible(_en, 'vi'), isTrue);
    });

    test('máy chưa từng cài đặt gì -> đúng mặc định cũ (Anh tắt)', () async {
      final c = await _container();

      final s = c.read(readingSettingsProvider);
      expect(s.isSourceVisible(_translit, 'vi'), isTrue);
      expect(s.isSourceVisible(_vi, 'vi'), isTrue);
      expect(s.isSourceVisible(_en, 'vi'), isFalse);
    });

    test('di trú GHI khoá mới đúng một lần', () async {
      final c = await _container(
        prefs: {ReadingSettingsController.kLegacyEnglishKey: true},
      );

      c.read(readingSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      final decoded = jsonDecode(_storedVisibility(c)!) as Map<String, dynamic>;
      expect(decoded['translit_latin'], isTrue);
      expect(decoded['vi_main'], isTrue);
      expect(decoded['en_sahih'], isTrue);
    });

    test('KHÔNG xoá khoá cũ — hạ cấp app vẫn đọc được lựa chọn', () async {
      final c = await _container(
        prefs: {ReadingSettingsController.kLegacyEnglishKey: true},
      );

      c.read(readingSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      final prefs = c.read(sharedPreferencesProvider);
      expect(
        prefs.getBool(ReadingSettingsController.kLegacyEnglishKey),
        isTrue,
      );
    });

    test('đã có khoá mới -> KHÔNG di trú lại, cờ cũ bị bỏ qua', () async {
      final c = await _container(
        prefs: {
          ReadingSettingsController.kSourceVisibilityKey:
              jsonEncode({'en_sahih': false}),
          // Cờ cũ nói ngược lại: bản mới phải thắng.
          ReadingSettingsController.kLegacyEnglishKey: true,
        },
      );

      expect(
        c.read(readingSettingsProvider).isSourceVisible(_en, 'vi'),
        isFalse,
      );
    });

    test('chuỗi lưu hỏng -> quay về di trú, không ném lỗi', () async {
      final c = await _container(
        prefs: {
          ReadingSettingsController.kSourceVisibilityKey: 'khong-phai-json',
          ReadingSettingsController.kLegacyEnglishKey: true,
        },
      );

      expect(
        c.read(readingSettingsProvider).isSourceVisible(_en, 'vi'),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------
  // Mặc định cho nguồn MỚI (chưa từng có trong prefs)
  // -------------------------------------------------------------
  group('Mặc định suy ra từ SourceType + ngôn ngữ', () {
    test('Tafsir mặc định TẮT; bản dịch cùng ngôn ngữ app mặc định BẬT',
        () async {
      final c = await _container();
      final s = c.read(readingSettingsProvider);

      expect(s.isSourceVisible(_tafsirAr, 'vi'), isFalse);

      const viTafsir = TranslationSource(
        id: 9,
        code: 'tafsir_vi',
        name: 'Tafsir tieng Viet',
        language: 'vi',
        type: SourceType.tafsir,
        displayOrder: 9,
      );
      expect(s.isSourceVisible(viTafsir, 'vi'), isFalse);

      const secondVi = TranslationSource(
        id: 10,
        code: 'vi_second',
        name: 'Ban dich tieng Viet thu hai',
        language: 'vi',
        type: SourceType.translation,
        displayOrder: 10,
      );
      expect(s.isSourceVisible(secondVi, 'vi'), isTrue);
      expect(s.isSourceVisible(secondVi, 'en'), isFalse);
    });

    test('lựa chọn của người dùng thắng mặc định', () async {
      final c = await _container();
      await c
          .read(readingSettingsProvider.notifier)
          .setSourceVisible(_tafsirAr.code, true);

      expect(
        c.read(readingSettingsProvider).isSourceVisible(_tafsirAr, 'vi'),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------
  // Hướng chữ suy ra từ ngôn ngữ (RTL)
  // -------------------------------------------------------------
  group('Hướng chữ theo ngôn ngữ', () {
    test('entity: chỉ ngôn ngữ RTL mới là RTL', () {
      expect(_tafsirAr.isRtl, isTrue);
      expect(_vi.isRtl, isFalse);
      expect(_en.isRtl, isFalse);
    });

    test('nguồn tiếng Ả Rập -> RTL + căn phải; tiếng Việt -> LTR', () {
      final ar = readingLayerStyle(
        source: _tafsirAr,
        scheme: _scheme,
        appLanguage: 'vi',
      );
      expect(ar.textDirection, TextDirection.rtl);
      expect(ar.textAlign, TextAlign.right);

      final vi = readingLayerStyle(
        source: _vi,
        scheme: _scheme,
        appLanguage: 'vi',
      );
      expect(vi.textDirection, TextDirection.ltr);
      expect(vi.textAlign, TextAlign.left);
    });

    test('bản dịch cùng ngôn ngữ app to hơn bản đối chiếu', () {
      final primary =
          readingLayerStyle(source: _vi, scheme: _scheme, appLanguage: 'vi');
      final secondary =
          readingLayerStyle(source: _en, scheme: _scheme, appLanguage: 'vi');

      expect(primary.textStyle.fontSize, 18);
      expect(secondary.textStyle.fontSize, 16);
    });
  });
}
