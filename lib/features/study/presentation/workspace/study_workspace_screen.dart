import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/full_empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../search/presentation/widgets/search_error_state.dart';
import 'study_workspace_controller.dart';
import 'study_workspace_shell.dart';

/// Study Workspace — bề mặt NGHIÊN CỨU SÂU cho MỘT Ayah
/// (`DR-2026-0007` D1).
///
/// Sprint 31.1 dựng ĐÚNG bộ khung: route + màn hình + vỏ + hợp đồng
/// mục + lối vào. Chưa có tính năng học nào, nên [StudyWorkspaceShell]
/// hiện chưa dựng gì — màn hình chỉ hiển thị CHỦ THỂ đang nghiên cứu.
/// Đó là dữ liệu thật (không phải nội dung giữ chỗ) và cũng là bằng
/// chứng chạy được cho luồng dữ liệu: trang đọc chỉ đưa `ayahId`, còn
/// Study tự nạp phần của mình.
///
/// TÊN: `StudyWorkspaceScreen`, không phải `StudyScreen` — cái tên đó
/// đã thuộc về tab Học (`features/study/presentation/study_screen.dart`,
/// bảng sáu công cụ học). Xem phần "deviation" của báo cáo Sprint 31.1.
class StudyWorkspaceScreen extends ConsumerWidget {
  const StudyWorkspaceScreen({super.key, required this.ayahId});

  /// Số hiệu Ayah toàn cục 1..6236 — khoá mà mọi bảng dữ liệu người
  /// dùng đã dùng, nên deep link không cần bước quy đổi nào.
  final int ayahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ayah = ref.watch(studyAyahProvider(ayahId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ayah.valueOrNull == null
              ? l10n.studyWorkspaceTitle
              : '${ayah.value!.surahNameLatin} '
                  '${ayah.value!.surahId}:${ayah.value!.ayahNumber}',
        ),
      ),
      body: ayah.when(
        loading: () => LoadingState(semanticsLabel: l10n.studyWorkspaceTitle),
        error: (_, __) => SearchErrorState(
          onRetry: () => ref.invalidate(studyAyahProvider(ayahId)),
        ),
        data: (data) {
          // Deep link tới id không tồn tại (1..6236) -> trạng thái rỗng
          // tử tế thay vì màn hình trắng hoặc crash.
          if (data == null) {
            return FullEmptyState(
              icon: Icons.search_off_outlined,
              message: l10n.emptySearchResults,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  data.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: quranTextStyle(
                    fontSize: kPreviewArabicFontSize,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                // Các mục học sẽ xuất hiện ở đây khi được đăng ký —
                // màn hình này không cần sửa gì khi đó.
                StudyWorkspaceShell(ayahId: ayahId),
              ],
            ),
          );
        },
      ),
    );
  }
}
