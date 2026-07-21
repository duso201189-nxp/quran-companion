import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../shared/widgets/section_header.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../data/flashcard_providers.dart';
import '../domain/entities/smart_deck_type.dart';
import 'widgets/flashcard_tile.dart';

/// Trình bày kết quả 1 Smart Deck (Sprint 13 Phase 3 mục 4) — CHỈ đọc
/// từ các provider truy vấn động đã có (smartDeckFlashcardsProvider/
/// verbFormGroupsProvider), không tự tính lại gì, không có bảng lưu
/// riêng cho Smart Deck nào (đúng yêu cầu "dynamic queries, not
/// duplicated data").
class SmartDeckScreen extends ConsumerWidget {
  const SmartDeckScreen({super.key, required this.type});

  final SmartDeckType type;

  String _title(AppLocalizations l10n) => switch (type) {
        SmartDeckType.todaysReview => l10n.smartDeckTodaysReview,
        SmartDeckType.mostDifficult => l10n.smartDeckMostDifficult,
        SmartDeckType.recentlyLearned => l10n.smartDeckRecentlyLearned,
        SmartDeckType.weakRoots => l10n.smartDeckWeakRoots,
        SmartDeckType.verbForms => l10n.smartDeckVerbForms,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resolvedAsync = ref.watch(resolvedFlashcardsProvider);
    final cardsByLemmaIdAsync = ref.watch(lemmaCardsByIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: SafeArea(
        child: type == SmartDeckType.verbForms
            ? _VerbFormsBody(
                l10n: l10n,
                resolvedAsync: resolvedAsync,
                cardsByLemmaIdAsync: cardsByLemmaIdAsync,
              )
            : _FlatBody(
                type: type,
                l10n: l10n,
                resolvedAsync: resolvedAsync,
                cardsByLemmaIdAsync: cardsByLemmaIdAsync,
              ),
      ),
    );
  }
}

class _FlatBody extends ConsumerWidget {
  const _FlatBody({
    required this.type,
    required this.l10n,
    required this.resolvedAsync,
    required this.cardsByLemmaIdAsync,
  });

  final SmartDeckType type;
  final AppLocalizations l10n;
  final AsyncValue<List<ResolvedFlashcard>> resolvedAsync;
  final AsyncValue<Map<int, SrsCard>> cardsByLemmaIdAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(smartDeckFlashcardsProvider(type));

    return idsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.errorLoadData)),
      data: (deckFlashcards) {
        if (deckFlashcards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.smartDeckEmpty, textAlign: TextAlign.center),
            ),
          );
        }
        final resolvedById = {
          for (final r
              in resolvedAsync.valueOrNull ?? const <ResolvedFlashcard>[])
            r.flashcard.id: r,
        };
        final cardsByLemmaId =
            cardsByLemmaIdAsync.valueOrNull ?? const <int, SrsCard>{};
        return ListView.builder(
          itemCount: deckFlashcards.length,
          itemBuilder: (context, i) {
            final f = deckFlashcards[i];
            final resolved = resolvedById[f.id] ?? (flashcard: f, lemma: null);
            return FlashcardTile(
              item: resolved,
              card: cardsByLemmaId[f.lexiconEntryId],
            );
          },
        );
      },
    );
  }
}

class _VerbFormsBody extends ConsumerWidget {
  const _VerbFormsBody({
    required this.l10n,
    required this.resolvedAsync,
    required this.cardsByLemmaIdAsync,
  });

  final AppLocalizations l10n;
  final AsyncValue<List<ResolvedFlashcard>> resolvedAsync;
  final AsyncValue<Map<int, SrsCard>> cardsByLemmaIdAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(verbFormGroupsProvider);

    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.errorLoadData)),
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.smartDeckEmpty, textAlign: TextAlign.center),
            ),
          );
        }
        final resolvedById = {
          for (final r
              in resolvedAsync.valueOrNull ?? const <ResolvedFlashcard>[])
            r.flashcard.id: r,
        };
        final cardsByLemmaId =
            cardsByLemmaIdAsync.valueOrNull ?? const <int, SrsCard>{};
        final forms = groups.keys.toList()..sort();

        return ListView(
          children: [
            for (final form in forms) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: SectionHeader(text: l10n.smartDeckVerbFormLabel(form)),
              ),
              for (final f in groups[form]!)
                FlashcardTile(
                  item: resolvedById[f.id] ?? (flashcard: f, lemma: null),
                  card: cardsByLemmaId[f.lexiconEntryId],
                ),
            ],
          ],
        );
      },
    );
  }
}
