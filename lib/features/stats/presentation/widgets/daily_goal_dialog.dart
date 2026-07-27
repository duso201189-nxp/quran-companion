import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/daily_goal_store.dart';

/// Dialog đặt chỉ tiêu đọc hằng ngày — 2 ô số (phút/ngày, Ayah/ngày),
/// tự lưu qua [DailyGoalStore] khi Lưu. Không có route riêng (DR-
/// 2026-0004 mục 2: chỉ dialog).
class DailyGoalDialog extends ConsumerStatefulWidget {
  const DailyGoalDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DailyGoalDialog(),
    );
  }

  @override
  ConsumerState<DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends ConsumerState<DailyGoalDialog> {
  late final _minutesController = TextEditingController(
    text: ref.read(dailyGoalStoreProvider).minutesPerDay?.toString() ?? '',
  );
  late final _ayahsController = TextEditingController(
    text: ref.read(dailyGoalStoreProvider).ayahsPerDay?.toString() ?? '',
  );

  @override
  void dispose() {
    _minutesController.dispose();
    _ayahsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(dailyGoalStoreProvider.notifier).setTarget(
          minutesPerDay: int.tryParse(_minutesController.text.trim()),
          ayahsPerDay: int.tryParse(_ayahsController.text.trim()),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profileGoal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minutesController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l10n.dailyGoalMinutesHint),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ayahsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l10n.dailyGoalAyahsHint),
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
