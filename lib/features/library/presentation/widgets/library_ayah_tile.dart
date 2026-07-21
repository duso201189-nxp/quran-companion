import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../quran/presentation/annotations/ayah_actions_sheet.dart'
    show kHighlightColorValues;
import '../../domain/library_item.dart';

/// Một dòng trong "Thư viện của tôi": header Ayah + văn bản Ả Rập +
/// bản dịch, kèm ghi chú (nhóm Notes) hoặc chấm màu (nhóm Highlights).
/// Chạm để nhảy tới đúng Ayah.
class LibraryAyahTile extends StatelessWidget {
  const LibraryAyahTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onOrganize,
  });

  final LibraryItem item;
  final VoidCallback onTap;

  /// Sắp xếp vào bộ sưu tập (Sprint 8, DR-2026-0003 mục C) — null =
  /// ẩn nút, chỉ tab Bookmarks truyền giá trị này.
  final VoidCallback? onOrganize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ayah = item.ayah;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ayah.surahNameLatin} · '
                        '${ayah.surahId}:${ayah.ayahNumber}',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    if (onOrganize != null)
                      IconButton(
                        icon: const Icon(Icons.create_new_folder_outlined),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        tooltip:
                            AppLocalizations.of(context).libraryOrganizeTooltip,
                        onPressed: onOrganize,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ayah.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: quranTextStyle(fontSize: 22, color: scheme.onSurface),
                ),
                if (ayah.translation != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    ayah.translation!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (item.note != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.note!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ),
                ],
                if (item.highlightColors.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final name in item.highlightColors)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: kHighlightColorValues[name],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
