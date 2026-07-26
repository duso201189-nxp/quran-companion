import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/features/profile/presentation/attribution/attribution_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/attribution_entry.dart';

/// Sprint 33.0 — CỔNG PHÁT HÀNH, không phải test giao diện.
///
/// Chạy trên đúng file dữ liệu sẽ phát hành. Nếu một bản dữ liệu mới
/// đưa vào một nguồn thiếu giấy phép hoặc thiếu địa chỉ, bản build đó
/// KHÔNG được rời khỏi máy — và test này là thứ chặn nó lại. Test dựng
/// bằng repo giả không thể làm việc đó, vì fake luôn có sẵn đúng những
/// trường mà người viết fake nhớ ra.

const _assetPath = 'assets/database/quran.sqlite';

void main() {
  final file = File(_assetPath);
  if (!file.existsSync()) {
    test('bỏ qua: chưa build assets/database/quran.sqlite', () {}, skip: true);
    return;
  }

  late ProviderContainer container;

  setUp(() {
    final copy = File('${file.path}.attribution-copy');
    copy.writeAsBytesSync(file.readAsBytesSync());
    final db = AppDatabase(NativeDatabase(copy));
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
      if (copy.existsSync()) copy.deleteSync();
    });
  });

  test('MỌI nguồn được phát hành đều có giấy phép và địa chỉ', () async {
    final data = await container.read(attributionProvider.future);

    expect(data.entries, isNotEmpty);
    for (final entry in data.entries) {
      expect(
        entry.license,
        isNotNull,
        reason: '${entry.name} phát hành mà không nêu giấy phép',
      );
      expect(entry.license, isNotEmpty, reason: entry.name);
      expect(
        entry.sourceUrl,
        isNotNull,
        reason: '${entry.name} phát hành mà không nêu địa chỉ nguồn',
      );
      expect(
        entry.sourceUrl,
        startsWith('http'),
        reason: '${entry.name} có địa chỉ không mở được',
      );
    }
  });

  test('văn bản Ả Rập ghi nguồn Tanzil kèm liên kết — điều khoản bắt buộc',
      () async {
    final data = await container.read(attributionProvider.future);
    final quranText =
        data.entries.where((e) => e.kind == AttributionKind.quranText).toList();

    // Điều khoản Tanzil: "The text can be used in any website or
    // application, provided that its source (Tanzil Project) is clearly
    // indicated and a link is made to tanzil.net".
    expect(quranText, hasLength(1));
    expect(quranText.single.author, contains('Tanzil'));
    expect(quranText.single.sourceUrl, contains('tanzil.net'));
  });

  test('mọi loại nội dung đang phát hành đều xuất hiện', () async {
    final data = await container.read(attributionProvider.future);
    final kinds = data.entries.map((e) => e.kind).toSet();

    // Bản build hiện tại: văn bản Ả Rập, phiên âm, bản dịch, Tafsir,
    // và các bản thu. Thiếu bất kỳ nhóm nào nghĩa là có nội dung đang
    // hiển thị trong app mà màn hình Ghi nguồn không nhắc tới.
    expect(kinds, containsAll(AttributionKind.values));
  });

  test('mỗi bản dịch/Tafsir nêu phiên bản — điều khoản QuranEnc mục 3',
      () async {
    final data = await container.read(attributionProvider.future);
    final texts = data.entries.where(
      (e) =>
          e.kind == AttributionKind.translation ||
          e.kind == AttributionKind.tafsir,
    );

    for (final entry in texts) {
      expect(
        entry.author,
        isNotNull,
        reason: '${entry.name} thiếu tác giả/nhà phát hành',
      );
    }
    // Bản Việt từ QuranEnc BẮT BUỘC có số phiên bản: điều khoản mục 3
    // đòi "mentioning the version number when re-publishing".
    final quranEnc = data.entries.where(
      (e) => (e.sourceUrl ?? '').contains('quranenc.com'),
    );
    expect(quranEnc, isNotEmpty);
    for (final entry in quranEnc) {
      expect(entry.version, isNotNull, reason: entry.name);
      expect(entry.version, isNotEmpty, reason: entry.name);
    }
  });
}
