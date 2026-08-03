import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/locale/locale_controller.dart';
import '../../../app/router.dart';
import '../../../app/theme/theme_controller.dart';

/// Phiên bản app — đọc từ metadata build (pubspec.yaml), không
/// hard-code, để nhãn hiển thị luôn khớp bản thật đang chạy.
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Màn hình Hồ sơ.
///
/// Hiện có: đổi giao diện (Sáng/Hệ thống/Tối) và ngôn ngữ (vi/en/ar).
/// Hồ sơ cá nhân, đồng bộ: chưa xây — nhãn dùng [AppLocalizations.comingSoon]
/// chung (Sprint R3b.1), KHÔNG còn lộ số bước nội bộ ra người dùng (xem
/// `docs/release/PRODUCT_READINESS_REVIEW.md` — `CLAUDE.md` đã tuyên bố
/// đánh số "Bước N/12" không còn là chỉ báo trạng thái từ Sprint 10).
///
/// Mục tiêu học (trước đây gắn nhãn sai "Coming in Step 8") ĐÃ xây và
/// đang chạy thật — xem `lib/features/stats/data/daily_goal_providers.dart`
/// — nên ô này bị GỠ khỏi màn hình thay vì đổi nhãn: đổi thành "Sắp ra
/// mắt" vẫn sẽ là một câu sai, chỉ đổi loại sai. Vào mục tiêu qua màn
/// Thống kê (widget goal đã có ở đó).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SectionLabel(l10n.sectionAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(themeControllerProvider.notifier)
                    .setMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.sectionLanguage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'vi',
                  label: Text(l10n.languageVietnamese),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(l10n.languageEnglish),
                ),
                ButtonSegment(
                  value: 'ar',
                  label: Text(l10n.languageArabic),
                ),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (selection) {
                ref
                    .read(localeControllerProvider.notifier)
                    .setLanguage(selection.first);
              },
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.collections_bookmark_outlined),
            title: Text(l10n.libraryTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.library),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profilePersonalInfo),
            subtitle: Text(l10n.comingSoon),
            enabled: false,
          ),
          // "Mục tiêu" (Goal) ĐÃ GỠ (Sprint R3b.1) — Daily Goal đã xây
          // và đang chạy thật (daily_goal_providers.dart/daily_goal_store
          // .dart/daily_goal_dialog.dart), nên tile "Coming in Step 8"
          // ở đây là SAI, không phải chưa xây. Vào mục tiêu qua Thống kê.
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(l10n.profileSync),
            subtitle: Text(l10n.comingSoon),
            enabled: false,
          ),
          const Divider(height: 32),
          _SectionLabel(l10n.sectionAbout),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: Text(l10n.aboutSources),
            subtitle: Text(l10n.aboutSourcesDetail),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.versionLabel),
            subtitle: Text(
              packageInfo.when(
                data: (info) => '${info.version}+${info.buildNumber}',
                loading: () => '…',
                error: (_, __) => '—',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
