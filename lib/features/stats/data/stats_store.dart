import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_provider.dart';
import '../../quran/presentation/reading/reading_position_store.dart';

/// Thống kê học tập cục bộ — lưu SharedPreferences, không cần backend.
///
/// Ghi nhận:
/// - Ngày có đọc (danh sách yyyy-MM-dd, tối đa 400 ngày gần nhất)
/// - Số phút đọc theo ngày (map phẳng 'stats.minutes.yyyy-MM-dd')
/// - Ayah đã đọc + % hoàn thành suy ra từ vị trí đọc từng Surah
///   (ReadingPositionStore) — không ghi trùng dữ liệu.
class StatsStore {
  StatsStore(this._ref);

  final Ref _ref;

  static const String kDays = 'stats.reading_days';
  static String minutesKey(String day) => 'stats.minutes.$day';

  static const int totalAyahs = 6236;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ---------------- Ghi ----------------

  /// Đánh dấu hôm nay là ngày có đọc.
  Future<void> markToday() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final today = dayKey(DateTime.now());
    final days = prefs.getStringList(kDays) ?? const [];
    if (days.contains(today)) return;
    final updated = [...days, today];
    // Giới hạn kích thước pref — giữ 400 ngày gần nhất.
    updated.sort();
    await prefs.setStringList(
      kDays,
      updated.length > 400
          ? updated.sublist(updated.length - 400)
          : updated,
    );
  }

  /// Cộng dồn thời gian đọc (giây) vào ngày hôm nay.
  Future<void> addSeconds(int seconds) async {
    if (seconds < 5) return; // lướt qua màn hình không tính
    final prefs = _ref.read(sharedPreferencesProvider);
    final key = minutesKey(dayKey(DateTime.now()));
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + seconds);
  }

  // ---------------- Đọc ----------------

  List<DateTime> get readingDays {
    final prefs = _ref.read(sharedPreferencesProvider);
    return [
      for (final s in prefs.getStringList(kDays) ?? const <String>[])
        if (DateTime.tryParse(s) != null) DateTime.parse(s),
    ]..sort();
  }

  int get readingDayCount => readingDays.length;

  /// Chuỗi ngày liên tiếp tính đến hôm nay (hoặc hôm qua).
  int get currentStreak {
    final days = readingDays.reversed.toList();
    if (days.isEmpty) return 0;
    final today = DateTime.now();
    var anchor = DateTime(today.year, today.month, today.day);
    // Cho phép chuỗi kết thúc hôm qua (hôm nay chưa đọc).
    if (days.first != anchor) {
      anchor = anchor.subtract(const Duration(days: 1));
      if (days.first != anchor) return 0;
    }
    var streak = 0;
    for (final d in days) {
      if (d == anchor) {
        streak++;
        anchor = anchor.subtract(const Duration(days: 1));
      } else if (d.isBefore(anchor)) {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    final days = readingDays;
    if (days.isEmpty) return 0;
    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else if (days[i] != days[i - 1]) {
        run = 1;
      }
    }
    return longest;
  }

  int get totalMinutes {
    final prefs = _ref.read(sharedPreferencesProvider);
    var seconds = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith('stats.minutes.')) {
        seconds += prefs.getInt(key) ?? 0;
      }
    }
    return seconds ~/ 60;
  }

  int minutesOn(DateTime day) {
    final prefs = _ref.read(sharedPreferencesProvider);
    return (prefs.getInt(minutesKey(dayKey(day))) ?? 0) ~/ 60;
  }

  /// Phút đọc 7 ngày gần nhất (cũ → mới) cho biểu đồ cột.
  List<({DateTime day, int minutes})> get last7Days {
    final today = DateTime.now();
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final d = DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: i));
          return (day: d, minutes: minutesOn(d));
        }(),
    ];
  }

  /// Tổng Ayah đã đọc tới (suy từ vị trí đọc đã lưu của từng Surah).
  int get ayahsRead {
    final prefs = _ref.read(sharedPreferencesProvider);
    var total = 0;
    for (var surah = 1; surah <= 114; surah++) {
      final pos = prefs.getInt(ReadingPositionStore.posKey(surah));
      if (pos != null) total += pos + 1;
    }
    return total;
  }

  double get completionPercent =>
      (ayahsRead / totalAyahs * 100).clamp(0, 100);
}

final statsStoreProvider = Provider<StatsStore>(StatsStore.new);

/// Bộ đếm phiên bản để màn hình thống kê tự làm mới khi mở lại.
final statsRefreshProvider = StateProvider<int>((ref) => 0);
