import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/utils/highlight.dart';
import '../domain/entities/ayah_search_result.dart';
import '../domain/entities/surah.dart';
import 'reading/reading_position_store.dart';
import 'surah_list_controller.dart';

/// Danh sách 114 Surah — tìm kiếm (không phân biệt dấu) + lọc
/// Mecca/Madinah. Có đủ loading / error (kèm Thử lại) / empty state.
class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahsAsync = ref.watch(filteredSurahsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabQuran)),
      body: Column(
        children: [
          _SearchAndFilterBar(l10n: l10n),
          Expanded(
            child: surahsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(l10n: l10n),
              data: (surahs) {
                final query = ref.watch(surahSearchQueryProvider).trim();
                // Không tìm kiếm: danh sách 114 Surah như thường.
                if (query.isEmpty) {
                  return surahs.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : _SurahListView(surahs: surahs);
                }
                // Đang tìm: Surah khớp tên + kết quả toàn văn Ayah.
                return _SearchResultsView(
                  l10n: l10n,
                  query: query,
                  surahs: surahs,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends ConsumerWidget {
  const _SearchAndFilterBar({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(surahFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            hintText: l10n.searchSurahHint,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (value) =>
                ref.read(surahSearchQueryProvider.notifier).state = value,
          ),
          const SizedBox(height: 8),
          // Lọc theo nơi mặc khải — SegmentedButton chuẩn M3,
          // screen reader đọc được trạng thái chọn.
          SegmentedButton<SurahFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: SurahFilter.all,
                label: Text(l10n.filterAll),
              ),
              ButtonSegment(
                value: SurahFilter.mecca,
                label: Text(l10n.revelationMecca),
              ),
              ButtonSegment(
                value: SurahFilter.madinah,
                label: Text(l10n.revelationMadinah),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (selection) =>
                ref.read(surahFilterProvider.notifier).state = selection.first,
          ),
        ],
      ),
    );
  }
}

class _SurahListView extends ConsumerWidget {
  const _SurahListView({required this.surahs});

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      itemCount: surahs.length,
      itemBuilder: (context, index) => SurahTile(surah: surahs[index]),
    );
  }
}

/// Một dòng Surah. Public để widget test truy cập trực tiếp.
class SurahTile extends StatelessWidget {
  const SurahTile({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final placeLabel = surah.revelationPlace == RevelationPlace.mecca
        ? l10n.revelationMecca
        : l10n.revelationMadinah;

    return Semantics(
      // Screen reader đọc trọn thông tin một lần, thay vì từng mảnh.
      label: '${surah.id}. ${surah.nameLatin} — ${surah.nameVi}. '
          '${l10n.surahAyahCount(surah.ayahCount)}. $placeLabel.',
      excludeSemantics: true,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: ListTile(
          onTap: () => context.push(AppRoutes.surahReading(surah.id)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          hoverColor: scheme.primaryContainer.withValues(alpha: 0.25),
          splashColor: scheme.primaryContainer.withValues(alpha: 0.35),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${surah.id}',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            surah.nameLatin,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${l10n.surahAyahCount(surah.ayahCount)} · $placeLabel',
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Tên Ả Rập — Naskh trang trọng, bề rộng cố định để mọi
          // dòng canh thẳng hàng hoàn hảo.
          trailing: SizedBox(
            width: 112,
            child: Text(
              surah.nameArabic,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              style: arabicTitleStyle(
                fontSize: 24,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kết quả tìm kiếm: Surah khớp tên/số + Ayah khớp nội dung (FTS),
/// phần khớp được tô đậm màu chính.
class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({
    required this.l10n,
    required this.query,
    required this.surahs,
  });

  final AppLocalizations l10n;
  final String query;
  final List<Surah> surahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahResults = ref.watch(ayahSearchProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Cả hai phần đều rỗng -> empty state chung (một thông điệp).
    final noAyahResults =
        query.length < 2 || (ayahResults.valueOrNull?.isEmpty ?? false);
    if (surahs.isEmpty && noAyahResults && !ayahResults.isLoading) {
      return _EmptyState(l10n: l10n);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      children: [
        for (final s in surahs) SurahTile(surah: s),
        if (query.length >= 2) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.searchResultsAyahs,
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ayahResults.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.errorLoadData),
            ),
            data: (results) => results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.searchNoAyahResults,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : Column(
                    children: [
                      for (final r in results)
                        _AyahResultTile(result: r, query: query),
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}

class _AyahResultTile extends ConsumerWidget {
  const _AyahResultTile({required this.result, required this.query});

  final AyahSearchResult result;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final highlightStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: scheme.primary,
      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          // Mở trang đọc ĐÚNG tại Ayah này (đặt vị trí trước khi mở).
          await ref.read(readingPositionStoreProvider).save(
                surahId: result.surahId,
                ayahIndex: result.ayahNumber - 1,
              );
          if (context.mounted) {
            unawaited(context.push(AppRoutes.surahReading(result.surahId)));
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.surahNameLatin} · '
                '${result.surahId}:${result.ayahNumber}',
                style: textTheme.labelMedium?.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: highlightSpans(
                    result.arabic,
                    query,
                    highlightStyle: highlightStyle,
                  ),
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: quranTextStyle(
                  fontSize: 22,
                  color: scheme.onSurface,
                ),
              ),
              if (result.translation != null) ...[
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: highlightSpans(
                      result.translation!,
                      query,
                      highlightStyle: highlightStyle,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: scheme.error),
            const SizedBox(height: 12),
            Text(l10n.errorLoadData, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(surahListProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 56,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(l10n.emptySearchResults, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
