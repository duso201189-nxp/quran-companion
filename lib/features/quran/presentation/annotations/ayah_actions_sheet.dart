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

/// Sheet thao tác một Ayah (mở bằng nhấn giữ): bookmark, highlight
/// 6 màu, trạng thái học, ghi chú. Watch provider -> phản ánh
/// realtime ngay khi bấm.
class AyahActionsSheet extends ConsumerWidget {
  const AyahActionsSheet({
    super.key,
    required this.surahId,
    required this.ayahId,
    required this.ayahNumber,
    this.arabicText,
    this.translationText,
  });

  final int surahId;
  final int ayahId;
  final int ayahNumber;

  /// Văn bản để Sao chép chữ Ả Rập (null = ẩn hành động).
  final String? arabicText;

  /// Văn bản để Sao chép bản dịch (null = ẩn hành động).
  final String? translationText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(userContentRepositoryProvider);
    final annotation =
        ref.watch(ayahAnnotationsProvider(surahId)).valueOrNull?[ayahId] ??
            AyahAnnotation.empty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.ayahSemanticLabel(ayahNumber)} — $surahId:$ayahNumber',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // ---- Bookmark + Yêu thích (1 chạm) ----
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                annotation.bookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              title: Text(l10n.bookmarkLabel),
              value: annotation.bookmarked,
              onChanged: (_) => repo.toggleBookmark(ayahId),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                annotation.favorited ? Icons.favorite : Icons.favorite_border,
              ),
              title: Text(l10n.favoriteLabel),
              value: annotation.favorited,
              onChanged: (_) => repo.toggleFavorite(ayahId),
            ),

            // ---- Sao chép nhanh ----
            if (arabicText != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.copy_rounded),
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

            // ---- Highlight 6 màu ----
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  for (final name in kHighlightColorNames)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _ColorDot(
                        color: kHighlightColorValues[name]!,
                        colorName: name,
                        selected: annotation.highlightColors.contains(name),
                        onTap: () => repo.toggleHighlight(ayahId, name),
                      ),
                    ),
                ],
              ),
            ),

            // ---- Trạng thái học ----
            Text(
              l10n.statusLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
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
