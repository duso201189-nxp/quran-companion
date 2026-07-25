import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/entities/translation_source.dart';
import '../domain/repositories/quran_repository.dart';
import 'quran_repository_impl.dart';

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Danh mục nguồn văn bản đang bật, đã sắp theo `display_order`.
///
/// Sprint 30.1 — ĐÂY là danh sách điều khiển việc dựng các lớp văn bản
/// của trang đọc. Trước đó `getEnabledSources()` là một phương thức
/// repository KHÔNG CÓ NƠI GỌI: schema mô tả nguồn bằng dữ liệu, còn
/// giao diện lại ép cứng ba mã nguồn — chính khoảng lệch đó khiến mỗi
/// bản dịch/Tafsir mới đều phải sửa widget.
///
/// KHÔNG `autoDispose`, KHÔNG `family`: nội dung là dữ liệu nhóm A chỉ
/// đọc, đóng gói sẵn theo bản phát hành và không đổi trong lúc chạy.
/// Vì vậy đây là ĐÚNG MỘT truy vấn cho cả phiên chạy, dùng chung cho
/// mọi `AyahCard` của mọi Surah và cho bảng cài đặt — không phải một
/// truy vấn mỗi Ayah, mỗi Surah hay mỗi lần dựng lại.
final translationSourcesProvider = FutureProvider<List<TranslationSource>>(
  (ref) => ref.watch(quranRepositoryProvider).getEnabledSources(),
);

/// Các nguồn thuộc ĐƯỜNG ĐỌC — phiên âm + bản dịch, KHÔNG có Tafsir.
///
/// Sprint 30.2 — ranh giới đọc ở tầng trình bày. Đây là thứ mà
/// `AyahCard` và bảng cài đặt hiển thị phải dùng: nếu bảng cài đặt
/// liệt kê cả Tafsir, người dùng bật lên sẽ không thấy gì, vì
/// `getAyahsOfSurah` (đúng như thiết kế) không bao giờ nạp văn bản
/// Tafsir.
///
/// KHÔNG thêm truy vấn: lọc trên KẾT QUẢ của
/// [translationSourcesProvider] — vẫn đúng một truy vấn cho cả phiên
/// chạy. Một mặt hàng Tafsir tương lai sẽ dựng khung nhìn riêng của
/// nó từ CÙNG kết quả đó, cũng không tốn truy vấn mới.
final readingSourcesProvider = FutureProvider<List<TranslationSource>>(
  (ref) async {
    final all = await ref.watch(translationSourcesProvider.future);
    return [
      for (final source in all)
        if (source.isReadingLayer) source,
    ];
  },
);

/// Các nguồn Tafsir đang bật — KHUNG NHÌN ĐỐI XỨNG với
/// [readingSourcesProvider] (Sprint 31.2).
///
/// Lọc trên kết quả của [translationSourcesProvider], nên KHÔNG thêm
/// truy vấn nào: danh mục vẫn là đúng một lần đọc cho cả phiên chạy.
/// Đây chính là cơ chế mà `DR-2026-0007` D6 hứa — đi từ 1 lên 10 nguồn
/// Tafsir không sửa một dòng mã nào, chỉ thêm dữ liệu.
final tafsirSourcesProvider = FutureProvider<List<TranslationSource>>(
  (ref) async {
    final all = await ref.watch(translationSourcesProvider.future);
    return [
      for (final source in all)
        if (source.type == SourceType.tafsir) source,
    ];
  },
);
