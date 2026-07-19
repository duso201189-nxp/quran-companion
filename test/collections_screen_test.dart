import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/library/data/bookmark_collection_providers.dart';
import 'package:quran_companion/features/library/presentation/collections/collections_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/fake_bookmark_collection_repository.dart';

void main() {
  late FakeBookmarkCollectionRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeBookmarkCollectionRepository();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        bookmarkCollectionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CollectionsScreen(),
      ),
    );
  }

  testWidgets('chưa có bộ sưu tập -> trạng thái rỗng', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No collections yet.'), findsOneWidget);
  });

  testWidgets('tạo bộ sưu tập mới qua FAB -> xuất hiện trong danh sách',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Yêu thích');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Yêu thích'), findsOneWidget);
    expect(find.text('0 ayahs'), findsOneWidget);
    expect(fakeRepo.collections, hasLength(1));
  });

  testWidgets('tên rỗng -> Save không tạo bộ sưu tập (dialog vẫn mở)',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakeRepo.collections, isEmpty);
    // Dialog vẫn còn trên màn hình (Save bị chặn, không pop).
    expect(find.text('Collection name'), findsOneWidget);
  });

  testWidgets('đổi tên bộ sưu tập qua menu', (tester) async {
    await fakeRepo.createCollection(name: 'Cũ');
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Mới');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Mới'), findsOneWidget);
    expect(find.text('Cũ'), findsNothing);
  });

  testWidgets('xóa bộ sưu tập qua menu + xác nhận', (tester) async {
    await fakeRepo.createCollection(name: 'Sẽ xóa');
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Sẽ xóa'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete collection?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Sẽ xóa'), findsNothing);
    expect(fakeRepo.collections, isEmpty);
  });

  testWidgets('hủy xác nhận xóa -> bộ sưu tập vẫn còn', (tester) async {
    await fakeRepo.createCollection(name: 'Giữ lại');
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Giữ lại'), findsOneWidget);
    expect(fakeRepo.collections, hasLength(1));
  });
}
