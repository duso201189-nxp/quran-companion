import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../../../quran/data/quran_providers.dart';
import '../../../../quran/domain/entities/translation_source.dart';
import '../../../../search/presentation/widgets/search_error_state.dart';
import '../study_panel.dart';
import '../study_section.dart';

/// Một mục Tafsir đã ghép nguồn với văn bản của đúng Ayah đang mở.
typedef TafsirEntry = ({TranslationSource source, String text});

/// Chú giải của MỘT Ayah.
///
/// `autoDispose.family` theo `ayahId` (`DR-2026-0007` D4): mở Ayah nào
/// nạp đúng Ayah đó, rời workspace là giải phóng. Không cache toàn
/// cục, không singleton.
///
/// Nếu bộ dữ liệu chưa có nguồn Tafsir nào (tình trạng hiện tại), hàm
/// thoát SỚM và KHÔNG chạm database — mở Study không tốn truy vấn nào.
final tafsirForAyahProvider =
    FutureProvider.autoDispose.family<List<TafsirEntry>, int>(
  (ref, ayahId) async {
    final sources = await ref.watch(tafsirSourcesProvider.future);
    if (sources.isEmpty) return const [];

    // Dùng LẠI `QuranRepository` — không có `TafsirRepository`
    // (`DR-2026-0006` D5). Chỉ MỘT Ayah, chỉ loại `tafsir`.
    final texts = await ref.watch(quranRepositoryProvider).getAyahTexts(
      ayahId: ayahId,
      types: const {SourceType.tafsir},
    );

    return <TafsirEntry>[
      for (final source in sources)
        if (texts[source.code] case final text?) (source: source, text: text),
    ]..sort((a, b) => a.source.displayOrder.compareTo(b.source.displayOrder));
  },
);

/// Mục Tafsir của Study Workspace — BẢN MẪU cho mọi mục sau này.
///
/// Toàn bộ những gì một mục cần: một giá trị [StudySection] + một
/// provider `autoDispose.family` + một widget. Không có "hệ thống
/// panel" riêng, không sửa vỏ, không sửa trang đọc.
final StudySection tafsirSection = StudySection(
  id: 'tafsir',
  builder: (context, ayahId) => _TafsirPanel(ayahId: ayahId),
);

class _TafsirPanel extends ConsumerWidget {
  const _TafsirPanel({required this.ayahId});

  final int ayahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Chưa có nguồn Tafsir nào -> mục KHÔNG tồn tại trên màn hình:
    // không tiêu đề, không khung chờ, không khoảng trống.
    final sources =
        ref.watch(tafsirSourcesProvider.select((value) => value.valueOrNull));
    if (sources == null || sources.isEmpty) return const SizedBox.shrink();

    final entries = ref.watch(tafsirForAyahProvider(ayahId));

    return entries.when(
      loading: () => StudyPanel(
        title: l10n.studyTafsirTitle,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => StudyPanel(
        title: l10n.studyTafsirTitle,
        child: SearchErrorState(
          onRetry: () => ref.invalidate(tafsirForAyahProvider(ayahId)),
        ),
      ),
      data: (list) {
        // Có nguồn Tafsir nhưng Ayah này chưa có chú giải -> vẫn ẩn
        // hẳn mục, không hiện "chưa có nội dung".
        if (list.isEmpty) return const SizedBox.shrink();

        return StudyPanel(
          title: l10n.studyTafsirTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in list)
                _TafsirEntryView(
                  key: ValueKey(entry.source.code),
                  entry: entry,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// MỘT nguồn Tafsir, dựng độc lập với các nguồn khác.
class _TafsirEntryView extends StatelessWidget {
  const _TafsirEntryView({super.key, required this.entry});

  final TafsirEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tên nguồn lấy từ DỮ LIỆU — nguồn thứ hai, thứ mười đều tự
          // có nhãn, không cần khoá l10n mới.
          Text(
            entry.source.name,
            style: textTheme.labelMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            entry.text,
            // Hướng chữ suy ra từ NGÔN NGỮ của nguồn (Sprint 30.1):
            // Tafsir tiếng Ả Rập hiển thị RTL mà không cần cấu hình.
            textDirection:
                entry.source.isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: entry.source.isRtl ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: AppTheme.latinFont,
              fontSize: 15,
              // Giãn dòng rộng hơn bản dịch: chú giải là đoạn dài.
              height: 1.75,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
