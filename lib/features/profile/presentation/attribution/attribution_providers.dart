import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../quran/data/quran_providers.dart';
import '../../../quran/domain/entities/attribution_entry.dart';
import '../../../quran/presentation/audio/audio_controller.dart';

/// Toàn bộ nội dung màn hình Ghi nguồn.
///
/// Record (không phải class) để có sẵn value equality — màn hình
/// `select` từng phần được mà không dựng lại thừa.
typedef AttributionData = ({
  List<AttributionEntry> entries,
  String? dataVersion,
  String? builtAt,
});

/// Ghép ba nguồn metadata ĐÃ CÓ thành một danh sách phẳng.
///
/// KHÔNG thêm truy vấn nào cho hai phần lớn nhất: dùng lại
/// [translationSourcesProvider] (một truy vấn cho cả phiên chạy) và
/// [recitersProvider] (đã có sẵn cho thanh audio). Chỉ các khoá `meta`
/// là đọc mới, và chúng là những lượt đọc khoá chính trên bảng bốn
/// dòng.
///
/// KHÔNG `autoDispose`: cùng lý do với [translationSourcesProvider] —
/// dữ liệu nhóm A chỉ đọc, cố định theo bản phát hành.
///
/// TẠI SAO ghép ở provider chứ không ở repository: đây là một KHUNG
/// NHÌN của tầng trình bày, không phải một sự thật mới về dữ liệu.
/// Thêm `getAttribution()` vào [QuranRepository] sẽ tạo đúng loại
/// đường song song mà `DR-2026-0006` D5 đã bác — repository đã trả về
/// đủ mọi thứ cần thiết.
final attributionProvider = FutureProvider<AttributionData>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final sources = await ref.watch(translationSourcesProvider.future);
  final reciters = await ref.watch(recitersProvider.future);

  final quranTextName = await repo.getMetaValue('arabic_source');

  return (
    entries: <AttributionEntry>[
      // Văn bản Ả Rập đứng đầu: nó là nội dung mà mọi thứ còn lại chỉ
      // đang chú giải. Bỏ qua nếu bản dữ liệu chưa mô tả nó — thà
      // thiếu một mục còn hơn hiện một mục trống rỗng.
      if (quranTextName != null && quranTextName.isNotEmpty)
        AttributionEntry(
          kind: AttributionKind.quranText,
          name: quranTextName,
          author: await repo.getMetaValue('arabic_author'),
          language: 'ar',
          license: await repo.getMetaValue('arabic_license'),
          sourceUrl: await repo.getMetaValue('arabic_source_url'),
        ),
      for (final source in sources)
        AttributionEntry.fromTranslationSource(source),
      for (final reciter in reciters) AttributionEntry.fromReciter(reciter),
    ],
    dataVersion: await repo.getMetaValue('data_version'),
    builtAt: await repo.getMetaValue('built_at'),
  );
});
