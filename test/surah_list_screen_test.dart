import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Repository giả — điều khiển được kết quả trả về cho từng test.
class _FakeQuranRepository implements QuranRepository {
  _FakeQuranRepository(this._surahs, {this.failFirstCall = false});

  final List<Surah> _surahs;
  bool failFirstCall;

  @override
  Future<List<Surah>> getAllSurahs() async {
    if (failFirstCall) {
      failFirstCall = false; // lần gọi sau (Thử lại) sẽ thành công
      throw Exception('mất mạng (giả lập)');
    }
    return _surahs;
  }

  @override
  Future<Surah?> getSurahById(int id) async => null;

  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];

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
}

final _testSurahs = [
  const Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai Đề',
    nameEn: 'The Opening',
    ayahCount: 7,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  ),
  const Surah(
    id: 2,
    nameArabic: 'البقرة',
    nameLatin: 'Al-Baqarah',
    nameVi: 'Con Bò Cái',
    nameEn: 'The Cow',
    ayahCount: 286,
    revelationPlace: RevelationPlace.madinah,
    orderRevealed: 87,
  ),
];

Widget _app(QuranRepository repo) {
  return ProviderScope(
    overrides: [quranRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(
      locale: Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SurahListScreen(),
    ),
  );
}

void main() {
  testWidgets('loading state hiển thị khi đang tải', (tester) async {
    // completer giữ Future treo -> luôn ở trạng thái loading
    final repo = _FakeQuranRepository(_testSurahs);
    await tester.pumpWidget(_app(repo));
    // chưa pumpAndSettle -> frame đầu là loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('data state: hiển thị Surah với đủ thông tin', (tester) async {
    await tester.pumpWidget(_app(_FakeQuranRepository(_testSurahs)));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.textContaining('7 câu'), findsOneWidget);
    expect(find.textContaining('286 câu'), findsOneWidget);
  });

  testWidgets('lọc Madinah chỉ còn Al-Baqarah', (tester) async {
    await tester.pumpWidget(_app(_FakeQuranRepository(_testSurahs)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Madinah').first);
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);
  });

  testWidgets('tìm không dấu "khai de" ra Al-Fatihah', (tester) async {
    await tester.pumpWidget(_app(_FakeQuranRepository(_testSurahs)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'khai de');
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('Al-Baqarah'), findsNothing);
  });

  testWidgets('không khớp -> empty state', (tester) async {
    await tester.pumpWidget(_app(_FakeQuranRepository(_testSurahs)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'xyzabc');
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy Surah nào phù hợp.'), findsOneWidget);
    expect(find.byType(SurahTile), findsNothing);
  });

  testWidgets('error state có nút Thử lại, bấm xong tải thành công',
      (tester) async {
    final repo = _FakeQuranRepository(_testSurahs, failFirstCall: true);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(
      find.text('Không tải được dữ liệu. Vui lòng thử lại.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
  });

  testWidgets('layout không vỡ ở text scale 200% (accessibility)',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(_FakeQuranRepository(_testSurahs)),
      ),
    );
    await tester.pumpAndSettle();

    // Không exception overflow nghĩa là pass; kiểm tra thêm nội dung.
    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
