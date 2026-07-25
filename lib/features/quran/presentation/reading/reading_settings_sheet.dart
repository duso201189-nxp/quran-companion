import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/quran_providers.dart';
import '../../domain/entities/translation_source.dart';
import 'reading_settings.dart';
import 'reading_sheet_motion.dart';

/// Bảng "Hiển thị" của trang đọc (Sprint 25.5) — gom MỌI tuỳ chọn đọc
/// đã có vào một nơi: chế độ đọc, cỡ chữ Ả Rập, và các lớp hỗ trợ đọc.
/// Trước đây chế độ đọc chỉ nằm ở một nút trên AppBar, tách rời khỏi
/// các tuỳ chọn hiển thị còn lại.
///
/// KHÔNG có provider hay chỗ lưu riêng: tất cả đi qua
/// [readingSettingsProvider] ([ReadingSettingsController]) đã có, vốn
/// tự ghi SharedPreferences. Sheet chỉ là bề mặt điều khiển.
///
/// Mỗi nhóm điều khiển tự `watch` ĐÚNG trường nó cần qua `select`:
/// kéo thanh cỡ chữ KHÔNG dựng lại ba công tắc bên dưới, và bật một
/// công tắc KHÔNG dựng lại thanh trượt hay hai công tắc kia.
class ReadingSettingsSheet extends StatelessWidget {
  const ReadingSettingsSheet({super.key});

  /// Mở bảng với đúng nhịp chuyển động chung của trang đọc; tôn trọng
  /// thiết lập "giảm chuyển động" của hệ điều hành.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      sheetAnimationStyle: readingSheetMotion(context),
      builder: (_) => const ReadingSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.displaySettings, style: textTheme.titleMedium),
            ),
            const SizedBox(height: 18),

            // ---- Chế độ đọc ----
            _GroupLabel(l10n.readingModeLabel),
            const SizedBox(height: 8),
            const _ModeSelector(),
            const SizedBox(height: 22),

            // ---- Cỡ chữ Ả Rập ----
            const _FontSizeControl(),
            const SizedBox(height: 16),

            // ---- Lớp hỗ trợ đọc ----
            _GroupLabel(l10n.readingLayersLabel),
            const SizedBox(height: 4),
            const _ReadingLayers(),
          ],
        ),
      ),
    );
  }
}

/// Nhãn nhóm — phân nhóm bằng chữ + khoảng trắng thay vì kẻ đường
/// ngăn, giữ bảng nhẹ nhàng.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(readingSettingsProvider.select((s) => s.mode));

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ReadingMode>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: ReadingMode.list,
            label: Text(l10n.readingModeList),
          ),
          ButtonSegment(
            value: ReadingMode.mushaf,
            label: Text(l10n.readingModeMushaf),
          ),
        ],
        selected: {mode},
        // Áp dụng NGAY; bảng vẫn mở để tinh chỉnh tiếp.
        onSelectionChanged: (selection) =>
            ref.read(readingSettingsProvider.notifier).setMode(selection.first),
      ),
    );
  }
}

class _FontSizeControl extends ConsumerWidget {
  const _FontSizeControl();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scale =
        ref.watch(readingSettingsProvider.select((s) => s.arabicScale));
    final percent = (scale * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _GroupLabel(l10n.readingFontSize)),
            // Giá trị hiện tại hiện ngay cạnh nhãn — kéo tới đâu thấy
            // tới đó, không phải đoán.
            Text(
              '$percent%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.text_decrease,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Expanded(
              child: Slider(
                value: scale,
                min: ReadingSettings.minScale,
                max: ReadingSettings.maxScale,
                divisions: 8,
                label: '$percent%',
                // Trình đọc màn hình đọc ra phần trăm thay vì số thực.
                semanticFormatterCallback: (value) =>
                    '${(value * 100).round()}%',
                onChanged:
                    ref.read(readingSettingsProvider.notifier).setArabicScale,
              ),
            ),
            Icon(
              Icons.text_increase,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }
}

/// Danh sách công tắc lớp văn bản — DỰNG TỪ DANH MỤC NGUỒN, không từ
/// ba công tắc viết sẵn (Sprint 30.1).
///
/// Thêm một bản dịch hay một nguồn Tafsir vào database là đủ để nó
/// xuất hiện ở đây, mang đúng tên do dữ liệu khai báo.
class _ReadingLayers extends ConsumerWidget {
  const _ReadingLayers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Sprint 30.2 — chỉ nguồn thuộc đường đọc: bật một công tắc
    // Tafsir ở đây sẽ không hiện gì, vì trang đọc không nạp Tafsir.
    final sources = ref.watch(readingSourcesProvider);

    return sources.when(
      // Cùng nhịp với phần còn lại của bảng: không nháy khung chờ toàn
      // bảng chỉ vì danh mục nguồn (một truy vấn nhỏ, thường đã sẵn).
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l10n.errorLoadData),
      ),
      data: (list) => Column(
        children: [
          for (final source in list) _LayerSwitch(source: source),
        ],
      ),
    );
  }
}

class _LayerSwitch extends ConsumerWidget {
  const _LayerSwitch({required this.source});

  final TranslationSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguage = Localizations.localeOf(context).languageCode;
    // select() trả về bool -> công tắc chỉ dựng lại khi CHÍNH nguồn
    // này đổi trạng thái, không phải khi bất kỳ nguồn nào đổi.
    final value = ref.watch(
      readingSettingsProvider.select(
        (s) => s.isSourceVisible(source, appLanguage),
      ),
    );

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      // Nhãn lấy từ dữ liệu (`translation_sources.name`) chứ không từ
      // l10n: tên nguồn là danh xưng của chính bản dịch/Tafsir đó
      // ("Bản dịch tiếng Việt", "Tafsir Ibn Kathir"), do bộ dữ liệu
      // khai báo — không thể có khoá l10n cho nguồn chưa tồn tại.
      title: Text(source.name),
      value: value,
      onChanged: (next) => ref
          .read(readingSettingsProvider.notifier)
          .setSourceVisible(source.code, next),
    );
  }
}
