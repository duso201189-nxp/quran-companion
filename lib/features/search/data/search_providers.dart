import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/data/quran_providers.dart';
import '../../quran/domain/entities/ayah_search_result.dart';

/// Từ khoá tìm kiếm hiện tại của [SearchScreen] — ĐỘC LẬP với
/// `surahSearchQueryProvider` (`surah_list_controller.dart`), vốn là
/// state riêng của ô tìm kiếm trên `SurahListScreen`. Hai màn hình
/// không được dùng chung một provider ở đây — gõ ở màn này không được
/// đụng tới màn kia (xem PHASE3_SPRINT_R1_DESIGN_REVIEW.md mục 1, 14).
///
/// **Sprint R1.2 — quyết định vòng đời, CỐ Ý KHÔNG `.autoDispose`.**
/// Đã kiểm tra: không có nơi nào trong `SearchScreen` gọi
/// `ref.watch(searchQueryProvider)` trực tiếp — màn hình chỉ
/// `ref.read(...notifier).state = ...` để GHI (trong `onChanged`/nút
/// xoá), còn nhánh hiển thị đọc `_queryController.text` (state cục bộ
/// của widget) để quyết định Empty/Loading/Error/NoResults/Results.
/// Provider DUY NHẤT thật sự `ref.watch` giá trị này là
/// [searchResultsProvider] — và nó chỉ được `SearchScreen` watch
/// (nên chỉ có subscriber) trong ĐÚNG nhánh thật (Mode Tìm kiếm,
/// Scope khác "Ghi chú của tôi") — nghĩa là số subscriber của
/// [searchQueryProvider] rơi về 0 bất cứ khi nào người dùng xoá hết
/// chữ, đổi Scope sang "Ghi chú của tôi", hoặc màn Empty State đang
/// hiện — tức RẤT THƯỜNG XUYÊN trong lúc gõ bình thường, không chỉ
/// lúc đóng màn hình. Nếu gắn `.autoDispose` ở đây, provider sẽ bị
/// huỷ và TÁI TẠO VỀ GIÁ TRỊ MẶC ĐỊNH `''` ngay giữa những khoảnh
/// khắc đó — nghĩa là từ khoá người dùng đang gõ có thể bị RESET một
/// cách khó lường, một lỗi thật chứ không phải lý thuyết, vì
/// `_buildBody` không có watcher liên tục nào giữ provider này sống.
/// Muốn `.autoDispose` an toàn sẽ cần thêm một `ref.watch` giữ-sống
/// liên tục trong `SearchScreen` — đúng dạng thay đổi cấu trúc màn
/// hình mà Sprint R1.2 được yêu cầu KHÔNG làm ("Do not redesign
/// SearchScreen"). Vì vậy giữ nguyên `StateProvider` thường (sống
/// suốt vòng đời app, như đa số provider hạ tầng khác trong dự án) —
/// đánh đổi chấp nhận được: giá trị có thể "cũ" nếu `SearchScreen`
/// được mở lại sau khi đã đóng, nhưng KHÔNG gây lỗi hiển thị vì
/// `_queryController.text` (luôn mới cho mỗi lần mở màn hình) mới là
/// nguồn quyết định UI, không phải provider này.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Tìm toàn văn Ayah (FTS5) cho [SearchScreen] — cùng cơ chế debounce
/// + kiểm tra query cũ với `ayahSearchProvider`
/// (`quran/presentation/surah_list_controller.dart`), nhưng đọc
/// [searchQueryProvider] riêng thay vì `surahSearchQueryProvider`.
/// Gọi thẳng `QuranRepository.searchAyahs()` đã có sẵn — không có
/// logic truy vấn mới, không đổi schema.
///
/// **Sprint R1.3 — rà soát debounce/gõ nhanh/kết quả cũ: CƠ CHẾ ĐÃ
/// ĐÚNG, KHÔNG thay thế.** Mỗi lần [searchQueryProvider] đổi (mỗi
/// phím gõ), Riverpod build lại closure này TỪ ĐẦU — bản build CŨ vẫn
/// tiếp tục chạy dở `await Future.delayed(...)` trong nền (Dart không
/// huỷ được `Future` đang chờ), nhưng dòng kiểm tra ngay sau đó
/// (`query != ref.read(searchQueryProvider)`) chặn nó gọi
/// `searchAyahs()` nếu người dùng đã gõ tiếp — nghĩa là gõ nhanh
/// KHÔNG sinh ra nhiều truy vấn DB chồng chéo, chỉ bản build ứng với
/// từ khoá ĐANG hiện tại mới thật sự gọi repository. Đồng thời,
/// `AsyncValue` của provider này chuyển sang `loading` NGAY khi build
/// lại (trước khi debounce/truy vấn xong), và [SearchScreen] luôn vẽ
/// [SearchLoadingSkeleton] cho nhánh `loading` — nên kết quả CŨ không
/// bao giờ còn hiển thị song song với một truy vấn MỚI đang chờ. Xem
/// `test/search_providers_test.dart` (nhóm "Sprint R1.3") cho phép
/// kiểm gõ nhanh trực tiếp trên cơ chế này.
final searchResultsProvider =
    FutureProvider.autoDispose<List<AyahSearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return const [];
  await Future<void>.delayed(const Duration(milliseconds: 250));
  // Query đã đổi trong lúc chờ -> phiên bản provider mới lo tiếp.
  if (query != ref.read(searchQueryProvider)) return const [];
  return ref.watch(quranRepositoryProvider).searchAyahs(query);
});
