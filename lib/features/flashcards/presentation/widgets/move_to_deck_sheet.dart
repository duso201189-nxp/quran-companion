import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/flashcard_providers.dart';
import '../deck_edit_dialog.dart';

/// Sheet chuyển 1 Flashcard sang deck khác (Sprint 13 Phase 3 — Deck
/// Management mục "Move flashcards"). Chọn ĐÚNG 1 deck (hoặc "Không
/// deck"). Dùng ListTile + dấu tick thay vì RadioListTile — Flutter đã
/// deprecate groupValue/onChanged trên từng Radio riêng lẻ (cần
/// RadioGroup bọc ngoài), ListTile+tick giữ đúng ngữ nghĩa "chọn 1"
/// đơn giản hơn mà không đụng API đang chuyển đổi.
class MoveToDeckSheet extends ConsumerWidget {
  const MoveToDeckSheet({super.key, required this.flashcardId});

  final String flashcardId;

  static Future<void> show(BuildContext context, String flashcardId) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => MoveToDeckSheet(flashcardId: flashcardId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decksAsync = ref.watch(allFlashcardDecksProvider);
    final flashcardsAsync = ref.watch(allFlashcardsProvider);
    final currentDeckId = flashcardsAsync.valueOrNull
        ?.where((f) => f.id == flashcardId)
        .firstOrNull
        ?.deckId;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.flashcardMoveToDeck,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _DeckChoiceTile(
              label: l10n.flashcardNoDeck,
              selected: currentDeckId == null,
              onTap: () => _move(ref, null),
            ),
            decksAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.errorLoadData),
              ),
              data: (decks) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final deck in decks)
                    _DeckChoiceTile(
                      label: deck.name,
                      selected: currentDeckId == deck.id,
                      onTap: () => _move(ref, deck.id),
                    ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_rounded),
              title: Text(l10n.flashcardDecksCreate),
              onTap: () => _createAndMove(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _move(WidgetRef ref, String? deckId) =>
      ref.read(flashcardRepositoryProvider).moveFlashcard(flashcardId, deckId);

  Future<void> _createAndMove(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name =
        await DeckEditDialog.show(context, title: l10n.flashcardDecksCreate);
    if (name == null) return;
    final deckId = await ref.read(flashcardRepositoryProvider).createDeck(name);
    await _move(ref, deckId);
  }
}

class _DeckChoiceTile extends StatelessWidget {
  const _DeckChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: onTap,
    );
  }
}
