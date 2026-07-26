import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/covering_text.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_settings.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint 30.1 — bài kiểm QUAN TRỌNG NHẤT của sprint: một nguồn Tafsir
/// mà KHÔNG dòng mã nào trong `lib/` biết tên vẫn hiển thị đúng chỗ,
/// đúng thứ tự và đúng hướng chữ, chỉ nhờ metadata của nó.
///
/// Tách khỏi `reading_source_model_test.dart` vì trộn `test()` dùng
/// `pumpEventQueue` với `testWidgets()` trong cùng một tệp làm binding
/// treo — các bài kiểm thuần logic ở tệp kia, dựng giao diện ở đây.

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

/// Nguồn KHÔNG hề tồn tại khi Sprint 30.1 được viết — một BẢN DỊCH
/// tiếng Ả Rập. Đây là ví dụ hợp lệ cho "thêm nguồn không sửa mã":
/// nó thuộc đường đọc và viết RTL.
const _arTranslation = TranslationSource(
  id: 4,
  code: 'ar_tafsir_style',
  name: 'Ban dich tieng A Rap',
  language: 'ar',
  type: SourceType.translation,
  displayOrder: 4,
);

/// Nguồn Tafsir — Sprint 30.2 đặt nó NGOÀI đường đọc. Có mặt trong
/// danh mục và có văn bản cho Ayah, nhưng trang đọc phải bỏ qua.
const _tafsirAr = TranslationSource(
  id: 5,
  code: 'tafsir_muyassar',
  name: 'Tafsir Al-Muyassar',
  language: 'ar',
  type: SourceType.tafsir,
  displayOrder: 5,
);

Future<Widget> _app(Map<String, bool> visibility) async {
  SharedPreferences.setMockInitialValues({
    ReadingSettingsController.kSourceVisibilityKey: jsonEncode(visibility),
  });
  final sp = await SharedPreferences.getInstance();
  // KHÔNG `addTearDown(userDb.close)`: đóng database trong tear-down
  // trong khi các stream query của Drift còn sống làm test treo (đã
  // tái hiện). Cây widget bị hủy ngay trong thân test (xem
  // [_testRendering]) đã đủ để Drift dọn stream; database bộ nhớ tự
  // biến mất khi isolate kết thúc — cùng cách `reading_screen_test`
  // đang làm.
  final userDb = UserDatabase(NativeDatabase.memory());

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      quranRepositoryProvider.overrideWithValue(_FourSourceRepo()),
      userDatabaseProvider.overrideWithValue(userDb),
      ayahAudioPlayerProvider.overrideWithValue(FakeAyahAudioPlayer()),
    ],
    child: const MaterialApp(
      locale: Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReadingScreen(surahId: 1),
    ),
  );
}

/// Bọc `testWidgets`: LUÔN hủy cây trong thân test, kể cả khi phần
/// thân ném lỗi.
///
/// Drift đóng stream query bằng Timer(0) khi cây bị hủy; nếu để
/// binding tự dọn sau test sẽ dính "A Timer is still pending" — và
/// nếu một bài kiểm thất bại giữa chừng mà không dọn, database còn mở
/// khiến MỌI bài kiểm sau trong tệp treo (đã gặp thật khi viết sprint
/// này). Cùng khuôn với `_testReading` trong `reading_screen_test`.
void _testRendering(String description, WidgetTesterCallback body) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    }
  });
}

/// Bơm nhịp có giới hạn thay cho `pumpAndSettle`.
///
/// Cùng lý do đã ghi ở `sprint8_navigation_test` / `audio_mini_player_test`:
/// các StreamProvider của Drift luôn sống khiến heuristic "hết frame"
/// của `pumpAndSettle` không bao giờ thấy màn hình đứng yên, dù trên
/// thực tế nó đã ổn định sau vài nhịp.
Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  _testRendering(
      'nguồn Tafsir MỚI hiện đúng thứ tự display_order và đúng hướng chữ',
      (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      await _app(const {
        'translit_latin': true,
        'vi_main': true,
        'en_sahih': true,
        'ar_tafsir_style': true,
      }),
    );
    await settle(tester);

    // Cả bốn lớp ĐỌC có mặt — kể cả nguồn tiếng Ả Rập chưa từng được
    // nhắc tới trong bất kỳ widget nào.
    expect(find.text('translit mot'), findsOneWidget);
    expect(find.text('ban viet mot'), findsOneWidget);
    expect(find.text('english one'), findsOneWidget);
    expect(find.text('ترجمة عربية'), findsOneWidget);

    // Đúng thứ tự display_order, đo bằng vị trí dọc thật.
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('translit mot'), lessThan(top('ban viet mot')));
    expect(top('ban viet mot'), lessThan(top('english one')));
    expect(top('english one'), lessThan(top('ترجمة عربية')));

    // Nguồn tiếng Ả Rập vẽ RTL nhờ metadata ngôn ngữ.
    final arabic = tester.widget<Text>(find.text('ترجمة عربية'));
    expect(arabic.textDirection, TextDirection.rtl);
    expect(arabic.textAlign, TextAlign.right);
  });

  _testRendering(
      'RANH GIỚI: Tafsir KHÔNG bao giờ là lớp đọc, kể cả khi người '
      'dùng bật rõ ràng (Sprint 30.2)', (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      // Bật rõ ràng — nếu ranh giới chỉ nằm ở giá trị mặc định thì
      // dòng này đã đủ để chú giải lọt vào trang đọc.
      await _app(const {'tafsir_muyassar': true, 'vi_main': true}),
    );
    await settle(tester);

    expect(find.text('ban viet mot'), findsOneWidget);
    expect(find.text('تفسير الآية'), findsNothing);
  });

  _testRendering('nguồn bị tắt thì KHÔNG dựng, dù Ayah có văn bản',
      (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      await _app(const {'tafsir_muyassar': false, 'en_sahih': false}),
    );
    await settle(tester);

    expect(find.text('ban viet mot'), findsOneWidget);
    expect(find.text('english one'), findsNothing);
    expect(find.text('تفسير الآية'), findsNothing);
  });

  _testRendering('cỡ chữ lớn: mọi lớp vẫn dựng, không tràn khung',
      (tester) async {
    useTallViewport(tester);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: await _app(const {
          'translit_latin': true,
          'vi_main': true,
          'en_sahih': true,
          'ar_tafsir_style': true,
        }),
      ),
    );
    await settle(tester);

    expect(find.text('ban viet mot'), findsOneWidget);
    expect(find.text('ترجمة عربية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Repo giả có BỐN nguồn, nguồn thứ tư là Tafsir tiếng Ả Rập.
class _FourSourceRepo implements QuranRepository {
  static const _surah = Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai De',
    nameEn: 'The Opening',
    ayahCount: 1,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  );

  @override
  Future<List<TranslationSource>> getEnabledSources() async =>
      const [_translit, _vi, _en, _arTranslation, _tafsirAr];

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [
        AyahContent(
          ayah: Ayah(id: 1, surahId: 1, ayahNumber: 1, textUthmani: 'نص عربي'),
          texts: {
            'translit_latin': 'translit mot',
            'vi_main': 'ban viet mot',
            'en_sahih': 'english one',
            'ar_tafsir_style': 'ترجمة عربية',
            // Có văn bản Tafsir trong dữ liệu — trang đọc vẫn phải bỏ
            // qua (ranh giới Sprint 30.2).
            'tafsir_muyassar': 'تفسير الآية',
          },
        ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];
  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [];
  @override
  Future<String?> getMetaValue(String key) async => null;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];
  @override
  Future<List<CoveringText>> getTextsCoveringAyah({
    required int ayahId,
    required Set<SourceType> types,
  }) async =>
      const [];

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}
