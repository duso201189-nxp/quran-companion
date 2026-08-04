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
import '../../../../core/quran/quran_address.dart';
import '../../../khatm/data/khatm_cycle_providers.dart';
import '../../../khatm/domain/entities/khatm_cycle.dart';
import '../../../khatm/domain/repositories/khatm_cycle_repository.dart';
import '../../../stats/data/stats_store.dart';
import '../../../stats/data/study_session_providers.dart';
import '../../../stats/domain/repositories/study_session_repository.dart';
import '../../data/user_content_providers.dart';
import '../../domain/ayah_decoration.dart';
import '../../domain/basmalah.dart';
import '../../domain/entities/ayah_annotation.dart';
import '../../domain/entities/ayah_content.dart';
import '../../domain/entities/surah.dart';
import '../../domain/playback_follow_policy.dart';
import '../annotations/ayah_actions_sheet.dart';
import '../audio/audio_bar.dart';
import '../audio/audio_controller.dart';
import 'mushaf_builder.dart';
import 'reading_controller.dart';
import 'reading_position_store.dart';
import 'reading_rows.dart';
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

  /// Lần gần nhất người dùng TỰ cuộn — đầu vào của
  /// `shouldFollowPlayback`. `null` = chưa cuộn lần nào trong phiên này.
  DateTime? _lastManualScrollAt;

  /// Surah này mở đầu thế nào — `null` khi chưa có dữ liệu.
  ///
  /// Sprint BM2: mọi phép quy đổi Ayah ↔ hàng cần giá trị này, kể cả ở
  /// những callback không nằm trong `build` (`_onPositionsChanged`, bộ
  /// lắng nghe audio). Giữ MỘT bản đã phân giải ở đây thay vì phân giải
  /// lại ở từng chỗ — hai lần phân giải là hai cơ hội lệch nhau.
  SurahOpening? _opening;

  // pinch-zoom
  double _pinchBaseScale = 1.0;
  int _maxPointers = 1;

  // thống kê phiên đọc (ngày + số phút)
  final Stopwatch _sessionWatch = Stopwatch();
  late final StatsStore _statsStore;
  late final StudySessionRepository _studySessionRepository;
  late final KhatmCycleRepository _khatmCycleRepository;

  /// Chu kỳ Khatm đang đọc dở, nếu có — Sprint SF-Khatm. Đọc lại ở
  /// `build()` (cùng lý do với [_opening]): `dispose()` không thể tự
  /// `ref.watch` một `StreamProvider` lần đầu và mong có dữ liệu ngay —
  /// nó chỉ thấy trạng thái đang tải, chưa emit. Giữ MỘT bản đã có sẵn
  /// từ khung hình gần nhất, giống hệt cách [_opening] được giữ lại
  /// cho các callback ngoài `build`.
  KhatmCycle? _activeKhatmCycle;

  @override
  void initState() {
    super.initState();
    _initialAyahIndex =
        ref.read(readingPositionStoreProvider).positionFor(widget.surahId) ?? 0;
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
    _statsStore = ref.read(statsStoreProvider);
    _studySessionRepository = ref.read(studySessionRepositoryProvider);
    _khatmCycleRepository = ref.read(khatmCycleRepositoryProvider);
    unawaited(_statsStore.markToday());
    _sessionWatch.start();
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    final seconds = _sessionWatch.elapsed.inSeconds;
    unawaited(_statsStore.addSeconds(seconds));
    // Sprint 8 (DR-2026-0003 mục A) — ghi song song vào
    // study_sessions (Drift) để "Phiên đọc" (streak/tổng kết hôm
    // nay) có dữ liệu thật; StatsStore/SharedPreferences vẫn là
    // nguồn cho lưới chỉ số hiện có, không đụng tới. Cùng ngưỡng
    // "< 5 giây bỏ qua" như StatsStore.addSeconds — lướt qua màn
    // hình không tính là một phiên đọc.
    if (seconds >= 5) {
      final lastIndex = _lastSavedIndex ?? _initialAyahIndex;
      unawaited(
        _studySessionRepository.logSession(
          date: StatsStore.dayKey(DateTime.now()),
          surahId: widget.surahId,
          ayahFrom: _initialAyahIndex,
          ayahTo: lastIndex,
          durationSec: seconds,
        ),
      );
      // Sprint SF-Khatm: tiến độ Khatm là một hành trình TUẦN TỰ, không
      // phải vị trí đọc gần nhất — nên chỉ ghi khi phiên này thật sự
      // nối tiếp biên của chu kỳ. Luật đó thuộc về Khatm, không thuộc
      // trang đọc: ở đây chỉ nói "phiên đi từ đâu tới đâu" rồi để
      // KhatmCycle.isExtendedBy quyết định.
      //
      // Dùng lại ĐÚNG hai đầu phiên vừa gửi cho study_sessions — không
      // đo lại lần nữa, để hai nơi không thể nói khác nhau.
      final cycle = _activeKhatmCycle;
      if (cycle != null) {
        final from = QuranAddress.fromZeroBasedAyahIndex(
          widget.surahId,
          _initialAyahIndex,
        );
        final to = QuranAddress.fromZeroBasedAyahIndex(
          widget.surahId,
          lastIndex,
        );
        if (cycle.isExtendedBy(from: from, to: to)) {
          unawaited(_khatmCycleRepository.updateProgress(cycle.id, to));
        }
      }
    }
    super.dispose();
  }

  /// Ayah đầu tiên đang hiển thị -> lưu làm vị trí đọc.
  void _onPositionsChanged() {
    final opening = _opening;
    // Chưa có dữ liệu thì chưa có vị trí nào đáng lưu. Không đoán bằng
    // "coi như không có phần mở đầu": đoán sai là ghi lệch một Ayah
    // xuống đĩa.
    if (opening == null) return;
    final positions = _positionsListener.itemPositions.value;
    final visible = positions.where((p) => p.itemTrailingEdge > 0);
    if (visible.isEmpty) return;
    final minItemIndex = visible.map((p) => p.index).reduce(min);
    // Hàng dẫn đầu (header hoặc phần mở đầu) -> coi như đang ở Ayah đầu.
    final ayahIndex =
        ReadingRows.ayahIndexForRow(opening: opening, row: minItemIndex) ?? 0;
    if (ayahIndex == _lastSavedIndex) return;
    _lastSavedIndex = ayahIndex;
    unawaited(
      ref
          .read(readingPositionStoreProvider)
          .save(surahId: widget.surahId, ayahIndex: ayahIndex),
    );
  }

  /// Ghi lại thời điểm người dùng TỰ cuộn (Sprint F1).
  ///
  /// `dragDetails != null` là dấu hiệu chắc chắn của thao tác kéo tay:
  /// cuộn do `ItemScrollController.scrollTo()` gây ra luôn để trường này
  /// null. Phân biệt bằng `UserScrollNotification` thì ngắn hơn nhưng
  /// KHÔNG an toàn — cuộn theo lập trình cũng phát ra nó, nên màn hình
  /// sẽ nhận thao tác của chính mình là của người dùng rồi tự chặn lần
  /// cuộn kế tiếp, thành ra bám audio cách quãng một Ayah.
  ///
  /// Chỉ cần bắt lúc bắt đầu kéo: quán tính sau khi thả tay
  /// (`BallisticScrollActivity`) không mang `dragDetails`, nhưng nó luôn
  /// nối tiếp một lần kéo vừa được ghi và ngắn hơn nhiều so với
  /// `kPlaybackFollowGrace`.
  ///
  /// KHÔNG gọi `setState`: trường này chỉ được đọc trong `ref.listen`
  /// của audio và không tham gia dựng giao diện. `setState` ở đây là
  /// dựng lại toàn bộ danh sách mỗi khung hình cuộn.
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _lastManualScrollAt = DateTime.now();
    }
    return false; // không nuốt thông báo — các lớp trên vẫn nhận được
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

    // Sprint BM2: phân giải MỘT lần cho cả khung hình. Các callback bên
    // dưới (cuộn, vị trí đọc) đọc lại trường này chứ không tự phân giải.
    final loaded = reading.valueOrNull;
    _opening = loaded == null || loaded.ayahs.isEmpty
        ? null
        : resolveSurahOpening(
            surahId: widget.surahId,
            firstAyahText: loaded.ayahs.first.ayah.textUthmani,
          );

    // Sprint SF-Khatm: cùng lý do giữ [_opening] một bản sẵn — xem
    // doc comment của trường [_activeKhatmCycle].
    _activeKhatmCycle = ref.watch(activeKhatmCycleProvider).valueOrNull;

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
      // Sprint F1: người dùng vừa tự cuộn -> để yên cho họ đọc. Hết
      // khoảng lặng thì bám theo audio trở lại (DR-2026-0019 §7.3).
      if (!shouldFollowPlayback(
        now: DateTime.now(),
        lastManualScrollAt: _lastManualScrollAt,
      )) {
        return;
      }
      // Sprint BM1: `currentIndex` là chỉ số PLAYLIST, không còn là chỉ
      // số Ayah. Hỏi địa chỉ thay vì tính: `zeroBasedAyahIndex` trả
      // `null` ở mức Surah, và mức Surah nghĩa là đang phát phần mở đầu.
      //
      // Sprint BM2: phần mở đầu giờ có HÀNG riêng, nên cuộn thẳng tới
      // nó — trước BM2 chỉ cuộn được về header.
      final opening = _opening;
      if (opening == null) return;
      final ayahIndex = next.currentAddress?.zeroBasedAyahIndex;
      _itemScrollController.scrollTo(
        index: ayahIndex == null
            ? ReadingRows.openingRowFor(opening) ?? 0
            : ReadingRows.rowForAyahIndex(
                opening: opening,
                ayahIndex: ayahIndex,
              ),
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
                    // Sprint F1: chỉ nhánh danh sách mới cần theo dõi
                    // cuộn tay — chế độ Mushaf không bao giờ tự cuộn.
                    : NotificationListener<ScrollNotification>(
                        onNotification: _onScrollNotification,
                        child: _AyahListView(
                          surah: data.surah,
                          ayahs: data.ayahs,
                          surahId: widget.surahId,
                          opening: _opening!,
                          focus: _focusMode,
                          // Vị trí 0 = chưa đọc dở -> mở từ ĐẦU trang
                          // (kèm header Surah); đọc dở -> nhảy thẳng
                          // tới Ayah đó, kẹp trong danh sách thật.
                          initialScrollIndex: _initialAyahIndex == 0
                              ? 0
                              : min(
                                  ReadingRows.rowForAyahIndex(
                                    opening: _opening!,
                                    ayahIndex: _initialAyahIndex,
                                  ),
                                  ReadingRows.lastRowFor(
                                    opening: _opening!,
                                    ayahCount: data.ayahs.length,
                                  ),
                                ),
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _positionsListener,
                        ),
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
        ayahs: [for (final a in data.ayahs) a.ayah],
        // Tiếp tục ở đúng Ayah đang đọc dở — mức Ayah, vì người dùng
        // đang ở giữa Surah chứ không yêu cầu đọc lại từ đầu.
        from: QuranAddress.fromZeroBasedAyahIndex(
          widget.surahId,
          (_lastSavedIndex ?? _initialAyahIndex)
              .clamp(0, data.ayahs.length - 1),
        ),
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
    required this.opening,
    required this.focus,
    required this.initialScrollIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  final Surah surah;
  final List<AyahContent> ayahs;
  final int surahId;

  /// Cách Surah này mở đầu — phân giải một lần ở `ReadingScreen`.
  final SurahOpening opening;
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
        const maxContentWidth = 720.0;
        final horizontal = constraints.maxWidth > maxContentWidth + 40
            ? (constraints.maxWidth - maxContentWidth) / 2
            : 20.0;
        return ScrollablePositionedList.builder(
          initialScrollIndex: initialScrollIndex,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: 12,
          ),
          itemCount: ReadingRows.rowCountFor(
            opening: opening,
            ayahCount: ayahs.length,
          ),
          itemBuilder: (context, row) {
            final ayahIndex = ReadingRows.ayahIndexForRow(
              opening: opening,
              row: row,
            );
            if (ayahIndex == null) {
              // Hàng dẫn đầu: header, hoặc phần mở đầu nếu Surah có.
              //
              // Sprint BM2: Basmalah rời khỏi header thành HÀNG riêng.
              // Giữ cả hai chỗ là vẽ nó hai lần; và chỉ khi đứng riêng
              // nó mới nhận được trang trí "đang phát" cùng nhãn
              // accessibility của chính mình.
              if (focus) return const SizedBox.shrink();
              // Biến cục bộ để kiểu được thăng hạng (trường của widget
              // thì không).
              final surahOpening = opening;
              if (row == ReadingRows.openingRowFor(opening) &&
                  surahOpening is OpeningPrefixesFirstAyah) {
                return _OpeningRow(
                  surahId: surahId,
                  text: surahOpening.text,
                  // Mức SURAH = "đọc Surah này từ đầu" -> bắt đầu ở
                  // chính phần mở đầu.
                  onPlay: () =>
                      ref.read(audioControllerProvider.notifier).playSurah(
                    ayahs: [for (final a in ayahs) a.ayah],
                    from: QuranAddress.surah(surahId),
                  ),
                );
              }
              return _SurahHeader(surah: surah);
            }
            return AyahCard(
              content: ayahs[ayahIndex],
              focus: focus,
              // Mức AYAH = người dùng chỉ đúng Ayah này. Sprint BM3:
              // trước đây thẻ Ayah 1 truyền chỉ số 0 và lại nghe
              // Basmalah — nút hứa một đằng, phát một nẻo.
              onPlay: () =>
                  ref.read(audioControllerProvider.notifier).playSurah(
                ayahs: [for (final a in ayahs) a.ayah],
                from: QuranAddress.ayah(
                  surahId,
                  ayahs[ayahIndex].ayah.ayahNumber,
                ),
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

  // Sprint BM2: header chỉ còn tên Surah, nơi giáng và số Ayah.
  // Basmalah đã ra `_OpeningRow` — một hàng thật, có trang trí và có
  // nhãn accessibility riêng.

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

        // Sprint BM2: Basmalah KHÔNG còn ở đây. Nó là một hàng riêng
        // (`_OpeningRow`) để nhận được trang trí "đang phát" và nhãn
        // accessibility của chính nó.
        const SizedBox(height: 18),
      ],
    );
  }
}

/// Phần mở đầu Surah như một HÀNG ĐỌC riêng — Sprint BM2 (Basmalah 2.0).
///
/// Chỉ dựng cho Surah có `OpeningPrefixesFirstAyah`. Al-Fatihah không
/// cần (Basmalah của nó LÀ Ayah 1, thẻ Ayah 1 vẽ rồi) và At-Tawbah
/// không có gì để vẽ — cả hai được `ReadingRows.openingRowFor` loại từ
/// trước, nên widget này không chứa `if` nào về số Surah.
///
/// Địa chỉ của nó là `QuranAddress.surah(surahId)` — cùng địa chỉ mà
/// BM1 gán cho mục phát tương ứng. Nhờ vậy phần tô sáng ở đây và phần
/// phát audio nói về đúng một thứ, không cần bảng tra nào ở giữa.
class _OpeningRow extends ConsumerWidget {
  const _OpeningRow({
    required this.surahId,
    required this.text,
    required this.onPlay,
  });

  final int surahId;
  final String text;

  /// Sprint BM3: phát Surah TỪ phần mở đầu. Trước BM3 hàng này chỉ nhìn
  /// được — nghe được Basmalah là nhờ phát cả Surah từ đầu, không phải
  /// nhờ chỉ vào nó.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Cùng cách so sánh mà `AyahCard` dùng, chỉ khác MỨC địa chỉ. F0 bảo
    // đảm `surah(N) != ayah(N, 1)`, nên khi Basmalah đang phát thì thẻ
    // Ayah 1 KHÔNG sáng theo, và ngược lại.
    final thisOpening = QuranAddress.surah(surahId);
    final isPlayingThis = ref.watch(
      audioControllerProvider.select((s) => s.currentAddress == thisOpening),
    );

    // Tầng trang trí của F1, dùng lại nguyên vẹn. Phần mở đầu không tô
    // màu được (không có bản ghi chú thích cho nó), nên tập màu rỗng —
    // và luật ưu tiên vẫn là luật cũ, không có nhánh mới nào.
    final decoration = resolveAyahDecoration(
      isPlaying: isPlayingThis,
      highlightColors: const {},
    );
    final background = switch (decoration) {
      PlayingDecoration() => Color.alphaBlend(
          scheme.primaryContainer.withValues(alpha: 0.35),
          scheme.surfaceContainerLow,
        ),
      NoDecoration() || UserHighlightDecoration() => Colors.transparent,
    };

    return Semantics(
      // `container: true`: phần mở đầu là MỘT phần tử, nên trình đọc
      // màn hình phải gặp một nút duy nhất mang nhãn của nó — không
      // phải một chuỗi ký tự Ả Rập trôi nổi giữa các Ayah. Không có cờ
      // này thì nhãn chỉ là chú thích, có thể bị gộp vào node khác.
      container: true,
      label: l10n.openingSemanticLabel,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cùng nút, cùng tooltip, cùng cách đổi icon khi đang phát
              // như thẻ Ayah — phần mở đầu hành xử như một phần tử đọc,
              // không phải một món trang trí đặc biệt.
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _ActionIcon(
                  tooltip: l10n.playFromHere,
                  icon: isPlayingThis
                      ? Icons.graphic_eq_rounded
                      : Icons.play_arrow_rounded,
                  color: scheme.primary,
                  onPressed: onPlay,
                ),
              ),
              Text(
                text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: quranTextStyle(
                  fontSize: 28,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(readingSettingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ayah đang phát audio -> nền highlight nhẹ (mục UX #6).
    // select(): thẻ CHỈ rebuild khi kết quả bool đổi — các tick
    // position/duration của trình phát không đụng tới danh sách.
    //
    // Sprint F0: trước đây là `s.currentIndex == ayahNumber - 1` —
    // so một chỉ số 0-based với một số 1-based bằng phép trừ trần.
    // Đúng, nhưng đúng một cách khó kiểm chứng. Giờ cả hai vế là
    // QuranAddress nên phép so sánh là bằng-nhau-theo-giá-trị, và
    // phép quy đổi nằm trong AudioState.currentAddress (có test).
    final thisAyah = QuranAddress.ayah(
      content.ayah.surahId,
      content.ayah.ayahNumber,
    );
    final isPlayingThis = ref.watch(
      audioControllerProvider.select((s) => s.currentAddress == thisAyah),
    );

    // Chú thích người dùng (bookmark/highlight/note/status) realtime.
    final annotation = ref
            .watch(ayahAnnotationsProvider(content.ayah.surahId))
            .valueOrNull?[content.ayah.id] ??
        AyahAnnotation.empty;

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

    // Chế độ Danh sách: Ayah 1 của Surah có Basmalah dẫn đầu bỏ phần
    // Basmalah (đã đưa lên header trang trí) -> chỉ một Basmalah.
    final displayArabic = ayahDisplayText(
      surahId: content.ayah.surahId,
      ayahNumber: content.ayah.ayahNumber,
      textUthmani: content.ayah.textUthmani,
    );

    final translit = content.texts['translit_latin'];
    final vi = content.texts['vi_main'];
    final en = content.texts['en_sahih'];

    // Nền thẻ. Sprint F1: LUẬT ưu tiên (đang phát > người dùng tô >
    // không gì) đã ra `resolveAyahDecoration`; ở đây chỉ còn việc của
    // tầng trình bày là đổi một dấu hiệu thành một màu — đúng ranh giới
    // DR-2026-0019 §6.3 ("engine không bao giờ gọi tên một màu").
    final decoration = resolveAyahDecoration(
      isPlaying: isPlayingThis,
      highlightColors: annotation.highlightColors,
    );
    final cardColor = switch (decoration) {
      NoDecoration() => scheme.surfaceContainerLow,
      PlayingDecoration() => Color.alphaBlend(
          scheme.primaryContainer.withValues(alpha: 0.35),
          scheme.surfaceContainerLow,
        ),
      // Tên màu không có trong bảng (dữ liệu cũ hoặc bảng đổi sau này)
      // -> nền thường, đúng như hành vi trước F1.
      UserHighlightDecoration(:final colorName) => switch (
            kHighlightColorValues[colorName]) {
          null => scheme.surfaceContainerLow,
          final color => Color.alphaBlend(
              color.withValues(alpha: 0.16),
              scheme.surfaceContainerLow,
            ),
        },
    };

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
                  if ((settings.showTransliteration && translit != null) ||
                      (settings.showVietnamese && vi != null) ||
                      (settings.showEnglish && en != null)) ...[
                    const SizedBox(height: 18),
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ---- Phiên âm (nhỏ hơn, kiểu phụ) ----
                  if (settings.showTransliteration && translit != null) ...[
                    Text(
                      translit,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        height: 1.55,
                        letterSpacing: 0.2,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ---- Bản dịch (LTR, dễ đọc) ----
                  if (settings.showVietnamese && vi != null) ...[
                    Text(
                      vi,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontSize: 18,
                        height: 1.7,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (settings.showEnglish && en != null) ...[
                    Text(
                      en,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFont,
                        fontSize: 16,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
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
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AyahActionsSheet(
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
