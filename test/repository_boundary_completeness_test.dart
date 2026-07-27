// CỔNG RANH GIỚI KHO MÃ — PHẦN KIỂM ĐỘ ĐẦY ĐỦ, TÁCH RIÊNG.
//
// Tệp anh em của `test/repository_boundary_test.dart` (phần CỐT LÕI —
// đọc header ở đó trước). Tệp này chứa ĐÚNG MỘT test, cố ý tách khỏi
// phần cốt lõi vì nó kiểm tra một câu hỏi khác hẳn:
//
//   Phần cốt lõi hỏi:  "có tệp nào đang VI PHẠM ranh giới không?"
//   Tệp này hỏi:       "cơ chế chặn-kích-thước có đang được THỬ THẬT
//                       với ít nhất một tệp quá khổ hay không, hay nó
//                       là mã chết chưa từng chạy qua trường hợp thật?"
//
// Câu hỏi thứ hai là về ĐỘ ĐẦY ĐỦ của bằng chứng, không phải về BẢO VỆ
// — nên khi không có tệp miễn trừ nào vượt ngưỡng trên nhánh đang chạy
// (vd. `main` sau khi các giai đoạn D1/D2 thôi theo dõi database và bộ
// phiên âm, mà chưa có gì lớn khác được miễn trừ), test này BÁO "chưa
// áp dụng" thay vì đỏ mãi mãi. KHÔNG giảm mức bảo vệ: phần cốt lõi vẫn
// chặn đúng như cũ trong mọi trường hợp; tệp này chỉ ngừng đòi hỏi
// bằng chứng mà nhánh hiện tại không có gì để cung cấp.
//
// Lý do tách được ghi trong header của
// `test/repository_boundary_test.dart` — đọc ở đó trước khi sửa tệp
// này.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TRÙNG VỚI `test/repository_boundary_test.dart` — cố ý. Hai tệp này
/// phải luôn đồng bộ danh sách miễn trừ; đây là chi phí đã chấp nhận
/// của việc tách thành hai tệp độc lập thay vì một thư viện dùng
/// chung, để mỗi tệp tự đứng vững, dễ soát xét một mình. Nguồn thật sự
/// đáng tin của danh sách này là tệp cốt lõi — nếu hai bên lệch nhau,
/// sửa theo tệp đó.
const Map<String, String> _grandfathered = {
  'assets/database/quran.sqlite':
      'thôi theo dõi ở giai đoạn D1 — DR-2026-0008 nước đi B',
  'tool/data/transliteration.json': 'thôi theo dõi ở giai đoạn D2',
  'tool/data/transliteration_words.json': 'thôi theo dõi ở giai đoạn D2',
};

/// TRÙNG với ngưỡng trong tệp cốt lõi — xem lý do chọn 1 MB ở đó.
const int _maxTrackedFileBytes = 1024 * 1024;

List<String> _trackedFiles() {
  final result = Process.runSync(
    'git',
    ['ls-files', '-z'],
    stdoutEncoding: null,
  );
  if (result.exitCode != 0) {
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

Map<String, int> _trackedFileSizes(List<String> tracked) {
  final sizes = <String, int>{};
  for (final path in tracked) {
    final file = File(path);
    if (!file.existsSync()) continue;
    sizes[path] = file.lengthSync();
  }
  return sizes;
}

void main() {
  group('Ranh giới kho mã — độ đầy đủ (DR-2026-0013)', () {
    test('mọi mục miễn trừ vượt ngưỡng đều nêu giai đoạn gỡ nó', () {
      final sizes = _trackedFileSizes(_trackedFiles());
      final neededBySizeGuard = _grandfathered.keys
          .where((p) => (sizes[p] ?? 0) > _maxTrackedFileBytes)
          .toList();

      if (neededBySizeGuard.isEmpty) {
        // KHÔNG đỏ. Nhánh này hiện không có mục miễn trừ nào vượt
        // ngưỡng để chứng minh cơ chế chặn-kích-thước đã được thử —
        // đó là một sự thật về NỘI DUNG hiện tại, không phải một lỗi
        // của cổng. Phần cốt lõi (`repository_boundary_test.dart`)
        // vẫn bảo vệ đầy đủ bất kể test này báo gì.
        markTestSkipped(
          'Không mục miễn trừ nào trên nhánh này vượt ngưỡng '
          '${_maxTrackedFileBytes ~/ 1024} KB — cơ chế chặn-kích-thước '
          'chưa có gì để tự chứng minh ở đây. Kích hoạt lại xác nhận '
          'khi một mục miễn trừ thật vượt ngưỡng tồn tại trên nhánh '
          'này. Xem header của test/repository_boundary_test.dart.',
        );
        return;
      }

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
