import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/flashcards/presentation/widgets/flashcard_tile.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

import 'fixtures/search_test_harness.dart';

const _item = (
  flashcard: Flashcard(
    id: 'fc-1',
    type: FlashcardType.lemma,
    lexiconEntryType: LexiconEntryType.lemma,
    lexiconEntryId: 1,
    createdAt: 0,
  ),
  lemma: null,
);

SrsCard _cardWith(SrsCardState state) => SrsCard(
      id: 'card-1',
      itemType: LearningItemType.lemma,
      itemId: 1,
      easeFactor: 2.5,
      intervalDays: 1,
      repetitions: 0,
      dueDate: 0,
      state: state,
      updatedAtMs: 0,
    );

/// Sprint 20 Phase 2, Task 6 — chấm màu trạng thái SM-2 trước đây
/// KHÔNG có chữ/nhãn thay thế nào (xem accessibility_audit.md mục
/// 2.5/8.6). Kiểm chứng cả 4 trạng thái đều có nhãn accessibility
/// đúng, tái sử dụng chuỗi l10n đã có sẵn cho bộ lọc trạng thái.
void main() {
  Future<void> pump(WidgetTester tester, SrsCardState state) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          FlashcardTile(item: _item, card: _cardWith(state)),
          locale: const Locale('en'),
        ),
      ),
    );
  }

  // Lưu ý: ListTile GỘP leading+title thành 1 SemanticsNode duy nhất
  // (đúng hành vi Flutter chuẩn — trình đọc màn hình đọc liền mạch cả
  // hàng, không dừng rời rạc ở icon rồi title) — label thật là
  // "New\nContent unavailable" (đã xác nhận bằng
  // debugSemantics.toStringDeep() trong lúc viết test này), KHÔNG
  // phải "New" đứng riêng. `Tooltip` (bọc ngoài `Semantics`, xem
  // flashcard_tile.dart) đóng góp `tooltip:` RIÊNG, không bị gộp —
  // đây là tín hiệu chính xác nhất để kiểm tra nhãn trạng thái.
  testWidgets('newCard -> tooltip "New", label CHỨA "New"', (tester) async {
    await pump(tester, SrsCardState.newCard);
    final semantics = tester.getSemantics(find.byType(FlashcardTile));
    expect(semantics.tooltip, 'New');
    expect(semantics.label, contains('New'));
  });

  testWidgets('learning -> tooltip "Learning", label CHỨA "Learning"',
      (tester) async {
    await pump(tester, SrsCardState.learning);
    final semantics = tester.getSemantics(find.byType(FlashcardTile));
    expect(semantics.tooltip, 'Learning');
    expect(semantics.label, contains('Learning'));
  });

  testWidgets('review -> tooltip "Review", label CHỨA "Review"',
      (tester) async {
    await pump(tester, SrsCardState.review);
    final semantics = tester.getSemantics(find.byType(FlashcardTile));
    expect(semantics.tooltip, 'Review');
    expect(semantics.label, contains('Review'));
  });

  testWidgets('lapsed -> tooltip "Lapsed", label CHỨA "Lapsed"',
      (tester) async {
    await pump(tester, SrsCardState.lapsed);
    final semantics = tester.getSemantics(find.byType(FlashcardTile));
    expect(semantics.tooltip, 'Lapsed');
    expect(semantics.label, contains('Lapsed'));
  });

  testWidgets('card == null -> không có chấm trạng thái, không nhãn nào',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          const FlashcardTile(item: _item),
          locale: const Locale('en'),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('giao diện chấm màu KHÔNG đổi (vẫn CircleAvatar radius 6)',
      (tester) async {
    await pump(tester, SrsCardState.review);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 6);
  });
}
