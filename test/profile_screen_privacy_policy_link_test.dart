import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/profile/presentation/profile_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// URL chuẩn tắc của Chính sách quyền riêng tư đã công bố. Viết lại
/// nguyên văn ở đây (không import hằng số từ app) để test gãy nếu ai đó
/// sửa URL trong code — chính URL này là thứ cần được bảo vệ.
const _canonicalPrivacyUrl =
    'https://duso201189-nxp.github.io/quran-companion/privacy/';

/// Nhãn liên kết theo từng locale — khớp khoá `privacyPolicy` trong ARB.
const _privacyLabels = <String, String>{
  'en': 'Privacy Policy',
  'vi': 'Chính sách quyền riêng tư',
  'ar': 'سياسة الخصوصية',
};

/// Fake nền tảng url_launcher — dùng lại đúng mẫu của test liên kết
/// Tanzil (`test/profile_screen_tanzil_link_test.dart`): thay
/// [UrlLauncherPlatform.instance], không dựng thêm lớp trừu tượng mới.
class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}

Widget _app(SharedPreferences sp, {String language = 'en'}) {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/library',
        builder: (_, __) => const Scaffold(body: Text('LIBRARY')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    child: MaterialApp.router(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Phóng to khung nhìn test để CẢ mục "Giới thiệu" được dựng thật.
///
/// `ListView` dựng lười: ở 800x600 mặc định, ô Chính sách quyền riêng
/// tư nằm ngoài cache extent nên chưa tồn tại trong cây — đó là hành vi
/// của ListView, không phải lỗi màn hình. Phóng to cho mọi ô hiện diện,
/// nhờ đó cờ `isHidden` phản ánh đúng thứ người dùng thật nhìn thấy.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Đoạn văn (RichText) có nội dung đúng bằng [label].
Finder _paragraph(String label) => find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == label,
    );

/// Toàn bộ node semantics của màn Hồ sơ, duyệt từ node gốc bao nó.
List<SemanticsNode> _allSemanticsNodes(WidgetTester tester) {
  final root = tester.getSemantics(find.byType(ProfileScreen));
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return nodes;
}

/// Chạm ĐÚNG vào dải chữ [start, end) của một đoạn văn, không phải tâm
/// ô ListTile — tâm RenderParagraph có thể rơi ra ngoài dải chữ vì đoạn
/// văn chiếm hết bề ngang. Cùng cách liên kết Tanzil đã được kiểm thử.
Future<void> _tapTextRange(
  WidgetTester tester,
  Finder paragraph,
  int start,
  int end,
) async {
  final renderParagraph = tester.renderObject<RenderParagraph>(paragraph);
  final box = renderParagraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: end),
      )
      .first;
  final localCenter = Offset(
    (box.left + box.right) / 2,
    (box.top + box.bottom) / 2,
  );
  await tester.tapAt(renderParagraph.localToGlobal(localCenter));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeUrlLauncher fakeLauncher;

  setUp(() {
    fakeLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeLauncher;
    SharedPreferences.setMockInitialValues({});
  });

  for (final entry in _privacyLabels.entries) {
    final language = entry.key;
    final label = entry.value;

    testWidgets('[$language] hiện nhãn Chính sách quyền riêng tư đã dịch',
        (tester) async {
      _useTallSurface(tester);
      final sp = await SharedPreferences.getInstance();
      await tester.pumpWidget(_app(sp, language: language));
      await tester.pumpAndSettle();

      // Nhãn đến từ ARB, không hard-code trong widget.
      final context = tester.element(find.byType(ProfileScreen));
      expect(AppLocalizations.of(context).privacyPolicy, label);
      expect(_paragraph(label), findsOneWidget);
    });

    testWidgets('[$language] lộ ra ĐÚNG MỘT liên kết, không đọc trùng',
        (tester) async {
      _useTallSurface(tester);
      final sp = await SharedPreferences.getInstance();
      await tester.pumpWidget(_app(sp, language: language));
      await tester.pumpAndSettle();

      // Chỉ đúng MỘT node semantics mang nhãn này trong TOÀN cây — nếu
      // bọc thêm Semantics(link:) quanh ListTile thì ở đây sẽ ra 2 node
      // và TalkBack/VoiceOver đọc lặp.
      final labelled = _allSemanticsNodes(tester)
          .where((node) => node.getSemanticsData().label.contains(label))
          .toList();
      expect(labelled, hasLength(1));

      final data = labelled.single.getSemanticsData();
      expect(data.label, label);
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      // Nằm trong khung nhìn: TalkBack đọc được ngay, không bị đánh dấu ẩn.
      expect(data.flagsCollection.isHidden, isFalse);

      // Và trong đúng trình tự mà TalkBack/VoiceOver quét qua màn hình,
      // nhãn này cũng chỉ xuất hiện MỘT lần — không đọc lặp.
      final announced = tester.semantics
          .simulatedAccessibilityTraversal()
          .where((node) => node.label.contains(label));
      expect(announced, hasLength(1));
    });
  }

  testWidgets('nhãn tiếng Ả Rập giữ hướng RTL', (tester) async {
    _useTallSurface(tester);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(_app(sp, language: 'ar'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ProfileScreen));
    expect(Directionality.of(context), TextDirection.rtl);

    final node = _allSemanticsNodes(tester).singleWhere(
      (n) => n.getSemanticsData().label == _privacyLabels['ar'],
    );
    expect(node.getSemanticsData().textDirection, TextDirection.rtl);
  });

  testWidgets('chạm vào liên kết mở ĐÚNG URL chuẩn tắc, không gì khác',
      (tester) async {
    _useTallSurface(tester);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(_app(sp));
    await tester.pumpAndSettle();

    final label = _privacyLabels['en']!;
    await _tapTextRange(tester, _paragraph(label), 0, label.length);

    expect(fakeLauncher.launchedUrls, equals([_canonicalPrivacyUrl]));
  });

  testWidgets('liên kết Tanzil vẫn mở đúng tanzil.net (không hồi quy)',
      (tester) async {
    _useTallSurface(tester);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(_app(sp));
    await tester.pumpAndSettle();

    final sourcesParagraph = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Tanzil.net'),
    );
    final plain = tester
        .renderObject<RenderParagraph>(sourcesParagraph)
        .text
        .toPlainText();
    final start = plain.indexOf('Tanzil.net');
    await _tapTextRange(
      tester,
      sourcesParagraph,
      start,
      start + 'Tanzil.net'.length,
    );

    expect(fakeLauncher.launchedUrls, equals(['https://tanzil.net']));
  });

  testWidgets('màn Hồ sơ chỉ có 2 liên kết: Tanzil và Chính sách',
      (tester) async {
    _useTallSurface(tester);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(_app(sp));
    await tester.pumpAndSettle();

    final linkLabels = _allSemanticsNodes(tester)
        .where((node) => node.getSemanticsData().flagsCollection.isLink)
        .map((node) => node.getSemanticsData().label)
        .toList();
    expect(
      linkLabels,
      unorderedEquals(<String>['Tanzil.net', _privacyLabels['en']!]),
    );
  });

  testWidgets('phần còn lại của màn Hồ sơ không đổi', (tester) async {
    _useTallSurface(tester);
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(_app(sp));
    await tester.pumpAndSettle();

    // Ghi công nguồn dữ liệu và ô phiên bản vẫn nguyên chỗ cũ.
    expect(find.text('Data sources'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('QuranEnc.com'),
      ),
      findsOneWidget,
    );

    // Điều hướng cũ còn chạy, và không có gì tự mở trình duyệt.
    expect(find.text('My Library'), findsOneWidget);
    await tester.tap(find.text('My Library'));
    await tester.pumpAndSettle();
    expect(find.text('LIBRARY'), findsOneWidget);
    expect(fakeLauncher.launchedUrls, isEmpty);
  });
}
