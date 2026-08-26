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

/// Fake nền tảng url_launcher — mẫu test chính thức của package (thay
/// [UrlLauncherPlatform.instance] thay vì mock kênh nền tảng), tránh
/// dựng một lớp bọc trừu tượng chỉ để test một link tĩnh, cố định.
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

Future<Widget> _app(SharedPreferences sp) async {
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
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  late _FakeUrlLauncher fakeLauncher;

  setUp(() {
    fakeLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeLauncher;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('hiển thị đầy đủ ghi công Tanzil cùng các nguồn khác',
      (tester) async {
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(await _app(sp));
    await tester.pumpAndSettle();

    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Tanzil.net'),
    );
    expect(richTextFinder, findsOneWidget);
    final plainText =
        tester.widget<RichText>(richTextFinder).text.toPlainText();
    // Nguyên câu dịch (EN) không đổi nghĩa — vẫn liệt kê đủ 4 nguồn.
    expect(plainText, contains('Tanzil.net'));
    expect(plainText, contains('QuranEnc.com'));
    expect(plainText, contains('EveryAyah.com'));
    expect(plainText, contains('KFGQPC'));
  });

  testWidgets('đoạn Tanzil.net được lộ ra như một liên kết cho TalkBack',
      (tester) async {
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(await _app(sp));
    await tester.pumpAndSettle();
    // testWidgets() đã tự bật semantics mặc định (semanticsEnabled:
    // true) — không tạo thêm SemanticsHandle thủ công ở đây để tránh
    // rò rỉ handle giữa các lần dispose.

    // Cuộn tới ListTile "Nguồn dữ liệu" — nằm dưới màn hình mặc định
    // của test, và nút/đoạn text ngoài khung nhìn bị đánh dấu isHidden
    // trong cây semantics (TalkBack thật cũng vậy trước khi cuộn tới).
    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Tanzil.net'),
    );
    await tester.ensureVisible(richTextFinder);
    await tester.pumpAndSettle();

    // RenderParagraph phát ra CÁC node semantics con riêng cho từng
    // đoạn có recognizer — đây là cây thật TalkBack/VoiceOver đọc,
    // không phải thứ `find.bySemanticsLabel` thấy được (nó chỉ khớp
    // node CHỦ SỞ HỮU của Element, không khớp các con do RenderParagraph
    // tự dựng) — nên duyệt thẳng cây semantics thay vì dùng finder đó.
    final paragraphNode = tester.getSemantics(richTextFinder);
    final children = <SemanticsNode>[];
    paragraphNode.visitChildren((child) {
      children.add(child);
      return true;
    });
    expect(
      children,
      isNotEmpty,
      reason: 'đoạn văn phải tách thành các node con vì có recognizer',
    );

    final tanzilNodes = children.where((n) => n.label == 'Tanzil.net').toList();
    expect(tanzilNodes, hasLength(1));
    final tanzilNode = tanzilNodes.single;
    final tanzilData = tanzilNode.getSemanticsData();
    expect(tanzilData.flagsCollection.isLink, isTrue);
    expect(tanzilData.hasAction(SemanticsAction.tap), isTrue);

    // Phần còn lại của câu (chứa QuranEnc.com/EveryAyah.com/KFGQPC)
    // KHÔNG được gắn cờ liên kết — chỉ đúng một đoạn Tanzil.net trở
    // thành link, tránh TalkBack đọc lặp hoặc biến cả câu thành 1 nút.
    final otherNodes = children.where((n) => n != tanzilNode);
    expect(otherNodes, isNotEmpty);
    for (final node in otherNodes) {
      final data = node.getSemanticsData();
      expect(data.flagsCollection.isLink, isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
    }
    final combinedOtherLabels = otherNodes.map((n) => n.label).join();
    expect(combinedOtherLabels, contains('QuranEnc.com'));
    expect(combinedOtherLabels, contains('EveryAyah.com'));
  });

  testWidgets('chạm vào Tanzil.net mở đúng https://tanzil.net, không gì khác',
      (tester) async {
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(await _app(sp));
    await tester.pumpAndSettle();

    final richTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('Tanzil.net'),
    );
    await tester.ensureVisible(richTextFinder);
    await tester.pumpAndSettle();
    final renderParagraph = tester.renderObject<RenderParagraph>(
      richTextFinder,
    );
    final plain = renderParagraph.text.toPlainText();
    final start = plain.indexOf('Tanzil.net');
    final end = start + 'Tanzil.net'.length;
    final box = renderParagraph
        .getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: end),
        )
        .first;
    final localCenter = Offset(
      (box.left + box.right) / 2,
      (box.top + box.bottom) / 2,
    );
    final globalCenter = renderParagraph.localToGlobal(localCenter);

    await tester.tapAt(globalCenter);
    await tester.pumpAndSettle();

    expect(fakeLauncher.launchedUrls, equals(['https://tanzil.net']));
  });

  testWidgets('các mục khác của màn Hồ sơ vẫn hoạt động bình thường',
      (tester) async {
    final sp = await SharedPreferences.getInstance();
    await tester.pumpWidget(await _app(sp));
    await tester.pumpAndSettle();

    expect(find.text('My Library'), findsOneWidget);
    await tester.tap(find.text('My Library'));
    await tester.pumpAndSettle();
    expect(find.text('LIBRARY'), findsOneWidget);
    // Chạm vào nguồn dữ liệu không kích hoạt url_launcher.
    expect(fakeLauncher.launchedUrls, isEmpty);
  });
}
