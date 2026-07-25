import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:quran_companion/features/quran/presentation/audio/audio_bar.dart';
import 'package:quran_companion/features/quran/presentation/audio/audio_controller.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint 28.0 — [AudioBar] được chia theo NHỊP THAY ĐỔI: chỉ dải tiến
/// độ và nhãn thời gian nghe `position`, hàng nút thì không.
///
/// Test khoá lại chính điều đó bằng ĐỊNH DANH widget: Flutter chỉ tạo
/// đối tượng Widget mới khi phần đó thật sự dựng lại, nên `identical`
/// là bằng chứng trực tiếp — không phải suy đoán từ số lần vẽ.

class _Repo implements QuranRepository {
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [
        Reciter(
          code: 'alafasy',
          name: 'Alafasy (test)',
          audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
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
        quranRepositoryProvider.overrideWithValue(_Repo()),
        ayahAudioPlayerProvider.overrideWithValue(player),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(bottomNavigationBar: AudioBar()),
        ),
      ),
    );
  }

  Future<void> startPlayback(WidgetTester tester) async {
    await container.read(audioControllerProvider.notifier).playSurah(
      surahId: 2,
      ayahs: const [
        Ayah(id: 1, surahId: 2, ayahNumber: 1, textUthmani: 'x'),
        Ayah(id: 2, surahId: 2, ayahNumber: 2, textUthmani: 'y'),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chưa phát -> thanh không chiếm chỗ', (tester) async {
    await pumpBar(tester);
    expect(find.byIcon(Icons.skip_next), findsNothing);
  });

  testWidgets('tick vị trí chỉ dựng lại nhãn thời gian — hàng nút giữ nguyên',
      (tester) async {
    await pumpBar(tester);
    await startPlayback(tester);

    player.durationController.add(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    // Trước tick: ghi nhớ đúng đối tượng Widget của hàng nút.
    final speedBefore = tester.widget<Text>(find.text('1.0x'));
    final reciterBefore = tester.widget<Text>(find.text('Alafasy (test)'));
    expect(find.textContaining('0:00'), findsOneWidget);

    // Một tick vị trí vượt ngưỡng throttle 300ms của controller.
    player.positionController.add(const Duration(seconds: 9));
    await tester.pumpAndSettle();

    // Nhãn thời gian PHẢI đổi — nếu không, phép so bên dưới vô nghĩa.
    expect(find.textContaining('0:09'), findsOneWidget);

    // ...còn hàng nút thì KHÔNG được dựng lại.
    expect(
      identical(tester.widget<Text>(find.text('1.0x')), speedBefore),
      isTrue,
    );
    expect(
      identical(
        tester.widget<Text>(find.text('Alafasy (test)')),
        reciterBefore,
      ),
      isTrue,
    );
  });

  testWidgets('đổi trạng thái phát thì hàng nút MỚI dựng lại (đổi icon)',
      (tester) async {
    await pumpBar(tester);
    await startPlayback(tester);

    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);

    await container.read(audioControllerProvider.notifier).togglePlayPause();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_filled), findsNothing);
  });

  testWidgets('lỗi phát -> hiện hàng lỗi kèm Thử lại; retry nạp lại nguồn',
      (tester) async {
    await pumpBar(tester);
    await startPlayback(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    expect(find.text(l10n.audioError), findsNothing);

    player.errorController.add('boom');
    await tester.pumpAndSettle();
    expect(find.text(l10n.audioError), findsOneWidget);

    player.playlist = const [];
    await tester.tap(find.text(l10n.retry));
    await tester.pumpAndSettle();

    // Dùng lại ĐÚNG nguồn đã lưu trong controller, không dựng lại URL.
    expect(player.playlist.length, 2);
  });
}
