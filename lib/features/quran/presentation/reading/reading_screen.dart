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
import '../../../stats/data/study_session_providers.dart';
import '../../../stats/domain/repositories/study_session_repository.dart';
import '../../data/quran_providers.dart';
import '../../data/user_content_providers.dart';
import '../../domain/basmalah.dart';
import '../../domain/entities/ayah_annotation.dart';
import '../../domain/entities/ayah_content.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/translation_source.dart';
import '../annotations/ayah_actions_sheet.dart';
import '../audio/audio_bar.dart';
import '../audio/audio_controller.dart';
import 'focus_transition.dart';
import 'jump_to_ayah_sheet.dart';
import 'mushaf_builder.dart';
import 'reading_controller.dart';
import 'reading_position_store.dart';
import 'reading_progress_indicator.dart';
import 'reading_settings.dart';
import 'reading_settings_sheet.dart';
import 'reading_source_style.dart';

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

  /// Vị trí Ayah đang đọc, CHỈ phục vụ hiển thị (dải tiến độ) — tách
  /// khỏi [_lastSavedIndex], vốn phục vụ việc chống ghi trùng khi lưu:
  /// hai mối quan tâm khác nhau (hiển thị vs lưu trữ), nên giữ riêng.
  /// Dùng ValueNotifier thay cho setState: cuộn chỉ dựng lại đúng dải
  /// tiến độ, KHÔNG dựng lại cả ReadingScreen.
  late final ValueNotifier<int> _currentAyahIndex;

  // pinch-zoom
  double _pinchBaseScale = 1.0;
  int _maxPointers = 1;

  // thống kê phiên đọc (ngày + số phút)
  final Stopwatch _sessionWatch = Stopwatch();
  late final StatsStore _statsStore;
  late final StudySessionRepository _studySessionRepository;

  @override
  void initState() {
    super.initState();
    _initialAyahIndex =
        ref.read(readingPositionStoreProvider).positionFor(widget.surahId) ?? 0;
    // Khởi tạo từ vị trí đã lưu -> mở lại Surah là dải tiến độ hiện
    // ĐÚNG chỗ đang đọc ngay từ khung hình đầu, không đợi cuộn.
    _currentAyahIndex = ValueNotifier<int>(_initialAyahIndex);
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
    _statsStore = ref.read(statsStoreProvider);
    _studySessionRepository = ref.read(studySessionRepositoryProvider);
    unawaited(_statsStore.markToday());
    _sessionWatch.start();
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    _currentAyahIndex.dispose();
    final seconds = _sessionWatch.elapsed.inSeconds;
    unawaited(_statsStore.addSeconds(seconds));
    // Sprint 8 (DR-2026-0003 mục A) — ghi song song vào
    // study_sessions (Drift) để "Phiên đọc" (streak/tổng kết hôm
    // nay) có dữ liệu thật; StatsStore/SharedPreferences vẫn là
    // nguồn cho lưới chỉ số hiện có, không đụng tới. Cùng ngưỡng
    // "< 5 giây bỏ qua" như StatsStore.addSeconds — lướt qua màn
    // hình không tính là một phiên đọc.
    if (seconds >= 5) {
      unawaited(
        _studySessionRepository.logSession(
          date: StatsStore.dayKey(DateTime.now()),
          surahId: widget.surahId,
          ayahFrom: _initialAyahIndex,
          ayahTo: _lastSavedIndex ?? _initialAyahIndex,
          durationSec: seconds,
        ),
      );
    }
    super.dispose();
  }

  /// Ayah đầu tiên đang hiển thị -> lưu làm vị trí đọc.
  void _onPositionsChanged() {
    final positions = _positionsListener.itemPositions.value;
    final visible = positions.where((p) => p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    final minItemIndex = visible.map((p) => p.index).reduce(min);
    final ayahIndex = max(0, minItemIndex - 1); // index 0 là header
    // ValueNotifier tự bỏ qua giá trị trùng -> không có rebuild thừa.
    _currentAyahIndex.value = ayahIndex;
    if (ayahIndex == _lastSavedIndex) return;
    _lastSavedIndex = ayahIndex;
    unawaited(
      ref
          .read(readingPositionStoreProvider)
          .save(surahId: widget.surahId, ayahIndex: ayahIndex),
    );
  }

  void _savePage(int firstAyahIndex) {
    // Chế độ Mushaf lật trang -> dải tiến độ theo Ayah đầu của trang.
    _currentAyahIndex.value = firstAyahIndex;
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
    final scheme = Theme.of(context).colorScheme;
    // CHỈ nghe `mode` — không nghe cả ReadingSettings. Trước đây kéo
    // hai ngón đổi cỡ chữ (previewArabicScale phát state mới theo TỪNG
    // khung hình cử chỉ) dựng lại cả màn hình đọc: Scaffold, AppBar và
    // toàn bộ cây danh sách. Giờ chỉ những widget thật sự dùng cỡ chữ
    // (AyahCard, _MushafView) dựng lại.
    final mode = ref.watch(readingSettingsProvider.select((s) => s.mode));
    final reading = ref.watch(surahReadingProvider(widget.surahId));
    final totalAyahs = reading.valueOrNull?.ayahs.length ?? 0;

    // Đang nghe audio -> tự cuộn đến Ayah đang phát (mục UX #5).
    //
    // Sprint 28.0 — select(): trước đây đăng ký nghe TOÀN BỘ AudioState,
    // nên callback này chạy theo từng tick vị trí (~3 lần/giây) chỉ để
    // so `sameAyah` rồi thoát. Nay chỉ nghe đúng ba trường quyết định
    // việc cuộn, nên callback chỉ chạy khi thật sự sang Ayah khác.
    ref.listen(
      audioControllerProvider.select(
        (s) => (active: s.active, surahId: s.surahId, index: s.currentIndex),
      ),
      (prev, next) {
        final sameAyah =
            prev?.index == next.index && prev?.surahId == next.surahId;
        if (!next.active ||
            next.surahId != widget.surahId ||
            sameAyah ||
            mode != ReadingMode.list ||
            !_itemScrollController.isAttached) {
          return;
        }
        _itemScrollController.scrollTo(
          index: next.index + 1, // +1: header
          alignment: 0.15,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      },
    );

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
                    mode == ReadingMode.list
                        ? ReadingMode.mushaf
                        : ReadingMode.list,
                  ),
            ),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          // Dải tiến độ nằm ở mép dưới, ngay trên AudioBar: xa vùng mắt
          // đọc kinh văn nhất, và chỉ lấy ~28px — khu vực chữ Ả Rập gần
          // như không đổi.
          //
          // Sprint 25.3 — vào/ra Focus Mode: vỏ dưới THU GỌN dần rồi
          // mới biến mất (thay vì bật/tắt đột ngột), và khi thu xong
          // thì được tháo hẳn khỏi cây (xem [FocusCollapse]).
          bottomNavigationBar: FocusCollapse(
            visible: !_focusMode,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (totalAyahs > 0)
                  ReadingProgressIndicator(
                    currentAyahIndex: _currentAyahIndex,
                    totalAyahs: totalAyahs,
                  ),
                const AudioBar(),
              ],
            ),
          ),
          appBar: _focusMode
              ? null
              : AppBar(
                  title: reading.maybeWhen(
                    data: (data) => Text(data.surah.nameLatin),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: l10n.jumpToAyahTitle,
                      icon: const Icon(Icons.numbers),
                      onPressed: () => unawaited(_openJumpToAyah(context)),
                    ),
                    IconButton(
                      tooltip: l10n.focusMode,
                      icon: const Icon(Icons.center_focus_strong),
                      onPressed: () => setState(() => _focusMode = true),
                    ),
                    IconButton(
                      tooltip: mode == ReadingMode.list
                          ? l10n.readingModeMushaf
                          : l10n.readingModeList,
                      icon: Icon(
                        mode == ReadingMode.list
                            ? Icons.auto_stories_outlined
                            : Icons.view_agenda_outlined,
                      ),
                      onPressed: () => unawaited(
                        ref.read(readingSettingsProvider.notifier).setMode(
                              mode == ReadingMode.list
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
          // Nền dịch RẤT nhẹ giữa hai chế độ (surface -> surfaceContainerLowest):
          // đủ để cảm thấy trang lùi lại một bước, không đủ để gây chú
          // ý. Cả hai đều là vai trò bề mặt M3 nên tương phản với
          // onSurface không đổi. AnimatedContainer giữ nguyên instance
          // widget con -> danh sách đọc KHÔNG dựng lại theo từng khung
          // hình của chuyển cảnh.
          body: AnimatedContainer(
            duration: focusTransitionDuration(context),
            curve: kFocusTransitionCurve,
            color: _focusMode ? scheme.surfaceContainerLowest : scheme.surface,
            child: SafeArea(
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
                  final content = mode == ReadingMode.mushaf
                      ? _MushafView(
                          ayahs: data.ayahs,
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
    unawaited(ReadingSettingsSheet.show(context));
  }

  /// Mở sheet "Chuyển tới Ayah" rồi thực hiện đúng cú nhảy đã chọn.
  Future<void> _openJumpToAyah(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Chế độ Mushaf: KHÔNG tự đổi sang Danh sách — đổi chế độ hiển thị
    // sau lưng người dùng là hành vi bất ngờ. Báo rõ rồi dừng.
    // (PageController lật trang là state riêng của _MushafView, màn
    // hình này không nắm; nhảy trong Mushaf thuộc phạm vi phase khác.)
    if (ref.read(readingSettingsProvider).mode == ReadingMode.mushaf) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.jumpToAyahListModeOnly),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final data = ref.read(surahReadingProvider(widget.surahId)).valueOrNull;
    if (data == null) return;

    final target = await JumpToAyahSheet.show(
      context,
      currentSurah: data.surah,
    );
    if (target == null) return;
    if (!mounted) return;
    _jumpToAyah(target, ayahCount: data.ayahs.length);
  }

  /// Cùng Surah -> cuộn tại chỗ (KHÔNG dựng lại màn hình, không đụng
  /// setState). Khác Surah -> mở Surah mới ĐÚNG cách vuốt ngang đổi
  /// Surah đang dùng ([_onScaleEnd]), không tạo đường điều hướng thứ
  /// hai. Cả hai nhánh đều ghi vị trí đọc qua [ReadingPositionStore]
  /// đã có — không thêm cơ chế lưu vị trí riêng.
  void _jumpToAyah(JumpTarget target, {required int ayahCount}) {
    final store = ref.read(readingPositionStoreProvider);

    if (target.surahId != widget.surahId) {
      // Lưu TRƯỚC khi rời màn hình: ReadingScreen mới tự đọc lại vị
      // trí này trong initState và mở đúng Ayah.
      unawaited(
        store.save(
          surahId: target.surahId,
          ayahIndex: target.ayahNumber - 1,
        ),
      );
      context.pushReplacement(AppRoutes.surahReading(target.surahId));
      return;
    }

    if (!_itemScrollController.isAttached) return;
    // index 0 là header Surah -> Ayah số N nằm ở index N (cùng quy ước
    // với cuộn theo audio trong build()).
    final index = target.ayahNumber.clamp(1, ayahCount);
    unawaited(store.save(surahId: target.surahId, ayahIndex: index - 1));
    _itemScrollController.scrollTo(
      index: index,
      // Cùng alignment/thời lượng/curve với cuộn theo audio — một
      // chuyển động duy nhất cho mọi lần "trang đọc tự di chuyển".
      alignment: 0.15,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
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
        // Điện thoại (< 760): giữ lề 20 như cũ. Tablet/Desktop: căn
        // giữa nội dung ở bề rộng đọc tối đa 720 (dễ đọc, không dàn
        // chữ quá rộng).
        //
        // Sprint 25.3 — Focus Mode nới lề và RÚT NGẮN dòng (720 -> 640):
        // dòng ngắn hơn thì mắt bắt đầu dòng kế dễ hơn, đúng cách một
        // trang Mushaf in được dàn. Đổi tĩnh, KHÔNG animate: animate bề
        // rộng sẽ bắt toàn bộ chữ Ả Rập đang hiển thị dàn lại từng
        // khung hình — cái giá không đáng cho một thay đổi gần như
        // không nhìn thấy.
        final maxContentWidth = focus ? 640.0 : 720.0;
        final horizontal = constraints.maxWidth > maxContentWidth + 40
            ? (constraints.maxWidth - maxContentWidth) / 2
            : (focus ? 28.0 : 20.0);
        return ScrollablePositionedList.builder(
          initialScrollIndex: initialScrollIndex,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            // Focus Mode: nhiều khoảng thở phía trên hơn, vì header
            // Surah đã được ẩn đi.
            vertical: focus ? 28 : 12,
          ),
          itemCount: ayahs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Basmalah trang trí = 4 từ đầu của Ayah 1 (lấy TỪ DỮ
              // LIỆU), chỉ với Surah có Basmalah dẫn đầu (≠ 1, 9).
              final basmalah = surahHasLeadingBasmalah(surahId) &&
                      ayahs.isNotEmpty
                  ? splitLeadingBasmalah(ayahs.first.ayah.textUthmani).basmalah
                  : null;
              return focus
                  ? const SizedBox.shrink()
                  : _SurahHeader(surah: surah, basmalah: basmalah);
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

class _MushafView extends ConsumerStatefulWidget {
  const _MushafView({
    required this.ayahs,
    required this.focus,
    required this.initialAyahIndex,
    required this.onPageFirstAyah,
  });

  final List<AyahContent> ayahs;
  final bool focus;
  final int initialAyahIndex;
  final ValueChanged<int> onPageFirstAyah;

  @override
  ConsumerState<_MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends ConsumerState<_MushafView> {
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
    // Tự nghe ĐÚNG cỡ chữ thay vì nhận cả ReadingSettings từ màn hình
    // cha — nhờ vậy đổi cỡ chữ chỉ dựng lại trang Mushaf, không dựng
    // lại ReadingScreen.
    final arabicScale =
        ref.watch(readingSettingsProvider.select((s) => s.arabicScale));

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
                        fontSize: quranBaseFontSize(width) * arabicScale,
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
  const _SurahHeader({required this.surah, this.basmalah});

  final Surah surah;

  /// Basmalah trang trí (lấy TỪ DỮ LIỆU Ayah 1) — hiển thị bên dưới
  /// thẻ tên Surah, thuần hình ảnh: không đánh số, không chọn /
  /// bookmark / yêu thích / highlight / chia sẻ. null = không hiển
  /// thị (Surah 1 & 9).
  final String? basmalah;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMecca = surah.revelationPlace == RevelationPlace.mecca;
    final placeLabel = isMecca ? l10n.revelationMecca : l10n.revelationMadinah;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.55),
                scheme.primaryContainer.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Text(
                surah.nameArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: arabicTitleStyle(fontSize: 44, color: scheme.primary),
              ),
              const SizedBox(height: 10),
              Text(
                surah.nameLatin,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              // Wrap (không Row): cỡ chữ lớn / màn hẹp -> chip tự
              // xuống dòng thay vì tràn ngang.
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  _HeaderChip(
                    icon: isMecca
                        ? Icons.brightness_2_outlined
                        : Icons.location_city_outlined,
                    label: placeLabel,
                  ),
                  _HeaderChip(
                    icon: Icons.menu_book_outlined,
                    label: l10n.surahAyahCount(surah.ayahCount),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Basmalah trang trí (thuần hình ảnh) — đúng luật Mushaf.
        // Lấy từ dữ liệu Ayah 1 (tách sẵn); null với Surah 1 & 9.
        if (basmalah != null)
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 4),
            child: Text(
              basmalah!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: quranTextStyle(
                fontSize: 28,
                color: scheme.onSurface.withValues(alpha: 0.85),
                height: 1.8,
              ),
            ),
          ),
        const SizedBox(height: 18),
      ],
    );
  }
}

/// Chip nhỏ trong header Surah (nơi mặc khải, số câu).
class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
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
    final settings = ref.watch(readingSettingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    if (focus) {
      // Focus Mode: thuần văn bản Qur'an, kết Ayah kiểu Mushaf.
      //
      // Sprint 25.3 — thoát SỚM, TRƯỚC các ref.watch audio/chú thích ở
      // dưới: chế độ này không vẽ highlight đang phát, bookmark, ghi
      // chú hay trạng thái học, nên cũng KHÔNG cần đăng ký nghe chúng.
      // Nhờ vậy mỗi tick của trình phát hoặc mỗi lần đổi chú thích
      // không còn dựng lại các Ayah đang hiển thị.
      return Padding(
        // Nhịp dọc rộng hơn giữa các Ayah — khoảng thở của trang in,
        // thay cho 6px sát nhau trước đây.
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          '${content.ayah.textUthmani} '
          '﴿${toArabicDigits(content.ayah.ayahNumber)}﴾',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          // height 2.2 = ĐÚNG khoảng dòng chế độ Mushaf đang dùng
          // (_MushafView), không phát minh con số mới.
          style: quranTextStyle(
            fontSize: quranBaseFontSize(width) * settings.arabicScale,
            color: scheme.onSurface,
            height: 2.2,
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
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
    //
    // Sprint 25.4 — select(): thẻ CHỈ dựng lại khi chú thích của CHÍNH
    // Ayah này đổi. Trước đây mọi thẻ đang hiển thị đều watch cả Map
    // của Surah, nên đánh dấu một Ayah làm dựng lại tất cả các Ayah
    // khác đang nhìn thấy. (Cần `==` theo giá trị của AyahAnnotation.)
    final annotation = ref.watch(
      ayahAnnotationsProvider(content.ayah.surahId).select(
        (value) => value.valueOrNull?[content.ayah.id] ?? AyahAnnotation.empty,
      ),
    );
    final highlightColor = annotation.highlightColors.isEmpty
        ? null
        : kHighlightColorValues[annotation.highlightColors.first];

    final arabicStyle = quranTextStyle(
      fontSize: quranBaseFontSize(width) * settings.arabicScale,
      color: scheme.onSurface,
    );

    // Chế độ Danh sách: Ayah 1 của Surah có Basmalah dẫn đầu bỏ phần
    // Basmalah (đã đưa lên header trang trí) -> chỉ một Basmalah.
    final displayArabic = ayahDisplayText(
      surahId: content.ayah.surahId,
      ayahNumber: content.ayah.ayahNumber,
      textUthmani: content.ayah.textUthmani,
    );

    // Sprint 30.1 — CÁC LỚP VĂN BẢN DỰNG TỪ DỮ LIỆU NGUỒN.
    //
    // Trước đây ba dòng cứng đọc đúng ba mã ('translit_latin',
    // 'vi_main', 'en_sahih'), mỗi mã một cờ và một kiểu chữ riêng —
    // thêm bản dịch hay Tafsir đều phải sửa widget này. Nay danh sách
    // lớp = giao của (nguồn đang bật trong database) × (nguồn người
    // dùng để hiện) × (Ayah này thực sự có văn bản), sắp theo
    // `display_order` của chính dữ liệu.
    //
    // Một truy vấn duy nhất cho cả phiên chạy, dùng chung mọi AyahCard
    // (xem `translationSourcesProvider`); đọc bằng `valueOrNull` nên
    // lúc chưa nạp xong thẻ vẫn hiện kinh văn, không nháy khung chờ.
    //
    // Sprint 30.2 — `readingSourcesProvider` (KHÔNG phải danh mục đầy
    // đủ): Tafsir không bao giờ là một lớp của trang đọc.
    final sources = ref.watch(
      readingSourcesProvider.select((value) => value.valueOrNull),
    );
    final appLanguage = Localizations.localeOf(context).languageCode;
    final layers = <({TranslationSource source, String text})>[
      for (final source in sources ?? const <TranslationSource>[])
        if (settings.isSourceVisible(source, appLanguage))
          if (content.texts[source.code] case final text?)
            (source: source, text: text),
    ]..sort((a, b) => a.source.displayOrder.compareTo(b.source.displayOrder));

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
                  // Wrap (không phải Row+Spacer): khi cờ trạng thái +
                  // sajdah + đủ icon hành động không vừa 1 hàng (màn
                  // hẹp, hoặc trạng thái có nhãn dài), nhóm icon tự
                  // xuống dòng thay vì tràn (RenderFlex overflow).
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                ),
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
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- Văn bản Qur'an (căn giữa, nhiều khoảng thở) ----
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      displayArabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: arabicStyle,
                    ),
                  ),

                  // Ngăn cách kinh văn với các lớp hỗ trợ đọc.
                  if (layers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ---- Các lớp văn bản, theo đúng thứ tự dữ liệu ----
                  //
                  // Mỗi lớp vẫn là MỘT `Text` riêng, y như trước: thẻ
                  // Ayah đã có `Semantics` gộp ở ngoài, nên KHÔNG thêm
                  // nhãn ngữ nghĩa cho từng lớp — làm vậy sẽ chèn tên
                  // nguồn vào giữa mạch đọc của trình đọc màn hình,
                  // tức đổi hành vi chứ không phải giữ nguyên.
                  for (final layer in layers) ...[
                    Builder(
                      builder: (context) {
                        final layout = readingLayerStyle(
                          source: layer.source,
                          scheme: scheme,
                          appLanguage: appLanguage,
                        );
                        return Text(
                          layer.text,
                          textDirection: layout.textDirection,
                          textAlign: layout.textAlign,
                          style: layout.textStyle,
                        );
                      },
                    ),
                    const SizedBox(height: 14),
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
    final l10n = AppLocalizations.of(context);
    unawaited(
      AyahActionsSheet.show(
        context,
        surahId: content.ayah.surahId,
        ayahId: content.ayah.id,
        ayahNumber: content.ayah.ayahNumber,
        // Nhất quán với phần hiển thị: Ayah 1 không kèm Basmalah.
        arabicText: ayahDisplayText(
          surahId: content.ayah.surahId,
          ayahNumber: content.ayah.ayahNumber,
          textUthmani: content.ayah.textUthmani,
        ),
        translationText: content.texts['vi_main'] ?? content.texts['en_sahih'],
        // Nghe/sao chép/chia sẻ: đưa thẳng hàm SẴN CÓ của thẻ xuống
        // sheet — không có bản sao logic thứ hai, hai nơi luôn khớp.
        onPlay: onPlay,
        onCopy: () => unawaited(_copyAyah(context, l10n)),
        onShare: () => unawaited(_copyAyah(context, l10n, forShare: true)),
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
    // Nhất quán với phần hiển thị: Ayah 1 không kèm Basmalah.
    final buf = StringBuffer(
      ayahDisplayText(
        surahId: content.ayah.surahId,
        ayahNumber: content.ayah.ayahNumber,
        textUthmani: content.ayah.textUthmani,
      ),
    );
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
