import 'dart:io';

import 'package:path/path.dart' as p;

import '../audio/audio_url.dart';
import 'cache_manager.dart';

/// Hàm tải bytes — tách ra để test không cần mạng.
typedef Downloader = Future<List<int>> Function(Uri uri);

Future<List<int>> httpDownloader(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } finally {
    client.close();
  }
}

/// CacheManager trên file system (Android/iOS/desktop).
class IoCacheManager implements CacheManager {
  IoCacheManager({
    required this.rootDirectory,
    Downloader? downloader,
  }) : _download = downloader ?? httpDownloader;

  /// Thư mục gốc cache audio (vd: <appSupport>/audio).
  final Directory rootDirectory;
  final Downloader _download;

  Directory _reciterDir(String code) =>
      Directory(p.join(rootDirectory.path, code));

  File _ayahFile(String code, int surahId, int ayahNumber) => File(
        p.join(_reciterDir(code).path, ayahCacheFileName(surahId, ayahNumber)),
      );

  @override
  Future<int> totalSizeBytes() => _dirSize(rootDirectory);

  @override
  Future<int> sizeOfReciterBytes(String reciterCode) =>
      _dirSize(_reciterDir(reciterCode));

  Future<int> _dirSize(Directory dir) async {
    if (!dir.existsSync()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  @override
  Future<void> clearAll() async {
    if (rootDirectory.existsSync()) {
      await rootDirectory.delete(recursive: true);
    }
  }

  @override
  Future<void> clearReciter(String reciterCode) async {
    final dir = _reciterDir(reciterCode);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<Uri?> cachedAyahUri({
    required String reciterCode,
    required int surahId,
    required int ayahNumber,
  }) async {
    final file = _ayahFile(reciterCode, surahId, ayahNumber);
    return file.existsSync() ? file.uri : null;
  }

  @override
  Stream<PrefetchProgress> prefetchSurah({
    required String reciterCode,
    required String urlTemplate,
    required int surahId,
    required int ayahCount,
  }) async* {
    await _reciterDir(reciterCode).create(recursive: true);
    var done = 0;
    yield PrefetchProgress(done: done, total: ayahCount);
    for (var n = 1; n <= ayahCount; n++) {
      final file = _ayahFile(reciterCode, surahId, n);
      if (!file.existsSync()) {
        try {
          final bytes = await _download(
            Uri.parse(
              buildAyahAudioUrl(
                template: urlTemplate,
                surahId: surahId,
                ayahNumber: n,
              ),
            ),
          );
          // Ghi file tạm rồi đổi tên: không bao giờ để lại file
          // tải dở (mất mạng giữa chừng) bị nhận nhầm là hợp lệ.
          final tmp = File('${file.path}.part');
          await tmp.writeAsBytes(bytes, flush: true);
          await tmp.rename(file.path);
        } on Exception {
          // Ayah lỗi: bỏ qua, giữ phần đã tải — lần prefetch sau
          // sẽ tải bù. Không ném lỗi để không hủy cả tiến trình.
        }
      }
      done++;
      yield PrefetchProgress(done: done, total: ayahCount);
    }
  }
}
