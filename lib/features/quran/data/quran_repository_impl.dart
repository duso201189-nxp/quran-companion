import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/ayah.dart';
import '../domain/entities/ayah_content.dart';
import '../domain/entities/ayah_search_result.dart';
import '../domain/entities/covering_text.dart';
import '../domain/entities/reciter.dart';
import '../domain/entities/surah.dart';
import '../domain/entities/translation_source.dart';
import '../domain/repositories/quran_repository.dart';
import 'fts_query.dart';
import 'transliteration_repository.dart';

/// Triển khai QuranRepository trên Drift.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging() (core/logging/repository_boundary_logging.dart):
/// lỗi được map qua mapToAppFailure() và ghi log (Logger, TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây, đúng Task
/// 3), rồi LUÔN rethrow nguyên vẹn lỗi gốc — hành vi (giá trị trả về
/// hoặc lỗi ném ra) giữ NGUYÊN so với trước, chỉ thêm log khi có lỗi.
class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl(
    this._db,
    this._logger, {
    TransliterationRepository transliteration =
        const TransliterationRepository(),
  }) : _transliteration = transliteration;

  final AppDatabase _db;
  final Logger _logger;
  final TransliterationRepository _transliteration;

  @override
  Future<List<Surah>> getAllSurahs() {
    return withFailureLogging(_logger, 'getAllSurahs', () async {
      final rows = await (_db.select(_db.surahs)
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();
      return rows.map(_surahFromRow).toList(growable: false);
    });
  }

  @override
  Future<Surah?> getSurahById(int id) {
    return withFailureLogging(_logger, 'getSurahById', () async {
      final row = await (_db.select(_db.surahs)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row == null ? null : _surahFromRow(row);
    });
  }

  @override
  Future<List<TranslationSource>> getEnabledSources() {
    return withFailureLogging(_logger, 'getEnabledSources', () async {
      final rows = await (_db.select(_db.translationSources)
            ..where((t) => t.isEnabled.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
          .get();
      return rows.map(_sourceFromRow).toList(growable: false);
    });
  }

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) {
    return withFailureLogging(_logger, 'getAyahsOfSurah', () async {
      final ayahRows = await (_db.select(_db.ayahs)
            ..where((t) => t.surahId.equals(surahId))
            ..orderBy([(t) => OrderingTerm.asc(t.ayahNumber)]))
          .get();
      if (ayahRows.isEmpty) return const [];

      final ayahIds = ayahRows.map((a) => a.id).toList(growable: false);

      // Sprint 30.2 — RANH GIỚI ĐỌC nằm trong mệnh đề WHERE, không
      // phải ở tầng trình bày: lọc sau khi đã đọc lên bộ nhớ vẫn phải
      // trả giá đọc đĩa + cấp phát chuỗi cho toàn bộ chú giải của cả
      // Surah. Loại trừ theo danh sách dẫn xuất từ `kSourceTypeByCode`
      // (không phải liệt kê loại được phép) nên loại LẠ — bộ dữ liệu
      // mới hơn mã nguồn — vẫn hiển thị, đúng quyết định Sprint 30.2.
      final byAyah = await _textsForAyahs(
        ayahIds,
        _db.translationSources.type.isNotIn(kNonReadingSourceTypeCodes),
      );

      return [
        for (final a in ayahRows)
          AyahContent(
            ayah: _ayahFromRow(a),
            texts: byAyah[a.id] ?? const <String, String>{},
          ),
      ];
    });
  }

  @override
  Future<List<CoveringText>> getTextsCoveringAyah({
    required int ayahId,
    required Set<SourceType> types,
  }) {
    return withFailureLogging(_logger, 'getTextsCoveringAyah', () async {
      if (types.isEmpty) return const <CoveringText>[];

      // Với MỖI nguồn, lấy mục có `ayah_id` LỚN NHẤT mà vẫn <= Ayah
      // đang xem VÀ còn nằm trong cùng Surah. Đó chính là đoạn đang
      // phủ Ayah này — đoạn kéo dài tới ngay trước mục kế tiếp.
      //
      // Chặn `>= MIN(ayah của Surah này)` là thứ ngăn đoạn cuối của
      // Surah trước tràn sang Surah sau (đã kiểm 114 Surah, 0 ca rò).
      //
      // VẪN MỘT truy vấn, không N+1: SQLite giải truy vấn tương quan
      // cho từng nguồn bên trong cùng một câu lệnh.
      final placeholders = List.filled(types.length, '?').join(', ');
      final rows = await _db.customSelect(
        'SELECT s.code AS code, t.text AS text, t.ayah_id AS start_id '
        'FROM translation_sources s '
        'JOIN translations t ON t.source_id = s.id '
        'WHERE s.is_enabled = 1 '
        'AND s.type IN ($placeholders) '
        'AND t.ayah_id = ('
        '  SELECT MAX(t2.ayah_id) FROM translations t2 '
        '  WHERE t2.source_id = s.id AND t2.ayah_id <= ? '
        '    AND t2.ayah_id >= ('
        '      SELECT MIN(a2.id) FROM ayahs a2 '
        '      WHERE a2.surah_id = (SELECT surah_id FROM ayahs WHERE id = ?)'
        '    )'
        ') '
        'ORDER BY s.display_order',
        variables: [
          for (final code in sourceTypeCodesFor(types))
            Variable.withString(code),
          Variable.withInt(ayahId),
          Variable.withInt(ayahId),
        ],
        readsFrom: {_db.translations, _db.translationSources, _db.ayahs},
      ).get();

      return [
        for (final row in rows)
          CoveringText(
            sourceCode: row.read<String>('code'),
            text: row.read<String>('text'),
            startAyahId: row.read<int>('start_id'),
          ),
      ];
    });
  }

  /// MỘT truy vấn join, dùng chung cho mọi lối nạp văn bản theo Ayah.
  ///
  /// Sprint 31.2 — trước đây phần join này chỉ tồn tại bên trong
  /// `getAyahsOfSurah`; Study cần đúng phép join đó với bộ lọc khác.
  /// Tách ra và nhận [sourceFilter] làm THAM SỐ để hai lối nạp không
  /// bao giờ lệch nhau về chuẩn hoá phiên âm hay điều kiện `is_enabled`
  /// — đó là "không nhân bản SQL" theo đúng nghĩa.
  ///
  /// Bộ lọc là biểu thức chứ không phải danh sách loại: đường đọc loại
  /// TRỪ (giữ loại lạ), Study chọn VÀO (chỉ đúng loại yêu cầu) — hai
  /// hình dạng vị từ khác nhau, không gộp được thành một tham số.
  Future<Map<int, Map<String, String>>> _textsForAyahs(
    List<int> ayahIds,
    Expression<bool> sourceFilter,
  ) async {
    final query = _db.select(_db.translations).join([
      innerJoin(
        _db.translationSources,
        _db.translationSources.id.equalsExp(_db.translations.sourceId),
      ),
    ])
      ..where(
        _db.translations.ayahId.isIn(ayahIds) &
            _db.translationSources.isEnabled.equals(true) &
            sourceFilter,
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
    return byAyah;
  }

  @override
  Future<List<Reciter>> getEnabledReciters() {
    return withFailureLogging(_logger, 'getEnabledReciters', () async {
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
            license: r.license,
            sourceUrl: r.sourceUrl,
          ),
      ];
    });
  }

  @override
  Future<String?> getMetaValue(String key) {
    return withFailureLogging(_logger, 'getMetaValue', () async {
      final row = await (_db.select(_db.metaEntries)
            ..where((t) => t.key.equals(key)))
          .getSingleOrNull();
      return row?.value;
    });
  }

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) {
    return withFailureLogging(_logger, 'searchAyahs', () async {
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
    });
  }

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) {
    return withFailureLogging(
      _logger,
      'getAyahsByIds',
      () => _headersForIds(ids.toSet().toList()),
    );
  }

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

    // Bản dịch xem trước cho tiêu đề kết quả: liệt kê MÃ nguồn cụ thể
    // nên Tafsir không lọt vào — nhưng là do trùng hợp, không do
    // ranh giới. Nếu sau này đổi sang lọc theo LOẠI (vd "bản dịch
    // theo ngôn ngữ giao diện"), PHẢI dùng
    // `type.isNotIn(kNonReadingSourceTypeCodes)` như
    // `getAyahsOfSurah`, nếu không chú giải dài sẽ tràn vào ô xem
    // trước một dòng.
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
        // Dùng bảng ánh xạ dùng chung (Sprint 30.2) thay cho `switch`
        // riêng ở đây — cùng một nguồn sự thật với bộ lọc SQL của
        // đường đọc.
        type: kSourceTypeByCode[row.type] ?? SourceType.translation,
        displayOrder: row.displayOrder,
        author: row.author,
        license: row.license,
        sourceUrl: row.sourceUrl,
        version: row.version,
        updatedAt: row.updatedAt,
      );
}
