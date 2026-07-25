import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/audio_url.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/audio/audio_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

class _RepoWithReciters implements QuranRepository {
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [
        Reciter(
          code: 'alafasy',
          name: 'Alafasy',
          audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
        ),
        Reciter(
          code: 'husary',
          name: 'Husary',
          audioUrlTemplate: 'https://h.test/{sss}{aaa}.mp3',
        ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [];
  @override
  Future<Surah?> getSurahById(int id) async => null;
  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];
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

List<Ayah> _ayahs(int count) => [
      for (var n = 1; n <= count; n++)
        Ayah(id: n, surahId: 2, ayahNumber: n, textUthmani: 'x$n'),
    ];

void main() {
  late FakeAyahAudioPlayer player;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    player = FakeAyahAudioPlayer();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        quranRepositoryProvider.overrideWithValue(_RepoWithReciters()),
        ayahAudioPlayerProvider.overrideWithValue(player),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('buildAyahAudioUrl thay {sss}{aaa} đúng 3 chữ số', () {
    expect(
      buildAyahAudioUrl(
        template: 'https://a.test/{sss}{aaa}.mp3',
        surahId: 2,
        ayahNumber: 45,
      ),
      'https://a.test/002045.mp3',
    );
  });

  test('playSurah: nạp playlist đủ Ayah, đúng URL, phát từ startIndex',
      () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.playSurah(surahId: 2, ayahs: _ayahs(3), startIndex: 1);

    expect(player.playlist.length, 3);
    expect(player.playlist.first.toString(), 'https://a.test/002001.mp3');
    expect(player.initialIndex, 1);
    expect(player.playing, isTrue);

    final state = container.read(audioControllerProvider);
    expect(state.active, isTrue);
    expect(state.surahId, 2);
    expect(state.currentIndex, 1);
    expect(state.reciter?.code, 'alafasy'); // Qari đầu khi chưa lưu
  });

  test('Qari đã lưu trong prefs được ưu tiên', () async {
    SharedPreferences.setMockInitialValues(
      {AudioController.kReciterPrefsKey: 'husary'},
    );
    final sp = await SharedPreferences.getInstance();
    final c2 = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        quranRepositoryProvider.overrideWithValue(_RepoWithReciters()),
        ayahAudioPlayerProvider.overrideWithValue(player),
      ],
    );
    addTearDown(c2.dispose);

    await c2
        .read(audioControllerProvider.notifier)
        .playSurah(surahId: 2, ayahs: _ayahs(2));

    expect(
      c2.read(audioControllerProvider).reciter?.code,
      'husary',
    );
    expect(player.playlist.first.toString(), 'https://h.test/002001.mp3');
  });

  test('nextAyah/previousAyah tôn trọng biên playlist', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.playSurah(surahId: 2, ayahs: _ayahs(2));

    await c.previousAyah(); // đang ở 0 -> không lùi
    expect(container.read(audioControllerProvider).currentIndex, 0);

    await c.nextAyah();
    expect(container.read(audioControllerProvider).currentIndex, 1);
    expect(player.seekedTo, 1);

    await c.nextAyah(); // đã ở cuối -> đứng yên
    expect(container.read(audioControllerProvider).currentIndex, 1);
  });

  test(
      'togglePlayPause: tạm dừng rồi phát tiếp — state luôn khớp engine '
      '(Sprint 28.0)', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.playSurah(surahId: 2, ayahs: _ayahs(2));
    await pumpEventQueue();

    // Tạm dừng. Bản cũ tính `!state.playing` SAU await, mà lúc đó
    // playingStream đã đặt false -> lật ngược thành true: engine dừng
    // nhưng thanh phát vẫn báo "đang phát".
    await c.togglePlayPause();
    await pumpEventQueue();
    expect(player.playing, isFalse);
    expect(container.read(audioControllerProvider).playing, isFalse);

    // Phát tiếp. Với lỗi cũ, nhánh này KHÔNG BAO GIỜ chạy được vì
    // state kẹt ở playing=true -> mỗi lần bấm lại gọi pause().
    await c.togglePlayPause();
    await pumpEventQueue();
    expect(player.playing, isTrue);
    expect(container.read(audioControllerProvider).playing, isTrue);
  });

  test('togglePlayPause không làm gì khi trình phát chưa hoạt động', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.togglePlayPause();
    await pumpEventQueue();

    expect(player.playing, isFalse);
    expect(container.read(audioControllerProvider).playing, isFalse);
  });

  test('cycleSpeed xoay vòng đúng dãy tốc độ', () async {
    final c = container.read(audioControllerProvider.notifier);

    await c.cycleSpeed(); // 1.0 -> 1.25
    expect(container.read(audioControllerProvider).speed, 1.25);
    await c.cycleSpeed();
    await c.cycleSpeed(); // -> 2.0
    expect(container.read(audioControllerProvider).speed, 2.0);
    await c.cycleSpeed(); // -> 0.75 (vòng lại)
    expect(container.read(audioControllerProvider).speed, 0.75);
  });

  test('cycleRepeat: off -> one -> all -> off, đẩy xuống player', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.playSurah(surahId: 2, ayahs: _ayahs(1));

    await c.cycleRepeat();
    expect(container.read(audioControllerProvider).repeat, RepeatMode.one);
    expect(player.repeatMode, RepeatMode.one);
    await c.cycleRepeat();
    expect(player.repeatMode, RepeatMode.all);
    await c.cycleRepeat();
    expect(player.repeatMode, RepeatMode.off);
  });

  test('stop: về idle nhưng giữ tốc độ + chế độ lặp', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.playSurah(surahId: 2, ayahs: _ayahs(1));
    await c.cycleSpeed();
    await c.stop();

    final state = container.read(audioControllerProvider);
    expect(state.active, isFalse);
    expect(state.speed, 1.25);
    expect(player.stopped, isTrue);
  });

  test('selectReciter lưu bền vào prefs', () async {
    final c = container.read(audioControllerProvider.notifier);
    await c.selectReciter(
      const Reciter(
        code: 'husary',
        name: 'Husary',
        audioUrlTemplate: 'https://h.test/{sss}{aaa}.mp3',
      ),
    );

    expect(
      container
          .read(sharedPreferencesProvider)
          .getString(AudioController.kReciterPrefsKey),
      'husary',
    );
  });

  // ---- Sprint 28.1 — đổi Qari phải NẠP LẠI nguồn thật ----
  //
  // Hợp đồng ghi trong doc của `selectReciter` ("nếu đang phát thì
  // giữ vị trí, nạp lại nguồn") trước đây không được thực hiện: hàm
  // chỉ lưu prefs + đổi nhãn, engine vẫn chạy giọng cũ.
  group('selectReciter khi đang phát (Sprint 28.1)', () {
    const husary = Reciter(
      code: 'husary',
      name: 'Husary',
      audioUrlTemplate: 'https://h.test/{sss}{aaa}.mp3',
    );

    test('nguồn phát ĐỔI sang Qari mới, giữ Surah + Ayah + vị trí', () async {
      final c = container.read(audioControllerProvider.notifier);
      await c.playSurah(surahId: 2, ayahs: _ayahs(5), startIndex: 2);
      await pumpEventQueue();

      expect(player.playlist[2].toString(), 'https://a.test/002003.mp3');

      // Nghe được 9 giây của Ayah thứ 3.
      player.positionController.add(const Duration(seconds: 9));
      await pumpEventQueue();
      expect(container.read(audioControllerProvider).position.inSeconds, 9);

      final loadsBefore = player.setPlaylistCount;
      await c.selectReciter(husary);
      await pumpEventQueue();

      // Nạp lại THẬT (không chỉ đổi nhãn) và bằng giọng mới.
      expect(player.setPlaylistCount, loadsBefore + 1);
      expect(player.playlist.length, 5);
      expect(player.playlist.first.toString(), 'https://h.test/002001.mp3');

      // ...giữ nguyên Surah, đúng Ayah đang nghe, đúng vị trí trong Ayah.
      final state = container.read(audioControllerProvider);
      expect(state.surahId, 2);
      expect(state.currentIndex, 2);
      expect(state.reciter?.code, 'husary');
      expect(player.initialIndex, 2);
      expect(player.initialPosition, const Duration(seconds: 9));
    });

    test('đang phát -> vẫn phát; đang tạm dừng -> KHÔNG tự phát', () async {
      final c = container.read(audioControllerProvider.notifier);
      await c.playSurah(surahId: 2, ayahs: _ayahs(3));
      await pumpEventQueue();

      await c.selectReciter(husary);
      await pumpEventQueue();
      expect(player.playing, isTrue);
      expect(container.read(audioControllerProvider).playing, isTrue);

      // Tạm dừng rồi đổi Qari: nạp lại nhưng không được tự phát.
      await c.togglePlayPause();
      await pumpEventQueue();
      expect(player.playing, isFalse);

      final loadsBefore = player.setPlaylistCount;
      await c.selectReciter(
        const Reciter(
          code: 'alafasy',
          name: 'Alafasy',
          audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
        ),
      );
      await pumpEventQueue();

      expect(player.setPlaylistCount, loadsBefore + 1);
      expect(player.playlist.first.toString(), 'https://a.test/002001.mp3');
      expect(player.playing, isFalse);
      expect(container.read(audioControllerProvider).playing, isFalse);
    });

    test('chọn lại đúng Qari đang nghe -> không cắt ngang (không nạp lại)',
        () async {
      final c = container.read(audioControllerProvider.notifier);
      await c.playSurah(surahId: 2, ayahs: _ayahs(3));
      await pumpEventQueue();

      final loadsBefore = player.setPlaylistCount;
      await c.selectReciter(
        const Reciter(
          code: 'alafasy',
          name: 'Alafasy',
          audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
        ),
      );
      await pumpEventQueue();

      expect(player.setPlaylistCount, loadsBefore);
      expect(player.playing, isTrue);
    });

    test('chưa phát gì -> chỉ ghi nhớ lựa chọn, không đụng engine', () async {
      final c = container.read(audioControllerProvider.notifier);
      await c.selectReciter(husary);
      await pumpEventQueue();

      expect(player.setPlaylistCount, 0);
      expect(container.read(audioControllerProvider).reciter?.code, 'husary');
      expect(container.read(audioControllerProvider).active, isFalse);
    });

    test('retry sau khi đổi Qari nạp lại giọng ĐANG chọn, không giọng cũ',
        () async {
      final c = container.read(audioControllerProvider.notifier);
      await c.playSurah(surahId: 2, ayahs: _ayahs(4), startIndex: 1);
      await pumpEventQueue();

      await c.selectReciter(husary);
      await pumpEventQueue();

      // Lỗi mạng giữa chừng -> người dùng bấm Thử lại.
      player.errorController.add('network');
      await pumpEventQueue();
      expect(
        container.read(audioControllerProvider).errorMessage,
        isNotNull,
      );

      await c.retry();
      await pumpEventQueue();

      expect(player.playlist.first.toString(), 'https://h.test/002001.mp3');
      expect(player.initialIndex, 1);

      final state = container.read(audioControllerProvider);
      expect(state.errorMessage, isNull);
      expect(state.playing, isTrue);
      expect(state.currentIndex, 1);
    });
  });
}
