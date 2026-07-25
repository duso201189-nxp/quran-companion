import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Sprint 31.0 — RANH GIỚI KIẾN TRÚC, dạng THỰC THI ĐƯỢC.
///
/// Mọi báo cáo sprint trước đều khuyến nghị "giữ trang đọc mỏng", và
/// trang đọc vẫn phình lên (1377 dòng, 17 lớp). Một ranh giới không
/// chạy được thì không phải ranh giới — các bài kiểm dưới đây làm hỏng
/// bộ test khi có người nối thêm tính năng vào Reading, thay vì trông
/// chờ vào lúc review.
///
/// Xem `DR-2026-0007` quyết định D7.

/// Mọi câu lệnh `import` thật trong [file] (bỏ qua chú thích).
List<String> _imports(File file) {
  return [
    for (final line in file.readAsLinesSync())
      if (RegExp(r"^\s*import\s+'").hasMatch(line))
        RegExp(r"import\s+'([^']+)'").firstMatch(line)!.group(1)!,
  ];
}

List<File> _dartFilesIn(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return [
    for (final e in dir.listSync(recursive: true))
      if (e is File && e.path.endsWith('.dart')) e,
  ];
}

/// Đường dẫn tương đối gọn để thông báo lỗi đọc được.
String _rel(File f) =>
    f.path.replaceAll(r'\', '/').split('quran_companion/').last;

/// Giải một `import` TƯƠNG ĐỐI thành đường dẫn chuẩn tính từ gốc gói
/// (vd `lib/features/stats/data/stats_store.dart`).
///
/// Bắt buộc phải giải THẬT, không được chỉ cắt bỏ `../`: cắt bỏ làm
/// mất thông tin ĐỘ SÂU, nên `'../../../stats/...'` và
/// `'../../../../features/stats/...'` trông giống hệt nhau — bản đầu
/// của bài kiểm này vì thế đã "đạt" mà không so sánh gì cả.
/// Trả về `null` cho import gói ngoài (`package:...`).
String? _resolveImport(File file, String import) {
  if (!import.startsWith('.')) return null;
  final dir =
      file.parent.path.replaceAll(r'\', '/').split('quran_companion/').last;
  final segments = <String>[...dir.split('/'), ...import.split('/')];
  final out = <String>[];
  for (final segment in segments) {
    if (segment == '.' || segment.isEmpty) continue;
    if (segment == '..') {
      if (out.isNotEmpty) out.removeLast();
      continue;
    }
    out.add(segment);
  }
  return out.join('/');
}

void main() {
  group('Ranh giới Reading (DR-2026-0007 D7)', () {
    final readingFiles =
        _dartFilesIn('lib/features/quran/presentation/reading');

    test('có tệp để kiểm — đường dẫn không bị đổi tên âm thầm', () {
      expect(readingFiles, isNotEmpty);
    });

    test('Reading KHÔNG import bất kỳ tính năng nào Study sẽ sở hữu', () {
      // Những feature này là nội dung của Study Workspace tương lai
      // (Tafsir, ghi chú nhiều bản, phân tích từ, module học...).
      // Trang đọc chạm tới bất kỳ cái nào nghĩa là Study đang bị nhét
      // ngược vào Reading.
      const forbidden = [
        'lib/features/lexicon/',
        'lib/features/library/',
        'lib/features/flashcards/',
        'lib/features/learning/',
        'lib/features/learning_journey/',
        'lib/features/learning_session/',
        'lib/features/smart_learning/',
        'lib/features/ai_tutor/',
        'lib/features/quiz/',
        'lib/features/analytics/',
        'lib/features/read_model/',
        'lib/features/khatm/',
      ];

      final violations = <String>[];
      for (final file in readingFiles) {
        for (final import in _imports(file)) {
          final resolved = _resolveImport(file, import);
          if (resolved == null) continue;
          for (final f in forbidden) {
            if (resolved.startsWith(f)) {
              violations.add('${_rel(file)} -> $resolved');
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Reading chỉ trình bày kinh văn. Tính năng học thuộc về '
            'Study Workspace (route riêng, provider riêng) — xem '
            'DR-2026-0007 D1/D2. Vi phạm:\n${violations.join('\n')}',
      );
    });

    test('NGÂN SÁCH phụ thuộc của Reading bị đóng băng', () {
      // Danh sách này là TRẦN, không phải mục tiêu. Thêm một mục =
      // thừa nhận Reading vừa lớn thêm, và phải có lý do ghi lại.
      //
      // Hai mục đang là NỢ KỸ THUẬT, không phải chấp thuận:
      //   - features/stats/**  : ghi nhật ký phiên đọc (DR-2026-0007 R1)
      //   - search_error_state : widget trình bày của feature khác (R7)
      const allowed = {
        'lib/app/router.dart',
        'lib/app/theme/app_theme.dart',
        'lib/core/storage/prefs_provider.dart',
        'lib/shared/widgets/loading_state.dart',
        'lib/features/search/presentation/widgets/search_error_state.dart',
        'lib/features/stats/data/stats_store.dart',
        'lib/features/stats/data/study_session_providers.dart',
        'lib/features/stats/domain/repositories/study_session_repository.dart',
      };

      const ownFeature = 'lib/features/quran/';
      final actual = <String>{};
      for (final file in readingFiles) {
        for (final import in _imports(file)) {
          final resolved = _resolveImport(file, import);
          // Chỉ xét import RA NGOÀI feature Qur'an; import nội bộ và
          // package ngoài không thuộc ngân sách này.
          if (resolved == null || resolved.startsWith(ownFeature)) continue;
          actual.add(resolved);
        }
      }

      final added = actual.difference(allowed);
      expect(
        added,
        isEmpty,
        reason: 'Reading vừa có phụ thuộc mới ra ngoài feature Qur\'an. '
            'Nếu đây là tính năng học -> đưa vào Study Workspace. Nếu '
            'thật sự thuộc Reading -> thêm vào danh sách kèm lý do '
            '(DR-2026-0007 D7). Mới:\n${added.join('\n')}',
      );
    });
  });

  group('Hướng phụ thuộc chung', () {
    test('domain KHÔNG import Flutter (PROJ-P-003)', () {
      final violations = <String>[];
      for (final feature in Directory('lib/features').listSync()) {
        if (feature is! Directory) continue;
        for (final file in _dartFilesIn('${feature.path}/domain')) {
          for (final import in _imports(file)) {
            if (import.startsWith('package:flutter/')) {
              violations.add('${_rel(file)} -> $import');
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Domain phải thuần Dart — không Flutter, không Drift. '
            'Vi phạm:\n${violations.join('\n')}',
      );
    });

    test('domain KHÔNG import Drift hay tầng data', () {
      final violations = <String>[];
      for (final feature in Directory('lib/features').listSync()) {
        if (feature is! Directory) continue;
        for (final file in _dartFilesIn('${feature.path}/domain')) {
          for (final import in _imports(file)) {
            if (import.startsWith('package:drift/') ||
                import.contains('/data/') ||
                import.startsWith('data/')) {
              violations.add('${_rel(file)} -> $import');
            }
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });
}
