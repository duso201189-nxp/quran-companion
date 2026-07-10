import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/ayah.dart';
import '../domain/entities/ayah_content.dart';
import '../domain/entities/ayah_search_result.dart';
import '../domain/entities/reciter.dart';
import '../domain/entities/surah.dart';
import '../domain/entities/translation_source.dart';
import '../domain/repositories/quran_repository.dart';
import 'fts_query.dart';
import 'transliteration_repository.dart';

/// Triển khai QuranRepository trên Drift.
class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl(
    this._db, {
    TransliterationRepository transliteration =
        const TransliterationRepository(),
  }) : _transliteration = transliteration;

  final AppDatabase _db;
  final TransliterationRepository _transliteration;

  @override
  Future<List<Surah>> getAllSurahs() async {
    final rows = await (_db.select(_db.surahs)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows.map(_surahFromRow).toList(growable: false);
  }

  @override
  Future<Surah?> getSurahById(int id) async {
    final row = await (_db.select(_db.surahs)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _surahFromRow(row);
  }

  @override
  Future<List<TranslationSource>> getEnabledSources() async {
    final rows = await (_db.select(_db.translationSources)
          ..where((t) => t.isEnabled.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
        .get();
    return rows.map(_sourceFromRow).toList(growable: false);
  }

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async {
    final ayahRows = await (_db.select(_db.ayahs)
          ..where((t) => t.surahId.equals(surahId))
          ..orderBy([(t) => OrderingTerm.asc(t.ayahNumber)]))
        .get();
    if (ayahRows.isEmpty) return const [];

    final ayahIds = ayahRows.map((a) => a.id).toList(growable: false);

    // 1 truy vấn join lấy văn bản mọi nguồn đang bật cho cả Surah —
    // tránh N+1 (hiệu năng là yêu cầu bất biến, xem ARCHITECTURE.md).
    final query = _db.select(_db.translations).join([
      innerJoin(
        _db.translationSources,
        _db.translationSources.id.equalsExp(_db.translations.sourceId),
      ),
    ])
      ..where(
        _db.translations.ayahId.isIn(ayahIds) &
            _db.translationSources.isEnabled.equals(true),
      );

    final byAyah = <int, Map<String, String>>{};
    for (final row in await query.get()) {
      final translation = row.readTable(_db.translations);
      final source = row.readTable(_db.translationSources);
      // Phiên âm đi qua TransliterationRepository: dataset chuẩn giữ
      // nguyên, dữ liệu định dạng cũ được chuyển sang Unicode sạch.
      final text = source.type == TransliterationRepository.sourceType
          ? _transliteration.normalize(translation.content)
          : translation.content;
      (byAyah[translation.ayahId] ??= <String, String>{})[source.code] = text;
    }

    return [
      for (final a in ayahRows)
        AyahContent(
          ayah: _ayahFromRow(a),
          texts: byAyah[a.id] ?? const <String, String>{},
        ),
    ];
  }

  @override
  Future<List<Reciter>> getEnabledReciters() async {
    final rows = await (_db.select(_db.reciters)
          ..where((t) => t.isEnabled.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
        .get();
    return [
      for (final r in rows)
        Reciter(
          code: r.code,
          name: r.name,
          nameArabic: r.nameArabic,
          audioUrlTemplate: r.audioUrlTemplate,
          bitrateKbps: r.bitrateKbps,
        ),
    ];
  }

  @override
  Future<String?> getMetaValue(String key) async {
    final row = await (_db.select(_db.metaEntries)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async {
    final match = ftsMatchExpression(query);
    if (match == null) return const [];

    // 1) FTS5: lấy ayah_id khớp (mọi nguồn), thứ tự Mushaf.
    final idRows = await _db.customSelect(
      'SELECT DISTINCT ayah_id FROM search_index '
      'WHERE search_index MATCH ? AND source_code IN '
      "('arabic_plain','vi_main_plain','translit_latin_plain','en_sahih') "
      'ORDER BY ayah_id LIMIT ?',
      variables: [
        Variable.withString(match),
        Variable.withInt(limit),
      ],
    ).get();
    final ids = [for (final r in idRows) r.read<int>('ayah_id')];
    return _headersForIds(ids);
  }

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) =>
      _headersForIds(ids.toSet().toList());

  /// Nạp Ayah + tên Surah + bản dịch hiển thị cho danh sách id,
  /// trả về theo thứ tự id tăng dần. Dùng chung cho tìm kiếm và
  /// Thư viện của tôi.
  Future<List<AyahSearchResult>> _headersForIds(List<int> ids) async {
    if (ids.isEmpty) return const [];

    final ayahRows = await (_db.select(_db.ayahs)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    if (ayahRows.isEmpty) return const [];

    final surahIds = {for (final a in ayahRows) a.surahId};
    final surahRows = await (_db.select(_db.surahs)
          ..where((t) => t.id.isIn(surahIds.toList())))
        .get();
    final surahName = {for (final s in surahRows) s.id: s.nameLatin};

    final translationQuery = _db.select(_db.translations).join([
      innerJoin(
        _db.translationSources,
        _db.translationSources.id.equalsExp(_db.translations.sourceId),
      ),
    ])
      ..where(
        _db.translations.ayahId.isIn(ids) &
            _db.translationSources.code.isIn(['vi_main', 'en_sahih']),
      );
    final vi = <int, String>{};
    final en = <int, String>{};
    for (final row in await translationQuery.get()) {
      final t = row.readTable(_db.translations);
      final s = row.readTable(_db.translationSources);
      (s.code == 'vi_main' ? vi : en)[t.ayahId] = t.content;
    }

    return [
      for (final a in ayahRows)
        AyahSearchResult(
          ayahId: a.id,
          surahId: a.surahId,
          ayahNumber: a.ayahNumber,
          surahNameLatin: surahName[a.surahId] ?? '',
          arabic: a.textUthmani,
          translation: vi[a.id] ?? en[a.id],
        ),
    ];
  }

  // ------------------- mappers -------------------

  Surah _surahFromRow(SurahRow row) => Surah(
        id: row.id,
        nameArabic: row.nameArabic,
        nameLatin: row.nameLatin,
        nameVi: row.nameVi,
        nameEn: row.nameEn,
        ayahCount: row.ayahCount,
        revelationPlace: switch (row.revelationPlace) {
          'madinah' => RevelationPlace.madinah,
          _ => RevelationPlace.mecca,
        },
        orderRevealed: row.orderRevealed,
      );

  Ayah _ayahFromRow(AyahRow row) => Ayah(
        id: row.id,
        surahId: row.surahId,
        ayahNumber: row.ayahNumber,
        textUthmani: row.textUthmani,
        juz: row.juz,
        hizb: row.hizb,
        page: row.page,
        sajdah: row.sajdah,
      );

  TranslationSource _sourceFromRow(TranslationSourceRow row) =>
      TranslationSource(
        id: row.id,
        code: row.code,
        name: row.name,
        language: row.language,
        type: switch (row.type) {
          'transliteration' => SourceType.transliteration,
          'tafsir' => SourceType.tafsir,
          _ => SourceType.translation,
        },
        displayOrder: row.displayOrder,
        author: row.author,
        license: row.license,
        sourceUrl: row.sourceUrl,
        version: row.version,
        updatedAt: row.updatedAt,
      );
}
