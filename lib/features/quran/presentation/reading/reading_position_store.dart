import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/prefs_provider.dart';

/// Lưu vị trí đọc cuối cùng — mở lại app quay về đúng Surah + Ayah.
///
/// Lưu 2 thứ:
/// - Surah đọc gần nhất (toàn cục — Trang chủ Bước 8 dùng cho
///   nút "Tiếp tục đọc").
/// - Vị trí Ayah trong TỪNG Surah (mở lại Surah nào cũng về đúng
///   chỗ cũ của Surah đó).
class ReadingPositionStore {
  ReadingPositionStore(this._read);

  final Ref _read;

  static const String kLastSurah = 'reading.last_surah_id';
  static const String kRecent = 'reading.recent_surahs';
  static String posKey(int surahId) => 'reading.pos.$surahId';

  int? get lastSurahId =>
      _read.read(sharedPreferencesProvider).getInt(kLastSurah);

  /// Chỉ số Ayah (0-based) đã đọc tới trong Surah, null nếu chưa đọc.
  int? positionFor(int surahId) =>
      _read.read(sharedPreferencesProvider).getInt(posKey(surahId));

  /// Các Surah đọc gần nhất (mới → cũ, tối đa 6) — cho Trang chủ.
  List<int> get recentSurahIds => [
        for (final s
            in _read.read(sharedPreferencesProvider).getStringList(kRecent) ??
                const <String>[])
          if (int.tryParse(s) != null) int.parse(s),
      ];

  Future<void> save({
    required int surahId,
    required int ayahIndex,
  }) async {
    final prefs = _read.read(sharedPreferencesProvider);
    await prefs.setInt(kLastSurah, surahId);
    await prefs.setInt(posKey(surahId), ayahIndex);
    final recent = recentSurahIds..remove(surahId);
    recent.insert(0, surahId);
    await prefs.setStringList(
      kRecent,
      [for (final id in recent.take(6)) '$id'],
    );
  }
}

final readingPositionStoreProvider = Provider<ReadingPositionStore>(
  ReadingPositionStore.new,
);
