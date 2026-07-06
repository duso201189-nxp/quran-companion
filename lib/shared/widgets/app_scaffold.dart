import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Khung điều hướng chính, tự thích ứng theo kích thước màn hình:
///
/// - < 800px  (điện thoại)        : NavigationBar dưới đáy
/// - 800–1099px (tablet dọc)      : NavigationRail thu gọn bên trái
/// - >= 1100px (tablet ngang, web): NavigationRail mở rộng
///
/// Ngưỡng theo khuyến nghị breakpoint của Material 3.
/// Nhãn tab lấy từ AppLocalizations — không hard-code chuỗi.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double railBreakpoint = 800;
  static const double extendedRailBreakpoint = 1100;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      // Tap lại tab đang mở -> quay về màn hình gốc của tab đó.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<({IconData icon, IconData selectedIcon, String label})> _destinations(
    AppLocalizations l10n,
  ) {
    return [
      (
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.tabHome,
      ),
      (
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book,
        label: l10n.tabQuran,
      ),
      (
        icon: Icons.style_outlined,
        selectedIcon: Icons.style,
        label: l10n.tabStudy,
      ),
      (
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: l10n.tabStats,
      ),
      (
        icon: Icons.person_outlined,
        selectedIcon: Icons.person,
        label: l10n.tabProfile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(AppLocalizations.of(context));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < railBreakpoint) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        final extended = width >= extendedRailBreakpoint;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                extended: extended,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                useIndicator: true,
                minWidth: 76,
                minExtendedWidth: 220,
                groupAlignment: -0.9,
                leading: const SizedBox(height: 8),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}
