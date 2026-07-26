import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/app.dart';
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
import 'package:quran_companion/features/quran/presentation/audio/audio_bar.dart';
import 'package:quran_companion/features/quran/presentation/audio/audio_controller.dart';
import 'package:quran_companion/features/quran/presentation/audio/audio_mini_player.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint 29.0 — thanh phát thu gọn ở cấp ứng dụng.
///
/// Chạy qua ROUTER THẬT của app (không phải GoRouter cô lập): điểm gắn
/// nằm ở `MaterialApp.builder`, TRÊN Navigator, nên chỉ app thật mới
/// kiểm chứng được đúng quan hệ tầng lớp — kể cả việc `context.push`
/// KHÔNG dùng được ở đó.

/// Repo giả có Qari (khác `FakeQuranRepo` của app_harness, vốn trả về
/// danh sách Qari rỗng nên `playSurah` sẽ không làm gì).
class _RepoWithAudio implements QuranRepository {
  static const _surah = Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai Đề',
    nameEn: 'The Opening',
    ayahCount: 7,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  );

  @override
  Future<List<Reciter>> getEnabledReciters() async => const [
        Reciter(
          code: 'alafasy',
          name: 'Alafasy (test)',
          audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
        ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];
  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [
        AyahContent(
          ayah: Ayah(id: 1, surahId: 1, ayahNumber: 1, textUthmani: 'نص ١'),
          texts: {},
        ),
        AyahContent(
          ayah: Ayah(id: 2, surahId: 1, ayahNumber: 2, textUthmani: 'نص ٢'),
          texts: {},
        ),
      ];
  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
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

/// Bơm nhịp có giới hạn — cùng lý do đã ghi ở `sprint8_navigation_test`:
/// các StreamProvider của Drift luôn sống trong IndexedStack khiến
/// `pumpAndSettle` không bao giờ thấy "hết frame".
Future<void> settle(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeAyahAudioPlayer player;
  late ProviderContainer container;

  /// Kích thước điện thoại: vỏ 5 tab chỉ dùng NavigationBar dưới đáy
  /// khi bề rộng < 800 (>= 800 là NavigationRail). Mặc định của
  /// flutter_test là 800x600 -> rơi đúng vào nhánh rail.
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<Widget> makeAudioApp() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    player = FakeAyahAudioPlayer();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        quranRepositoryProvider.overrideWithValue(_RepoWithAudio()),
        userDatabaseProvider.overrideWithValue(
          UserDatabase(NativeDatabase.memory()),
        ),
        ayahAudioPlayerProvider.overrideWithValue(player),
      ],
    );
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const QuranCompanionApp(),
    );
  }

  Future<void> startPlayback() async {
    await container.read(audioControllerProvider.notifier).playSurah(
      surahId: 1,
      ayahs: const [
        Ayah(id: 1, surahId: 1, ayahNumber: 1, textUthmani: 'a'),
        Ayah(id: 2, surahId: 1, ayahNumber: 2, textUthmani: 'b'),
      ],
    );
  }

  /// Dọn cây sớm để Drift đóng stream bằng Timer(0) trong thân test,
  /// tránh assertion "Timer is still pending" của flutter_test.
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('chưa phát -> KHÔNG có thanh thu gọn nào trong cây',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);

    expect(find.byType(AudioMiniPlayer), findsNothing);
    await teardownTree(tester);
  });

  testWidgets('đang phát ở màn hình ngoài trang đọc -> thanh thu gọn hiện',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);

    await startPlayback();
    await settle(tester);

    // Ở tab Trang chủ: thanh thu gọn xuất hiện, kèm đúng Qari + tham
    // chiếu Ayah đang phát.
    expect(find.byType(AudioMiniPlayer), findsOneWidget);
    expect(find.text('Alafasy (test)'), findsOneWidget);
    expect(find.text('1:1'), findsOneWidget);

    // Không che thanh điều hướng: cả hai cùng có mặt và không chồng lấn.
    expect(find.byType(NavigationBar), findsOneWidget);
    final navRect = tester.getRect(find.byType(NavigationBar));
    final miniRect = tester.getRect(find.byType(AudioMiniPlayer));
    expect(miniRect.top, greaterThanOrEqualTo(navRect.bottom));

    await teardownTree(tester);
  });

  testWidgets('phát tiếp khi rời trang đọc; quay lại giữ nguyên trạng thái',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);

    // Vào tab Qur'an -> mở Surah -> đang ở trang đọc.
    await tester.tap(find.text('Qur\'an').last);
    await settle(tester);
    await tester.tap(find.text('Al-Fatihah').first);
    await settle(tester);
    expect(find.byType(ReadingScreen), findsOneWidget);

    await startPlayback();
    await settle(tester);

    // Trên trang đọc: CHỈ AudioBar đầy đủ, KHÔNG có thanh thu gọn —
    // không nhân đôi bộ điều khiển.
    expect(find.byType(AudioBar), findsOneWidget);
    expect(find.byType(AudioMiniPlayer), findsNothing);

    await container.read(audioControllerProvider.notifier).nextAyah();
    await settle(tester);
    expect(container.read(audioControllerProvider).currentIndex, 1);

    // Rời trang đọc sang tab khác.
    await tester.tap(find.text('Trang chủ').last);
    await settle(tester);
    expect(find.byType(ReadingScreen), findsNothing);

    // Nhạc KHÔNG dừng, và thanh thu gọn tiếp quản việc điều khiển.
    expect(player.playing, isTrue);
    expect(container.read(audioControllerProvider).active, isTrue);
    expect(find.byType(AudioMiniPlayer), findsOneWidget);

    // Quay lại trang đọc: đúng Surah/Ayah cũ, thanh thu gọn tự ẩn.
    await tester.tap(find.text('Qur\'an').last);
    await settle(tester);
    expect(find.byType(ReadingScreen), findsOneWidget);
    expect(find.byType(AudioMiniPlayer), findsNothing);
    expect(find.byType(AudioBar), findsOneWidget);

    final state = container.read(audioControllerProvider);
    expect(state.surahId, 1);
    expect(state.currentIndex, 1);
    expect(state.reciter?.code, 'alafasy');

    await teardownTree(tester);
  });

  testWidgets(
      'thanh thu gọn dùng CHUNG một controller: tạm dừng ở đây thì '
      'AudioBar trang đọc thấy ngay', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);

    await startPlayback();
    await settle(tester);
    expect(find.byType(AudioMiniPlayer), findsOneWidget);

    // Tạm dừng TỪ thanh thu gọn.
    await tester.tap(
      find.descendant(
        of: find.byType(AudioMiniPlayer),
        matching: find.byIcon(Icons.pause_circle_filled),
      ),
    );
    await settle(tester);

    // Engine dừng thật, state dùng chung phản ánh đúng.
    expect(player.playing, isFalse);
    expect(container.read(audioControllerProvider).playing, isFalse);

    // Vào trang đọc: AudioBar đọc CÙNG state -> hiện nút Phát.
    await tester.tap(find.text('Qur\'an').last);
    await settle(tester);
    await tester.tap(find.text('Al-Fatihah').first);
    await settle(tester);

    expect(find.byType(AudioBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AudioBar),
        matching: find.byIcon(Icons.play_circle_filled),
      ),
      findsOneWidget,
    );

    await teardownTree(tester);
  });

  testWidgets('dừng hẳn từ thanh thu gọn -> thanh biến mất khỏi cây',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);

    await startPlayback();
    await settle(tester);
    expect(find.byType(AudioMiniPlayer), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AudioMiniPlayer),
        matching: find.byIcon(Icons.close),
      ),
    );
    await settle(tester);

    expect(player.stopped, isTrue);
    expect(find.byType(AudioMiniPlayer), findsNothing);
    expect(container.read(audioControllerProvider).active, isFalse);

    await teardownTree(tester);
  });

  testWidgets('gộp MỘT node accessibility, là nút, có gợi ý mở trang đọc',
      (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(await makeAudioApp());
    await settle(tester);
    await startPlayback();
    await settle(tester);

    final label = find.bySemanticsLabel('Đang phát, Alafasy (test), 1:1');
    expect(label, findsOneWidget);

    final node = tester.getSemantics(label);
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.hint, 'Mở trang đọc');

    await teardownTree(tester);
  });
}
