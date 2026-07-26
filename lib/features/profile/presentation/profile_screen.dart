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
/// Hồ sơ cá nhân và đồng bộ đám mây chưa có trong bản này; mục
/// tiêu hằng ngày đã chạy nhưng cố định, chưa đặt được.
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
          // RC-1 — ba ô này trước đây ghi "Sẽ xây dựng ở Bước 10 / 8 /
          // 11". "Bước N" là từ vựng NỘI BỘ của ROADMAP.md, vô nghĩa
          // với người dùng, và ô giữa còn sai: mục tiêu hằng ngày ĐÃ
          // tồn tại và đang chạy — chỉ là cố định, không đặt được.
          //
          // Giờ mỗi ô nói đúng trạng thái hôm nay. Hai ô chưa có thì
          // nói thẳng là chưa có, không hẹn phiên bản nào.
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(l10n.profileGoal),
            subtitle: Text(l10n.profileGoalFixed),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profilePersonalInfo),
            subtitle: Text(l10n.profileNotAvailableYet),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(l10n.profileSync),
            subtitle: Text(l10n.profileSyncNotAvailable),
            enabled: false,
          ),
          const Divider(height: 32),
          _SectionLabel(l10n.sectionAbout),
          // Sprint 33.0 — trước đây đây là một dòng chữ TĨNH liệt kê
          // bốn cái tên nguồn. Nó đã lỗi thời ngay khi Sprint 31.3
          // nhập bộ Tafsir đầu tiên. Giờ nó dẫn sang màn hình đọc
          // metadata thật, nên không thể lệch với dữ liệu được nữa.
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: Text(l10n.aboutSources),
            subtitle: Text(l10n.aboutSourcesDetail),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.attribution),
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
