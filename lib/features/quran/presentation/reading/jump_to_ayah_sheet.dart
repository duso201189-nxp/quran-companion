import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../shared/widgets/loading_state.dart';
import '../../../search/presentation/widgets/search_error_state.dart';
import '../../domain/entities/surah.dart';
import '../surah_list_controller.dart';

/// Đích "Chuyển tới Ayah" người dùng đã chọn — record, cùng kiểu đã
/// dùng cho `SurahReading` (reading_controller.dart), không dựng thêm
/// lớp dữ liệu mới cho 2 số nguyên.
typedef JumpTarget = ({int surahId, int ayahNumber});

/// Sheet "Chuyển tới Ayah" (Sprint 25.1).
///
/// CHỈ chọn đích — KHÔNG tự cuộn, KHÔNG tự điều hướng, KHÔNG ghi vị
/// trí đọc: trả [JumpTarget] về cho nơi gọi (`ReadingScreen`) quyết
/// định, vì chỉ nơi đó nắm `ItemScrollController` của danh sách đang
/// hiển thị. Giữ sheet thuần trình bày đúng như các sheet hiện có.
///
/// Dùng LẠI [surahListProvider] (surah_list_controller.dart) làm nguồn
/// 114 Surah — KHÔNG thêm provider mới cho danh sách đã tồn tại. Đây
/// cũng là lý do sheet là `ConsumerStatefulWidget` chứ không nhận sẵn
/// danh sách qua tham số: đúng mẫu `AyahActionsSheet`/`MoveToDeckSheet`
/// (sheet tự đọc provider nó cần).
class JumpToAyahSheet extends ConsumerStatefulWidget {
  const JumpToAyahSheet({super.key, required this.currentSurah});

  /// Surah đang đọc — chọn sẵn trong bộ chọn, vì phần lớn lượt dùng là
  /// nhảy trong CÙNG Surah: người dùng chỉ cần gõ số câu rồi xác nhận.
  final Surah currentSurah;

  /// Mở sheet; trả về đích đã chọn, hoặc null nếu người dùng đóng lại.
  static Future<JumpTarget?> show(
    BuildContext context, {
    required Surah currentSurah,
  }) {
    return showModalBottomSheet<JumpTarget>(
      context: context,
      showDragHandle: true,
      // Bàn phím số chiếm nửa màn hình -> sheet phải cuộn/đẩy được.
      isScrollControlled: true,
      builder: (_) => JumpToAyahSheet(currentSurah: currentSurah),
    );
  }

  @override
  ConsumerState<JumpToAyahSheet> createState() => _JumpToAyahSheetState();
}

class _JumpToAyahSheetState extends ConsumerState<JumpToAyahSheet> {
  late Surah _surah = widget.currentSurah;
  final TextEditingController _ayahController = TextEditingController();

  @override
  void dispose() {
    _ayahController.dispose();
    super.dispose();
  }

  /// Số câu hợp lệ trong Surah đang chọn, hoặc null nếu ngoài phạm vi.
  int? _validAyahNumber(String raw) {
    final number = int.tryParse(raw.trim());
    if (number == null || number < 1 || number > _surah.ayahCount) return null;
    return number;
  }

  void _submit() {
    final number = _validAyahNumber(_ayahController.text);
    if (number == null) return;
    Navigator.of(context).pop((surahId: _surah.id, ayahNumber: number));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        // Đẩy nội dung lên trên bàn phím thay vì để bàn phím che ô nhập.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.jumpToAyahTitle,
                  style: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 20),
              _buildSurahPicker(l10n),
              const SizedBox(height: 16),
              TextField(
                controller: _ayahController,
                // Việc chính của sheet là gõ số câu -> sẵn sàng gõ ngay.
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.jumpToAyahNumberLabel,
                  // Phạm vi hợp lệ hiện sẵn — không đợi người dùng gõ sai
                  // rồi mới bật chữ đỏ (giữ sheet tĩnh lặng, không nhấp
                  // nháy theo từng phím).
                  helperText: l10n.jumpToAyahRange(_surah.ayahCount),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // ValueListenableBuilder: mỗi phím gõ CHỈ dựng lại đúng nút
              // xác nhận, không dựng lại cả sheet (và không dựng lại danh
              // sách 114 mục của bộ chọn Surah).
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _ayahController,
                child: Text(l10n.jumpToAyahAction),
                builder: (context, value, child) {
                  final enabled = _validAyahNumber(value.text) != null;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: enabled ? _submit : null,
                      child: child,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahPicker(AppLocalizations l10n) {
    return ref.watch(surahListProvider).when(
          // Chiều cao xấp xỉ một ô nhập -> bố cục không giật khi tải xong.
          loading: () => LoadingState(
            semanticsLabel: l10n.surahListLoading,
            height: 56,
          ),
          // Vẫn giữ được ô số câu bên dưới: hỏng danh sách Surah không
          // chặn việc nhảy trong CHÍNH Surah đang đọc.
          error: (_, __) => SearchErrorState(
            onRetry: () => ref.invalidate(surahListProvider),
          ),
          data: (surahs) => DropdownMenu<int>(
            initialSelection: _surah.id,
            // Chiếm trọn bề ngang sheet, canh thẳng với ô số câu.
            expandedInsets: EdgeInsets.zero,
            // 114 Surah -> gõ để lọc nhanh hơn cuộn.
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 320,
            label: Text(l10n.jumpToAyahSurahLabel),
            dropdownMenuEntries: [
              for (final surah in surahs)
                DropdownMenuEntry<int>(
                  value: surah.id,
                  label: '${surah.id}. ${surah.nameLatin}',
                ),
            ],
            onSelected: (id) {
              if (id == null) return;
              setState(() {
                _surah = surahs.firstWhere((surah) => surah.id == id);
              });
            },
          ),
        );
  }
}
