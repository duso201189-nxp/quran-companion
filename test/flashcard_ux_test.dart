import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/flashcards/domain/entities/smart_deck_type.dart';
import 'package:quran_companion/features/flashcards/presentation/add_flashcard_screen.dart';
import 'package:quran_companion/features/flashcards/presentation/flashcard_browse_screen.dart';
import 'package:quran_companion/features/flashcards/presentation/flashcard_decks_screen.dart';
import 'package:quran_companion/features/flashcards/presentation/smart_deck_screen.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gieo 2 Lemma mẫu vào AppDatabase (nhóm A) trong bộ nhớ — tối giản,
/// chỉ đủ để AddFlashcardScreen/searchLemmas có gì để tìm/thêm. KHÔNG
/// dùng nội dung thật (Lexicon thật hiện chưa có dữ liệu — xem Sprint
/// 12 Phase 3 §5).
Future<void> _seedLemmas(AppDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.lemmas, [
      const LemmaRow(
        id: 10,
        arabic: 'كَتَبَ',
        transliteration: 'kataba',
        meaningVi: 'đã viết',
        occurrenceCount: 42,
      ),
      const LemmaRow(
        id: 20,
        arabic: 'قَرَأَ',
        transliteration: 'qaraa',
        meaningVi: 'đã đọc',
        occurrenceCount: 30,
      ),
    ]);
  });
}

/// Thay cây widget bằng 1 widget rỗng rồi pump — buộc ProviderScope
/// (và mọi StreamProvider Drift .watch() bên trong) unmount/dispose
/// NGAY TRONG thân test, thay vì để flutter_test tự dọn sau khi test
/// kết thúc. Không gọi bước này, Drift lên lịch 1 Timer dọn dẹp thời
/// lượng 0 (StreamQueryStore.markAsClosed) không kịp chạy trước khi
/// flutter_test kiểm tra "không còn Timer nào đang chờ" -> lỗi giả
/// ("Timer is still pending") dù test tự nó đã đúng.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  late UserDatabase userDb;
  late AppDatabase appDb;
  late SharedPreferences prefs;

  setUp(() async {
    userDb = UserDatabase(NativeDatabase.memory());
    appDb = AppDatabase(NativeDatabase.memory());
    await _seedLemmas(appDb);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await userDb.close();
    await appDb.close();
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: AppRoutes.study,
      routes: [
        GoRoute(
          path: AppRoutes.study,
          builder: (_, __) => const StudyScreen(),
        ),
        GoRoute(
          path: AppRoutes.flashcards,
          builder: (_, __) => const FlashcardBrowseScreen(),
        ),
        GoRoute(
          path: AppRoutes.addFlashcard,
          builder: (_, __) => const AddFlashcardScreen(),
        ),
        GoRoute(
          path: AppRoutes.flashcardDecks,
          builder: (_, __) => const FlashcardDecksScreen(),
        ),
        GoRoute(
          path: AppRoutes.smartDeck,
          builder: (_, state) =>
              SmartDeckScreen(type: state.extra! as SmartDeckType),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(userDb),
        appDatabaseProvider.overrideWithValue(appDb),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
      'StudyScreen -> chạm Flashcard -> FlashcardBrowseScreen, trạng thái '
      'rỗng (Onboarding) khi chưa có Flashcard nào', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();

    expect(find.text('No flashcards yet'), findsOneWidget);
    expect(find.text('Add your first flashcard'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets(
      'Onboarding CTA -> AddFlashcardScreen, tìm + thêm 1 Lemma -> quay '
      'lại Browse thấy Flashcard vừa thêm', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add your first flashcard'));
    await tester.pumpAndSettle();
    expect(find.byType(AddFlashcardScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kataba');
    await tester.pumpAndSettle();

    expect(find.text('كَتَبَ'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
    await tester.pumpAndSettle();

    // Đã thêm -> icon đổi thành dấu tick, không còn nút Thêm.
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('No flashcards yet'), findsNothing);
    expect(find.text('كَتَبَ'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets(
      'Add Flashcard: nguồn Root/Phrase hiện trạng thái "chưa có dữ liệu", '
      'không giả lập kết quả tìm kiếm', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add your first flashcard'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Root'));
    await tester.pumpAndSettle();

    expect(find.text('No browsable data for this type yet.'), findsOneWidget);

    await _disposeTree(tester);
  });

  group('FlashcardDecksScreen', () {
    Future<void> openDecks(WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flashcards'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('rỗng lúc đầu, tạo deck mới hiện ngay trong danh sách',
        (tester) async {
      await openDecks(tester);
      expect(find.text('No decks yet.'), findsOneWidget);

      await tester.tap(find.text('Create deck'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Al-Baqarah Vocabulary');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Al-Baqarah Vocabulary'), findsOneWidget);
      expect(find.text('No decks yet.'), findsNothing);

      await _disposeTree(tester);
    });

    testWidgets('đổi tên deck qua menu', (tester) async {
      await openDecks(tester);
      await tester.tap(find.text('Create deck'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Tên cũ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Tên mới');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Tên mới'), findsOneWidget);
      expect(find.text('Tên cũ'), findsNothing);

      await _disposeTree(tester);
    });

    testWidgets('xoá deck qua menu + xác nhận', (tester) async {
      await openDecks(tester);
      await tester.tap(find.text('Create deck'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Deck để xoá');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Deck để xoá'), findsNothing);
      expect(find.text('No decks yet.'), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets(
      'Smart Deck: chạm chip "Today\'s Review" điều hướng sang '
      'SmartDeckScreen, trạng thái rỗng khi chưa có gì đến hạn',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add your first flashcard'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'kataba');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text("Today's Review"));
    await tester.pumpAndSettle();

    expect(find.byType(SmartDeckScreen), findsOneWidget);

    await _disposeTree(tester);
  });
}
