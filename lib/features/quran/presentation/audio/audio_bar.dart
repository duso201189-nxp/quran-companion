import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../core/audio/ayah_audio_player.dart';
import 'audio_controller.dart';

String _fmtTime(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Thanh trình phát mini, dính đáy trang đọc khi đang phát.
///
/// Gồm: tiến độ Ayah (kèm thời gian), Qari, prev/play/next,
/// tốc độ, lặp, dừng; hiển thị trạng thái tải và lỗi (kèm Thử lại).
///
/// Sprint 28.0 — CHIA THEO NHỊP THAY ĐỔI, không phải theo hình khối.
/// Trước đây cả thanh `watch` nguyên `AudioState`, nên mỗi tick vị trí
/// (~300ms) dựng lại toàn bộ: 6 IconButton kèm Tooltip, TextButton
/// tốc độ, hàng lỗi... trong khi chỉ hai chỗ thật sự đổi là dải tiến
/// độ và nhãn thời gian. Nay mỗi phần chỉ `select` đúng trường nó vẽ:
///
///   [AudioBar]            -> `active` (chỉ đổi khi bắt đầu/dừng phát)
///   [_AudioProgressBar]   -> `loading`, `progress`   (mỗi ~300ms)
///   [_AudioErrorRow]      -> có lỗi hay không
///   [_AudioControlsRow]   -> Qari, playing, loading, speed, repeat
///   [_AudioTrackLabel]    -> vị trí/thời lượng       (mỗi ~300ms)
///
/// Bố cục hiển thị KHÔNG đổi — vẫn đúng cây Material > SafeArea >
/// Column như trước.
class AudioBar extends ConsumerWidget {
  const AudioBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(audioControllerProvider.select((s) => s.active));
    if (!active) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 3,
      child: const SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AudioProgressBar(),
            _AudioErrorRow(),
            _AudioControlsRow(),
          ],
        ),
      ),
    );
  }
}

/// Dải tiến độ của Ayah đang phát.
class _AudioProgressBar extends ConsumerWidget {
  const _AudioProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (loading, progress) = ref.watch(
      audioControllerProvider.select((s) => (s.loading, s.progress)),
    );

    return LinearProgressIndicator(
      minHeight: 3,
      value: loading ? null : progress ?? 0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

/// Lỗi phát: thông báo + Thử lại. Không lỗi -> chiếm 0 chiều cao,
/// đúng như nhánh `if` trước đây.
class _AudioErrorRow extends ConsumerWidget {
  const _AudioErrorRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ cần BIẾT CÓ lỗi: thanh luôn hiển thị `l10n.audioError` cố
    // định, không hiển thị `errorMessage` thô của engine.
    final hasError = ref.watch(
      audioControllerProvider.select((s) => s.errorMessage != null),
    );
    if (!hasError) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.audioError,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: ref.read(audioControllerProvider.notifier).retry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

/// Hàng điều khiển: Qari, prev/play/next, tốc độ, lặp, dừng.
class _AudioControlsRow extends ConsumerWidget {
  const _AudioControlsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(audioControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (reciterName, playing, loading, speed, repeat) = ref.watch(
      audioControllerProvider.select(
        (s) => (s.reciter?.name ?? '', s.playing, s.loading, s.speed, s.repeat),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.selectReciter,
            icon: const Icon(Icons.record_voice_over_outlined),
            onPressed: () => _openReciterPicker(context),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reciterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium,
                ),
                const _AudioTrackLabel(),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.previousAyah,
            icon: const Icon(Icons.skip_previous),
            onPressed: controller.previousAyah,
          ),
          // Play/Pause — khi đang tải hiển thị vòng xoay.
          loading
              ? Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: scheme.primary,
                    semanticsLabel: l10n.audioLoading,
                  ),
                )
              : IconButton(
                  tooltip: playing ? l10n.pause : l10n.play,
                  icon: Icon(
                    playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 40,
                    color: scheme.primary,
                  ),
                  onPressed: controller.togglePlayPause,
                ),
          IconButton(
            tooltip: l10n.nextAyah,
            icon: const Icon(Icons.skip_next),
            onPressed: controller.nextAyah,
          ),
          TextButton(
            onPressed: controller.cycleSpeed,
            child: Text('${speed}x'),
          ),
          IconButton(
            tooltip: l10n.repeatMode,
            icon: Icon(
              switch (repeat) {
                RepeatMode.off => Icons.repeat,
                RepeatMode.one => Icons.repeat_one_on,
                RepeatMode.all => Icons.repeat_on,
              },
            ),
            onPressed: controller.cycleRepeat,
          ),
          IconButton(
            tooltip: l10n.stopAudio,
            icon: const Icon(Icons.close),
            onPressed: controller.stop,
          ),
        ],
      ),
    );
  }

  void _openReciterPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const ReciterPickerSheet(),
    );
  }
}

/// Nhãn "surah:ayah · vị trí / thời lượng" — phần đổi nhanh nhất của
/// thanh phát, tách riêng để tick vị trí không kéo theo cả hàng nút.
class _AudioTrackLabel extends ConsumerWidget {
  const _AudioTrackLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (surahId, currentIndex, position, duration) = ref.watch(
      audioControllerProvider.select(
        (s) => (s.surahId, s.currentIndex, s.position, s.duration),
      ),
    );
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      duration == null
          ? '$surahId:${currentIndex + 1}'
          : '$surahId:${currentIndex + 1}'
              ' · ${_fmtTime(position)}'
              ' / ${_fmtTime(duration)}',
      style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}

/// Chọn Qari từ bảng `reciters`.
class ReciterPickerSheet extends ConsumerWidget {
  const ReciterPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciters = ref.watch(recitersProvider);
    // select(): sheet chỉ dựng lại khi ĐỔI Qari — không theo từng
    // tick vị trí của trình phát đang chạy phía sau.
    final selectedCode = ref.watch(
      audioControllerProvider.select((s) => s.reciter?.code),
    );

    return SafeArea(
      child: reciters.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.errorLoadData, textAlign: TextAlign.center),
        ),
        data: (list) => RadioGroup<String>(
          groupValue: selectedCode,
          onChanged: (code) async {
            if (code == null) return;
            final reciter = list.firstWhere((r) => r.code == code);
            await ref
                .read(audioControllerProvider.notifier)
                .selectReciter(reciter);
            if (context.mounted) Navigator.pop(context);
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.selectReciter,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final r in list)
                RadioListTile<String>(
                  value: r.code,
                  title: Text(r.name),
                  subtitle: r.nameArabic == null ? null : Text(r.nameArabic!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
