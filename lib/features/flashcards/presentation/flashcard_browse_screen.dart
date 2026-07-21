import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../data/flashcard_providers.dart';
import '../domain/entities/flashcard_deck.dart';
import '../domain/entities/flashcard_type.dart';
import '../domain/entities/smart_deck_type.dart';
import '../domain/flashcard_filter.dart';
import 'widgets/flashcard_tile.dart';

/// Duyệt Flashcard (Sprint 13 Phase 3 mục 1/5/6/7) — điểm vào chính
/// của UX Flashcard: tìm kiếm + lọc (deck/loại/trạng thái), Smart Deck
/// (mục 4, truy vấn động), Onboarding cho người dùng lần đầu (mục 7),
/// 3 trạng thái rỗng (mục 6 — "No flashcards" ở đây,
/// "No review today" ở FlashcardReviewScreen/SmartDeckScreen.todaysReview
/// đã có sẵn, "Empty deck" khi lọc theo 1 deck rỗng).
class FlashcardBrowseScreen extends ConsumerStatefulWidget {
  const FlashcardBrowseScreen({super.key});

  @override
  ConsumerState<FlashcardBrowseScreen> createState() =>
      _FlashcardBrowseScreenState();
}

class _FlashcardBrowseScreenState extends ConsumerState<FlashcardBrowseScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _deckFilter;
  FlashcardType? _typeFilter;
  FlashcardStatusFilter _statusFilter = FlashcardStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedAsync = ref.watch(resolvedFlashcardsProvider);
    final decksAsync = ref.watch(allFlashcardDecksProvider);
    final cardsByLemmaIdAsync = ref.watch(lemmaCardsByIdProvider);
    final dueAsync = ref.watch(dueFlashcardCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flashcardsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: l10n.flashcardDecksTitle,
            onPressed: () => context.push(AppRoutes.flashcardDecks),
          ),
        ],
      ),
      body: SafeArea(
        child: resolvedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.errorLoadData)),
          data: (resolved) {
            if (resolved.isEmpty) {
              return _NoFlashcardsEmptyState(l10n: l10n);
            }

            final cardsByLemmaId =
                cardsByLemmaIdAsync.valueOrNull ?? const <int, SrsCard>{};
            final dueLemmaIds = <int>{
              for (final c in dueAsync.valueOrNull ?? const <SrsCard>[])
                c.itemId,
            };
            final filtered = filterFlashcards(
              items: resolved,
              query: _query,
              deckFilter: _deckFilter,
              typeFilter: _typeFilter,
              statusFilter: _statusFilter,
              cardsByLemmaId: cardsByLemmaId,
              dueLemmaIds: dueLemmaIds,
            );

            return Column(
              children: [
                if (resolved.length == 1) _FirstFlashcardNudge(l10n: l10n),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.flashcardSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DeckFilterChip(
                          l10n: l10n,
                          selected: _deckFilter,
                          decks: decksAsync.valueOrNull ?? const [],
                          onChanged: (v) => setState(() => _deckFilter = v),
                        ),
                        const SizedBox(width: 8),
                        _TypeFilterChip(
                          l10n: l10n,
                          selected: _typeFilter,
                          onChanged: (v) => setState(() => _typeFilter = v),
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          l10n: l10n,
                          selected: _statusFilter,
                          onChanged: (v) => setState(() => _statusFilter = v),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final type in SmartDeckType.values) ...[
                          ActionChip(
                            avatar: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                            ),
                            label: Text(_smartDeckLabel(l10n, type)),
                            onPressed: () => context.push(
                              AppRoutes.smartDeck,
                              extra: type,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyFilterResult(
                          l10n: l10n,
                          isDeckFilter: _deckFilter != null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final item = filtered[i];
                            final deck = _deckFilter == null
                                ? (decksAsync.valueOrNull ?? const [])
                                    .where((d) => d.id == item.flashcard.deckId)
                                    .firstOrNull
                                : null;
                            return FlashcardTile(
                              item: item,
                              card:
                                  cardsByLemmaId[item.flashcard.lexiconEntryId],
                              deck: deck,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addFlashcard),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.flashcardAdd),
      ),
    );
  }

  String _smartDeckLabel(AppLocalizations l10n, SmartDeckType type) =>
      switch (type) {
        SmartDeckType.todaysReview => l10n.smartDeckTodaysReview,
        SmartDeckType.mostDifficult => l10n.smartDeckMostDifficult,
        SmartDeckType.recentlyLearned => l10n.smartDeckRecentlyLearned,
        SmartDeckType.weakRoots => l10n.smartDeckWeakRoots,
        SmartDeckType.verbForms => l10n.smartDeckVerbForms,
      };
}

class _DeckFilterChip extends StatelessWidget {
  const _DeckFilterChip({
    required this.l10n,
    required this.selected,
    required this.decks,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final String? selected;
  final List<FlashcardDeck> decks;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = switch (selected) {
      null => l10n.flashcardFilterAllDecks,
      noDeckFilter => l10n.flashcardNoDeck,
      final id => decks.where((d) => d.id == id).firstOrNull?.name ??
          l10n.flashcardFilterAllDecks,
    };

    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(l10n.flashcardFilterAllDecks)),
        PopupMenuItem(value: noDeckFilter, child: Text(l10n.flashcardNoDeck)),
        for (final d in decks) PopupMenuItem(value: d.id, child: Text(d.name)),
      ],
      child: Chip(label: Text(label)),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final FlashcardType? selected;
  final ValueChanged<FlashcardType?> onChanged;

  String _label(FlashcardType? type) => switch (type) {
        null => l10n.flashcardFilterAllTypes,
        FlashcardType.lemma => l10n.addFlashcardSourceLemma,
        FlashcardType.root => l10n.addFlashcardSourceRoot,
        FlashcardType.phrase => l10n.addFlashcardSourcePhrase,
        FlashcardType.grammar ||
        FlashcardType.note ||
        FlashcardType.custom =>
          type.name,
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FlashcardType?>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(_label(null))),
        PopupMenuItem(
          value: FlashcardType.lemma,
          child: Text(_label(FlashcardType.lemma)),
        ),
        PopupMenuItem(
          value: FlashcardType.root,
          child: Text(_label(FlashcardType.root)),
        ),
        PopupMenuItem(
          value: FlashcardType.phrase,
          child: Text(_label(FlashcardType.phrase)),
        ),
      ],
      child: Chip(label: Text(_label(selected))),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final FlashcardStatusFilter selected;
  final ValueChanged<FlashcardStatusFilter> onChanged;

  String _label(FlashcardStatusFilter s) => switch (s) {
        FlashcardStatusFilter.all => l10n.flashcardFilterAllStatus,
        FlashcardStatusFilter.due => l10n.flashcardFilterDue,
        FlashcardStatusFilter.newCard => l10n.flashcardFilterNew,
        FlashcardStatusFilter.learning => l10n.flashcardFilterLearning,
        FlashcardStatusFilter.review => l10n.flashcardFilterReview,
        FlashcardStatusFilter.lapsed => l10n.flashcardFilterLapsed,
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FlashcardStatusFilter>(
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final s in FlashcardStatusFilter.values)
          PopupMenuItem(value: s, child: Text(_label(s))),
      ],
      child: Chip(label: Text(_label(selected))),
    );
  }
}

class _NoFlashcardsEmptyState extends StatelessWidget {
  const _NoFlashcardsEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.style_outlined, size: 64, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.flashcardOnboardingTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.flashcardOnboardingBody,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.addFlashcard),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.flashcardOnboardingCta),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nudge Onboarding bước 2 (mục 7 — "hướng dẫn ôn thẻ đầu tiên") —
/// hiện khi vừa có ĐÚNG 1 Flashcard (vừa thêm xong), gợi ý ôn ngay.
/// Không có cờ "đã xem onboarding" lưu riêng — điều kiện hiển thị suy
/// thẳng từ resolved.length == 1, không thêm dữ liệu lưu trữ mới.
class _FirstFlashcardNudge extends StatelessWidget {
  const _FirstFlashcardNudge({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.flashcardOnboardingReviewNudge,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.flashcardReview),
            child: Text(l10n.flashcardOnboardingReviewCta),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterResult extends StatelessWidget {
  const _EmptyFilterResult({required this.l10n, required this.isDeckFilter});

  final AppLocalizations l10n;
  final bool isDeckFilter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          isDeckFilter ? l10n.flashcardEmptyDeck : l10n.flashcardNoResults,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
