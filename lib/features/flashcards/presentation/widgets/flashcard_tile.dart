import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../learning/domain/entities/srs_card.dart';
import '../../data/flashcard_providers.dart';
import '../../domain/entities/flashcard_deck.dart';
import 'move_to_deck_sheet.dart';

enum _FlashcardAction { move, remove }

/// 1 dòng Flashcard dùng chung ở Browse/Smart Deck/Deck detail — hiển
/// thị nội dung Lexicon đã giải quyết (ResolvedFlashcard, xem
/// flashcard_providers.dart) + badge trạng thái SM-2 nếu có SrsCard.
/// KHÔNG tự truy vấn Lemma riêng — luôn nhận [item] đã giải quyết sẵn
/// từ tầng gọi (tránh N+1 truy vấn rải rác nhiều nơi).
class FlashcardTile extends ConsumerWidget {
  const FlashcardTile({super.key, required this.item, this.card, this.deck});

  final ResolvedFlashcard item;
  final SrsCard? card;

  /// Deck của Flashcard này — chỉ truyền khi màn hình đang gộp NHIỀU
  /// deck (Browse tổng hợp); bỏ qua khi đã lọc theo đúng 1 deck.
  final FlashcardDeck? deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lemma = item.lemma;

    return ListTile(
      title: Text(
        lemma?.arabic ?? l10n.flashcardContentUnavailable,
        textDirection: TextDirection.rtl,
        style: textTheme.titleMedium,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              [
                if (lemma?.transliteration != null) lemma!.transliteration!,
                if (lemma?.meaningVi != null) lemma!.meaningVi!,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (deck != null) ...[
            const SizedBox(width: 6),
            DeckLabel(deck: deck),
          ],
        ],
      ),
      leading: card == null
          ? null
          : Tooltip(
              message: _stateLabel(l10n, card!.state),
              child: Semantics(
                label: _stateLabel(l10n, card!.state),
                child: CircleAvatar(
                  backgroundColor: _stateColor(scheme, card!.state),
                  radius: 6,
                ),
              ),
            ),
      trailing: PopupMenuButton<_FlashcardAction>(
        onSelected: (action) => _handle(context, ref, action),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _FlashcardAction.move,
            child: Text(l10n.flashcardMoveToDeck),
          ),
          PopupMenuItem(
            value: _FlashcardAction.remove,
            child: Text(l10n.flashcardRemove),
          ),
        ],
      ),
    );
  }

  Color _stateColor(ColorScheme scheme, SrsCardState state) => switch (state) {
        SrsCardState.newCard => scheme.outlineVariant,
        SrsCardState.learning => scheme.tertiary,
        SrsCardState.review => scheme.primary,
        SrsCardState.lapsed => scheme.error,
      };

  /// Sprint 20 Phase 2, Task 6 — chấm màu SM-2 trước đây KHÔNG có chữ/
  /// nhãn thay thế nào (chỉ `CircleAvatar` màu, vi phạm "không dùng
  /// MÀU SẮC làm cách truyền đạt duy nhất", WCAG 1.4.1 — xem
  /// accessibility_audit.md mục 2.5). Tái sử dụng NGUYÊN VẸN 4 chuỗi
  /// l10n đã có sẵn cho bộ lọc trạng thái
  /// (`flashcard_browse_screen.dart`'s `_StatusFilterChip._label`),
  /// KHÔNG thêm khoá l10n mới — cùng 4 trạng thái, chỉ khác ngữ cảnh
  /// hiển thị (nhãn bộ lọc vs nhãn accessibility của 1 thẻ).
  String _stateLabel(AppLocalizations l10n, SrsCardState state) =>
      switch (state) {
        SrsCardState.newCard => l10n.flashcardFilterNew,
        SrsCardState.learning => l10n.flashcardFilterLearning,
        SrsCardState.review => l10n.flashcardFilterReview,
        SrsCardState.lapsed => l10n.flashcardFilterLapsed,
      };

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _FlashcardAction action,
  ) async {
    switch (action) {
      case _FlashcardAction.move:
        await MoveToDeckSheet.show(context, item.flashcard.id);
      case _FlashcardAction.remove:
        await ref
            .read(flashcardRepositoryProvider)
            .removeFlashcard(item.flashcard.id);
    }
  }
}

/// Chip nhỏ hiển thị tên deck của Flashcard — dùng ở tile khi cần
/// biết deck (Browse tổng hợp mọi deck), không cần khi đã lọc theo
/// đúng 1 deck.
class DeckLabel extends StatelessWidget {
  const DeckLabel({super.key, required this.deck});

  final FlashcardDeck? deck;

  @override
  Widget build(BuildContext context) {
    if (deck == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        deck!.name,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
