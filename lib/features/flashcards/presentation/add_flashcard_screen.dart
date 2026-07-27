import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../lexicon/data/lexicon_providers.dart';
import '../../lexicon/domain/entities/lemma.dart';
import '../../lexicon/domain/entities/lexicon_entry.dart';
import '../data/flashcard_providers.dart';
import '../domain/entities/flashcard.dart';
import '../domain/entities/flashcard_type.dart';

/// Nguồn thêm Flashcard (Sprint 13 Phase 3 mục 2) — CHỈ [lemma] có
/// truy vấn duyệt/tìm thật (LexiconRepository.searchLemmas, thêm ở
/// phase này). [root]/[phrase] hiện diện đúng cấu trúc (người dùng
/// chọn được) nhưng CHƯA có phương thức duyệt/tìm tương ứng trên
/// LexiconRepository, và Lexicon hiện cũng chưa có dữ liệu Root/Phrase
/// thật — cùng mức "cấu trúc có sẵn, dữ liệu/thao tác thật chưa tới"
/// mà FlashcardType đã áp dụng từ Sprint 12 Phase 0.1. KHÔNG giả lập
/// kết quả tìm kiếm cho 2 loại này.
enum AddFlashcardSource { lemma, root, phrase }

class AddFlashcardScreen extends ConsumerStatefulWidget {
  const AddFlashcardScreen({super.key});

  @override
  ConsumerState<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends ConsumerState<AddFlashcardScreen> {
  AddFlashcardSource _source = AddFlashcardSource.lemma;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addFlashcardTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SegmentedButton<AddFlashcardSource>(
                segments: [
                  ButtonSegment(
                    value: AddFlashcardSource.lemma,
                    label: Text(l10n.addFlashcardSourceLemma),
                  ),
                  ButtonSegment(
                    value: AddFlashcardSource.root,
                    label: Text(l10n.addFlashcardSourceRoot),
                  ),
                  ButtonSegment(
                    value: AddFlashcardSource.phrase,
                    label: Text(l10n.addFlashcardSourcePhrase),
                  ),
                ],
                selected: {_source},
                onSelectionChanged: (s) => setState(() => _source = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.addFlashcardSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(),
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
            Expanded(
              child: switch (_source) {
                AddFlashcardSource.lemma => _LemmaResults(query: _query),
                AddFlashcardSource.root ||
                AddFlashcardSource.phrase =>
                  _SourceNotAvailable(l10n: l10n),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LemmaResults extends ConsumerWidget {
  const _LemmaResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resultsAsync = ref.watch(lemmaSearchProvider(query));
    final existingAsync = ref.watch(allFlashcardsProvider);
    final existingLemmaIds = <int>{
      for (final f in existingAsync.valueOrNull ?? const <Flashcard>[])
        if (f.type.name == 'lemma') f.lexiconEntryId,
    };

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.errorLoadData)),
      data: (lemmas) {
        if (lemmas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.addFlashcardNoResults,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: lemmas.length,
          itemBuilder: (context, i) {
            final lemma = lemmas[i];
            final added = existingLemmaIds.contains(lemma.id);
            return _LemmaResultTile(lemma: lemma, added: added);
          },
        );
      },
    );
  }
}

class _LemmaResultTile extends ConsumerWidget {
  const _LemmaResultTile({required this.lemma, required this.added});

  final Lemma lemma;
  final bool added;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(
        lemma.arabic,
        textDirection: TextDirection.rtl,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        [
          if (lemma.transliteration != null) lemma.transliteration!,
          if (lemma.meaningVi != null) lemma.meaningVi!,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: added
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          : IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () =>
                  ref.read(flashcardRepositoryProvider).addFlashcard(
                        type: FlashcardType.lemma,
                        lexiconEntryType: LexiconEntryType.lemma,
                        lexiconEntryId: lemma.id,
                      ),
              tooltip: l10n.addFlashcardAdd,
            ),
    );
  }
}

class _SourceNotAvailable extends StatelessWidget {
  const _SourceNotAvailable({required this.l10n});

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
            Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addFlashcardSourceNotAvailable,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
