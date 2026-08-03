import '../quran/quran_address.dart';

/// Một mục trong playlist audio: nguồn phát, kèm phần mô tả mà HỆ ĐIỀU
/// HÀNH cần để vẽ thông báo và màn hình khoá.
///
/// ## Vì sao playlist không còn là `List<Uri>`
///
/// Trước Sprint B1, `AyahAudioPlayer.setPlaylist` nhận `List<Uri>` trần.
/// Đủ để phát, nhưng không đủ để phát NỀN: thông báo media của Android
/// và iOS đòi tiêu đề, tên "album", tên người trình bày. Một URL không
/// trả lời được câu hỏi "người dùng đang nghe gì" — và khi màn hình đã
/// khoá thì thông báo là toàn bộ giao diện còn lại.
///
/// [address] là `QuranAddress` của Sprint F0, không phải một cặp
/// `(surahId, index)` rời. Đây chính là chỗ khoản đầu tư F0 trả lãi:
/// mục playlist, thông báo hệ điều hành và thẻ Ayah trên màn hình giờ
/// cùng gọi tên một vị trí theo một cách duy nhất.
class AyahAudioItem {
  const AyahAudioItem({
    required this.address,
    required this.source,
    required this.surahName,
    required this.reciterName,
  });

  /// Ayah này là Ayah nào. Mức Ayah, 1-based.
  final QuranAddress address;

  /// Nguồn phát — URL từ xa, hoặc `file://` nếu đã tải offline.
  final Uri source;

  /// Tên Surah dạng Latin (vd. `Al-Fatihah`).
  ///
  /// Latin chứ không phải bản dịch: thông báo hệ điều hành không có
  /// ngôn ngữ giao diện của ứng dụng, và tên Latin là dạng người nghe
  /// Qur'an nhận ra được bất kể họ dùng bản dịch nào.
  final String surahName;

  /// Tên Qari đang đọc.
  final String reciterName;

  @override
  bool operator ==(Object other) =>
      other is AyahAudioItem &&
      other.address == address &&
      other.source == source &&
      other.surahName == surahName &&
      other.reciterName == reciterName;

  @override
  int get hashCode => Object.hash(address, source, surahName, reciterName);

  @override
  String toString() => 'AyahAudioItem($address, $reciterName)';
}
