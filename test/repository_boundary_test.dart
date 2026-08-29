// CỔNG RANH GIỚI KHO MÃ — `DR-2026-0013` giai đoạn B1/B2, CỐT LÕI.
//
// Kho mã này CÔNG KHAI. Nội dung có giấy phép hạn chế không được phép
// nằm trong nó: đưa một bộ chú giải vào git không phải là "đóng gói
// nội dung trong ứng dụng" (thứ mà giấy phép cho phép, hoặc đang xin),
// mà là "xuất bản nguyên văn tác phẩm dưới dạng tệp tải về" — một
// hành vi khác hẳn và khó biện minh hơn nhiều với người giữ quyền.
//
// TẠI SAO PHẢI LÀ TEST, KHÔNG PHẢI TÀI LIỆU:
//
//   `.gitignore`      bỏ qua được bằng `git add -f` (và trên nhánh này
//                     hiện chưa liệt kê các mẫu hạn chế — xem
//                     CI_GATE_CORE_PLAN.md §2, cổng này không dựa vào
//                     lớp đó để hoạt động)
//   pre-commit hook   bỏ qua được bằng `--no-verify`, và không tồn tại
//                     trên một bản clone mới (không có hook nào được
//                     theo dõi trong kho mã này)
//   soát xét mã       một tệp JSON 10 MB trong diff chỉ là MỘT DÒNG
//   tài liệu          không làm hỏng được bản build
//
// Cổng này chạy trong CI trên mọi push và mọi pull request, kể cả từ
// fork (nó chỉ đọc metadata của git, không cần bí mật nào), tự động —
// `ci.yml` không cần sửa gì để chạy tệp này, `flutter test --coverage`
// đã quét toàn bộ `test/`.
//
// TỆP NÀY LÀ PHẦN CỐT LÕI, TÁCH THEO `CI_GATE_SPLIT_PLAN.md`:
//   • CÓ  : cơ chế cấm-theo-mẫu, cơ chế chặn-theo-kích-thước, và các
//           test tự kiểm sự toàn vẹn của chính cơ chế miễn trừ.
//           KHÔNG phụ thuộc bất kỳ tệp miễn trừ cụ thể nào có tồn tại
//           hay không — danh sách miễn trừ rỗng vẫn làm cổng chạy
//           đúng, thậm chí NGHIÊM NGẶT HƠN (không tệp nào được tha).
//   • KHÔNG: test "mọi mục miễn trừ vượt ngưỡng đều nêu giai đoạn gỡ
//           nó" — test đó chỉ chứng minh cơ chế chặn-kích-thước đã
//           từng được thử với dữ liệu thật, một câu hỏi về ĐỘ ĐẦY ĐỦ,
//           không phải về BẢO VỆ. Xem
//           `test/repository_boundary_completeness_test.dart`.
//
// TRẠNG THÁI DANH SÁCH MIỄN TRỪ TRÊN NHÁNH NÀY (`main`):
//   `main` không "sạch" — nó đã theo dõi từ trước ba trong năm tệp mà
//   `sprint1-my-library` miễn trừ (database trước khi nhập tafsir, và
//   cả hai bộ phiên âm). HAI mục còn lại (Ibn Kathir, Al-Muyassar)
//   KHÔNG được miễn trừ ở đây vì `main` chưa từng theo dõi chúng — nếu
//   ai đó thêm lại đúng hai tệp đó vào `main`, cổng này phải bắt được
//   ngay, và nó sẽ bắt được vì `_grandfathered` dưới đây không có tên
//   chúng.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mẫu đường dẫn của nội dung KHÔNG được phép nằm trong kho mã công
/// khai. Khớp theo MẪU, không theo tên cụ thể: một bộ Tafsir MỚI thêm
/// vào mai sau cũng bị chặn mà không ai phải nhớ sửa danh sách này.
///
/// Nguồn của các mẫu: `docs/LICENSING.md`. Mỗi mẫu tương ứng một dạng
/// nội dung mà ít nhất một nguồn trong đó có `redistribute_file` là
/// `deny` hoặc `unknown`.
final List<({RegExp pattern, String reason})> _restricted = [
  (
    pattern: RegExp(r'^assets/database/.*\.sqlite$'),
    reason: 'database nội dung — chứa TOÀN BỘ các nguồn hiện có, kể cả '
        'bản dịch chỉ-phi-thương-mại',
  ),
  (
    pattern: RegExp(r'^tool/data/tafsir_.*\.json$'),
    reason: 'bộ chú giải Tafsir — Ibn Kathir (Abridged) là (c) Maktaba '
        'Dar-us-Salam 2003; Al-Muyassar chưa xác minh',
  ),
  (
    pattern: RegExp(r'^tool/data/transliteration.*\.json$'),
    reason: 'bộ phiên âm Quran.com QDC — giấy phép chưa xác minh',
  ),
  (
    pattern: RegExp(r'\.(sqlite3?|db)$'),
    reason: 'database nội dung ở bất kỳ đâu trong cây thư mục',
  ),
];

/// MIỄN TRỪ TẠM THỜI — những tệp ĐÃ nằm trong git trước khi cổng này
/// tồn tại, TRÊN NHÁNH NÀY. Không có danh sách này, cổng sẽ đỏ ngay
/// lúc merge vì `main` đã theo dõi ba tệp này từ trước cả DR-2026-0013.
///
/// ĐƯỜNG DẪN CHÍNH XÁC, KHÔNG PHẢI MẪU — đây là điểm mấu chốt của cả
/// cổng. Nếu miễn trừ theo mẫu thì một bộ Tafsir MỚI cũng được miễn
/// theo. Miễn theo đường dẫn chính xác nghĩa là đúng ba tệp này được
/// tha, tệp thứ tư thì không.
///
/// Mỗi dòng ghi rõ GIAI ĐOẠN NÀO XOÁ NÓ. Danh sách này chỉ được ngắn
/// đi, không bao giờ dài ra. So với `sprint1-my-library` (5 mục),
/// nhánh này THIẾU hai mục — `tool/data/tafsir_en-tafsir-ibn-kathir.json`
/// và `tool/data/tafsir_ar-tafsir-muyassar.json` — vì `main` chưa từng
/// theo dõi chúng. Đó KHÔNG phải một điểm yếu cần bù đắp; đó chính là
/// cổng đang làm đúng việc của nó.
const Map<String, String> _grandfathered = {
  'assets/database/quran.sqlite':
      'thôi theo dõi ở giai đoạn D1 — DR-2026-0008 nước đi B',
  'tool/data/transliteration.json': 'thôi theo dõi ở giai đoạn D2',
  'tool/data/transliteration_words.json': 'thôi theo dõi ở giai đoạn D2',
};

/// Mọi tệp đang được git theo dõi, đường dẫn tương đối gốc kho mã.
///
/// Dùng `-z` để tên tệp lạ (khoảng trắng, ký tự Unicode) không bị git
/// bọc trong dấu nháy và escape.
List<String> _trackedFiles() {
  final result = Process.runSync(
    'git',
    ['ls-files', '-z'],
    stdoutEncoding: null,
  );
  if (result.exitCode != 0) {
    // KHÔNG bỏ qua trong im lặng. Một cổng không xác minh được là một
    // cổng không tồn tại; thà đỏ ầm ĩ còn hơn xanh giả.
    fail(
      'không chạy được `git ls-files` (mã thoát ${result.exitCode}). '
      'Cổng ranh giới kho mã cần git để hoạt động.',
    );
  }
  return utf8
      .decode(result.stdout as List<int>)
      .split(String.fromCharCode(0))
      .where((p) => p.isNotEmpty)
      .toList();
}

({RegExp pattern, String reason})? _restrictionFor(String path) {
  for (final rule in _restricted) {
    if (rule.pattern.hasMatch(path)) return rule;
  }
  return null;
}

// ---------------------------------------------------------------------
// CHẶN THEO KÍCH THƯỚC
//
// Chặn-theo-mẫu ở trên bắt được những dạng nội dung ĐÃ BIẾT. Một bộ dữ
// liệu có hình dạng chưa từng thấy — `tool/data/hadith.bin`,
// `assets/corpus.pack` — lọt qua mọi mẫu. Cơ chế này bắt CẢ LỚP thay
// vì từng trường hợp: một tệp được theo dõi mà lớn bất thường gần như
// chắc chắn là nội dung, bất kể nó tên gì.
// ---------------------------------------------------------------------

/// Ngưỡng kích thước cho MỘT tệp được git theo dõi.
///
/// CHỌN 2 MB THEO SỐ ĐO, không theo cảm tính. Phân bố thực tế trên
/// `main` (kích thước TRÊN ĐĨA, đo lại 2026-08-03 sau khi Sprint R3a.1
/// vendor `web/sqlite3.wasm` — xem lịch sử đổi ngưỡng bên dưới):
///
///   19,031 MB  assets/database/quran.sqlite            (miễn trừ, D1)
///    2,534 MB  tool/data/transliteration_words.json    (miễn trừ, D2)
///    0,731 MB  tool/data/transliteration.json          (miễn trừ, D2)
///  ─────────── khoảng trống tự nhiên ───────────
///    0,712 MB  web/sqlite3.wasm               ← TỆP HỢP LỆ LỚN NHẤT
///    0,401 MB  assets/fonts/Inter-Bold.ttf
///    0,400 MB  assets/fonts/Inter-SemiBold.ttf
///
/// LỊCH SỬ ĐỔI NGƯỠNG:
///
/// Ngưỡng gốc (1 MB, chọn ở DR-2026-0013 B1/B2) dựa trên tệp hợp lệ
/// lớn nhất khi đó là `assets/fonts/Inter-Bold.ttf` (0,401 MB) — dư
/// địa ~2,5 lần. Sprint R3a.1 (Phase 3, 2026-08-03) vendor
/// `web/sqlite3.wasm` (0,712 MB) — SQLite biên dịch WebAssembly cho
/// runtime Drift trên Web, tải nguyên bản từ release GitHub của
/// `sqlite3.dart` (xem `docs/DATA_PIPELINE.md` mục "Web runtime"), một
/// PHỤ THUỘC BUILD hợp pháp, KHÔNG phải nội dung Qur'an có giấy phép
/// hạn chế — `_restricted` ở trên không khớp nó, và không nên khớp.
/// Tệp này trở thành tệp hợp lệ lớn nhất mới, ăn gần hết dư địa của
/// ngưỡng 1 MB (chỉ còn ~1,4 lần) — test "ngưỡng còn dư địa thật" ngay
/// bên dưới bắt được ĐÚNG LÚC nó xảy ra, đúng mục đích thiết kế của
/// nó, không phải một lỗi của test.
///
/// Ngưỡng MỚI (2 MB) đo lại THEO ĐÚNG PHƯƠNG PHÁP GỐC trên phân bố tệp
/// THẬT của `main` hôm nay: 2 MB / 0,712 MB ≈ 2,8 lần — cùng bậc dư
/// địa (hơn 2 lần, không sát mép) mà lần chọn ngưỡng đầu tiên đã đặt
/// ra, không phải một con số tuỳ hứng hay nới ngay sát tệp hiện tại.
///
/// ĐỔI NGƯỠNG: sửa đúng hằng số này, VÀ hằng số cùng tên trong
/// `test/repository_boundary_completeness_test.dart` (hai tệp cố ý
/// trùng giá trị này — xem doc comment ở đó). Test ngay bên dưới khoá
/// lại lý do chọn nó, nên hạ ngưỡng quá tay sẽ làm đỏ chính nó.
const int _maxTrackedFileBytes = 2 * 1024 * 1024;

/// Kích thước của từng tệp đang được git theo dõi, theo byte.
///
/// ĐO TRÊN ĐĨA, KHÔNG PHẢI KÍCH THƯỚC BLOB — một đánh đổi có chủ ý:
/// trên Windows `core.autocrlf` thêm một byte mỗi dòng cho tệp văn
/// bản, nên kích thước trên đĩa lớn hơn hoặc bằng kích thước blob. Sai
/// lệch đó LỆCH VỀ PHÍA AN TOÀN (thà cảnh báo thừa còn hơn bỏ sót).
///
/// Đồng bộ, không tiến trình con nào ngoài `git ls-files` đã gọi ở
/// trên.
Map<String, int> _trackedFileSizes(List<String> tracked) {
  final sizes = <String, int>{};
  for (final path in tracked) {
    final file = File(path);
    // Tệp còn được theo dõi nhưng đã xoá khỏi cây làm việc: bỏ qua ở
    // đây; test "miễn trừ lỗi thời" mới là nơi bắt trường hợp đó.
    if (!file.existsSync()) continue;
    sizes[path] = file.lengthSync();
  }
  return sizes;
}

String _mb(int bytes) => '${(bytes / 1048576).toStringAsFixed(3)} MB';

void main() {
  group('Ranh giới kho mã (DR-2026-0013, cốt lõi)', () {
    late List<String> tracked;

    setUpAll(() => tracked = _trackedFiles());

    test('git đọc được và kho mã không rỗng', () {
      expect(
        tracked.length,
        greaterThan(100),
        reason: 'danh sách tệp quá ngắn — nhiều khả năng đọc nhầm thư mục',
      );
    });

    test('KHÔNG tệp nội dung hạn chế nào mới được đưa vào git', () {
      final violations = <String>[];

      for (final path in tracked) {
        final rule = _restrictionFor(path);
        if (rule == null) continue;
        if (_grandfathered.containsKey(path)) continue;
        violations.add('  $path\n      → ${rule.reason}');
      }

      expect(
        violations,
        isEmpty,
        reason: '\n\nNội dung có giấy phép hạn chế đã bị đưa vào một kho '
            'mã CÔNG KHAI:\n\n${violations.join('\n')}\n\n'
            'Kho mã này công khai; thêm tệp như vậy là XUẤT BẢN nguyên '
            'văn tác phẩm, không phải đóng gói nó trong ứng dụng.\n'
            'Xem docs/adr/DR-2026-0013-ci-licence-gate.md và '
            'docs/LICENSING.md.\n'
            'Nếu tệp này thật sự được phép phân phối lại, hãy ghi lại '
            'bằng chứng giấy phép TRƯỚC, rồi mới nới mẫu cấm.\n',
      );
    });

    test('mọi mục miễn trừ đều CÒN được theo dõi — danh sách tự co lại', () {
      // Khi một tệp miễn trừ bị thôi theo dõi (vd. giai đoạn D1/D2), test
      // này đỏ cho tới khi dòng miễn trừ tương ứng bị xoá. Đó là cơ chế
      // duy nhất khiến danh sách miễn trừ không bao giờ phình ra vì
      // quán tính.
      final stale = _grandfathered.keys
          .where((p) => !tracked.contains(p))
          .map((p) => '  $p → ${_grandfathered[p]}')
          .toList();

      expect(
        stale,
        isEmpty,
        reason: '\n\nMục miễn trừ đã lỗi thời — tệp không còn trong git.\n'
            'Xoá dòng tương ứng khỏi _grandfathered:\n\n'
            '${stale.join('\n')}\n',
      );
    });

    test('mỗi mục miễn trừ nêu rõ giai đoạn xoá nó', () {
      for (final entry in _grandfathered.entries) {
        expect(
          entry.value,
          matches(RegExp('giai đoạn [A-F][0-9]')),
          reason: '${entry.key}: lý do miễn trừ phải nêu giai đoạn xoá nó, '
              'nếu không nó sẽ nằm lại vĩnh viễn',
        );
      }
    });

    test('miễn trừ là ĐƯỜNG DẪN CHÍNH XÁC, không phải mẫu', () {
      // Bảo vệ chính cơ chế bảo vệ: nếu ai đó đổi khoá miễn trừ thành
      // mẫu ('tool/data/*.json'), mọi bộ dữ liệu tương lai sẽ lọt.
      for (final path in _grandfathered.keys) {
        expect(
          path,
          isNot(anyOf(contains('*'), contains('?'), contains('['))),
          reason: '$path trông như một mẫu; miễn trừ phải là đường dẫn '
              'chính xác của đúng một tệp',
        );
      }
    });

    test('mỗi mẫu cấm thật sự khớp thứ nó nói là khớp', () {
      // Một mẫu viết sai (vd. thiếu neo `^`) sẽ không bắt được gì và
      // cổng vẫn xanh — kiểu hỏng tệ nhất. Kiểm bằng ví dụ cụ thể,
      // không phụ thuộc nội dung thật của kho mã.
      const shouldBlock = [
        'assets/database/quran.sqlite',
        'assets/database/hadith.sqlite',
        'tool/data/tafsir_en-tafsir-ibn-kathir.json',
        'tool/data/tafsir_ur-some-new-corpus.json',
        'tool/data/transliteration.json',
        'tool/data/transliteration_words.json',
        'some/other/place/content.db',
        'scratch/dump.sqlite3',
      ];
      for (final path in shouldBlock) {
        expect(
          _restrictionFor(path),
          isNotNull,
          reason: '$path phải bị chặn nhưng không mẫu nào khớp',
        );
      }

      const shouldPass = [
        'tool/data/surah_names.json', // siêu dữ liệu 114 tên, không phải tác phẩm
        'lib/main.dart',
        'assets/licenses/Amiri-OFL.txt',
        'assets/fonts/Amiri-Regular.ttf',
        'pubspec.yaml',
        'docs/LICENSING.md',
        'test/repository_boundary_test.dart',
      ];
      for (final path in shouldPass) {
        expect(
          _restrictionFor(path),
          isNull,
          reason: '$path bị chặn nhầm',
        );
      }
    });
  });

  group('Chặn theo kích thước (DR-2026-0013, cốt lõi)', () {
    late Map<String, int> sizes;

    setUpAll(() => sizes = _trackedFileSizes(_trackedFiles()));

    test('đọc được kích thước của mọi tệp đang theo dõi', () {
      expect(
        sizes.length,
        greaterThan(100),
        reason: 'quá ít tệp — nhiều khả năng đọc nhầm thư mục',
      );
      expect(
        sizes.values.every((s) => s >= 0),
        isTrue,
        reason: 'kích thước âm nghĩa là parse sai',
      );
    });

    test(
        'KHÔNG tệp theo dõi nào vượt ngưỡng ${_maxTrackedFileBytes ~/ 1024} KB',
        () {
      // DÙNG CHUNG danh sách miễn trừ ở trên — cùng tệp, cùng lý do,
      // cùng cơ chế tự co lại. Không có danh sách miễn trừ THỨ HAI để
      // quên cập nhật.
      final oversized = <String>[];

      for (final entry in sizes.entries) {
        if (entry.value <= _maxTrackedFileBytes) continue;
        if (_grandfathered.containsKey(entry.key)) continue;
        oversized.add('  ${entry.key}  (${_mb(entry.value)})');
      }

      expect(
        oversized,
        isEmpty,
        reason: '\n\nTệp quá lớn đã được đưa vào git '
            '(ngưỡng ${_mb(_maxTrackedFileBytes)}):\n\n'
            '${oversized.join('\n')}\n\n'
            'Một tệp lớn được theo dõi gần như luôn là NỘI DUNG, không '
            'phải mã nguồn — kể cả khi tên nó không khớp mẫu cấm nào.\n'
            'Nếu đây thật sự là tài sản hợp lệ của dự án: ghi lại lý do, '
            'rồi thêm nó vào _grandfathered kèm giai đoạn sẽ gỡ nó.\n'
            'Nếu đây là dữ liệu: nó thuộc về kho lưu trữ riêng tư, xem '
            'docs/adr/DR-2026-0009-data-supply-chain.md.\n',
      );
    });

    test('ngưỡng còn dư địa thật trên tệp hợp lệ lớn nhất', () {
      // Khoá lại LÝ DO chọn ngưỡng, không chỉ con số. Nếu ai đó hạ
      // ngưỡng xuống sát tệp hợp lệ lớn nhất, hoặc thêm một tài sản
      // hợp lệ lớn bất thường, test này đỏ và buộc phải quyết định có
      // ý thức thay vì lặng lẽ nới miễn trừ. Tính TRÊN CHÍNH nhánh
      // đang chạy — không hardcode tên tệp nào.
      final legitimate = sizes.entries
          .where((e) => !_grandfathered.containsKey(e.key))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      expect(legitimate, isNotEmpty);
      final largest = legitimate.first;

      expect(
        _maxTrackedFileBytes,
        greaterThan(largest.value * 2),
        reason: 'ngưỡng ${_mb(_maxTrackedFileBytes)} chỉ hơn tệp hợp lệ '
            'lớn nhất (${largest.key}, ${_mb(largest.value)}) chưa tới '
            'hai lần. Quá sát: một phông chữ hay biểu tượng hơi lớn sẽ '
            'làm đỏ CI vì lý do sai.',
      );
    });
  });
}
