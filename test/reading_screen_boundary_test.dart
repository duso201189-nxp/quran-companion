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
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/study/data/boundary_completion_store.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Al-Ikhlas (Surah 112) — **4 Ayah trong ấn bản đang ship**, khớp
/// `AyahOrdinal.ayahCounts[111]`. Phải dùng một Surah có số Ayah THẬT
/// khớp bảng hằng: `SurahCompletion` đọc bảng hằng, không đọc
/// `Surah.ayahCount` của repository giả — một Surah giả 2 Ayah sẽ
/// không bao giờ "xong" và bài kiểm sẽ xanh vì lý do sai.
const _surah = Surah(
  id: 112,
  nameArabic: 'الإخلاص',
  nameLatin: 'Al-Ikhlas',
  nameVi: 'Thuần Khiết',
  nameEn: 'Sincerity',
  ayahCount: 4,
  revelationPlace: RevelationPlace.mecca,
  orderRevealed: 22,
);

List<AyahContent> _ayahs() => [
      for (var n = 1; n <= 4; n++)
        AyahContent(
          ayah: Ayah(
            id: 6222 + n,
            surahId: 112,
            ayahNumber: n,
            textUthmani: 'نص $n',
            juz: 30,
          ),
          texts: {'vi_main': 'câu $n'},
        ),
    ];

class _FakeRepo implements QuranRepository {
  @override
  Future<Surah?> getSurahById(int id) async => id == 112 ? _surah : null;
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => _ayahs();
  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];
  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}

UserDatabase? _lastDb;
SharedPreferences? _lastPrefs;

Future<Widget> _app({int? resumeAtIndex}) async {
  SharedPreferences.setMockInitialValues({
    if (resumeAtIndex != null) ReadingPositionStore.posKey(112): resumeAtIndex,
  });
  final sp = await SharedPreferences.getInstance();
  _lastPrefs = sp;
  final db = UserDatabase(NativeDatabase.memory());
  _lastDb = db;
  return ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(_FakeRepo()),
      sharedPreferencesProvider.overrideWithValue(sp),
      ayahAudioPlayerProvider.overrideWithValue(FakeAyahAudioPlayer()),
      userDatabaseProvider.overrideWithValue(db),
    ],
    child: const MaterialApp(
      locale: Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReadingScreen(surahId: 112),
    ),
  );
}

/// Cùng vòng đời với `_testReading` trong `reading_screen_test.dart`:
/// huỷ cây NGAY TRONG thân test (dispose() mới chạy, mới có dấu để
/// kiểm), xả Timer(0) của Drift, rồi đóng database qua
/// `tester.runAsync` — `addTearDown` chạy sau khi callback đã return,
/// lúc đó `runAsync` treo vĩnh viễn.
void _testBoundary(String description, WidgetTesterCallback body) {
  testWidgets(description, (tester) async {
    // Màn hình cao để cả 4 Ayah ngắn cùng nằm trong khung nhìn —
    // "xa nhất đã hiện ra" mới lên tới Ayah cuối mà không cần cuộn.
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await body(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final db = _lastDb;
    _lastDb = null;
    if (db != null) {
      await tester.runAsync(db.close);
    }
  });
}

/// Để đồng hồ phiên chạy thật quá ngưỡng 5 giây của `dispose()`.
Future<void> _elapseValidSession(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 5200)),
  );
}

/// Huỷ cây ngay trong thân test rồi để các ghi `unawaited` của
/// `dispose()` chạy xong — không dùng timer/pump tuỳ tiện, chỉ nhường
/// một lượt cho vòng lặp sự kiện thật.
Future<void> _endSession(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
}

bool _marked() =>
    _lastPrefs!.getInt(BoundaryCompletionController.surahKey(112)) != null;

int? _pending() => _lastPrefs!.getInt(BoundaryCompletionController.pendingKey);

void main() {
  _testBoundary(
      'mở THẲNG Ayah cuối (Tìm kiếm/Thư viện/Hàng đợi ôn tập đã lưu vị '
      'trí trước) rồi ngồi yên -> KHÔNG đánh dấu đọc trọn: 5 giây chứng '
      'minh phiên có thật, không chứng minh vừa đọc qua Ayah cuối',
      (tester) async {
    // Al-Ikhlas 4 Ayah -> chỉ số cuối là 3.
    await tester.pumpWidget(await _app(resumeAtIndex: 3));
    await tester.pumpAndSettle();

    await _elapseValidSession(tester);
    await _endSession(tester);

    expect(_marked(), isFalse);
    expect(_pending(), isNull);
  });

  _testBoundary(
      'đi từ đầu tới Ayah cuối TRONG phiên này -> CÓ đánh dấu đọc trọn',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await _elapseValidSession(tester);
    await _endSession(tester);

    expect(_marked(), isTrue);
    expect(_pending(), 112);
  });

  _testBoundary('phiên ngắn hơn 5 giây -> KHÔNG đánh dấu, dù đã thấy Ayah cuối',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    // Không để đồng hồ chạy quá ngưỡng.
    await _endSession(tester);

    expect(_marked(), isFalse);
  });

  _testBoundary(
      'đọc dở (khung nhìn nhỏ, chưa thấy Ayah cuối) -> KHÔNG đánh dấu',
      (tester) async {
    // Khung nhìn thấp: Ayah cuối không lọt vào, mốc xa nhất không tới 3.
    tester.view.physicalSize = const Size(400, 260);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await _elapseValidSession(tester);
    await _endSession(tester);

    expect(_marked(), isFalse);
  });

  _testBoundary(
      'quay lại Ayah đầu SAU khi đã thấy Ayah cuối -> vẫn tính là đọc '
      'trọn (mốc xa nhất chỉ tăng, không giảm)', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    // Thu nhỏ khung nhìn lại như thể người dùng cuộn ngược lên đầu:
    // chỉ còn Ayah đầu trong tầm nhìn.
    tester.view.physicalSize = const Size(400, 260);
    await tester.pumpAndSettle();

    await _elapseValidSession(tester);
    await _endSession(tester);

    expect(_marked(), isTrue);
  });

  _testBoundary(
      'ghi phiên đọc hiện có KHÔNG đổi: study_sessions vẫn nhận đúng '
      'ayah_from/ayah_to cũ (vị trí trên cùng), không phải mốc xa nhất',
      (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await _elapseValidSession(tester);
    await _endSession(tester);

    final rows = await _lastDb!.select(_lastDb!.studySessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.surahId, 112);
    // ayah_to là Ayah TRÊN CÙNG (0), KHÔNG phải Ayah cuối (3) — Sprint
    // 7.4 không được đổi ngữ nghĩa cột này.
    expect(rows.single.ayahFrom, 0);
    expect(rows.single.ayahTo, 0);
  });
}
