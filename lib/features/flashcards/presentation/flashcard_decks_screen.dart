import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../data/flashcard_providers.dart';
import '../domain/entities/flashcard_deck.dart';
import 'deck_edit_dialog.dart';

enum _DeckAction { rename, delete }

/// Quản lý Deck Flashcard (Sprint 13 Phase 3 mục 3) — cùng khuôn
/// CollectionsScreen (Bookmark, Sprint 8) hệt: danh sách + số lượng,
/// tạo qua FAB, đổi tên/xoá qua menu trên mỗi dòng. "Move flashcards"
/// (mục 3 còn lại) nằm ở MoveToDeckSheet, mở từ FlashcardTile — xoá 1
/// deck ở đây đã tự gỡ deckId khỏi mọi Flashcard liên quan
/// (FlashcardRepositoryImpl.deleteDeck).
class FlashcardDecksScreen extends ConsumerWidget {
  const FlashcardDecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decksAsync = ref.watch(allFlashcardDecksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcardDecksTitle)),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.errorLoadData)),
          data: (decks) {
            if (decks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.flashcardDecksEmpty,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: decks.length,
              itemBuilder: (context, i) => _DeckTile(deck: decks[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.flashcardDecksCreate),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name =
        await DeckEditDialog.show(context, title: l10n.flashcardDecksCreate);
    if (name == null) return;
    await ref.read(flashcardRepositoryProvider).createDeck(name);
  }
}

class _DeckTile extends ConsumerWidget {
  const _DeckTile({required this.deck});

  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final flashcardsAsync = ref.watch(flashcardsInDeckProvider(deck.id));

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        child: const Icon(Icons.style_rounded),
      ),
      title: Text(deck.name),
      subtitle: Text(
        l10n.flashcardDeckItemCount(flashcardsAsync.valueOrNull?.length ?? 0),
      ),
      trailing: PopupMenuButton<_DeckAction>(
        onSelected: (action) => _handle(context, ref, action),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _DeckAction.rename,
            child: Text(l10n.flashcardDecksRename),
          ),
          PopupMenuItem(
            value: _DeckAction.delete,
            child: Text(l10n.flashcardDecksDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _DeckAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(flashcardRepositoryProvider);
    switch (action) {
      case _DeckAction.rename:
        final name = await DeckEditDialog.show(
          context,
          title: l10n.flashcardDecksRename,
          initialName: deck.name,
        );
        if (name == null) break;
        await repo.renameDeck(deck.id, name);
      case _DeckAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.flashcardDecksDeleteConfirmTitle),
            content: Text(l10n.flashcardDecksDeleteConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.flashcardDecksDelete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.deleteDeck(deck.id);
        }
    }
  }
}
