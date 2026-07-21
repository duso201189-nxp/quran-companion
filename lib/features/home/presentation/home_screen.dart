import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../quran/data/quran_providers.dart';
import '../../quran/domain/entities/ayah_content.dart';
import '../../quran/domain/entities/surah.dart';
import '../../quran/presentation/reading/reading_position_store.dart';
import '../../quran/presentation/surah_list_controller.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../../stats/data/daily_goal_providers.dart';
import '../../stats/data/stats_store.dart';
import '../../stats/data/study_session_providers.dart';
import '../../stats/presentation/widgets/daily_goal_dialog.dart';

/// Câu Qur'an trong ngày — chọn luân phiên theo ngày từ danh sách
/// các Ayah quen thuộc (tất định: cùng ngày luôn cùng câu).
final todaysVerseProvider =
    FutureProvider<({Surah surah, AyahContent content})?>((ref) async {
  const picks = <(int, int)>[
    (2, 255),
    (1, 5),
    (94, 5),
    (3, 190),
    (55, 13),
    (93, 3),
    (103, 2),
    (13, 28),
    (17, 80),
    (112, 1),
    (2, 286),
    (29, 69),
    (20, 114),
    (49, 13),
  ];
  final day = DateTime.now().difference(DateTime(2026)).inDays;
  final (surahId, ayahNo) = picks[day % picks.length];
  final repo = ref.watch(quranRepositoryProvider);
  final surah = await repo.getSurahById(surahId);
  if (surah == null) return null;
  final ayahs = await repo.getAyahsOfSurah(surahId);
  if (ayahNo > ayahs.length) return null;
  return (surah: surah, content: ayahs[ayahNo - 1]);
});

/// Trang chủ — dashboard học tập: đọc tiếp, câu hôm nay, tiến độ,
/// truy cập nhanh, Surah gần đây.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Surah hay đọc — lối tắt khi chưa có lịch sử riêng.
  static const List<int> _quickSurahIds = [1, 18, 36, 55, 56, 67];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(statsStoreProvider);
    final positions = ref.watch(readingPositionStoreProvider);
    final surahsAsync = ref.watch(surahListProvider);
    // Nguồn canonical cho streak — DR-2026-0004 mục 1. Không đọc
    // stats.currentStreak (StatsStore) nữa.
    final currentStreak = ref.watch(currentStreakProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabHome),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchLabel,
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: SafeArea(
        // Sprint 20 Phase 2, Task 5 — TRƯỚC đây surahsAsync chỉ đọc qua
        // `.valueOrNull ?? []`, KHÔNG có nhánh loading/error nào: khi
        // tải chậm hoặc lỗi, Quick Access/Recent Surahs/Continue Reading
        // đều lặng lẽ coi như "chưa có Surah nào" — không spinner,
        // không thông báo lỗi (xem accessibility_audit.md mục 3.1).
        // Đưa Home về ĐÚNG mẫu `.when()` mà MỌI màn hình khác trong app
        // đã dùng (Analytics/AI Tutor/Learning Journey/Smart Learning/
        // Search/Flashcards) — tái sử dụng LoadingState/SearchErrorState
        // có sẵn, KHÔNG đổi bố cục/nội dung của nhánh data (giữ nguyên
        // giao diện khi tải thành công, đúng "Do not redesign Home").
        child: surahsAsync.when(
          loading: () => LoadingState(semanticsLabel: l10n.homeLoading),
          error: (_, __) => SearchErrorState(
            onRetry: () => ref.invalidate(surahListProvider),
          ),
          data: (surahs) {
            final surahById = <int, Surah>{
              for (final s in surahs) s.id: s,
            };
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth > 760
                    ? (constraints.maxWidth - 720) / 2
                    : 16.0;
                return ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                  children: [
                    _ContinueReadingCard(
                      l10n: l10n,
                      lastSurah:
                          surahById[positions.lastSurahId] ?? surahById[1],
                      lastAyahIndex: positions.lastSurahId == null
                          ? null
                          : positions.positionFor(positions.lastSurahId!),
                    ),
                    const SizedBox(height: 16),
                    _StatChipsRow(
                      l10n: l10n,
                      stats: stats,
                      currentStreak: currentStreak,
                    ),
                    const SizedBox(height: 16),
                    _DailyGoalCard(l10n: l10n),
                    const SizedBox(height: 16),
                    _TodaysVerseCard(l10n: l10n),
                    const SizedBox(height: 20),
                    _SectionTitle(l10n.quickAccess),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final id in _quickSurahIds)
                          if (surahById[id] != null)
                            ActionChip(
                              avatar: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  '$id',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              label: Text(surahById[id]!.nameLatin),
                              onPressed: () =>
                                  context.push(AppRoutes.surahReading(id)),
                            ),
                      ],
                    ),
                    if (positions.recentSurahIds.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionTitle(l10n.recentSurahs),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: positions.recentSurahIds.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final id = positions.recentSurahIds[i];
                            final surah = surahById[id];
                            if (surah == null) {
                              return const SizedBox.shrink();
                            }
                            return _RecentSurahCard(
                              surah: surah,
                              ayahIndex: positions.positionFor(id) ?? 0,
                              l10n: l10n,
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// KHÔNG gộp vào `SectionHeader` dùng chung (`lib/shared/widgets/`) —
/// dùng `titleMedium` (không phải `titleSmall`), khác về mặt hình ảnh
/// so với 6 nơi đã gộp (xem `SectionHeader`'s doc comment và
/// accessibility_audit.md mục "SectionHeader") — Home là trang chủ,
/// cố ý có hệ thống phân cấp thị giác nổi bật hơn các màn hình khác.
/// Tự thêm `Semantics(header: true)` (Sprint 20 Phase 2, Task 4) để
/// vẫn đạt cùng chuẩn heading semantics mà không đổi giao diện.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Thẻ "Đọc tiếp" — nổi bật nhất trang chủ.
class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.l10n,
    required this.lastSurah,
    required this.lastAyahIndex,
  });

  final AppLocalizations l10n;
  final Surah? lastSurah;
  final int? lastAyahIndex;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surah = lastSurah;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              scheme.primaryContainer.withValues(alpha: 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(AppRoutes.surahReading(surah?.id ?? 1)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah == null
                            ? l10n.startReading
                            : l10n.continueReading,
                        style: textTheme.labelLarge?.copyWith(
                          color:
                              scheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah?.nameLatin ?? l10n.tabQuran,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      if (surah != null && lastAyahIndex != null)
                        Text(
                          '${l10n.ayahSemanticLabel(lastAyahIndex! + 1)}'
                          ' / ${surah.ayahCount}',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer
                                .withValues(alpha: 0.75),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 44,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ba chỉ số nhanh: chuỗi ngày học · Ayah đã đọc · phút hôm nay.
class _StatChipsRow extends StatelessWidget {
  const _StatChipsRow({
    required this.l10n,
    required this.stats,
    required this.currentStreak,
  });

  final AppLocalizations l10n;
  final StatsStore stats;

  /// Nguồn canonical — currentStreakProvider (DR-2026-0004 mục 1),
  /// không phải stats.currentStreak.
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            value: l10n.streakDays(currentStreak),
            label: l10n.learningStreak,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.auto_stories_rounded,
            value: '${stats.ayahsRead}',
            label: l10n.ayahsReadLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.timer_rounded,
            value: '${stats.minutesOn(today)}',
            label: l10n.dailyProgress,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Thẻ "Mục tiêu học" — CHỈ đọc từ dailyGoalProgressProvider, không
/// tự tính gì ở tầng UI (DR-2026-0004 mục 2). Chạm để đặt/đổi chỉ
/// tiêu qua DailyGoalDialog. Ẩn khi provider chưa có dữ liệu, cùng
/// quy ước với _TodaysVerseCard.
class _DailyGoalCard extends ConsumerWidget {
  const _DailyGoalCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = ref.watch(dailyGoalProgressProvider);

    if (progress == null) return const SizedBox.shrink();

    final minutesTarget = progress.minutesTarget;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DailyGoalDialog.show(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.flag_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileGoal,
                      style: textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      minutesTarget != null
                          ? l10n.dailyGoalMinutesProgress(
                              progress.minutesToday,
                              minutesTarget,
                            )
                          : l10n.dailyGoalNotSet,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ "Câu Qur'an hôm nay".
///
/// Sprint 20 Phase 2, Task 5 — TRƯỚC đây dùng `maybeWhen(orElse: () =>
/// SizedBox.shrink())`: loading VÀ lỗi đều render ra KHÔNG GÌ CẢ,
/// người dùng không phân biệt được "đang tải" với "lỗi" với "hôm nay
/// không có câu nào" (xem accessibility_audit.md mục 3.1). `data ==
/// null` (không tìm thấy Surah/Ayah — trường hợp dữ liệu hợp lệ,
/// không phải lỗi) VẪN ẩn thẻ như cũ; chỉ thêm 2 nhánh loading/error
/// còn thiếu, tái sử dụng LoadingState/SearchErrorState.
class _TodaysVerseCard extends ConsumerWidget {
  const _TodaysVerseCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final verse = ref.watch(todaysVerseProvider);

    return verse.when(
      loading: () => LoadingState(semanticsLabel: l10n.homeTodaysVerseLoading),
      error: (_, __) => SearchErrorState(
        onRetry: () => ref.invalidate(todaysVerseProvider),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        final locale = Localizations.localeOf(context).languageCode;
        final translation = locale == 'vi'
            ? data.content.texts['vi_main'] ?? data.content.texts['en_sahih']
            : data.content.texts['en_sahih'] ?? data.content.texts['vi_main'];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.todaysVerse,
                    style:
                        textTheme.labelLarge?.copyWith(color: scheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                data.content.ayah.textUthmani,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: quranTextStyle(
                  fontSize: 26,
                  color: scheme.onSurface,
                ),
              ),
              if (translation != null) ...[
                const SizedBox(height: 10),
                Text(
                  translation,
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push(
                    AppRoutes.surahReading(data.surah.id),
                  ),
                  child: Text(
                    '${data.surah.nameLatin} '
                    '${data.content.ayah.surahId}:'
                    '${data.content.ayah.ayahNumber}',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentSurahCard extends StatelessWidget {
  const _RecentSurahCard({
    required this.surah,
    required this.ayahIndex,
    required this.l10n,
  });

  final Surah surah;
  final int ayahIndex;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.surahReading(surah.id)),
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                surah.nameLatin,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.ayahSemanticLabel(ayahIndex + 1)}'
                ' / ${surah.ayahCount}',
                style: textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: (ayahIndex + 1) / surah.ayahCount,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
