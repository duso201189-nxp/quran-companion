// CỔNG RANH GIỚI KHO MÃ — `DR-2026-0013` giai đoạn B1.
//
// Kho mã này CÔNG KHAI. Nội dung có giấy phép hạn chế không được phép
// nằm trong nó: đưa một bộ chú giải vào git không phải là "đóng gói
// nội dung trong ứng dụng" (thứ mà giấy phép cho phép, hoặc đang xin),
// mà là "xuất bản nguyên văn tác phẩm dưới dạng tệp tải về" — một
// hành vi khác hẳn và khó biện minh hơn nhiều với người giữ quyền.
//
// TẠI SAO PHẢI LÀ TEST, KHÔNG PHẢI TÀI LIỆU:
//
//   `.gitignore`      bỏ qua được bằng `git add -f`
//   pre-commit hook   bỏ qua được bằng `--no-verify`, và không tồn tại
//                     trên một bản clone mới
//   soát xét mã       một tệp JSON 10 MB trong diff chỉ là MỘT DÒNG
//   tài liệu          không làm hỏng được bản build
//
// Cổng này chạy trong CI trên mọi push và mọi pull request, kể cả từ
// fork (nó chỉ đọc metadata của git, không cần bí mật nào). Đó là lớp
// DUY NHẤT trong bốn lớp mà không ai bỏ qua được.
//
// PHẠM VI GIAI ĐOẠN B1 — cố ý hẹp:
//   • CÓ  : danh sách CẤM theo mẫu đường dẫn của các dạng nội dung đã
//           biết, cộng danh sách MIỄN TRỪ tạm thời cho những tệp hiện
//           đã nằm trong git.
//   • KHÔNG: chặn theo KÍCH THƯỚC (giai đoạn B2) — nó bắt được cả
//           những dạng nội dung chưa từng thấy, và đó là việc riêng
//           của B2, không phải của B1.
//   • KHÔNG: suy ra danh sách cấm từ sổ đăng ký giấy phép (giai đoạn
//           F3). Sổ đăng ký chưa tồn tại, nên B1 gieo tay danh sách
//           dưới đây. F3 sẽ thay phần gieo tay bằng phần suy ra mà
//           không đổi cơ chế.

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
    reason: 'database nội dung — chứa TOÀN BỘ sáu nguồn, kể cả bản dịch '
        'chỉ-phi-thương-mại và bộ chú giải còn bản quyền',
  ),
  (
    pattern: RegExp(r'^tool/data/tafsir_.*\.json$'),
    reason: 'bộ chú giải Tafsir — Ibn Kathir (Abridged) là (c) Maktaba '
        'Dar-us-Salam 2003; Al-Muyassar chưa xác minh',
  ),
  (
    pattern: RegExp(r'^tool/data/transliteration.*\.json$'),
    reason: 'bộ phiên âm Quran.com/QUL — giấy phép chưa xác minh',
  ),
  (
    pattern: RegExp(r'\.(sqlite3?|db)$'),
    reason: 'database nội dung ở bất kỳ đâu trong cây thư mục',
  ),
];

/// MIỄN TRỪ TẠM THỜI — những tệp ĐÃ nằm trong git trước khi cổng này
/// tồn tại. Không có danh sách này, B1 sẽ đỏ ngay lúc merge và vi phạm
/// yêu cầu "mọi giai đoạn phải để kho mã build được".
///
/// ĐƯỜNG DẪN CHÍNH XÁC, KHÔNG PHẢI MẪU — đây là điểm mấu chốt của cả
/// cổng. Nếu miễn trừ theo mẫu thì một bộ Tafsir MỚI cũng được miễn
/// theo. Miễn theo đường dẫn chính xác nghĩa là đúng năm tệp này được
/// tha, tệp thứ sáu thì không.
///
/// Mỗi dòng ghi rõ GIAI ĐOẠN NÀO XOÁ NÓ. Danh sách này chỉ được ngắn
/// đi, không bao giờ dài ra.
const Map<String, String> _grandfathered = {
  'tool/data/tafsir_en-tafsir-ibn-kathir.json':
      'xoá ở giai đoạn A3 (gỡ bộ Ibn Kathir) — DR-2026-0008 nước đi A',
  'assets/database/quran.sqlite':
      'thôi theo dõi ở giai đoạn D1 — DR-2026-0008 nước đi B',
  'tool/data/tafsir_ar-tafsir-muyassar.json': 'thôi theo dõi ở giai đoạn D2',
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
// Giai đoạn B2 — CHẶN THEO KÍCH THƯỚC
//
// B1 chặn theo MẪU đường dẫn: bắt được những dạng nội dung ĐÃ BIẾT.
// Một bộ dữ liệu có hình dạng chưa từng thấy — `tool/data/hadith.bin`,
// `assets/corpus.pack` — lọt qua mọi mẫu. B2 bắt CẢ LỚP thay vì từng
// trường hợp: một tệp được theo dõi mà lớn bất thường gần như chắc
// chắn là nội dung, bất kể nó tên gì.
//
// Lớp này lẽ ra đã chặn được sai lầm ban đầu mà không cần biết Ibn
// Kathir là gì.
// ---------------------------------------------------------------------

/// Ngưỡng kích thước cho MỘT tệp được git theo dõi.
///
/// CHỌN 1 MB THEO SỐ ĐO, không theo cảm tính. Phân bố thực tế của 636
/// tệp đang theo dõi (kích thước blob, không phải kích thước trên đĩa):
///
///   32,707 MB  assets/database/quran.sqlite            (miễn trừ, D1)
///   10,067 MB  tool/data/tafsir_en-...-ibn-kathir.json (miễn trừ, A3)
///    2,534 MB  tool/data/transliteration_words.json    (miễn trừ, D2)
///    1,978 MB  tool/data/tafsir_ar-tafsir-muyassar.json(miễn trừ, D2)
///    0,725 MB  tool/data/transliteration.json          (miễn trừ, D2)
///  ─────────── khoảng trống tự nhiên ───────────
///    0,401 MB  assets/fonts/Inter-Bold.ttf   ← TỆP HỢP LỆ LỚN NHẤT
///    0,400 MB  assets/fonts/Inter-SemiBold.ttf
///    0,334 MB  lib/core/database/app_database.g.dart
///
/// Có một khoảng trống thật giữa 0,401 MB (tệp hợp lệ lớn nhất) và
/// 0,725 MB (tệp nội dung nhỏ nhất). Ngưỡng đặt trong khoảng đó, lệch
/// về phía an toàn:
///
///   0,5 MB  dư địa 1,2x — quá sát, một phông chữ hơi lớn là đỏ
///   1   MB  dư địa 2,5x — CHỌN
///   2   MB  dư địa 5x   nhưng cho lọt một bộ dữ liệu 1,9 MB
///   5   MB  dư địa 12x  nhưng cho lọt một bộ dữ liệu 4,9 MB
///
/// `IMPLEMENTATION_PROGRAM.md` đề xuất "~5 MB" khi chưa có số đo. Số
/// đo cho thấy 5 MB quá rộng: nó cho lọt cả hai bộ Tafsir hiện có nếu
/// chúng được đặt tên khác. 1 MB vẫn thừa chỗ cho những tài sản hợp lệ
/// đã biết sắp thêm — biểu tượng thích ứng, biểu tượng cửa hàng
/// 512x512, ảnh feature 1024x500 đều dưới 0,3 MB — và biểu tượng 1024
/// hiện có của macOS chỉ 0,098 MB.
///
/// ĐỔI NGƯỠNG: sửa đúng hằng số này. Test ngay bên dưới khoá lại lý do
/// chọn nó, nên hạ ngưỡng quá tay sẽ làm đỏ chính nó.
const int _maxTrackedFileBytes = 1024 * 1024;

/// Kích thước của từng tệp đang được git theo dõi, theo byte.
///
/// ĐO TRÊN ĐĨA, KHÔNG PHẢI KÍCH THƯỚC BLOB — và đó là một đánh đổi có
/// chủ ý, không phải cẩu thả.
///
/// Bản đầu của B2 đọc kích thước blob qua `git cat-file --batch-check`,
/// vì blob mới đúng là thứ nằm trong kho. Nó BẾ TẮC: ghi 636 mã SHA
/// (~26 KB) vào stdin của git trong khi không ai đọc stdout, nên git
/// chặn ở lượt ghi stdout còn ta chặn ở lượt ghi stdin. Đo được: stdin
/// mất 55 giây rồi bị giết, chỉ nhận về 211/636 kích thước. Sửa được
/// bằng cách đọc stdout song song, nhưng cách sửa ấy hỏng lại chỉ vì
/// ai đó đảo hai dòng — quá mong manh cho một cổng phải sống nhiều năm.
///
/// Kích thước trên đĩa lớn hơn hoặc bằng kích thước blob: trên Windows
/// `core.autocrlf` thêm một byte mỗi dòng cho tệp văn bản. Sai lệch đó
/// LỆCH VỀ PHÍA AN TOÀN (thà cảnh báo thừa còn hơn bỏ sót) và không
/// đáng kể ở ngưỡng này: tệp văn bản hợp lệ lớn nhất là
/// `app_database.g.dart` 0,334 MB, cách ngưỡng 1 MB gấp ba lần, trong
/// khi CRLF chỉ làm phình vài phần trăm. Tệp nhị phân không bị ảnh
/// hưởng chút nào.
///
/// Đồng bộ, không tiến trình con nào ngoài `git ls-files` mà B1 đã gọi.
Map<String, int> _trackedFileSizes(List<String> tracked) {
  final sizes = <String, int>{};
  for (final path in tracked) {
    final file = File(path);
    // Tệp còn được theo dõi nhưng đã xoá khỏi cây làm việc: bỏ qua ở
    // đây; test "miễn trừ lỗi thời" của B1 mới là nơi bắt trường hợp đó.
    if (!file.existsSync()) continue;
    sizes[path] = file.lengthSync();
  }
  return sizes;
}

String _mb(int bytes) => '${(bytes / 1048576).toStringAsFixed(3)} MB';

void main() {
  group('Ranh giới kho mã (DR-2026-0013 B1)', () {
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
      // Khi giai đoạn A3 gỡ bộ Ibn Kathir, test này đỏ cho tới khi dòng
      // miễn trừ tương ứng bị xoá. Đó là cơ chế duy nhất khiến danh
      // sách miễn trừ không bao giờ phình ra vì quán tính.
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
      // cổng vẫn xanh — kiểu hỏng tệ nhất. Kiểm bằng ví dụ cụ thể.
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

  group('Chặn theo kích thước (DR-2026-0013 B2)', () {
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
      // DÙNG CHUNG danh sách miễn trừ của B1 — cùng năm tệp, cùng lý do,
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
      // ý thức thay vì lặng lẽ nới miễn trừ.
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

    test('mọi mục miễn trừ vượt ngưỡng đều nêu giai đoạn gỡ nó', () {
      // B1 đã kiểm điều này cho toàn bộ danh sách; ở đây kiểm lại RIÊNG
      // cho những mục mà chặn-kích-thước thật sự cần, để nếu B1 bị gỡ
      // thì B2 vẫn không mất tính chất tự co lại.
      final neededBySizeGuard = _grandfathered.keys
          .where((p) => (sizes[p] ?? 0) > _maxTrackedFileBytes);

      expect(
        neededBySizeGuard,
        isNotEmpty,
        reason: 'không mục miễn trừ nào vượt ngưỡng — hoặc dữ liệu đã ra '
            'khỏi git (tốt: hạ ngưỡng hoặc xoá miễn trừ), hoặc ngưỡng '
            'đặt quá cao để có tác dụng',
      );

      for (final path in neededBySizeGuard) {
        expect(
          _grandfathered[path],
          matches(RegExp('giai đoạn [A-F][0-9]')),
          reason: '$path vượt ngưỡng nhưng lý do miễn trừ không nêu giai '
              'đoạn gỡ nó',
        );
      }
    });
  });
}
