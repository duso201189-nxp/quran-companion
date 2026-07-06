import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Theme trung tâm của ứng dụng — Material Design 3.
///
/// Màu chủ đạo: xanh lá (#1B7A43) trên nền trắng / nền tối.
/// Mọi màn hình lấy màu từ [ColorScheme], KHÔNG hard-code màu
/// trong widget — để Dark Mode và màu tùy chỉnh sau này
/// hoạt động tự động.
///
/// Chữ: Inter cho toàn bộ UI Latin (đủ dấu tiếng Việt);
/// văn bản Qur'an dùng UthmanicHafs, tiêu đề Ả Rập dùng
/// NotoNaskhArabic/Amiri (khai báo tại chỗ hiển thị).
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF1B7A43);

  /// Font chữ Latin của toàn ứng dụng.
  static const String latinFont = 'Inter';

  /// Font văn bản Qur'an (Mushaf Madinah — KFGQPC HAFS).
  static const String quranFont = 'UthmanicHafs';

  /// Font tiêu đề Ả Rập (tên Surah...).
  static const String arabicTitleFont = 'NotoNaskhArabic';
  static const List<String> arabicTitleFallback = ['Amiri'];
  static const List<String> quranFontFallback = [
    'Amiri',
    'Scheherazade New',
  ];

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: latinFont,
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: latinFont,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: scheme.onSurface,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          fontFamily: latinFont,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: scheme.onSurface,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: latinFont,
          fontSize: 13,
          color: scheme.onSurfaceVariant,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: isDark ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          scheme.surfaceContainerHigh,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontFamily: latinFont,
          fontSize: 12,
          color: scheme.onInverseSurface,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chuyển trang mượt, đồng nhất trên mọi nền tảng.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Cỡ chữ Qur'an theo bề rộng màn hình (chuẩn thiết kế):
/// desktop ≥ 1100 → 36, tablet ≥ 800 → 34, mobile → 30.
double quranBaseFontSize(double width) {
  if (width >= 1100) return 36;
  if (width >= 800) return 34;
  return 30;
}

/// Style văn bản Qur'an dùng chung mọi nơi hiển thị chữ Ả Rập
/// của Mushaf — đảm bảo đồng nhất tuyệt đối.
TextStyle quranTextStyle({
  required double fontSize,
  required Color color,
  double height = 2.0,
}) {
  return TextStyle(
    fontFamily: AppTheme.quranFont,
    fontFamilyFallback: AppTheme.quranFontFallback,
    fontSize: fontSize,
    height: height,
    // Chia đều khoảng dòng trên/dưới: tashkeel cao (fathatan, dấu
    // madd...) không bị cắt ở mép trên của dòng đầu.
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w400,
    color: color,
  );
}

/// Style tiêu đề Ả Rập (tên Surah) — Naskh trang trọng.
TextStyle arabicTitleStyle({
  required double fontSize,
  required Color color,
  FontWeight weight = FontWeight.w700,
}) {
  return TextStyle(
    fontFamily: AppTheme.arabicTitleFont,
    fontFamilyFallback: AppTheme.arabicTitleFallback,
    fontSize: fontSize,
    height: 1.6,
    fontWeight: weight,
    color: color,
  );
}
