import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/library/domain/library_item.dart';
import 'package:quran_companion/features/library/presentation/widgets/library_ayah_tile.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

const _item = LibraryItem(
  ayah: AyahSearchResult(
    ayahId: 1,
    surahId: 1,
    ayahNumber: 1,
    surahNameLatin: 'Al-Fatihah',
    arabic: 'بسم الله',
  ),
  savedAt: 0,
);

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('onOrganize null -> không hiện nút Sắp xếp', (tester) async {
    await tester.pumpWidget(
      _wrap(LibraryAyahTile(item: _item, onTap: () {})),
    );

    expect(find.byIcon(Icons.create_new_folder_outlined), findsNothing);
  });

  testWidgets('onOrganize khác null -> hiện nút, bấm gọi đúng callback',
      (tester) async {
    var organizeTapped = false;
    await tester.pumpWidget(
      _wrap(
        LibraryAyahTile(
          item: _item,
          onTap: () {},
          onOrganize: () => organizeTapped = true,
        ),
      ),
    );

    expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    await tester.pump();

    expect(organizeTapped, isTrue);
  });

  testWidgets('bấm nút Sắp xếp không kích hoạt onTap của cả tile',
      (tester) async {
    var tileTapped = false;
    var organizeTapped = false;
    await tester.pumpWidget(
      _wrap(
        LibraryAyahTile(
          item: _item,
          onTap: () => tileTapped = true,
          onOrganize: () => organizeTapped = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    await tester.pump();

    expect(organizeTapped, isTrue);
    expect(tileTapped, isFalse);
  });
}
