import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ayah_audio_item.dart';

/// Chế độ lặp của trình phát.
enum RepeatMode { off, one, all }

/// Trạng thái xử lý của engine audio (rút gọn từ just_audio).
enum AyahPlayerProcessing { idle, loading, ready, completed }

/// Trừu tượng hóa trình phát audio theo playlist Ayah.
///
/// Lý do tồn tại: (1) unit test AudioController không cần thiết bị
/// thật; (2) đổi engine audio sau này không chạm business logic.
abstract interface class AyahAudioPlayer {
  /// Chỉ số Ayah đang phát trong playlist (null khi chưa nạp).
  Stream<int?> get currentIndexStream;

  Stream<bool> get playingStream;

  /// Vị trí phát trong Ayah hiện tại.
  Stream<Duration> get positionStream;

  /// Thời lượng Ayah hiện tại (null khi chưa biết).
  Stream<Duration?> get durationStream;

  /// idle -> loading (tải/buffer) -> ready -> completed (hết playlist).
  Stream<AyahPlayerProcessing> get processingStream;

  /// Lỗi phát (mạng, nguồn hỏng...) — engine KHÔNG ném exception ra
  /// ngoài; mọi lỗi đi qua stream này để UI xử lý một chỗ.
  Stream<String> get errorStream;

  /// Mục playlist đang phát, kèm mô tả — `null` khi chưa nạp.
  ///
  /// Sprint B1: cái mà [currentIndexStream] không trả lời được. Một chỉ
  /// số chỉ có nghĩa với ai đang giữ playlist; thông báo của hệ điều
  /// hành thì không, nên nó cần chính mục đó.
  Stream<AyahAudioItem?> get currentItemStream;

  /// Mục playlist hiện tại theo lối đồng bộ — `null` khi chưa nạp.
  ///
  /// Cần cho bên nghe đăng ký MUỘN (adapter hệ điều hành dựng sau khi
  /// nhạc đã chạy): một stream broadcast không phát lại giá trị cũ.
  AyahAudioItem? get currentItem;

  /// Toàn bộ playlist đang nạp — rỗng khi chưa nạp.
  ///
  /// Sprint B2: thông báo của hệ điều hành cần cả DANH SÁCH, không chỉ
  /// mục đang phát, vì hai việc:
  ///
  /// 1. vẽ hàng đợi (`MediaBrowserService` / Android Auto);
  /// 2. biết đâu là mục CUỐI. Không có nó, nút "kế tiếp" trên màn hình
  ///    khoá nhảy ra ngoài playlist — hệ điều hành vẫn vẽ nút đó dù đã
  ///    hết bài.
  List<AyahAudioItem> get playlist;

  /// Phát mỗi lần [setPlaylist] đổi danh sách.
  ///
  /// Tách khỏi [currentItemStream] có chủ ý: nạp playlist mới mà chỉ số
  /// đầu trùng chỉ số cũ thì mục hiện tại KHÔNG đổi, nhưng hàng đợi thì
  /// có. Suy hàng đợi từ mục đang phát là một hợp đồng ngầm, đúng tình
  /// cờ — đúng loại ràng buộc Sprint F2 vừa đi gỡ.
  Stream<List<AyahAudioItem>> get playlistStream;

  Future<void> setPlaylist(List<AyahAudioItem> items, {int initialIndex = 0});

  Future<void> play();

  Future<void> pause();

  Future<void> seekToIndex(int index);

  Future<void> setSpeed(double speed);

  Future<void> setRepeatMode(RepeatMode mode);

  Future<void> stop();

  Future<void> dispose();
}

/// Override trong main.dart (JustAudioAyahPlayer) và trong test
/// (FakeAyahAudioPlayer).
final ayahAudioPlayerProvider = Provider<AyahAudioPlayer>(
  (ref) => throw UnimplementedError(
    'ayahAudioPlayerProvider phải được override trong main.dart',
  ),
);
