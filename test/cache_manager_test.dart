import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/cache/io_cache_manager.dart';

void main() {
  late Directory tempDir;
  late IoCacheManager cache;
  var downloadCalls = <String>[];

  IoCacheManager makeCache({Set<int> failAyahs = const {}}) {
    return IoCacheManager(
      rootDirectory: Directory('${tempDir.path}/audio'),
      downloader: (uri) async {
        downloadCalls.add(uri.toString());
        final name = uri.pathSegments.last; // 002001.mp3
        final ayah = int.parse(name.substring(3, 6));
        if (failAyahs.contains(ayah)) {
          throw const SocketException('mất mạng (giả lập)');
        }
        return List<int>.filled(100, 7); // 100 byte giả
      },
    );
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('quran_cache_test');
    downloadCalls = [];
    cache = makeCache();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('prefetchSurah tải đủ Ayah, báo tiến độ tăng dần', () async {
    final progress = await cache
        .prefetchSurah(
          reciterCode: 'alafasy',
          urlTemplate: 'https://a.test/{sss}{aaa}.mp3',
          surahId: 2,
          ayahCount: 3,
        )
        .toList();

    expect(progress.first.done, 0);
    expect(progress.last.done, 3);
    expect(progress.last.finished, isTrue);
    expect(downloadCalls.length, 3);
    expect(await cache.sizeOfReciterBytes('alafasy'), 300);
  });

  test('Ayah đã có -> không tải lại (chạy prefetch 2 lần)', () async {
    Future<void> run() => cache
        .prefetchSurah(
          reciterCode: 'alafasy',
          urlTemplate: 'https://a.test/{sss}{aaa}.mp3',
          surahId: 2,
          ayahCount: 2,
        )
        .drain<void>();

    await run();
    await run();

    expect(downloadCalls.length, 2); // lần 2 không tải gì thêm
  });

  test('mất mạng giữa chừng: giữ phần đã tải, không ném lỗi', () async {
    cache = makeCache(failAyahs: {2});

    final progress = await cache
        .prefetchSurah(
          reciterCode: 'alafasy',
          urlTemplate: 'https://a.test/{sss}{aaa}.mp3',
          surahId: 2,
          ayahCount: 3,
        )
        .toList();

    expect(progress.last.done, 3); // tiến trình chạy hết
    // ayah 1, 3 đã cache; ayah 2 chưa
    expect(
      await cache.cachedAyahUri(
        reciterCode: 'alafasy',
        surahId: 2,
        ayahNumber: 1,
      ),
      isNotNull,
    );
    expect(
      await cache.cachedAyahUri(
        reciterCode: 'alafasy',
        surahId: 2,
        ayahNumber: 2,
      ),
      isNull,
    );
  });

  test('clearReciter chỉ xóa Qari đó; clearAll xóa hết', () async {
    for (final code in ['alafasy', 'husary']) {
      await cache
          .prefetchSurah(
            reciterCode: code,
            urlTemplate: 'https://a.test/{sss}{aaa}.mp3',
            surahId: 1,
            ayahCount: 1,
          )
          .drain<void>();
    }
    expect(await cache.totalSizeBytes(), 200);

    await cache.clearReciter('alafasy');
    expect(await cache.sizeOfReciterBytes('alafasy'), 0);
    expect(await cache.sizeOfReciterBytes('husary'), 100);

    await cache.clearAll();
    expect(await cache.totalSizeBytes(), 0);
  });
}
