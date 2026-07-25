import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/library/domain/library_item.dart';
import 'package:quran_companion/features/library/presentation/widgets/library_ayah_tile.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:quran_companion/shared/widgets/card_shell.dart';

/// Sprint 27.1 — [CardShell] là vỏ thẻ dùng chung, trích ra từ hai cây
/// widget giống hệt nhau (ResultCard + LibraryAyahTile).
///
/// Test khoá lại ĐÚNG hai điều mà việc dùng chung có thể làm hỏng:
/// hình học của thẻ, và việc gộp/không gộp ngữ nghĩa. Hai widget gọi
/// nó KHÔNG bị hợp nhất, nên mỗi bên vẫn giữ test riêng đã có
/// (`result_card_test.dart`, `library_ayah_tile_organize_test.dart`).

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

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

void main() {
  group('CardShell — vỏ dùng chung', () {
    testWidgets('dựng nội dung con và giữ nguyên hình học của bản gốc',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const CardShell(child: Text('nội dung'))),
      );

      expect(find.text('nội dung'), findsOneWidget);

      // Hình học phải khớp CHÍNH XÁC hai bản gốc: ngoài 8/3, trong 14,
      // bo góc 14, nền surfaceContainerLow.
      expect(
        CardShell.outerPadding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
      expect(CardShell.innerPadding, const EdgeInsets.all(14));
      expect(CardShell.radius, 14);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(CardShell),
          matching: find.byType(Material),
        ),
      );
      final context = tester.element(find.byType(CardShell));
      expect(material.color, Theme.of(context).colorScheme.surfaceContainerLow);
      expect(material.borderRadius, BorderRadius.circular(CardShell.radius));
    });

    testWidgets('onTap null -> chạm không lỗi và không có node nút',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const CardShell(semanticsLabel: 'thẻ', child: Text('x'))),
      );

      await tester.tap(find.byType(CardShell));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('thẻ'))
            .flagsCollection
            .isButton,
        isFalse,
      );
    });

    testWidgets('có onTap -> chạm gọi callback và node là nút', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          CardShell(
            semanticsLabel: 'thẻ',
            onTap: () => tapped = true,
            child: const Text('x'),
          ),
        ),
      );

      await tester.tap(find.byType(CardShell));
      await tester.pump();

      expect(tapped, isTrue);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('thẻ'))
            .flagsCollection
            .isButton,
        isTrue,
      );
    });

    testWidgets(
        'không truyền semanticsLabel -> KHÔNG gộp, widget con vẫn tự '
        'đọc được', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CardShell(
            child: Text('dòng con phải đọc được riêng'),
          ),
        ),
      );

      // Không có node gộp nào nuốt mất nội dung con.
      expect(
        find.bySemanticsLabel('dòng con phải đọc được riêng'),
        findsOneWidget,
      );
    });
  });

  group('Bên gọi giữ nguyên hành vi sau khi dùng chung vỏ', () {
    testWidgets('ResultCard vẫn gộp thành MỘT node nút duy nhất',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ResultCard(
            icon: Icons.menu_book_outlined,
            sourceLabel: 'Ar-Rahman · 55:1',
            primaryText: 'الرحمن',
            secondaryText: 'The Most Merciful',
            onTap: null,
          ),
        ),
      );

      expect(find.byType(CardShell), findsOneWidget);
      expect(
        find.bySemanticsLabel('Ar-Rahman · 55:1. الرحمن. The Most Merciful'),
        findsOneWidget,
      );
    });

    testWidgets(
        'LibraryAyahTile KHÔNG gộp — nút "sắp xếp" vẫn là node riêng '
        'bấm được (điều kiện bắt buộc để dùng chung vỏ)', (tester) async {
      var organized = false;
      await tester.pumpWidget(
        _wrap(
          LibraryAyahTile(
            item: _item,
            onTap: () {},
            onOrganize: () => organized = true,
          ),
        ),
      );

      expect(find.byType(CardShell), findsOneWidget);

      final organizeButton = find.byIcon(Icons.create_new_folder_outlined);
      expect(organizeButton, findsOneWidget);
      // Nếu vỏ gộp ngữ nghĩa (excludeSemantics) thì nút này biến mất
      // khỏi cây accessibility — chính là điều phải KHÔNG xảy ra.
      expect(
        tester.getSemantics(organizeButton).flagsCollection.isButton,
        isTrue,
      );

      await tester.tap(organizeButton);
      await tester.pump();
      expect(organized, isTrue);
    });
  });
}
