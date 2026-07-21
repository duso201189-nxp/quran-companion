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
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
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

const _surah = Surah(
  id: 1,
  nameArabic: 'الفاتحة',
  nameLatin: 'Al-Fatihah',
  nameVi: 'Khai Đề',
  nameEn: 'The Opening',
  ayahCount: 2,
  revelationPlace: RevelationPlace.mecca,
  orderRevealed: 5,
);

List<AyahContent> _ayahs() => [
      const AyahContent(
        ayah: Ayah(
          id: 1,
          surahId: 1,
          ayahNumber: 1,
          textUthmani: 'نص عربي ١',
          juz: 1,
        ),
        texts: {
          'translit_latin': 'translit mot',
          'vi_main': 'bản việt một',
          'en_sahih': 'english one',
        },
      ),
      const AyahContent(
        ayah: Ayah(
          id: 2,
          surahId: 1,
          ayahNumber: 2,
          textUthmani: 'نص عربي ٢',
          juz: 1,
          sajdah: true,
        ),
        texts: {'vi_main': 'bản việt hai'},
      ),
    ];

class _FakeRepo implements QuranRepository {
  _FakeRepo({this.surahExists = true, this.empty = false});

  final bool surahExists;
  final bool empty;

  @override
  Future<Surah?> getSurahById(int id) async => surahExists ? _surah : null;

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async =>
      empty ? const [] : _ayahs();

  @override
  Future<List<Surah>> getAllSurahs() async => [_surah];

  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];

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
    await tester.tap(find.text('Bản dịch tiếng Anh'));
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
    expect(find.text('نص عربي ١'), findsOneWidget);
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
}
