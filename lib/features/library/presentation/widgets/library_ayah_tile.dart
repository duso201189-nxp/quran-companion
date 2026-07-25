import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/card_shell.dart';
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

    // KHÔNG truyền semanticsLabel: thẻ này có widget con phải tự đọc
    // được (nút "sắp xếp vào bộ sưu tập", các chấm màu highlight), nên
    // không gộp cả thẻ thành một node như ResultCard.
    return CardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${ayah.surahNameLatin} · '
                  '${ayah.surahId}:${ayah.ayahNumber}',
                  style: cardSourceLabelStyle(textTheme, scheme),
                ),
              ),
              if (onOrganize != null)
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  tooltip: AppLocalizations.of(context).libraryOrganizeTooltip,
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
            style: quranTextStyle(
              fontSize: kPreviewArabicFontSize,
              color: scheme.onSurface,
            ),
          ),
          if (ayah.translation != null) ...[
            const SizedBox(height: 6),
            Text(
              ayah.translation!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: cardSecondaryTextStyle(textTheme, scheme),
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
                // Cùng `Semantics(label: colorName)` với `_ColorDot`
                // (ayah_actions_sheet.dart) — KHÔNG thêm `button:true`
                // ở đây vì các chấm này chỉ HIỂN THỊ màu đã tô, không
                // bấm được (không có onTap/InkWell, khác _ColorDot).
                for (final name in item.highlightColors)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Semantics(
                      label: name,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: kHighlightColorValues[name],
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
