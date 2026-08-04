import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/audio_url.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/quran/quran_address.dart';
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

  /// Chỉ Surah 2 có tên — Surah khác trả null để test được cả nhánh
  /// rơi-về-địa-chỉ khi database không có hàng tương ứng.
  @override
  Future<Surah?> getSurahById(int id) async => id == 2
      ? const Surah(
          id: 2,
          nameArabic: 'البقرة',
          nameLatin: 'Al-Baqarah',
          nameVi: 'Con Bò',
          nameEn: 'The Cow',
          ayahCount: 286,
          revelationPlace: RevelationPlace.madinah,
          orderRevealed: 87,
        )
      : null;
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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}

List<Ayah> _ayahs(int count, {int surahId = 2}) => [
      for (var n = 1; n <= count; n++)
        Ayah(id: n, surahId: surahId, ayahNumber: n, textUthmani: 'x$n'),
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
    // BM3: mức AYAH -> phát đúng Ayah 2, không chèn Basmalah.
    await c.playSurah(ayahs: _ayahs(3), from: QuranAddress.ayah(2, 2));

    // Sprint BM1: 3 Ayah + 1 phần mở đầu = 4 mục. Trước BM1 là 3, và
    // con số cũ chính là lỗi: Basmalah hiện trên màn hình nhưng không
    // bao giờ được phát.
    expect(player.playlist.length, 4);

    // Mục 0 là phần mở đầu: địa chỉ mức SURAH và audio lấy từ 001001
    // (Ayah 1 của Al-Fatihah CHÍNH LÀ Basmalah) — không thêm tài nguyên.
    expect(player.playlist.first.address, QuranAddress.surah(2));
    expect(
      player.playlist.first.source.toString(),
      'https://a.test/001001.mp3',
    );

    // Mục 1 trở đi mới là các Ayah thật.
    expect(player.playlist[1].address, QuranAddress.ayah(2, 1));
    expect(
      player.playlist[1].source.toString(),
      'https://a.test/002001.mp3',
    );
    expect(player.playlist.last.address, QuranAddress.ayah(2, 3));
    expect(player.playing, isTrue);

    // Sprint B1: mỗi mục mang đủ mô tả cho thông báo hệ điều hành.
    expect(player.playlist.first.surahName, 'Al-Baqarah');
    expect(player.playlist.first.reciterName, 'Alafasy');

    // `startIndex: 1` là chỉ số AYAH (Ayah 2) -> mục phát thứ 2.
    expect(player.initialIndex, 2);

    final state = container.read(audioControllerProvider);
    expect(state.active, isTrue);
    expect(state.surahId, 2);
    expect(state.currentIndex, 2); // chỉ số PLAYLIST
    expect(state.currentAddress, QuranAddress.ayah(2, 2)); // Ayah thật
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
        .playSurah(ayahs: _ayahs(2), from: QuranAddress.surah(2));

    expect(
      c2.read(audioControllerProvider).reciter?.code,
      'husary',
    );
    // BM1: mục đầu là phần mở đầu -> 001001 của CHÍNH Qari đó. Basmalah
    // không bao giờ đổi sang giọng khác giữa chừng.
    expect(
      player.playlist.first.source.toString(),
      'https://h.test/001001.mp3',
    );
    expect(
      player.playlist[1].source.toString(),
      'https://h.test/002001.mp3',
    );
  });

  test('Surah không có trong database -> tên rơi về địa chỉ, KHÔNG chặn phát',
      () async {
    final c = container.read(audioControllerProvider.notifier);
    // _RepoWithReciters chỉ biết Surah 2.
    await c.playSurah(
      ayahs: _ayahs(2, surahId: 3),
      from: QuranAddress.surah(3),
    );

    // Thiếu một cái tên không phải lý do để người dùng không nghe được.
    expect(player.playing, isTrue);
    expect(player.playlist, hasLength(3)); // BM1: 2 Ayah + phần mở đầu
    expect(player.playlist.first.surahName, '3');
  });

  test('nextAyah/previousAyah tôn trọng biên PLAYLIST (đã gồm mở đầu)',
      () async {
    final c = container.read(audioControllerProvider.notifier);
    // BM3: mức SURAH -> đọc từ đầu, nên bắt đầu ở phần mở đầu.
    await c.playSurah(ayahs: _ayahs(2), from: QuranAddress.surah(2));

    // Bắt đầu từ Ayah đầu = đọc Surah từ đầu -> mục 0 là Basmalah.
    expect(container.read(audioControllerProvider).currentIndex, 0);
    expect(
      container.read(audioControllerProvider).currentAddress,
      QuranAddress.surah(2),
    );

    await c.previousAyah(); // đang ở đầu playlist -> không lùi
    expect(container.read(audioControllerProvider).currentIndex, 0);

    await c.nextAyah(); // -> Ayah 1
    expect(container.read(audioControllerProvider).currentIndex, 1);
    expect(
      container.read(audioControllerProvider).currentAddress,
      QuranAddress.ayah(2, 1),
    );
    expect(player.seekedTo, 1);

    await c.nextAyah(); // -> Ayah 2 (mục cuối của playlist 3 mục)
    expect(container.read(audioControllerProvider).currentIndex, 2);

    await c.nextAyah(); // đã ở cuối -> đứng yên
    expect(container.read(audioControllerProvider).currentIndex, 2);
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
    await c.playSurah(ayahs: _ayahs(1), from: QuranAddress.surah(2));

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
    await c.playSurah(ayahs: _ayahs(1), from: QuranAddress.surah(2));
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
}
