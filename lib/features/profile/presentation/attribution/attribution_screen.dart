import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../quran/domain/entities/attribution_entry.dart';
import 'attribution_providers.dart';

/// Màn hình Ghi nguồn (Sprint 33.0).
///
/// KHÔNG ÉP CỨNG NGUỒN NÀO. Mọi dòng chữ trên màn hình này hoặc là
/// nhãn đã bản địa hoá, hoặc là giá trị đọc từ database. Thêm một bản
/// dịch/Tafsir/Qari = thêm dữ liệu, màn hình tự có thêm mục — cùng
/// khế ước với trang đọc (`DR-2026-0006` D3).
///
/// Trước sprint này, phần "Nguồn dữ liệu" trong Hồ sơ là MỘT CHUỖI
/// TĨNH liệt kê bốn cái tên. Nó đã sai ngay khi Sprint 31.3 nhập bộ
/// Tafsir đầu tiên: Quran.com và hai bộ chú giải không hề được nhắc
/// tới, dù văn bản của họ đang hiển thị trong app.
class AttributionScreen extends ConsumerWidget {
  const AttributionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(attributionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attributionTitle)),
      body: data.when(
        loading: () => LoadingState(semanticsLabel: l10n.attributionTitle),
        error: (_, __) => _Message(l10n.attributionEmpty),
        data: (data) => _Body(data: data),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final AttributionData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (data.entries.isEmpty) return _Message(l10n.attributionEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          l10n.attributionIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        // Thứ tự nhóm lấy từ THỨ TỰ KHAI BÁO của enum, không phải một
        // danh sách viết tay song song có thể quên cập nhật khi thêm
        // loại nguồn mới.
        for (final kind in AttributionKind.values)
          ..._group(context, kind, [
            for (final entry in data.entries)
              if (entry.kind == kind) entry,
          ]),
        const Divider(height: 32),
        _DataBuildFooter(data: data),
      ],
    );
  }

  List<Widget> _group(
    BuildContext context,
    AttributionKind kind,
    List<AttributionEntry> entries,
  ) {
    if (entries.isEmpty) return const [];
    return [
      const SizedBox(height: 16),
      SectionHeader(text: _kindLabel(AppLocalizations.of(context), kind)),
      const SizedBox(height: 8),
      for (final entry in entries) _EntryCard(entry: entry),
    ];
  }
}

/// Nhãn nhóm — phép `switch` VÉT CẠN, nên thêm giá trị vào
/// [AttributionKind] mà quên nhãn sẽ không biên dịch được.
String _kindLabel(AppLocalizations l10n, AttributionKind kind) {
  return switch (kind) {
    AttributionKind.quranText => l10n.attributionKindQuranText,
    AttributionKind.transliteration => l10n.attributionKindTransliteration,
    AttributionKind.translation => l10n.attributionKindTranslation,
    AttributionKind.tafsir => l10n.attributionKindTafsir,
    AttributionKind.audio => l10n.attributionKindAudio,
  };
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final AttributionEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hướng chữ theo CHỮ VIẾT CỦA CHÍNH CHUỖI ĐÓ, không theo
            // ngôn ngữ của nguồn: tên bộ Tafsir tiếng Ả Rập phải đọc
            // đúng chiều kể cả khi giao diện đang là tiếng Việt, còn
            // tên Latin của một Qari đọc tiếng Ả Rập thì không.
            Text(
              entry.name,
              textDirection:
                  entry.isNameRtl ? TextDirection.rtl : TextDirection.ltr,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (entry.author != null && entry.author!.isNotEmpty)
              _Field(
                label: l10n.attributionAuthor,
                value: entry.author!,
                isRtl: entry.isAuthorRtl,
              ),
            if (entry.language != null)
              _Field(
                label: l10n.attributionLanguage,
                // Mã ISO 639-1 nguyên bản: bảng tra tên ngôn ngữ sẽ
                // lại là một danh sách ép cứng, và im lặng bỏ trống ở
                // ngôn ngữ thứ tư mà không ai thấy.
                value: entry.language!.toUpperCase(),
              ),
            if (entry.version != null && entry.version!.isNotEmpty)
              _Field(label: l10n.versionLabel, value: entry.version!),
            if (entry.updatedAt != null && entry.updatedAt!.isNotEmpty)
              _Field(label: l10n.attributionUpdated, value: entry.updatedAt!),
            if (entry.license != null && entry.license!.isNotEmpty)
              _Field(label: l10n.attributionLicense, value: entry.license!),
            if (entry.sourceUrl != null && entry.sourceUrl!.isNotEmpty)
              _SourceUrl(url: entry.sourceUrl!),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.isRtl = false});

  final String label;
  final String value;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: isRtl ? TextDirection.rtl : null,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Địa chỉ nguồn + nút sao chép.
///
/// HIỂN THỊ chứ không mở trình duyệt: mở liên kết ngoài cần
/// `url_launcher` (thêm phụ thuộc mới + khai báo `queries` trong
/// AndroidManifest). Điều khoản Tanzil đòi người dùng phải tới được
/// tanzil.net để theo dõi thay đổi — địa chỉ hiển thị đầy đủ, chọn
/// được và sao chép được đã đáp ứng điều đó. Nâng lên liên kết bấm
/// được là việc còn lại, đã xếp hạng trong báo cáo Sprint 33.0.
class _SourceUrl extends StatelessWidget {
  const _SourceUrl({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              l10n.attributionSourceUrl,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: SelectableText(
              url,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: l10n.attributionCopyUrl,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.attributionUrlCopied)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DataBuildFooter extends StatelessWidget {
  const _DataBuildFooter({required this.data});

  final AttributionData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final version = data.dataVersion;
    final builtAt = data.builtAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (version != null)
          _Field(
            label: l10n.attributionDataVersion,
            value: builtAt == null ? version : '$version · $builtAt',
          ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.gavel_outlined),
          title: Text(l10n.attributionSoftwareLicenses),
          subtitle: Text(l10n.attributionSoftwareLicensesDetail),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(context: context),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
