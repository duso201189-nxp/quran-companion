import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../stats/data/stats_store.dart';
import '../../data/user_content_providers.dart';
import '../../domain/entities/ayah_annotation.dart';
import '../../domain/entities/ayah_content.dart';
import '../../domain/entities/surah.dart';
import '../annotations/ayah_actions_sheet.dart';
import '../audio/audio_bar.dart';
import '../audio/audio_controller.dart';
import 'mushaf_builder.dart';
import 'reading_controller.dart';
import 'reading_position_store.dart';
import 'reading_settings.dart';

/// Trang đọc Qur'an — màn hình quan trọng nhất của ứng dụng.
///
/// Trải nghiệm đọc:
/// - 2 chế độ: Danh sách (Ayah + lớp dịch) và Mushaf (nguyên trang,
///   lật ngang phải-sang-trái như bản in — hỗ trợ Hifz).
/// - Focus Mode: ẩn thanh công cụ + mọi bản dịch, chỉ còn văn bản
///   Qur'an; chạm một lần để thoát.
/// - Gesture: hai ngón phóng to/thu nhỏ chữ Ả Rập (live, lưu khi
///   nhấc tay); vuốt ngang (chế độ danh sách) để đổi Surah.
/// - Tự lưu vị trí: mở lại app quay về đúng Surah + Ayah đang đọc.
/// - RAM: ScrollablePositionedList chỉ dựng phần nhìn thấy;
///   provider autoDispose giải phóng khi rời màn hình.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.surahId});

  final int surahId;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  bool _focusMode = false;
  int _initialAyahIndex = 0;
  int? _lastSavedIndex;

  // pinch-zoom
  double _pinchBaseScale = 1.0;
  int _maxPointers = 1;

  // thống kê phiên đọc (ngày + số phút)
  final Stopwatch _sessionWatch = Stopwatch();
  late final StatsStore _statsStore;

  @override
  void initState() {
    super.initState();
    _initialAyahIndex =
        ref.read(readingPositionStoreProvider).positionFor(widget.surahId) ?? 0;
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
    _statsStore = ref.read(statsStoreProvider);
    unawaited(_statsStore.markToday());
    _sessionWatch.start();
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    unawaited(_statsStore.addSeconds(_sessionWatch.elapsed.inSeconds));
    super.dispose();
  }

  /// Ayah đầu tiên đang hiển thị -> lưu làm vị trí đọc.
  void _onPositionsChanged() {
    final positions = _positionsListener.itemPositions.value;
    final visible = positions.where((p) => p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    final minItemIndex = visible.map((p) => p.index).reduce(min);
    final ayahIndex = max(0, minItemIndex - 1); // index 0 là header
    if (ayahIndex == _lastSavedIndex) return;
    _lastSavedIndex = ayahIndex;
    unawaited(
      ref
          .read(readingPositionStoreProvider)
          .save(surahId: widget.surahId, ayahIndex: ayahIndex),
    );
  }

  void _savePage(int firstAyahIndex) {
    unawaited(
      ref
          .read(readingPositionStoreProvider)
          .save(surahId: widget.surahId, ayahIndex: firstAyahIndex),
    );
  }

  // ---------------- Gesture ----------------

  void _onScaleStart(ScaleStartDetails details) {
    _pinchBaseScale = ref.read(readingSettingsProvider).arabicScale;
    _maxPointers = details.pointerCount;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _maxPointers = max(_maxPointers, details.pointerCount);
    if (details.pointerCount >= 2) {
      ref
          .read(readingSettingsProvider.notifier)
          .previewArabicScale(_pinchBaseScale * details.scale);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_maxPointers >= 2) {
      unawaited(
        ref.read(readingSettingsProvider.notifier).commitArabicScale(),
      );
      return;
    }
    // Một ngón, vuốt ngang đủ mạnh -> đổi Surah (chế độ danh sách;
    // ở chế độ Mushaf, vuốt ngang thuộc về lật trang).
    if (ref.read(readingSettingsProvider).mode == ReadingMode.mushaf) {
      return;
    }
    final v = details.velocity.pixelsPerSecond;
    if (v.dx.abs() < 300 || v.dx.abs() < v.dy.abs()) return;
    final next = v.dx < 0 ? widget.surahId + 1 : widget.surahId - 1;
    if (next < 1 || next > 114) return;
    context.pushReplacement(AppRoutes.surahReading(next));
  }

  void _onTap() {
    if (_focusMode) setState(() => _focusMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(readingSettingsProvider);
    final reading = ref.watch(surahReadingProvider(widget.surahId));

    // Đang nghe audio -> tự cuộn đến Ayah đang phát (mục UX #5).
    ref.listen<AudioState>(audioControllerProvider, (prev, next) {
      final sameAyah = prev?.currentIndex == next.currentIndex &&
          prev?.surahId == next.surahId;
      if (!next.active ||
          next.surahId != widget.surahId ||
          sameAyah ||
          settings.mode != ReadingMode.list ||
          !_itemScrollController.isAttached) {
        return;
      }
      _itemScrollController.scrollTo(
        index: next.currentIndex + 1, // +1: header
        alignment: 0.15,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });

    // Phím tắt desktop: Space phát/dừng · ←/→ Ayah trước/kế ·
    // +/- cỡ chữ · F chế độ tập trung · M đổi List/Mushaf.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _shortcutPlayPause(reading),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            ref.read(audioControllerProvider.notifier).nextAyah(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            ref.read(audioControllerProvider.notifier).previousAyah(),
        const SingleActivator(LogicalKeyboardKey.equal): () =>
            _shortcutScale(0.1),
        const SingleActivator(LogicalKeyboardKey.add): () =>
            _shortcutScale(0.1),
        const SingleActivator(LogicalKeyboardKey.minus): () =>
            _shortcutScale(-0.1),
        const SingleActivator(LogicalKeyboardKey.keyF): () =>
            setState(() => _focusMode = !_focusMode),
        const SingleActivator(LogicalKeyboardKey.keyM): () => unawaited(
              ref.read(readingSettingsProvider.notifier).setMode(
                    settings.mode == ReadingMode.list
                        ? ReadingMode.mushaf
                        : ReadingMode.list,
                  ),
            ),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          bottomNavigationBar: _focusMode ? null : const AudioBar(),
          appBar: _focusMode
              ? null
              : AppBar(
                  title: reading.maybeWhen(
                    data: (data) => Text(data.surah.nameLatin),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: l10n.focusMode,
                      icon: const Icon(Icons.center_focus_strong),
                      onPressed: () => setState(() => _focusMode = true),
                    ),
                    IconButton(
                      tooltip: settings.mode == ReadingMode.list
                          ? l10n.readingModeMushaf
                          : l10n.readingModeList,
                      icon: Icon(
                        settings.mode == ReadingMode.list
                            ? Icons.auto_stories_outlined
                            : Icons.view_agenda_outlined,
                      ),
                      onPressed: () => unawaited(
                        ref.read(readingSettingsProvider.notifier).setMode(
                              settings.mode == ReadingMode.list
                                  ? ReadingMode.mushaf
                                  : ReadingMode.list,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.displaySettings,
                      icon: const Icon(Icons.text_fields),
                      onPressed: () => _openDisplaySettings(context),
                    ),
                  ],
                ),
          body: SafeArea(
            child: reading.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ReadingErrorState(
                l10n: l10n,
                notFound: error is SurahNotFoundException,
                onRetry: () =>
                    ref.invalidate(surahReadingProvider(widget.surahId)),
              ),
              data: (data) {
                if (data.ayahs.isEmpty) {
                  return _ReadingEmptyState(l10n: l10n);
                }
                final content = settings.mode == ReadingMode.mushaf
                    ? _MushafView(
                        ayahs: data.ayahs,
                        settings: settings,
                        focus: _focusMode,
                        initialAyahIndex: _initialAyahIndex,
                        onPageFirstAyah: _savePage,
                      )
                    : _AyahListView(
                        surah: data.surah,
                        ayahs: data.ayahs,
                        surahId: widget.surahId,
                        focus: _focusMode,
                        // Vị trí 0 = chưa đọc dở -> mở từ ĐẦU trang (kèm
                        // header Surah); đọc dở -> nhảy thẳng tới Ayah đó.
                        initialScrollIndex: _initialAyahIndex == 0
                            ? 0
                            : min(_initialAyahIndex + 1, data.ayahs.length),
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _positionsListener,
                      );
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTap,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: content,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Space: đang phát -> pause/resume; chưa phát -> phát Surah này
  /// từ vị trí đang đọc.
  void _shortcutPlayPause(AsyncValue<SurahReading> reading) {
    final audio = ref.read(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);
    if (audio.active) {
      unawaited(controller.togglePlayPause());
      return;
    }
    final data = reading.valueOrNull;
    if (data == null || data.ayahs.isEmpty) return;
    unawaited(
      controller.playSurah(
        surahId: widget.surahId,
        ayahs: [for (final a in data.ayahs) a.ayah],
        startIndex: (_lastSavedIndex ?? _initialAyahIndex)
            .clamp(0, data.ayahs.length - 1),
      ),
    );
  }

  void _shortcutScale(double delta) {
    final settings = ref.read(readingSettingsProvider);
    unawaited(
      ref
          .read(readingSettingsProvider.notifier)
          .setArabicScale(settings.arabicScale + delta),
    );
  }

  void _openDisplaySettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const DisplaySettingsSheet(),
    );
  }
}

// ==================== CHẾ ĐỘ DANH SÁCH ====================

class _AyahListView extends ConsumerWidget {
  const _AyahListView({
    required this.surah,
    required this.ayahs,
    required this.surahId,
    required this.focus,
    required this.initialScrollIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  final Surah surah;
  final List<AyahContent> ayahs;
  final int surahId;
  final bool focus;
  final int initialScrollIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth > 740
            ? (constraints.maxWidth - 700) / 2
            : 20.0;
        return ScrollablePositionedList.builder(
          initialScrollIndex: initialScrollIndex,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: 12,
          ),
          itemCount: ayahs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return focus
                  ? const SizedBox.shrink()
                  : _SurahHeader(surah: surah);
            }
            return AyahCard(
              content: ayahs[index - 1],
              focus: focus,
              onPlay: () =>
                  ref.read(audioControllerProvider.notifier).playSurah(
                        surahId: surahId,
                        ayahs: [for (final a in ayahs) a.ayah],
                        startIndex: index - 1,
                      ),
            );
          },
        );
      },
    );
  }
}

// ==================== CHẾ ĐỘ MUSHAF ====================

class _MushafView extends StatefulWidget {
  const _MushafView({
    required this.ayahs,
    required this.settings,
    required this.focus,
    required this.initialAyahIndex,
    required this.onPageFirstAyah,
  });

  final List<AyahContent> ayahs;
  final ReadingSettings settings;
  final bool focus;
  final int initialAyahIndex;
  final ValueChanged<int> onPageFirstAyah;

  @override
  State<_MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<_MushafView> {
  late final List<MushafPage> _pages = buildMushafPages(widget.ayahs);
  late final PageController _controller = PageController(
    initialPage: pageIndexForAyah(_pages, widget.initialAyahIndex),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return PageView.builder(
      controller: _controller,
      // Mushaf lật từ phải sang trái như bản in.
      reverse: true,
      itemCount: _pages.length,
      onPageChanged: (i) => widget.onPageFirstAyah(_pages[i].firstAyahIndex),
      itemBuilder: (context, index) {
        final page = _pages[index];
        final width = MediaQuery.sizeOf(context).width;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      page.text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                      style: quranTextStyle(
                        fontSize: quranBaseFontSize(width) *
                            widget.settings.arabicScale,
                        height: 2.2,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.focus)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.pageLabel(page.pageNumber),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ==================== THÀNH PHẦN CHUNG ====================

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final placeLabel = surah.revelationPlace == RevelationPlace.mecca
        ? l10n.revelationMecca
        : l10n.revelationMadinah;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.primaryContainer.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            surah.nameArabic,
            textDirection: TextDirection.rtl,
            style: arabicTitleStyle(
              fontSize: 40,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            surah.nameLatin,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.surahAyahCount(surah.ayahCount)} · $placeLabel',
            style:
                textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Thẻ một Ayah. [focus] = true: chỉ văn bản Ả Rập + dấu kết Ayah.
class AyahCard extends ConsumerWidget {
  const AyahCard({
    super.key,
    required this.content,
    this.focus = false,
    this.onPlay,
  });

  final AyahContent content;
  final bool focus;

  /// Phát audio từ Ayah này (null = không hiện nút, vd Focus Mode).
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(readingSettingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ayah đang phát audio -> nền highlight nhẹ (mục UX #6).
    // select(): thẻ CHỈ rebuild khi kết quả bool đổi — các tick
    // position/duration của trình phát không đụng tới danh sách.
    final isPlayingThis = ref.watch(
      audioControllerProvider.select(
        (s) =>
            s.active &&
            s.surahId == content.ayah.surahId &&
            s.currentIndex == content.ayah.ayahNumber - 1,
      ),
    );

    // Chú thích người dùng (bookmark/highlight/note/status) realtime.
    final annotation = ref
            .watch(ayahAnnotationsProvider(content.ayah.surahId))
            .valueOrNull?[content.ayah.id] ??
        AyahAnnotation.empty;
    final highlightColor = annotation.highlightColors.isEmpty
        ? null
        : kHighlightColorValues[annotation.highlightColors.first];

    final width = MediaQuery.sizeOf(context).width;
    final arabicStyle = quranTextStyle(
      fontSize: quranBaseFontSize(width) * settings.arabicScale,
      color: scheme.onSurface,
    );

    if (focus) {
      // Focus Mode: thuần văn bản Qur'an, kết Ayah kiểu Mushaf.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '${content.ayah.textUthmani} '
          '﴿${toArabicDigits(content.ayah.ayahNumber)}﴾',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: arabicStyle,
        ),
      );
    }

    final translit = content.texts['translit_latin'];
    final vi = content.texts['vi_main'];
    final en = content.texts['en_sahih'];

    // Nền thẻ: đang phát > highlight người dùng > mặt thẻ tối.
    final cardColor = isPlayingThis
        ? Color.alphaBlend(
            scheme.primaryContainer.withValues(alpha: 0.35),
            scheme.surfaceContainerLow,
          )
        : highlightColor != null
            ? Color.alphaBlend(
                highlightColor.withValues(alpha: 0.16),
                scheme.surfaceContainerLow,
              )
            : scheme.surfaceContainerLow;

    return Semantics(
      label: l10n.ayahSemanticLabel(content.ayah.ayahNumber),
      child: Padding(
        // Khoảng cách dọc 24 giữa các thẻ Ayah.
        padding: const EdgeInsets.only(bottom: 24),
        child: _HoverBuilder(
          builder: (hovered) => GestureDetector(
            onLongPress: () => _openActionsSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: hovered
                    ? Color.alphaBlend(
                        scheme.primaryContainer.withValues(alpha: 0.10),
                        cardColor,
                      )
                    : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? scheme.primary.withValues(alpha: 0.30)
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: hovered ? 0.28 : 0.18),
                    blurRadius: hovered ? 18 : 12,
                    offset: Offset(0, hovered ? 6 : 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Hàng đầu: huy hiệu số Ayah + trạng thái + hành động ----
                  Row(
                    children: [
                      _AyahNumberBadge(
                        surahId: content.ayah.surahId,
                        ayahNumber: content.ayah.ayahNumber,
                      ),
                      if (annotation.status != AyahStatus.none) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            switch (annotation.status) {
                              AyahStatus.learning => l10n.statusLearning,
                              AyahStatus.learned => l10n.statusLearned,
                              AyahStatus.review => l10n.statusReview,
                              AyahStatus.none => '',
                            },
                            style: textTheme.labelSmall
                                ?.copyWith(color: scheme.onTertiaryContainer),
                          ),
                        ),
                      ],
                      if (content.ayah.sajdah) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: l10n.sajdahAyah,
                          child: Icon(
                            Icons.self_improvement_rounded,
                            size: 20,
                            color: scheme.tertiary,
                            semanticLabel: l10n.sajdahAyah,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _ActionIcon(
                        tooltip: l10n.bookmarkLabel,
                        icon: annotation.bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: annotation.bookmarked
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        onPressed: () => ref
                            .read(userContentRepositoryProvider)
                            .toggleBookmark(content.ayah.id),
                      ),
                      _ActionIcon(
                        tooltip: l10n.favoriteLabel,
                        icon: annotation.favorited
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: annotation.favorited
                            ? scheme.tertiary
                            : scheme.onSurfaceVariant,
                        onPressed: () => ref
                            .read(userContentRepositoryProvider)
                            .toggleFavorite(content.ayah.id),
                      ),
                      _ActionIcon(
                        tooltip: l10n.copyAyah,
                        icon: Icons.copy_rounded,
                        color: scheme.onSurfaceVariant,
                        onPressed: () => _copyAyah(context, l10n),
                      ),
                      _ActionIcon(
                        tooltip: l10n.shareAyah,
                        icon: Icons.share_rounded,
                        color: scheme.onSurfaceVariant,
                        onPressed: () =>
                            _copyAyah(context, l10n, forShare: true),
                      ),
                      if (onPlay != null)
                        _ActionIcon(
                          tooltip: l10n.playFromHere,
                          icon: isPlayingThis
                              ? Icons.graphic_eq_rounded
                              : Icons.play_arrow_rounded,
                          color: scheme.primary,
                          onPressed: onPlay!,
                        ),
                      _ActionIcon(
                        tooltip: l10n.moreActions,
                        icon: Icons.more_horiz_rounded,
                        color: scheme.onSurfaceVariant,
                        onPressed: () => _openActionsSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ---- Văn bản Qur'an ----
                  Text(
                    content.ayah.textUthmani,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: arabicStyle,
                  ),
                  const SizedBox(height: 16),

                  // ---- Phiên âm ----
                  if (settings.showTransliteration && translit != null) ...[
                    Text(
                      translit,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        height: 1.6,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ---- Bản dịch ----
                  if (settings.showVietnamese && vi != null) ...[
                    Text(
                      vi,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontSize: 18,
                        height: 1.65,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (settings.showEnglish && en != null) ...[
                    Text(
                      en,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontSize: 16,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ---- Ghi chú người dùng ----
                  if (annotation.note != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        annotation.note!,
                        style: textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openActionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AyahActionsSheet(
        surahId: content.ayah.surahId,
        ayahId: content.ayah.id,
        ayahNumber: content.ayah.ayahNumber,
        arabicText: content.ayah.textUthmani,
        translationText: content.texts['vi_main'] ?? content.texts['en_sahih'],
      ),
    );
  }

  /// Sao chép Ayah (kèm bản dịch đang bật) vào bộ nhớ tạm.
  /// [forShare]: thêm nguồn trích dẫn — cách "chia sẻ" trên desktop.
  Future<void> _copyAyah(
    BuildContext context,
    AppLocalizations l10n, {
    bool forShare = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final buf = StringBuffer(content.ayah.textUthmani);
    for (final text in [
      content.texts['translit_latin'],
      content.texts['vi_main'],
      content.texts['en_sahih'],
    ]) {
      if (text != null) buf.write('\n$text');
    }
    buf.write(
      '\n— Qur\'an ${content.ayah.surahId}:${content.ayah.ayahNumber}',
    );
    if (forShare) buf.write(' (Qur\'an Companion)');
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.ayahCopied),
          behavior: SnackBarBehavior.floating,
          width: 320,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// Theo dõi hover (desktop/web) — builder nhận trạng thái hovered.
class _HoverBuilder extends StatefulWidget {
  const _HoverBuilder({required this.builder});

  final Widget Function(bool hovered) builder;

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(_hovered),
    );
  }
}

/// Huy hiệu tròn xanh lá chứa số Ayah — dùng thống nhất mọi nơi.
class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({
    required this.surahId,
    required this.ayahNumber,
  });

  final int surahId;
  final int ayahNumber;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '$surahId:$ayahNumber',
      child: Container(
        constraints: const BoxConstraints(minWidth: 36),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: FittedBox(
          child: Text(
            '$ayahNumber',
            style: TextStyle(
              fontFamily: AppTheme.latinFont,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: scheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút hành động của thẻ Ayah — icon bo tròn, tooltip, hiệu ứng
/// phóng nhẹ khi hover (desktop/web).
class _ActionIcon extends StatefulWidget {
  const _ActionIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: IconButton(
          tooltip: widget.tooltip,
          visualDensity: VisualDensity.compact,
          icon: Icon(widget.icon, size: 21, color: widget.color),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}

/// Bottom sheet cài đặt hiển thị — áp dụng live khi kéo slider.
class DisplaySettingsSheet extends ConsumerWidget {
  const DisplaySettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(readingSettingsProvider);
    final controller = ref.read(readingSettingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.displaySettings,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_decrease),
                Expanded(
                  child: Slider(
                    value: settings.arabicScale,
                    min: ReadingSettings.minScale,
                    max: ReadingSettings.maxScale,
                    divisions: 8,
                    label: l10n.readingFontSize,
                    onChanged: controller.setArabicScale,
                  ),
                ),
                const Icon(Icons.text_increase),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.showTransliteration),
              value: settings.showTransliteration,
              onChanged: controller.setShowTransliteration,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.showVietnamese),
              value: settings.showVietnamese,
              onChanged: controller.setShowVietnamese,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.showEnglish),
              value: settings.showEnglish,
              onChanged: controller.setShowEnglish,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingErrorState extends StatelessWidget {
  const _ReadingErrorState({
    required this.l10n,
    required this.notFound,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final bool notFound;
  final VoidCallback onRetry;

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
              notFound ? Icons.menu_book_outlined : Icons.cloud_off_outlined,
              size: 56,
              color: scheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              notFound ? l10n.surahNotFound : l10n.errorLoadData,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (!notFound)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadingEmptyState extends StatelessWidget {
  const _ReadingEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.surahNoContent, textAlign: TextAlign.center),
      ),
    );
  }
}
