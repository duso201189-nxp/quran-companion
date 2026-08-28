import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
/// Thống kê (`DailyGoalCard`, đặt ở đó từ Sprint 6.3 — cùng widget
/// dùng chung với Trang chủ, xem `stats/presentation/widgets/
/// daily_goal_card.dart`).
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
            subtitle: _SourcesAttribution(text: l10n.aboutSourcesDetail),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: _PrivacyPolicyLink(label: l10n.privacyPolicy),
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

/// Mở một đích NGOÀI cố định bằng `url_launcher` — cơ chế duy nhất của
/// app cho liên kết ngoài (dựng từ Session 134 cho liên kết Tanzil).
///
/// Đích luôn là hằng số biên dịch trong file này, KHÔNG bao giờ dựng từ
/// input người dùng. Nuốt lỗi thay vì crash: `launchUrl` ném
/// PlatformException (hoặc lỗi tuỳ nền tảng) khi máy không có handler
/// nào mở được https.
Future<void> _launchExternal(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Không có trình duyệt/handler để mở — im lặng bỏ qua, không crash.
  }
}

/// Dòng "Nguồn dữ liệu" — giữ nguyên câu đã dịch (vi/en/ar) nhưng biến
/// đoạn "Tanzil.net" thành liên kết chạm được, mở https://tanzil.net.
///
/// Giấy phép văn bản Ả Rập của Tanzil yêu cầu liên kết tới tanzil.net
/// để người dùng theo dõi thay đổi bản gốc (Session 133). Chuỗi dịch ở
/// cả 3 ngôn ngữ đều giữ nguyên "Tanzil.net" không dịch, nên tách theo
/// chuỗi con này là an toàn — không cần đổi cấu trúc ARB hay dịch mới.
class _SourcesAttribution extends StatefulWidget {
  const _SourcesAttribution({required this.text});

  final String text;

  @override
  State<_SourcesAttribution> createState() => _SourcesAttributionState();
}

class _SourcesAttributionState extends State<_SourcesAttribution> {
  static const _tanzilLabel = 'Tanzil.net';
  static final Uri _tanzilUri = Uri.parse('https://tanzil.net');

  late final TapGestureRecognizer _tanzilRecognizer;

  @override
  void initState() {
    super.initState();
    _tanzilRecognizer = TapGestureRecognizer()..onTap = _openTanzil;
  }

  @override
  void dispose() {
    _tanzilRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openTanzil() => _launchExternal(_tanzilUri);

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final index = text.indexOf(_tanzilLabel);
    if (index < 0) {
      // An toàn dự phòng: nếu bản dịch tương lai đổi cách viết
      // "Tanzil.net", hiển thị nguyên câu thay vì vỡ layout/crash.
      return Text(text);
    }
    final before = text.substring(0, index);
    final after = text.substring(index + _tanzilLabel.length);
    final linkColor = Theme.of(context).colorScheme.primary;

    return Text.rich(
      TextSpan(
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          TextSpan(
            text: _tanzilLabel,
            recognizer: _tanzilRecognizer,
            style: TextStyle(
              color: linkColor,
              decoration: TextDecoration.underline,
            ),
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }
}

/// Liên kết "Chính sách quyền riêng tư" trong mục Giới thiệu.
///
/// Chính sách đã công bố công khai (Session 137) phải truy cập được từ
/// BÊN TRONG app, không chỉ từ trang cửa hàng — xem
/// `docs/release/V1_STORE_LEGAL_READINESS.md`. Đây là phần hiện thực kỹ
/// thuật của yêu cầu đó; nó KHÔNG phải kết luận pháp lý về nội dung
/// chính sách (khâu rà soát pháp lý vẫn đang mở).
///
/// Dùng lại đúng khuôn TextSpan + [TapGestureRecognizer] của liên kết
/// Tanzil: `RenderParagraph` tự phát ra MỘT node semantics con mang cờ
/// `isLink` kèm hành động tap, nên không bọc thêm `Semantics` (bọc thêm
/// sẽ sinh node trùng, TalkBack/VoiceOver đọc lặp).
class _PrivacyPolicyLink extends StatefulWidget {
  const _PrivacyPolicyLink({required this.label});

  /// Nhãn đã dịch (`l10n.privacyPolicy`) — không hard-code chuỗi hiển thị.
  final String label;

  @override
  State<_PrivacyPolicyLink> createState() => _PrivacyPolicyLinkState();
}

class _PrivacyPolicyLinkState extends State<_PrivacyPolicyLink> {
  /// URL chuẩn tắc của chính sách đã công bố (hiệu lực 27/08/2026).
  /// Hằng số cố định, không ghép chuỗi, không nhận từ input.
  static final Uri _privacyPolicyUri = Uri.parse(
    'https://duso201189-nxp.github.io/quran-companion/privacy/',
  );

  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()
      ..onTap = () => _launchExternal(_privacyPolicyUri);
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: widget.label,
        recognizer: _recognizer,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
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
