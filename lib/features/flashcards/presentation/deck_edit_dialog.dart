import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Dialog dùng chung tạo mới / đổi tên deck Flashcard — chỉ tên (bắt
/// buộc), khác CollectionEditDialog (Bookmark có thêm emoji):
/// FlashcardDeck không có trường emoji (xem
/// lib/features/flashcards/domain/entities/flashcard_deck.dart —
/// không thêm trường mới ngoài phạm vi phase này). Trả về tên qua
/// Navigator.pop, hoặc null nếu hủy.
class DeckEditDialog extends StatefulWidget {
  const DeckEditDialog({
    super.key,
    required this.title,
    this.initialName = '',
  });

  final String title;
  final String initialName;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String initialName = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => DeckEditDialog(title: title, initialName: initialName),
    );
  }

  @override
  State<DeckEditDialog> createState() => _DeckEditDialogState();
}

class _DeckEditDialogState extends State<DeckEditDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.flashcardDeckNameHint),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
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
