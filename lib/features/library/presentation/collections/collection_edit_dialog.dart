import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Dialog dùng chung cho tạo mới / đổi tên bộ sưu tập — tên (bắt
/// buộc) + emoji (tùy chọn). Trả về (name, emoji) qua
/// Navigator.pop, hoặc null nếu hủy.
class CollectionEditDialog extends StatefulWidget {
  const CollectionEditDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.initialEmoji,
  });

  final String title;
  final String initialName;
  final String? initialEmoji;

  static Future<(String name, String? emoji)?> show(
    BuildContext context, {
    required String title,
    String initialName = '',
    String? initialEmoji,
  }) {
    return showDialog<(String, String?)>(
      context: context,
      builder: (_) => CollectionEditDialog(
        title: title,
        initialName: initialName,
        initialEmoji: initialEmoji,
      ),
    );
  }

  @override
  State<CollectionEditDialog> createState() => _CollectionEditDialogState();
}

class _CollectionEditDialogState extends State<CollectionEditDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _emojiController =
      TextEditingController(text: widget.initialEmoji ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final emoji = _emojiController.text.trim();
    Navigator.of(context).pop((name, emoji.isEmpty ? null : emoji));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.collectionNameHint),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emojiController,
            decoration: InputDecoration(hintText: l10n.collectionEmojiHint),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
