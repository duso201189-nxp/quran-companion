import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/user_content_providers.dart';
import '../../domain/entities/ayah_annotation.dart';

/// Màu hiển thị của 6 tên màu highlight (ánh xạ ở tầng UI).
const Map<String, Color> kHighlightColorValues = {
  'amber': Color(0xFFFFC107),
  'green': Color(0xFF4CAF50),
  'blue': Color(0xFF2196F3),
  'pink': Color(0xFFE91E63),
  'orange': Color(0xFFFF9800),
  'purple': Color(0xFF9C27B0),
};

/// Nhịp mở/đóng sheet — mềm khi vào, gọn hơn một chút khi ra, không
/// nảy. Một hằng số duy nhất để mọi lần mở sheet Ayah giống hệt nhau.
const AnimationStyle _sheetMotion = AnimationStyle(
  duration: Duration(milliseconds: 280),
  curve: Curves.easeOutCubic,
  reverseDuration: Duration(milliseconds: 220),
  reverseCurve: Curves.easeInCubic,
);

/// Sheet thao tác một Ayah (mở bằng nhấn giữ hoặc nút "…" trên thẻ) —
/// BỀ MẶT DUY NHẤT gom mọi thao tác trên một Ayah: bookmark, yêu
/// thích, nghe, sao chép, chia sẻ, tô màu, trạng thái học, ghi chú.
///
/// Sheet KHÔNG tự dựng lại nghiệp vụ nào: bookmark/yêu thích/tô màu/
/// trạng thái/ghi chú đi thẳng qua [UserContentRepository] đã có; còn
/// nghe/sao chép/chia sẻ nhận callback từ nơi gọi (`AyahCard` vốn đã
/// nắm danh sách Ayah cho AudioController và hàm soạn văn bản sao
/// chép) — nhờ vậy thẻ và sheet không bao giờ lệch hành vi.
class AyahActionsSheet extends ConsumerWidget {
  const AyahActionsSheet({
    super.key,
    required this.surahId,
    required this.ayahId,
    required this.ayahNumber,
    this.arabicText,
    this.translationText,
    this.onPlay,
    this.onCopy,
    this.onShare,
  });

  final int surahId;
  final int ayahId;
  final int ayahNumber;

  /// Văn bản để Sao chép chữ Ả Rập (null = ẩn hành động).
  final String? arabicText;

  /// Văn bản để Sao chép bản dịch (null = ẩn hành động).
  final String? translationText;

  /// Nghe từ Ayah này. null = ẩn (vd Focus Mode không truyền).
  final VoidCallback? onPlay;

  /// Sao chép / chia sẻ TOÀN VĂN Ayah kèm các lớp dịch đang bật —
  /// dùng lại đúng hàm của [AyahCard], không soạn lại ở đây.
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  /// Mở sheet với đúng nhịp chuyển động chuẩn; tôn trọng thiết lập
  /// "giảm chuyển động" của hệ điều hành (không cần AnimationController
  /// riêng — `sheetAnimationStyle` nhận thẳng thời lượng 0).
  static Future<void> show(
    BuildContext context, {
    required int surahId,
    required int ayahId,
    required int ayahNumber,
    String? arabicText,
    String? translationText,
    VoidCallback? onPlay,
    VoidCallback? onCopy,
    VoidCallback? onShare,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : _sheetMotion,
      builder: (_) => AyahActionsSheet(
        surahId: surahId,
        ayahId: ayahId,
        ayahNumber: ayahNumber,
        arabicText: arabicText,
        translationText: translationText,
        onPlay: onPlay,
        onCopy: onCopy,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final repo = ref.read(userContentRepositoryProvider);

    // select(): sheet CHỈ dựng lại khi chú thích của CHÍNH Ayah này
    // đổi — thao tác trên Ayah khác trong cùng Surah không đụng tới
    // (cần `==` theo giá trị của AyahAnnotation, xem entity).
    final annotation = ref.watch(
      ayahAnnotationsProvider(surahId).select(
        (value) => value.valueOrNull?[ayahId] ?? AyahAnnotation.empty,
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                '${l10n.ayahSemanticLabel(ayahNumber)} — $surahId:$ayahNumber',
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 18),

            // ---- Hàng thao tác nhanh ----
            // Wrap (không phải Row): nhiều ngôn ngữ + cỡ chữ lớn thì
            // các mục tự xuống dòng thay vì tràn ngang.
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _SheetAction(
                  icon: annotation.bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: l10n.bookmarkLabel,
                  selected: annotation.bookmarked,
                  // Bật/tắt -> GIỮ sheet mở để thấy trạng thái đổi ngay.
                  onTap: () => repo.toggleBookmark(ayahId),
                ),
                _SheetAction(
                  icon: annotation.favorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: l10n.favoriteLabel,
                  selected: annotation.favorited,
                  onTap: () => repo.toggleFavorite(ayahId),
                ),
                if (onPlay != null)
                  _SheetAction(
                    icon: Icons.play_arrow_rounded,
                    label: l10n.playFromHere,
                    // Hành động một lần -> đóng sheet, trả người dùng
                    // về trang đọc ngay.
                    onTap: () => _runAndClose(context, onPlay!),
                  ),
                if (onCopy != null)
                  _SheetAction(
                    icon: Icons.copy_rounded,
                    label: l10n.copyAyah,
                    onTap: () => _runAndClose(context, onCopy!),
                  ),
                if (onShare != null)
                  _SheetAction(
                    icon: Icons.share_rounded,
                    label: l10n.shareAyah,
                    onTap: () => _runAndClose(context, onShare!),
                  ),
              ],
            ),

            // ---- Sao chép từng phần ----
            if (arabicText != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.abc_rounded),
                title: Text(l10n.copyArabic),
                onTap: () => _copy(context, l10n, arabicText!),
              ),
            if (translationText != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate_rounded),
                title: Text(l10n.copyTranslation),
                onTap: () => _copy(context, l10n, translationText!),
              ),

            const SizedBox(height: 12),

            // ---- Tô màu 6 màu ----
            Text(l10n.ayahHighlightLabel, style: textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final name in kHighlightColorNames)
                  _ColorDot(
                    color: kHighlightColorValues[name]!,
                    colorName: name,
                    selected: annotation.highlightColors.contains(name),
                    onTap: () => repo.toggleHighlight(ayahId, name),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Trạng thái học ----
            Text(l10n.statusLabel, style: textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<AyahStatus>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AyahStatus.none,
                  label: Text(l10n.statusNone),
                ),
                ButtonSegment(
                  value: AyahStatus.learning,
                  label: Text(l10n.statusLearning),
                ),
                ButtonSegment(
                  value: AyahStatus.learned,
                  label: Text(l10n.statusLearned),
                ),
                ButtonSegment(
                  value: AyahStatus.review,
                  label: Text(l10n.statusReview),
                ),
              ],
              selected: {annotation.status},
              onSelectionChanged: (sel) => repo.setStatus(ayahId, sel.first),
            ),
            const SizedBox(height: 8),

            // ---- Ghi chú ----
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                annotation.note == null
                    ? Icons.note_add_outlined
                    : Icons.edit_note,
              ),
              title: Text(
                annotation.note == null ? l10n.addNote : l10n.editNote,
              ),
              subtitle: annotation.note == null
                  ? null
                  : Text(
                      annotation.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => _openNoteDialog(
                context,
                repo.saveNote,
                initial: annotation.note ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Đóng sheet TRƯỚC rồi mới chạy hành động — người dùng thấy mình
  /// quay lại trang đọc ngay, SnackBar (nếu có) hiện trên trang đọc
  /// chứ không bị sheet che.
  void _runAndClose(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  Future<void> _copy(
    BuildContext context,
    AppLocalizations l10n,
    String text,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: '$text\n— Qur\'an $surahId:$ayahNumber'),
    );
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

  Future<void> _openNoteDialog(
    BuildContext context,
    Future<void> Function(int, String) save, {
    required String initial,
  }) {
    // Controller phải sống qua cả animation đóng dialog -> để
    // _NoteDialog (StatefulWidget) tự sở hữu và dispose.
    return showDialog<void>(
      context: context,
      builder: (_) => _NoteDialog(
        initial: initial,
        onSave: (text) => save(ayahId, text),
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial, required this.onSave});

  final String initial;
  final Future<void> Function(String) onSave;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.noteLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 6,
        minLines: 3,
        decoration: InputDecoration(
          hintText: l10n.noteHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onSave(_controller.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Một ô thao tác nhanh trong sheet: vòng tròn icon + nhãn bên dưới.
///
/// Vùng chạm rộng (48px vòng tròn + padding) thay cho SwitchListTile
/// cũ; [selected] tô nền `secondaryContainer` để trạng thái bật/tắt
/// nhận ra được KHÔNG CHỈ bằng màu — icon cũng đổi (bookmark viền ->
/// bookmark đặc), đúng WCAG 1.4.1.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 88,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.secondaryContainer
                          : scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.colorName,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String colorName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: colorName,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    width: 3,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                : null,
          ),
          child: selected
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
