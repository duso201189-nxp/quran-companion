import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/library/domain/library_kind.dart';
import 'package:quran_companion/features/library/presentation/library_controller.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/annotations/ayah_actions_sheet.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart' show flushPendingDriftTimers;

/// Sprint 7.5 (Reflection Practice) — nội dung Qur'an giả tối giản:
/// đúng 1 Surah, 1 Ayah, đủ để ayahAnnotationsProvider/surahReadingProvider
/// giải quyết được id Ayah đang kiểm mà không cần bộ dữ liệu lớn.
class _FakeQuranRepo implements QuranRepository {
  static const _surah = Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai Đề',
    nameEn: 'The Opening',
    ayahCount: 1,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  );

  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;

  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [
        AyahContent(
          ayah: Ayah(
            id: 1,
            surahId: 1,
            ayahNumber: 1,
            textUthmani: 'نص عربي ١',
            juz: 1,
          ),
          texts: {'vi_main': 'bản việt một'},
        ),
      ];

  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [];
  @override
  Future<String?> getMetaValue(String key) async => null;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];
  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          if (id == 1)
            const AyahSearchResult(
              ayahId: 1,
              surahId: 1,
              ayahNumber: 1,
              surahNameLatin: 'Al-Fatihah',
              arabic: 'نص عربي ١',
              translation: 'bản việt một',
            ),
      ];
}

// Sprint 7.5 — mở AyahActionsSheet qua showModalBottomSheet, ĐÚNG như
// reading_screen.dart dùng thật (xem 'Nhấn giữ Ayah: sheet mở...'/
// 'Ghi chú: lưu qua dialog...' trong reading_screen_test.dart) — không
// render sheet thẳng làm body màn hình: đó là cách dùng KHÔNG có tiền
// lệ trong repo này.
Widget _wrap(UserDatabase db) {
  return ProviderScope(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => const AyahActionsSheet(
                  surahId: 1,
                  ayahId: 1,
                  ayahNumber: 1,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester, UserDatabase db) async {
  await tester.pumpWidget(_wrap(db));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// Mỗi test tạo UserDatabase in-memory RIÊNG (cô lập dữ liệu) và phải tự
// đóng lại trước khi callback testWidgets return. KHÔNG đóng qua
// tearDown/addTearDown: hai hàm đó chạy SAU khi callback đã return, lúc
// đó tester.runAsync không còn coi mình "trong" một test đang chạy nữa
// và treo vĩnh viễn — đúng nguyên nhân/cách chữa đã xác nhận trong
// reading_screen_test.dart (_testReading). Gói chung ở đây để cả 6 test
// dưới đều đi qua đúng vòng đời: thân test -> flush Timer(0) của Drift
// -> đóng db qua tester.runAsync (thoát khỏi FakeAsync để close() thật
// sự hoàn tất).
void _test(
  String description,
  Future<void> Function(WidgetTester tester, UserDatabase db) body,
) {
  testWidgets(description, (tester) async {
    final db = UserDatabase(NativeDatabase.memory());
    await body(tester, db);
    await flushPendingDriftTimers(tester);
    await tester.runAsync(db.close);
  });
}

void main() {
  _test(
      '1: mục Suy ngẫm (Reflection) xuất hiện trong Ayah Actions sheet '
      '— chưa có nội dung -> nhãn "Add reflection"', (tester, db) async {
    await _openSheet(tester, db);

    expect(find.text('Add reflection'), findsOneWidget);
    expect(find.text('Edit reflection'), findsNothing);
  });

  _test(
      '2+3: bấm vào mục Suy ngẫm -> mở đúng dialog hiện có, nội dung '
      'Suy ngẫm/Ghi chú cũ (nếu có) được điền sẵn', (tester, db) async {
    // Seed sẵn 1 ghi chú cho Ayah 1 — mô phỏng "đã từng viết Suy ngẫm".
    await db.into(db.notes).insert(
          NotesCompanion.insert(
            id: 'note-1',
            ayahId: 1,
            content: 'suy ngẫm cũ của tôi',
            updatedAt: 0,
          ),
        );

    await _openSheet(tester, db);

    // Nhãn đổi sang "Edit reflection" vì đã có nội dung.
    expect(find.text('Edit reflection'), findsOneWidget);

    await tester.tap(find.text('Edit reflection'));
    await tester.pumpAndSettle();

    // Dialog hiện có (_NoteDialog, AlertDialog) mở ra, tiêu đề dùng
    // đúng nhãn Suy ngẫm mới (noteLabel), nội dung cũ điền sẵn trong
    // TextField. Giới hạn tìm kiếm bên TRONG dialog — sheet phía sau
    // vẫn còn dòng xem trước (subtitle) chứa cùng chuỗi văn bản, tìm
    // không giới hạn sẽ khớp cả hai nơi.
    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Reflection')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('suy ngẫm cũ của tôi'),
      ),
      findsOneWidget,
    );
  });

  _test(
      '4: lưu nội dung mới -> đi qua đúng cơ chế saveNote hiện có (bảng '
      'notes), không có bảng/cơ chế lưu trữ mới nào', (tester, db) async {
    await _openSheet(tester, db);

    await tester.tap(find.text('Add reflection'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'suy ngẫm mới');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.notes).get();
    expect(rows, hasLength(1));
    expect(rows.single.ayahId, 1);
    expect(rows.single.content, 'suy ngẫm mới');

    // Dialog tự đóng sau khi lưu, nhãn ngoài sheet cập nhật ngay
    // (annotation stream phản ánh realtime, không cần thao tác thêm).
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Edit reflection'), findsOneWidget);
  });

  _test(
      '5: bấm Cancel, không nhập gì -> KHÔNG lưu, sheet vẫn ở trạng '
      'thái "chưa có Suy ngẫm" (tuỳ chọn, không có hậu quả)',
      (tester, db) async {
    await _openSheet(tester, db);

    await tester.tap(find.text('Add reflection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final rows = await db.select(db.notes).get();
    expect(rows, isEmpty);
    expect(find.text('Add reflection'), findsOneWidget);
    expect(find.text('Edit reflection'), findsNothing);
  });

  _test(
      '6: hành vi Thư viện > Ghi chú (LibraryKind.notes) không đổi — vẫn '
      'hiển thị đúng nội dung đã lưu qua saveNote, danh tính "Notes" '
      'giữ nguyên (không đổi sang Suy ngẫm ở mặt Thư viện)',
      (tester, db) async {
    final container = ProviderContainer(
      overrides: [
        userDatabaseProvider.overrideWithValue(db),
        quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      ],
    );

    await container
        .read(userContentRepositoryProvider)
        .saveNote(1, 'ghi chú của tôi');

    final items =
        await container.read(libraryItemsProvider(LibraryKind.notes).future);

    expect(items, hasLength(1));
    expect(items.single.ayah.ayahId, 1);
    expect(items.single.note, 'ghi chú của tôi');

    container.dispose();
  });
}
