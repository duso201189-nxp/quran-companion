import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../quran/domain/entities/surah.dart';
import '../../quran/presentation/surah_list_controller.dart'
    show surahListProvider;
import '../data/hifz_providers.dart';
import '../domain/hifz_range_input.dart';

/// Tạo kế hoạch Hifz mới — Sprint 7.7b-ii.
///
/// Người dùng nhập Surah + số Ayah 1-based (KHÔNG bao giờ nhập ordinal
/// toàn cục) — [HifzRangeInputValidator] kiểm trong phạm vi Surah đã
/// chọn RỒI quy đổi sang ordinal, đúng ranh giới
/// `HifzPlanRepository.createPlan` cần. `HifzPlanRepository` không
/// đổi — validate luôn chạy TRƯỚC khi gọi `createPlan`, không gọi khi
/// kiểm thất bại.
class HifzPlanFormScreen extends ConsumerStatefulWidget {
  const HifzPlanFormScreen({super.key});

  @override
  ConsumerState<HifzPlanFormScreen> createState() => _HifzPlanFormScreenState();
}

class _HifzPlanFormScreenState extends ConsumerState<HifzPlanFormScreen> {
  Surah? _surah;
  final _ayahFromController = TextEditingController();
  final _ayahToController = TextEditingController();

  String? _surahError;
  String? _ayahFromError;
  String? _ayahToError;
  bool _saving = false;

  @override
  void dispose() {
    _ayahFromController.dispose();
    _ayahToController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _surahError = null;
      _ayahFromError = null;
      _ayahToError = null;
    });

    final surah = _surah;
    if (surah == null) {
      setState(() => _surahError = l10n.hifzFormSurahRequired);
      return;
    }

    final ayahFrom = int.tryParse(_ayahFromController.text.trim());
    final ayahTo = int.tryParse(_ayahToController.text.trim());
    if (ayahFrom == null || ayahTo == null) {
      setState(() {
        if (ayahFrom == null) _ayahFromError = l10n.hifzFormAyahInvalidNumber;
        if (ayahTo == null) _ayahToError = l10n.hifzFormAyahInvalidNumber;
      });
      return;
    }

    final result = HifzRangeInputValidator.validate(
      surahId: surah.id,
      surahAyahCount: surah.ayahCount,
      ayahFrom: ayahFrom,
      ayahTo: ayahTo,
    );

    switch (result) {
      case HifzRangeInvalid(:final reason):
        setState(() {
          switch (reason) {
            case HifzRangeInvalidReason.ayahFromBelowOne:
              _ayahFromError = l10n.hifzFormAyahFromBelowOne;
            case HifzRangeInvalidReason.ayahToAboveSurahCount:
              _ayahToError =
                  l10n.hifzFormAyahToAboveSurahCount(surah.ayahCount);
            case HifzRangeInvalidReason.ayahFromAfterAyahTo:
              _ayahFromError = l10n.hifzFormAyahFromAfterAyahTo;
          }
        });
        return;
      case HifzRangeValid(:final ayahFromOrdinal, :final ayahToOrdinal):
        setState(() => _saving = true);
        await ref.read(hifzPlanRepositoryProvider).createPlan(
              ayahFrom: ayahFromOrdinal,
              ayahTo: ayahToOrdinal,
            );
        if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hifzPlanCreate)),
      body: SafeArea(
        child: surahsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.errorLoadData, textAlign: TextAlign.center),
            ),
          ),
          data: (surahs) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Surah>(
                  initialValue: _surah,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.hifzFormSurahLabel,
                    hintText: l10n.hifzFormSurahHint,
                    errorText: _surahError,
                  ),
                  items: [
                    for (final s in surahs)
                      DropdownMenuItem(
                        value: s,
                        child: Text('${s.id}. ${s.nameLatin}'),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _surah = value;
                    _surahError = null;
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ayahFromController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.hifzFormAyahFromLabel,
                    errorText: _ayahFromError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ayahToController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.hifzFormAyahToLabel,
                    errorText: _ayahToError,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
