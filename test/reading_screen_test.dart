import 'package:drift/drift.dart' show driftRuntimeOptions;
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
import 'package:quran_companion/features/quran/presentation/annotations/ayah_actions_sheet.dart';
import 'package:quran_companion/features/quran/presentation/reading/jump_to_ayah_sheet.dart';
import 'package:quran_companion/features/quran/presentation/reading/mushaf_builder.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_progress_indicator.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_settings.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_settings_sheet.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:quran_companion/features/stats/domain/entities/study_session.dart';
import 'package:quran_companion/features/stats/domain/repositories/study_session_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Ghi lại mọi lời gọi logSession — dùng để xác nhận Sprint 8 Phase
/// 5 (tích hợp) gọi đúng repository với đúng tham số khi kết thúc
/// phiên đọc, không cần chạm tới database thật.
class _SpyStudySessionRepository implements StudySessionRepository {
  final List<StudySession> logged = [];

  @override
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  }) async {
    final id = 'spy-${logged.length}';
    logged.add(
      StudySession(
        id: id,
        date: date,
        surahId: surahId,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        durationSec: durationSec,
        note: note,
        createdAt: 0,
      ),
    );
    return id;
  }

  @override
  Stream<List<StudySession>> watchAllSessions() => throw UnimplementedError();
  @override
  Stream<List<StudySession>> watchSessionsOnDate(String date) =>
      throw UnimplementedError();
  @override
  Future<int> totalDurationOnDate(String date) => throw UnimplementedError();
  @override
  Future<Set<String>> distinctReadingDates() => throw UnimplementedError();
  @override
  Future<int> currentStreak({DateTime? today}) => throw UnimplementedError();
  @override
  Future<int> longestStreak() => throw UnimplementedError();
}

Surah _surahWith(int ayahCount) => Surah(
      id: 1,
      nameArabic: 'الفاتحة',
      nameLatin: 'Al-Fatihah',
      nameVi: 'Khai Đề',
      nameEn: 'The Opening',
      ayahCount: ayahCount,
      revelationPlace: RevelationPlace.mecca,
      orderRevealed: 5,
    );

/// Ayah 1 & 2 giữ NGUYÊN nội dung cũ — nhiều test hiện có khẳng định
/// đúng các chuỗi này. Từ Ayah 3 trở đi sinh thêm, chỉ dùng cho test
/// cần danh sách đủ dài để cuộn thật (Sprint 25.1 — Chuyển tới Ayah).
List<AyahContent> _ayahs(int count) => [
      for (var i = 1; i <= count; i++)
        AyahContent(
          ayah: Ayah(
            id: i,
            surahId: 1,
            ayahNumber: i,
            textUthmani: 'نص عربي ${toArabicDigits(i)}',
            juz: 1,
            sajdah: i == 2,
          ),
          texts: switch (i) {
            1 => const {
                'translit_latin': 'translit mot',
                'vi_main': 'bản việt một',
                'en_sahih': 'english one',
              },
            2 => const {'vi_main': 'bản việt hai'},
            _ => {'vi_main': 'bản việt câu $i'},
          },
        ),
    ];

class _FakeRepo implements QuranRepository {
  _FakeRepo({
    this.surahExists = true,
    this.empty = false,
    this.ayahCount = 2,
  });

  final bool surahExists;
  final bool empty;
  final int ayahCount;

  Surah get _surah => _surahWith(ayahCount);

  @override
  Future<Surah?> getSurahById(int id) async => surahExists ? _surah : null;

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async =>
      empty ? const [] : _ayahs(ayahCount);

  @override
  Future<List<Surah>> getAllSurahs() async => [_surah];

  @override
  // Sprint 30.1 — trang đọc dựng lớp văn bản TỪ danh mục nguồn, nên
  // fake phải cung cấp nó (trước đây trả rỗng vì không ai gọi tới).
  Future<List<TranslationSource>> getEnabledSources() async => const [
        TranslationSource(
          id: 1,
          code: 'translit_latin',
          name: 'Phien am Latin',
          language: 'en',
          type: SourceType.transliteration,
          displayOrder: 1,
        ),
        TranslationSource(
          id: 2,
          code: 'vi_main',
          name: 'Ban dich tieng Viet',
          language: 'vi',
          type: SourceType.translation,
          displayOrder: 2,
        ),
        TranslationSource(
          id: 3,
          code: 'en_sahih',
          name: 'English',
          language: 'en',
          type: SourceType.translation,
          displayOrder: 3,
        ),
      ];

  @override
  Future<List<Reciter>> getEnabledReciters() async => const [
        Reciter(
          code: 'alafasy',
          name: 'Alafasy (test)',
          audioUrlTemplate: 'https://audio.test/{sss}{aaa}.mp3',
        ),
      ];

  @override
  Future<String?> getMetaValue(String key) async => null;

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];

  @override
  Future<Map<String, String>> getAyahTexts({
    required int ayahId,
    required Set<SourceType> types,
  }) async =>
      const {};

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}

/// UserDatabase của lần gọi [_app] gần nhất — [_testReading] đóng lại
/// ngay trong thân test (xem lý do bên dưới).
UserDatabase? _lastUserDb;

Future<Widget> _app(
  QuranRepository repo, {
  int surahId = 1,
  List<Override> extraOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  // Mỗi test tạo UserDatabase riêng (cô lập dữ liệu) — phải đóng lại
  // sau test, nếu không sẽ rò rỉ isolate/connection SQLite in-memory
  // và trigger cảnh báo "UserDatabase created multiple times" của Drift
  // khi nhiều test chạy chung 1 process. KHÔNG đóng qua addTearDown:
  // addTearDown chạy sau khi callback testWidgets đã return, lúc đó
  // tester.runAsync không còn coi mình "trong" một test đang chạy nữa
  // và treo vĩnh viễn (xác nhận bằng debug print — before/after
  // runAsync không bao giờ in ra after). Thay vào đó [_testReading]
  // đóng database ngay trong thân callback, trước khi nó return.
  final userDb = UserDatabase(NativeDatabase.memory());
  _lastUserDb = userDb;
  return ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(repo),
      sharedPreferencesProvider.overrideWithValue(sp),
      ayahAudioPlayerProvider.overrideWithValue(FakeAyahAudioPlayer()),
      userDatabaseProvider.overrideWithValue(userDb),
      ...extraOverrides,
    ],
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReadingScreen(surahId: surahId),
    ),
  );
}

/// Bọc testWidgets: hủy cây widget NGAY TRONG thân test rồi bơm thêm
/// một frame — drift đóng stream query bằng Timer(0) khi cây bị hủy,
/// nếu để binding tự hủy sau test sẽ dính lỗi "A Timer is still
/// pending" của flutter_test.
void _testReading(String description, WidgetTesterCallback body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    // Hai lần pump có tiến thời gian: xả cả chuỗi Timer(0) nối tiếp
    // khi drift đóng stream + isolate dọn dẹp.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final db = _lastUserDb;
    _lastUserDb = null;
    if (db != null) {
      await tester.runAsync(db.close);
    }
  });
}

void main() {
  // Mỗi test cố ý tạo UserDatabase in-memory riêng để cô lập dữ liệu
  // (xem _app/_testReading) — không phải lỗi dùng chung 1 kết nối,
  // nên tắt cảnh báo "created multiple times" của Drift cho file này.
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  _testReading('loading -> nội dung Ayah hiển thị đủ các lớp mặc định',
      (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('نص عربي ١'), findsOneWidget);
    expect(find.text('translit mot'), findsOneWidget); // translit: bật
    expect(find.text('bản việt một'), findsOneWidget); // việt: bật
    expect(find.text('english one'), findsNothing); // anh: tắt mặc định
    // huy hiệu số Ayah trong thẻ
    expect(
      find.descendant(
        of: find.byType(AyahCard),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  _testReading('header Surah hiển thị tên + số câu', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.textContaining('2 câu'), findsOneWidget);
  });

  _testReading('bật lớp English trong sheet -> hiển thị ngay', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.text_fields));
    await tester.pumpAndSettle();
    // Sprint 30.1 — nhãn công tắc nay là TÊN NGUỒN từ dữ liệu
    // (`translation_sources.name`), không còn là chuỗi l10n cố định.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // đóng sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('english one'), findsOneWidget);
  });

  _testReading('kéo slider tăng cỡ chữ Ả Rập', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    double arabicSize() =>
        tester.widget<Text>(find.text('نص عربي ١')).style!.fontSize!;
    final before = arabicSize();

    await tester.tap(find.byIcon(Icons.text_fields));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(arabicSize(), greaterThan(before));
  });

  _testReading('ayah sajdah có biểu tượng riêng', (tester) async {
    // Bố cục thẻ cao hơn (Phase 12 polish) -> viewport cao để cả Ayah
    // 2 (có sajdah) nằm trong khung nhìn, khỏi phải cuộn.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.self_improvement_rounded), findsOneWidget);
  });

  _testReading('surah không tồn tại -> thông báo Không tìm thấy',
      (tester) async {
    await tester.pumpWidget(
      await _app(_FakeRepo(surahExists: false), surahId: 999),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy Surah này.'), findsOneWidget);
    // không có nút Thử lại cho lỗi not-found (retry vô nghĩa)
    expect(find.text('Thử lại'), findsNothing);
  });

  _testReading('surah rỗng nội dung -> empty state', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo(empty: true)));
    await tester.pumpAndSettle();

    expect(find.textContaining('chưa có nội dung'), findsOneWidget);
  });

  _testReading(
      'AudioBar: ẩn khi chưa phát; bấm nút phát của Ayah -> hiện thanh, '
      'Ayah được highlight, next hoạt động', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.pause_circle_filled), findsNothing);

    // nút phát trên Ayah đầu
    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await tester.pumpAndSettle();

    // thanh phát xuất hiện với tên Qari + vị trí 1:1
    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
    expect(find.text('Alafasy (test)'), findsOneWidget);
    expect(find.text('1:1'), findsWidgets);
    // Ayah 1 đổi icon sang đang phát
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);

    // next -> vị trí 1:2
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();
    expect(find.text('1:2'), findsWidgets);

    // đổi tốc độ
    await tester.tap(find.text('1.0x'));
    await tester.pumpAndSettle();
    expect(find.text('1.25x'), findsOneWidget);

    // dừng -> thanh biến mất
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.pause_circle_filled), findsNothing);
  });

  _testReading('Focus Mode: ẩn AppBar + bản dịch, chạm để thoát',
      (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.center_focus_strong));
    await tester.pumpAndSettle();

    // chỉ còn văn bản Qur'an
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('bản việt một'), findsNothing);
    expect(find.text('translit mot'), findsNothing);
    expect(find.textContaining('نص عربي ١'), findsOneWidget);
    expect(find.textContaining('﴿١﴾'), findsOneWidget);

    // chạm một lần -> quay lại đầy đủ
    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('bản việt một'), findsOneWidget);
  });

  _testReading('Mushaf Mode: PageView với văn bản liền mạch + số trang',
      (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    // 2 ayah cùng trang (page null -> trang 0) gộp một khối
    expect(find.textContaining('﴿١﴾'), findsOneWidget);
    expect(find.textContaining('﴿٢﴾'), findsOneWidget);

    // chuyển lại chế độ danh sách
    await tester.tap(find.byIcon(Icons.view_agenda_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);
    expect(find.text('bản việt một'), findsOneWidget);
  });

  _testReading('mở lại Surah quay về đúng Ayah đã đọc', (tester) async {
    // vị trí đã lưu: ayah index 1 (ayah thứ 2)
    SharedPreferences.setMockInitialValues({
      'reading.last_surah_id': 1,
      'reading.pos.1': 1,
    });
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranRepositoryProvider.overrideWithValue(_FakeRepo()),
          sharedPreferencesProvider.overrideWithValue(sp),
        ],
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReadingScreen(surahId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // danh sách khởi tạo tại index 2 (header + ayah 1 nằm trên) —
    // ayah 2 hiển thị ngay không cần cuộn
    expect(find.textContaining('نص عربي ٢'), findsOneWidget);
  });

  _testReading('Bookmark 1 chạm: icon đổi trạng thái ngay', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
  });

  _testReading('Nhấn giữ Ayah: sheet mở, đặt trạng thái + highlight',
      (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.longPress(find.textContaining('نص عربي ١'));
    await tester.pumpAndSettle();

    // sheet hiện đủ nhóm thao tác
    expect(find.text('Trạng thái học'), findsOneWidget);

    await tester.tap(find.text('Đang học'));
    await tester.pumpAndSettle();

    // chọn màu green (Semantics label)
    await tester.tap(find.bySemanticsLabel('green'));
    await tester.pumpAndSettle();

    // đóng sheet -> chip trạng thái hiện trên thẻ Ayah
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Đang học'), findsOneWidget);
  });

  _testReading('Ghi chú: lưu qua dialog, hiện dưới Ayah', (tester) async {
    await tester.pumpWidget(await _app(_FakeRepo()));
    await tester.pumpAndSettle();

    await tester.longPress(find.textContaining('نص عربي ١'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm ghi chú'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ghi chú của tôi');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // đóng sheet
    await tester.pumpAndSettle();

    expect(find.text('ghi chú của tôi'), findsOneWidget);
  });

  _testReading('text scale 200%: không overflow', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: await _app(_FakeRepo()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Ở cỡ chữ 200% trên khung 400x800, RIÊNG header Surah đã chiếm
    // trọn khung hình nên chưa có AyahCard nào được dựng — cuộn xuống
    // để tới Ayah đầu tiên. (Trước Sprint 25.2, Ayah 1 lọt vừa vặn
    // trong cacheExtent nên tìm được mà không cần cuộn; dải tiến độ
    // lấy thêm ~34px ở đáy đã đẩy nó ra ngoài. Đây là bố cục đúng, nên
    // test cuộn tới nội dung thay vì giả định nó luôn dựng sẵn.)
    await tester.dragFrom(const Offset(200, 400), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('نص عربي ١'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Sprint 8 Phase 5 — tích hợp study_sessions', () {
    _testReading(
        'rời trang đọc rất nhanh (< 5 giây) -> KHÔNG ghi study_sessions '
        '(cùng ngưỡng StatsStore.addSeconds)', (tester) async {
      final spy = _SpyStudySessionRepository();
      await tester.pumpWidget(
        await _app(
          _FakeRepo(),
          extraOverrides: [
            studySessionRepositoryProvider.overrideWithValue(spy),
          ],
        ),
      );
      await tester.pumpAndSettle();
      // _testReading tự dispose cây widget ngay sau khi thân test
      // (hàm callback này) return — phiên đọc chỉ kéo dài vài mili-
      // giây, chắc chắn dưới ngưỡng 5 giây.

      expect(spy.logged, isEmpty);
    });

    _testReading('phiên đọc >= 5 giây -> ghi 1 study_session đúng surahId/ngày',
        (tester) async {
      final spy = _SpyStudySessionRepository();
      await tester.pumpWidget(
        await _app(
          _FakeRepo(),
          extraOverrides: [
            studySessionRepositoryProvider.overrideWithValue(spy),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Stopwatch dùng đồng hồ thật (không phải fake clock của
      // tester.pump) — đợi thật hơn 5 giây qua runAsync.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5200)),
      );

      // Dispose NGAY TRONG thân test (không đợi _testReading tự dọn
      // sau khi callback return) để assert được sau khi dispose() đã
      // chạy xong và gọi logSession.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(spy.logged, hasLength(1));
      final session = spy.logged.single;
      expect(session.surahId, 1);
      expect(session.date, isNotEmpty);
      expect(session.durationSec, greaterThanOrEqualTo(5));
      expect(session.ayahFrom, 0);
    });
  });

  group('Sprint 25.1 — Chuyển tới Ayah', () {
    _testReading('nhập số câu -> cuộn tới đúng Ayah + lưu vị trí đọc',
        (tester) async {
      // Khung hình hẹp: chỉ vài thẻ Ayah nằm trong tầm nhìn, nên việc
      // cuộn tới Ayah 10 là cuộn THẬT (Ayah 1 bị hủy dựng).
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await _app(_FakeRepo(ayahCount: 12)));
      await tester.pumpAndSettle();

      expect(find.text('bản việt một'), findsOneWidget);
      expect(find.text('bản việt câu 10'), findsNothing);

      await tester.tap(find.byIcon(Icons.numbers));
      await tester.pumpAndSettle();
      expect(find.byType(JumpToAyahSheet), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Số câu'), '10');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Chuyển tới'));
      await tester.pumpAndSettle();

      // Sheet đóng lại, danh sách đã ở Ayah 10.
      expect(find.byType(JumpToAyahSheet), findsNothing);
      expect(find.text('bản việt câu 10'), findsOneWidget);
      expect(find.text('bản việt một'), findsNothing);

      // Vị trí đọc đã tiến khỏi đầu Surah. KHÔNG khẳng định đúng một
      // con số: sau khi cuộn xong, _onPositionsChanged còn ghi đè bằng
      // chỉ số Ayah đầu tiên NHÌN THẤY (alignment 0.15 chừa một phần
      // Ayah trước đó ở mép trên) — cả hai đều là hành vi đúng.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('reading.pos.1'), greaterThan(0));
    });

    _testReading('chế độ Mushaf -> KHÔNG mở sheet, báo chỉ dùng ở Danh sách',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_stories_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.numbers));
      await tester.pumpAndSettle();

      expect(find.byType(JumpToAyahSheet), findsNothing);
      expect(
        find.text('Chuyển tới Ayah hiện chỉ dùng được ở chế độ Danh sách.'),
        findsOneWidget,
      );
      // KHÔNG tự đổi chế độ sau lưng người dùng.
      expect(find.byType(PageView), findsOneWidget);
    });

    _testReading('số câu ngoài phạm vi -> nút Chuyển tới bị vô hiệu',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo(ayahCount: 12)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.numbers));
      await tester.pumpAndSettle();

      final button = find.widgetWithText(FilledButton, 'Chuyển tới');
      final field = find.widgetWithText(TextField, 'Số câu');

      // Phạm vi hợp lệ hiện sẵn, chưa nhập gì -> chưa bấm được.
      expect(find.text('1–12'), findsOneWidget);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      await tester.enterText(field, '99');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      await tester.enterText(field, '5');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    });
  });

  group('Sprint 25.2 — Dải tiến độ đọc', () {
    _testReading('hiện vị trí hiện tại ở đáy màn hình; Focus Mode ẩn đi',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();

      expect(find.byType(ReadingProgressIndicator), findsOneWidget);
      expect(find.text('Ayah 1 / 2'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.center_focus_strong));
      await tester.pumpAndSettle();

      // Focus Mode = chỉ còn kinh văn, dải tiến độ biến mất cùng AppBar.
      expect(find.byType(ReadingProgressIndicator), findsNothing);
    });

    _testReading('cuộn tới Ayah khác -> dải tiến độ cập nhật theo',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await _app(_FakeRepo(ayahCount: 12)));
      await tester.pumpAndSettle();

      expect(find.text('Ayah 1 / 12'), findsOneWidget);

      // Dùng chính "Chuyển tới Ayah" (Sprint 25.1) để di chuyển thật.
      await tester.tap(find.byIcon(Icons.numbers));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Số câu'), '10');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Chuyển tới'));
      await tester.pumpAndSettle();

      // Đã rời khỏi đầu Surah — KHÔNG khẳng định đúng một con số vì
      // Ayah đầu tiên NHÌN THẤY sau khi cuộn phụ thuộc alignment.
      expect(find.text('Ayah 1 / 12'), findsNothing);
      expect(find.byType(ReadingProgressIndicator), findsOneWidget);
    });

    _testReading('Surah rỗng nội dung -> không hiện dải tiến độ',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo(empty: true)));
      await tester.pumpAndSettle();

      expect(find.byType(ReadingProgressIndicator), findsNothing);
    });

    _testReading('mở lại Surah -> phản ánh NGAY vị trí đã lưu, không cần cuộn',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Đang đọc dở tại Ayah thứ 6 (index 5) của một Surah 12 câu.
      SharedPreferences.setMockInitialValues({
        'reading.last_surah_id': 1,
        'reading.pos.1': 5,
      });
      final sp = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quranRepositoryProvider.overrideWithValue(_FakeRepo(ayahCount: 12)),
            sharedPreferencesProvider.overrideWithValue(sp),
          ],
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ReadingScreen(surahId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Không thao tác cuộn nào: con số đến thẳng từ ReadingPositionStore.
      expect(find.text('Ayah 6 / 12'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });
  });

  group('Sprint 25.3 — Focus Mode', () {
    _testReading('dùng khoảng dòng của trang Mushaf (height 2.2)',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();

      // Ngoài Focus Mode: khoảng dòng mặc định của quranTextStyle.
      expect(
        tester.widget<Text>(find.text('نص عربي ١')).style?.height,
        2.0,
      );

      await tester.tap(find.byIcon(Icons.center_focus_strong));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Text>(find.textContaining('نص عربي ١')).style?.height,
        2.2,
      );
    });

    _testReading('vỏ dưới thu gọn dần, không tắt phụt ngay khung hình đầu',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      expect(find.byType(ReadingProgressIndicator), findsOneWidget);

      await tester.tap(find.byIcon(Icons.center_focus_strong));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      // Vẫn còn: đang thu gọn giữa chừng.
      expect(find.byType(ReadingProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      // Thu xong -> tháo hẳn, Focus Mode không còn dựng vỏ dưới nữa.
      expect(find.byType(ReadingProgressIndicator), findsNothing);
    });
  });

  group('Sprint 25.4 — Sheet thao tác Ayah', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.longPress(find.textContaining('نص عربي ١'));
      await tester.pumpAndSettle();
    }

    _testReading('gom đủ thao tác nhanh + nhóm tô màu/trạng thái/ghi chú',
        (tester) async {
      tester.view.physicalSize = const Size(500, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      await openSheet(tester);

      expect(find.byType(AyahActionsSheet), findsOneWidget);
      // Thao tác nhanh — gồm cả Nghe/Sao chép/Chia sẻ mới thêm.
      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.text('Yêu thích'), findsOneWidget);
      expect(find.text('Nghe từ Ayah này'), findsOneWidget);
      expect(find.text('Sao chép'), findsOneWidget);
      expect(find.text('Chia sẻ'), findsOneWidget);
      // Các nhóm bên dưới, mỗi nhóm có nhãn riêng.
      expect(find.text('Tô màu'), findsOneWidget);
      expect(find.text('Trạng thái học'), findsOneWidget);
      expect(find.text('Thêm ghi chú'), findsOneWidget);
    });

    _testReading('bật/tắt bookmark trong sheet -> GIỮ sheet mở, đổi ngay',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      await openSheet(tester);

      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);

      await tester.tap(find.bySemanticsLabel('Bookmark'));
      await tester.pumpAndSettle();

      // Toggle -> sheet vẫn mở để thấy trạng thái vừa đổi.
      expect(find.byType(AyahActionsSheet), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsWidgets);
    });

    _testReading('Nghe từ Ayah này -> đóng sheet rồi bắt đầu phát',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      await openSheet(tester);

      await tester.tap(find.bySemanticsLabel('Nghe từ Ayah này'));
      await tester.pumpAndSettle();

      // Hành động một lần -> trả người dùng về trang đọc.
      expect(find.byType(AyahActionsSheet), findsNothing);
      // Dùng LẠI audio controller sẵn có: thanh phát xuất hiện.
      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      expect(find.text('1:1'), findsWidgets);
    });
  });

  group('Sprint 25.5 — Bảng Hiển thị', () {
    Future<void> openPanel(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.text_fields));
      await tester.pumpAndSettle();
    }

    _testReading('gom đủ nhóm: chế độ đọc, cỡ chữ, lớp hỗ trợ đọc',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      await openPanel(tester);

      expect(find.byType(ReadingSettingsSheet), findsOneWidget);
      // Chế độ đọc — trước Sprint 25.5 chỉ có ở nút trên AppBar.
      expect(find.text('Chế độ đọc'), findsOneWidget);
      expect(find.byType(SegmentedButton<ReadingMode>), findsOneWidget);
      // Cỡ chữ + giá trị hiện tại hiển thị ngay cạnh nhãn.
      expect(find.text('Cỡ chữ Ả Rập'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      // Ba lớp hỗ trợ đọc.
      expect(find.text('Lớp hỗ trợ đọc'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(3));
    });

    _testReading('đổi chế độ đọc trong bảng -> áp dụng ngay, bảng VẪN mở',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();
      await openPanel(tester);

      await tester.tap(find.text('Chế độ Mushaf'));
      await tester.pumpAndSettle();

      // Bảng vẫn mở để tinh chỉnh tiếp...
      expect(find.byType(ReadingSettingsSheet), findsOneWidget);
      // ...và thay đổi đã áp dụng cho trang đọc phía sau.
      expect(find.byType(PageView), findsOneWidget);
    });

    _testReading('kéo cỡ chữ -> phần trăm đổi theo và chữ Ả Rập lớn lên',
        (tester) async {
      await tester.pumpWidget(await _app(_FakeRepo()));
      await tester.pumpAndSettle();

      double arabicSize() =>
          tester.widget<Text>(find.text('نص عربي ١')).style!.fontSize!;
      final before = arabicSize();

      await openPanel(tester);
      expect(find.text('100%'), findsOneWidget);

      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pumpAndSettle();

      // Giá trị mới hiện ngay trong bảng, không cần đóng ra xem.
      expect(find.text('100%'), findsNothing);
      await tester.tapAt(const Offset(10, 10)); // đóng bảng
      await tester.pumpAndSettle();
      expect(arabicSize(), greaterThan(before));
    });
  });
}
