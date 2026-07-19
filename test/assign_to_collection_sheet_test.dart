import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/library/data/bookmark_collection_providers.dart';
import 'package:quran_companion/features/library/presentation/collections/assign_to_collection_sheet.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/fake_bookmark_collection_repository.dart';

const _ayahId = 42;

void main() {
  late FakeBookmarkCollectionRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeBookmarkCollectionRepository()..bookmarkedAyahs.add(_ayahId);
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        bookmarkCollectionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AssignToCollectionSheet.show(context, _ayahId),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('hiện danh sách bộ sưu tập, chưa gán -> checkbox tắt',
      (tester) async {
    await fakeRepo.createCollection(name: 'Ôn tập');
    await openSheet(tester);

    expect(find.text('Add to collection'), findsOneWidget);
    expect(find.text('Ôn tập'), findsOneWidget);
    final tile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(tile.value, isFalse);
  });

  testWidgets('bấm checkbox -> gọi assignBookmark, checkbox bật lại đúng',
      (tester) async {
    await fakeRepo.createCollection(name: 'Ôn tập');
    await openSheet(tester);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();

    expect(fakeRepo.membership.values.first, contains(_ayahId));
    final tile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(tile.value, isTrue);
  });

  testWidgets('bỏ chọn checkbox đã bật -> gọi unassignBookmark',
      (tester) async {
    final id = await fakeRepo.createCollection(name: 'Ôn tập');
    fakeRepo.membership[id] = [_ayahId];
    await openSheet(tester);

    var tile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(tile.value, isTrue);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();

    expect(fakeRepo.membership[id], isNot(contains(_ayahId)));
    tile = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(tile.value, isFalse);
  });

  testWidgets('"New collection" -> tạo bộ sưu tập mới rồi gán ngay',
      (tester) async {
    await openSheet(tester);

    expect(find.text('New collection'), findsOneWidget);
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Mới tạo');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakeRepo.collections, hasLength(1));
    expect(fakeRepo.collections.single.name, 'Mới tạo');
    expect(
      fakeRepo.membership[fakeRepo.collections.single.id],
      contains(_ayahId),
    );
  });
}
