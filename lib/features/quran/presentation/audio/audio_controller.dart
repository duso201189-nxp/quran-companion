import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_url.dart';
import '../../../../core/audio/ayah_audio_item.dart';
import '../../../../core/audio/ayah_audio_player.dart';
import '../../../../core/quran/quran_address.dart';
import '../../../../core/storage/prefs_provider.dart';
import '../../data/quran_providers.dart';
import '../../domain/basmalah.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/reciter.dart';
import '../../domain/reading_playlist.dart';

/// Danh sách Qari (từ database nội dung).
final recitersProvider = FutureProvider<List<Reciter>>(
  (ref) => ref.watch(quranRepositoryProvider).getEnabledReciters(),
);

/// Các mức tốc độ phát, xoay vòng.
const List<double> kPlaybackSpeeds = [0.75, 1.0, 1.25, 1.5, 2.0];

/// Trạng thái trình phát Ayah.
class AudioState {
  const AudioState({
    this.surahId,
    this.currentIndex = 0,
    this.currentAddress,
    this.playing = false,
    this.speed = 1.0,
    this.repeat = RepeatMode.off,
    this.reciter,
    this.position = Duration.zero,
    this.duration,
    this.loading = false,
    this.errorMessage,
  });

  /// Surah đang phát; null = trình phát chưa hoạt động.
  final int? surahId;

  /// Chỉ số **mục phát** 0-based trong playlist — KHÔNG phải chỉ số Ayah.
  ///
  /// ⚠️ Sprint BM1: hai hệ này từng là một, và giờ thì không. Surah có
  /// phần mở đầu tách rời (112/114 Surah) có thêm một mục ở đầu
  /// playlist, nên `currentIndex == 1` ở đó là **Ayah 1**, không phải
  /// Ayah 2.
  ///
  /// ĐỪNG suy ra Ayah từ trường này. Dùng [currentAddress], hoặc
  /// `ReadingPlaylist.ayahIndexForItem` nếu thật sự cần chỉ số. Đặc
  /// biệt: **đừng bao giờ ghi giá trị này xuống đĩa** —
  /// `ReadingPositionStore` và `study_sessions` đều thuần hệ Ayah.
  final int currentIndex;
  final bool playing;
  final double speed;
  final RepeatMode repeat;
  final Reciter? reciter;

  /// Vị trí phát trong Ayah hiện tại.
  final Duration position;

  /// Thời lượng Ayah hiện tại (null khi chưa biết).
  final Duration? duration;

  /// Đang tải/buffer nguồn audio.
  final bool loading;

  /// Lỗi phát gần nhất (null = không lỗi).
  final String? errorMessage;

  bool get active => surahId != null;

  /// Địa chỉ của mục đang phát — `null` khi chưa phát gì.
  ///
  /// Sprint F0 dựng nó bằng phép tính từ [currentIndex]. Sprint BM1 đổi
  /// thành **trường được lưu**, lấy thẳng từ `AyahAudioItem` đang phát,
  /// vì sau khi playlist có thêm phần mở đầu thì [currentIndex] không
  /// còn suy ra được Ayah nữa. Mục phát vốn đã mang địa chỉ của chính
  /// nó (Sprint B1) — hỏi nó là đúng nguồn, tính lại là đoán.
  ///
  /// **Hai mức, và sự khác nhau có ý nghĩa:**
  /// - mức Ayah (`2:255`) — đang phát một Ayah;
  /// - mức Surah (`2`) — đang phát PHẦN MỞ ĐẦU của Surah đó.
  ///
  /// `QuranAddress.surah(2) != QuranAddress.ayah(2, 1)` (F0 có test),
  /// nên phép so bằng ở `AyahCard` không thể tô nhầm Ayah 1 khi
  /// Basmalah đang phát. Và `zeroBasedAyahIndex` trả `null` ở mức
  /// Surah — đó chính là dấu hiệu "chưa tới Ayah nào" mà phần cuộn
  /// theo audio dùng.
  final QuranAddress? currentAddress;

  double? get progress {
    final d = duration;
    if (d == null || d.inMilliseconds == 0) return null;
    return (position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioState copyWith({
    int? surahId,
    int? currentIndex,
    QuranAddress? currentAddress,
    bool? playing,
    double? speed,
    RepeatMode? repeat,
    Reciter? reciter,
    Duration? position,
    Duration? duration,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    bool clearDuration = false,
  }) {
    return AudioState(
      surahId: surahId ?? this.surahId,
      currentIndex: currentIndex ?? this.currentIndex,
      currentAddress: currentAddress ?? this.currentAddress,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
      repeat: repeat ?? this.repeat,
      reciter: reciter ?? this.reciter,
      position: position ?? this.position,
      duration: clearDuration ? null : duration ?? this.duration,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const AudioState idle = AudioState();
}

class AudioController extends Notifier<AudioState> {
  static const String kReciterPrefsKey = 'audio.reciter';

  final List<StreamSubscription<Object?>> _subs = [];
  int _playlistLength = 0;

  /// Playlist đang phát — giữ lại để Thử lại sau lỗi mạng.
  List<AyahAudioItem> _items = const [];

  AyahAudioPlayer get _player => ref.read(ayahAudioPlayerProvider);

  /// Địa chỉ của mục phát thứ [item] — `null` nếu ngoài playlist.
  ///
  /// Hỏi thẳng mục phát thay vì tính lại từ chỉ số: mục đã mang địa chỉ
  /// của chính nó từ Sprint B1, và sau BM1 thì chỉ số không còn suy ra
  /// được Ayah nữa.
  QuranAddress? _addressAt(int item) =>
      item >= 0 && item < _items.length ? _items[item].address : null;

  @override
  AudioState build() {
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      _subs.clear();
    });
    return AudioState.idle;
  }

  void _ensureSubscriptions() {
    if (_subs.isNotEmpty) return;
    _subs.addAll([
      _player.currentIndexStream.listen((index) {
        if (index != null && index != state.currentIndex) {
          // Mục phát mới -> reset vị trí/thời lượng của thanh tiến độ.
          // Địa chỉ đi kèm luôn ở đây, cùng một lần đặt state: hai
          // trường này rời nhau dù chỉ một khung hình là thanh phát và
          // phần tô sáng nói hai chuyện khác nhau.
          state = state.copyWith(
            currentIndex: index,
            currentAddress: _addressAt(index),
            position: Duration.zero,
            clearDuration: true,
          );
        }
      }),
      _player.playingStream.listen((playing) {
        if (playing != state.playing) {
          state = state.copyWith(playing: playing);
        }
      }),
      _player.positionStream.listen((position) {
        // Throttle ~300ms: đủ mượt cho thanh tiến độ, không spam
        // rebuild (thẻ Ayah chỉ watch qua select nên không bị ảnh
        // hưởng, đây là để nhẹ cho chính AudioBar).
        if ((position - state.position).abs() >
                const Duration(milliseconds: 300) ||
            position == Duration.zero) {
          state = state.copyWith(position: position);
        }
      }),
      _player.durationStream.listen((duration) {
        if (duration != state.duration) {
          state = state.copyWith(duration: duration);
        }
      }),
      _player.processingStream.listen((processing) {
        final loading = processing == AyahPlayerProcessing.loading;
        if (loading != state.loading) {
          state = state.copyWith(loading: loading);
        }
        // Hết playlist (repeat off) -> hiển thị nút phát lại.
        if (processing == AyahPlayerProcessing.completed && state.playing) {
          state = state.copyWith(playing: false);
        }
      }),
      _player.errorStream.listen((message) {
        state = state.copyWith(errorMessage: message, loading: false);
      }),
    ]);
  }

  /// Phát một Surah, bắt đầu tại [from].
  ///
  /// Sprint BM3: [from] thay cho `startIndex` cũ. Mức của địa chỉ mang
  /// ý định — mức Surah là "đọc từ đầu" (có phần mở đầu), mức Ayah là
  /// "phát đúng Ayah này". Trước BM3 cả hai cùng đi qua một chỉ số nên
  /// không phân biệt được; xem `ReadingPlaylist.itemForAddress`.
  ///
  /// Surah lấy từ chính [from] chứ không nhận thêm tham số: hai nguồn
  /// cho cùng một thông tin là hai thứ có thể lệch nhau.
  Future<void> playSurah({
    required List<Ayah> ayahs,
    required QuranAddress from,
  }) async {
    final surahId = from.surah;
    final reciter = await _resolveReciter();
    if (reciter == null || ayahs.isEmpty) return;

    // Tên Surah lấy TRONG controller chứ không nhận qua tham số: bên
    // gọi nào quên truyền thì thông báo trên màn hình khoá sẽ thiếu
    // chữ một cách âm thầm, và đó là loại lỗi không ai thấy cho tới
    // khi cầm điện thoại thật. Một lượt đọc theo khoá chính, trong
    // đường đã async sẵn và đã có trạng thái loading.
    final surahName = await _resolveSurahName(surahId);

    // Sprint BM1: Surah này mở đầu thế nào? Cùng khai báo mà `ReadingRows`
    // dùng, nên playlist và danh sách hàng không thể lệch nhau.
    final opening = resolveSurahOpening(
      surahId: surahId,
      firstAyahText: ayahs.first.textUthmani,
    );

    _items = [
      if (ReadingPlaylist.leadingItemsFor(opening) == 1)
        AyahAudioItem(
          // Mức SURAH, không phải Ayah: đây là thứ mở đầu Surah, không
          // phải một Ayah của nó. F0 sắp mức Surah đứng trước mọi Ayah
          // của chính nó, nên thứ tự playlist khớp thứ tự đọc mà không
          // cần luật riêng.
          address: QuranAddress.surah(surahId),
          // Basmalah của MỌI Surah là Ayah 1 của Al-Fatihah — cùng Qari,
          // cùng bitrate, cùng CDN. Không thêm tài nguyên, không thêm
          // giấy phép: chỉ là địa chỉ một tệp đã có.
          source: Uri.parse(
            buildAyahAudioUrl(
              template: reciter.audioUrlTemplate,
              surahId: 1,
              ayahNumber: 1,
            ),
          ),
          surahName: surahName,
          reciterName: reciter.name,
        ),
      for (final a in ayahs)
        AyahAudioItem(
          address: QuranAddress.ayah(surahId, a.ayahNumber),
          source: Uri.parse(
            buildAyahAudioUrl(
              template: reciter.audioUrlTemplate,
              surahId: surahId,
              ayahNumber: a.ayahNumber,
            ),
          ),
          surahName: surahName,
          reciterName: reciter.name,
        ),
    ];
    _playlistLength = _items.length;

    // Địa chỉ -> mục phát. Mức Surah rơi vào mục 0 (phần mở đầu nếu
    // có); mức Ayah rơi vào đúng Ayah đó.
    final startItem = ReadingPlaylist.itemForAddress(
      opening: opening,
      from: from,
    );

    _ensureSubscriptions();

    state = AudioState(
      surahId: surahId,
      currentIndex: startItem,
      currentAddress: _addressAt(startItem),
      playing: true,
      speed: state.speed,
      repeat: state.repeat,
      reciter: reciter,
      loading: true,
    );

    await _player.setPlaylist(_items, initialIndex: startItem);
    await _player.setSpeed(state.speed);
    await _player.setRepeatMode(state.repeat);
    await _player.play();
  }

  /// Thử lại sau lỗi (mạng chập chờn...): nạp lại playlist tại
  /// đúng Ayah đang dở rồi phát tiếp.
  Future<void> retry() async {
    if (!state.active || _items.isEmpty) return;
    state = state.copyWith(clearError: true, loading: true);
    await _player.setPlaylist(_items, initialIndex: state.currentIndex);
    await _player.setSpeed(state.speed);
    await _player.setRepeatMode(state.repeat);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (!state.active) return;
    if (state.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    state = state.copyWith(playing: !state.playing);
  }

  /// Mục phát kế. Biên là độ dài PLAYLIST, không phải số Ayah — với
  /// Surah có phần mở đầu, hai con số đó lệch nhau 1.
  Future<void> nextAyah() async {
    if (!state.active) return;
    final next = state.currentIndex + 1;
    if (next >= _playlistLength) return; // đã ở mục cuối
    state =
        state.copyWith(currentIndex: next, currentAddress: _addressAt(next));
    await _player.seekToIndex(next);
  }

  /// Mục phát trước. Từ Ayah 1 của Surah có phần mở đầu, lùi một bước
  /// là về chính Basmalah — đúng thứ tự người đọc đi qua.
  Future<void> previousAyah() async {
    if (!state.active) return;
    final prev = state.currentIndex - 1;
    if (prev < 0) return;
    state =
        state.copyWith(currentIndex: prev, currentAddress: _addressAt(prev));
    await _player.seekToIndex(prev);
  }

  /// Xoay vòng tốc độ: 0.75 -> 1.0 -> 1.25 -> 1.5 -> 2.0 -> 0.75.
  Future<void> cycleSpeed() async {
    final i = kPlaybackSpeeds.indexOf(state.speed);
    final next = kPlaybackSpeeds[(i + 1) % kPlaybackSpeeds.length];
    state = state.copyWith(speed: next);
    if (state.active) await _player.setSpeed(next);
  }

  /// Xoay vòng lặp: off -> one (lặp Ayah) -> all (lặp Surah) -> off.
  Future<void> cycleRepeat() async {
    final next =
        RepeatMode.values[(state.repeat.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeat: next);
    if (state.active) await _player.setRepeatMode(next);
  }

  Future<void> stop() async {
    await _player.stop();
    state = AudioState(speed: state.speed, repeat: state.repeat);
  }

  /// Đổi Qari — lưu bền; nếu đang phát thì giữ vị trí, nạp lại nguồn.
  Future<void> selectReciter(Reciter reciter) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(kReciterPrefsKey, reciter.code);
    state = state.copyWith(reciter: reciter);
  }

  /// Tên Latin của Surah cho thông báo hệ điều hành.
  ///
  /// Không tìm thấy -> rơi về chính địa chỉ (`"2"`). Xấu hơn nhưng
  /// đúng; chặn phát chỉ vì thiếu một cái tên thì tệ hơn nhiều.
  Future<String> _resolveSurahName(int surahId) async {
    final surah = await ref.read(quranRepositoryProvider).getSurahById(surahId);
    return surah?.nameLatin ?? '${QuranAddress.surah(surahId)}';
  }

  Future<Reciter?> _resolveReciter() async {
    if (state.reciter != null) return state.reciter;
    final reciters = await ref.read(recitersProvider.future);
    if (reciters.isEmpty) return null;
    final saved =
        ref.read(sharedPreferencesProvider).getString(kReciterPrefsKey);
    return reciters.firstWhere(
      (r) => r.code == saved,
      orElse: () => reciters.first,
    );
  }
}

final audioControllerProvider =
    NotifierProvider<AudioController, AudioState>(AudioController.new);
