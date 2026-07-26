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
}
