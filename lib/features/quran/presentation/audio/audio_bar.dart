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
class AudioBar extends ConsumerWidget {
  const AudioBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final audio = ref.watch(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!audio.active) return const SizedBox.shrink();

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Thanh tiến độ Ayah hiện tại ----
            LinearProgressIndicator(
              minHeight: 3,
              value: audio.loading ? null : audio.progress ?? 0,
              backgroundColor: scheme.surfaceContainerHighest,
            ),

            // ---- Lỗi phát: thông báo + Thử lại ----
            if (audio.errorMessage != null)
              Container(
                width: double.infinity,
                color: scheme.errorContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onErrorContainer),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.retry,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),

            Padding(
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
                          audio.reciter?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium,
                        ),
                        Text(
                          audio.duration == null
                              ? '${audio.surahId}:${audio.currentIndex + 1}'
                              : '${audio.surahId}:${audio.currentIndex + 1}'
                                  ' · ${_fmtTime(audio.position)}'
                                  ' / ${_fmtTime(audio.duration!)}',
                          style: textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.previousAyah,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: controller.previousAyah,
                  ),
                  // Play/Pause — khi đang tải hiển thị vòng xoay.
                  audio.loading
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
                          tooltip: audio.playing ? l10n.pause : l10n.play,
                          icon: Icon(
                            audio.playing
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
                    child: Text('${audio.speed}x'),
                  ),
                  IconButton(
                    tooltip: l10n.repeatMode,
                    icon: Icon(
                      switch (audio.repeat) {
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
            ),
          ],
        ),
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

/// Chọn Qari từ bảng `reciters`.
class ReciterPickerSheet extends ConsumerWidget {
  const ReciterPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reciters = ref.watch(recitersProvider);
    final selected = ref.watch(audioControllerProvider).reciter;

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
          groupValue: selected?.code,
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
