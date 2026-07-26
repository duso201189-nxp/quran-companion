import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/profile/presentation/attribution/attribution_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/covering_text.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Sprint 33.0 — màn hình Ghi nguồn phải ĐƯỢC DỮ LIỆU ĐIỀU KHIỂN.
///
/// Test then chốt ở đây là `nguồn mới xuất hiện mà không sửa mã`: nếu
/// ai đó thay danh sách dựng từ database bằng một danh sách viết tay
/// (chính là thứ màn hình này vừa thay thế), test đó sẽ đỏ.

const _meta = {
  'arabic_source': 'Tanzil.net Uthmani (verified text)',
  'arabic_author': 'Tanzil Project',
  'arabic_source_url': 'https://tanzil.net/download/',
  'arabic_license': 'Tanzil Terms',
  'data_version': '6',
  'built_at': '2026-07-26',
};

class _Repo implements QuranRepository {
  _Repo({this.sources = const [], this.reciters = const [], this.meta = _meta});

  final List<TranslationSource> sources;
  final List<Reciter> reciters;
  final Map<String, String> meta;

  @override
  Future<List<TranslationSource>> getEnabledSources() async => sources;

  @override
  Future<List<Reciter>> getEnabledReciters() async => reciters;

  @override
  Future<String?> getMetaValue(String key) async => meta[key];

  @override
  Future<List<Surah>> getAllSurahs() async => const [];
  @override
  Future<Surah?> getSurahById(int id) async => null;
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String q, {
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

TranslationSource _source(
  int id,
  String code,
  String name,
  String language,
  SourceType type, {
  String? author,
  String? license,
  String? url,
  String? version,
}) {
  return TranslationSource(
    id: id,
    code: code,
    name: name,
    language: language,
    type: type,
    displayOrder: id,
    author: author,
    license: license,
    sourceUrl: url,
    version: version,
  );
}

Future<void> _pump(WidgetTester tester, _Repo repo, {Locale? locale}) async {
  // Khung nhìn CAO: `ListView` dựng con theo kiểu lười, nên trên khung
  // 600px mặc định các mục cuối (Qari, nguồn thứ tư) chưa tồn tại
  // trong cây widget và `find` sẽ không thấy — một test xanh giả nếu
  // ta chỉ kiểm mục đầu.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [quranRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: locale ?? const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AttributionScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mỗi nguồn đang bật thành đúng một thẻ, kèm giấy phép + địa chỉ',
      (tester) async {
    await _pump(
      tester,
      _Repo(
        sources: [
          _source(
            2,
            'vi_main',
            'Rowwad Vietnamese',
            'vi',
            SourceType.translation,
            author: 'Rowwad Translation Center',
            license: 'QuranEnc terms',
            url: 'https://quranenc.com/en/browse/vietnamese_rwwad',
            version: '1.0.8',
          ),
        ],
        reciters: const [
          Reciter(
            code: 'alafasy',
            name: 'Mishary Rashid Alafasy',
            nameArabic: 'مشاري راشد العفاسي',
            audioUrlTemplate: 'https://a.test/{sss}{aaa}.mp3',
            license: 'Phi thương mại — everyayah.com',
            sourceUrl: 'https://everyayah.com',
          ),
        ],
      ),
    );

    // Văn bản Ả Rập (từ `meta`) + 1 bản dịch + 1 Qari.
    expect(find.text('Tanzil.net Uthmani (verified text)'), findsOneWidget);
    expect(find.text('Rowwad Vietnamese'), findsOneWidget);
    expect(find.text('Mishary Rashid Alafasy'), findsOneWidget);

    // Đây là phần có ý nghĩa pháp lý: giấy phép và địa chỉ của MỌI mục.
    expect(find.text('Tanzil Terms'), findsOneWidget);
    expect(find.text('QuranEnc terms'), findsOneWidget);
    expect(find.text('Phi thương mại — everyayah.com'), findsOneWidget);
    expect(find.text('https://tanzil.net/download/'), findsOneWidget);
    expect(
      find.text('https://quranenc.com/en/browse/vietnamese_rwwad'),
      findsOneWidget,
    );
    expect(find.text('https://everyayah.com'), findsOneWidget);

    // Ghi công tác giả + phiên bản bản dịch (điều khoản QuranEnc mục 3).
    expect(find.text('Rowwad Translation Center'), findsOneWidget);
    expect(find.text('1.0.8'), findsOneWidget);

    // Tên Latin của Qari KHÔNG bị ép RTL chỉ vì bản thu là tiếng Ả Rập;
    // tên Ả Rập của chính người đó thì có.
    expect(
      tester.widget<Text>(find.text('Mishary Rashid Alafasy')).textDirection,
      TextDirection.ltr,
    );
    expect(
      tester.widget<Text>(find.text('مشاري راشد العفاسي')).textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('thêm nguồn = thêm dữ liệu: nguồn thứ tư tự xuất hiện',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));

    await _pump(
      tester,
      _Repo(
        sources: [
          // Tên KHÁC hẳn nhãn nhóm, để `find.text` phân biệt được
          // tiêu đề nhóm với tên nguồn.
          _source(
            1,
            'translit',
            'Latin (Quran.com)',
            'en',
            SourceType.transliteration,
          ),
          _source(2, 'vi_main', 'Bản Việt', 'vi', SourceType.translation),
          _source(3, 'tafsir_a', 'Tafsir Muyassar', 'ar', SourceType.tafsir),
          // Nguồn "mới": mã nguồn KHÔNG biết gì về nó.
          _source(
            4,
            'ur_new',
            'Urdu Translation',
            'ur',
            SourceType.translation,
          ),
        ],
      ),
    );

    expect(find.text('Urdu Translation'), findsOneWidget);
    // ...và nó nằm đúng trong nhóm Bản dịch đang tồn tại.
    expect(find.text(l10n.attributionKindTranslation), findsOneWidget);
    expect(find.text(l10n.attributionKindTafsir), findsOneWidget);
    expect(find.text(l10n.attributionKindTransliteration), findsOneWidget);
  });

  testWidgets('nhóm rỗng không hiện tiêu đề', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));

    await _pump(
      tester,
      _Repo(
        sources: [
          _source(2, 'vi_main', 'Bản Việt', 'vi', SourceType.translation),
        ],
      ),
    );

    expect(find.text(l10n.attributionKindTranslation), findsOneWidget);
    // Không có Tafsir và không có Qari trong bản dữ liệu này.
    expect(find.text(l10n.attributionKindTafsir), findsNothing);
    expect(find.text(l10n.attributionKindAudio), findsNothing);
  });

  testWidgets(
      'tên nguồn Ả Rập dựng theo chiều RTL ngay khi app chạy tiếng Việt',
      (tester) async {
    await _pump(
      tester,
      _Repo(
        sources: [
          _source(3, 'tafsir_a', 'المیسر', 'ar', SourceType.tafsir),
          _source(2, 'vi_main', 'Bản Việt', 'vi', SourceType.translation),
        ],
      ),
    );

    expect(
      tester.widget<Text>(find.text('المیسر')).textDirection,
      TextDirection.rtl,
    );
    expect(
      tester.widget<Text>(find.text('Bản Việt')).textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('nút sao chép đưa địa chỉ nguồn vào clipboard', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await _pump(
      tester,
      _Repo(
        sources: [
          _source(
            2,
            'vi_main',
            'Bản Việt',
            'vi',
            SourceType.translation,
            url: 'https://quranenc.com',
          ),
        ],
        meta: const {},
      ),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pumpAndSettle();

    expect(copied, 'https://quranenc.com');
    expect(find.text(l10n.attributionUrlCopied), findsOneWidget);
  });

  testWidgets('chân trang nêu phiên bản dữ liệu đang chạy', (tester) async {
    await _pump(tester, _Repo());
    expect(find.text('6 · 2026-07-26'), findsOneWidget);
  });

  testWidgets('bản dữ liệu không mô tả nguồn nào -> nói thẳng, không thẻ rỗng',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    await _pump(tester, _Repo(meta: const {}));
    expect(find.text(l10n.attributionEmpty), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });
}
