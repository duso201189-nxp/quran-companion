import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/ayah_audio_item.dart';
import 'package:quran_companion/core/audio/just_audio_player.dart';
import 'package:quran_companion/core/quran/quran_address.dart';

/// Test nạp-trước Ayah kế của [JustAudioAyahPlayer] (Sprint audio
/// buffering fix — xem doc comment "Nạp trước Ayah kế" của lớp đó).
///
/// KHÔNG mô phỏng `currentIndexStream`/`setPlaylist` bằng một
/// `AudioPlayer` thật: cả hai đều cần kênh nền tảng (platform channel)
/// mà `flutter_test` không có sẵn — đúng lý do lớp này chưa từng có
/// test trực tiếp trước sprint này. [JustAudioAyahPlayer.debugSetItemsForTest]
/// và [JustAudioAyahPlayer.debugSimulateIndexChange] (cả hai chỉ dựng
/// để test) gọi thẳng phần logic nạp-trước — vốn chỉ phụ thuộc `_items`
/// và [AyahPrefetcher] đã tiêm vào, không phụ thuộc trình phát chính đã
/// nạp xong hay chưa. Đây chính là "seam giả lập nhẹ, không phải engine
/// thật thứ hai" được khuyến nghị.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AyahAudioItem item(int ayahNumber) {
    final n = ayahNumber.toString().padLeft(3, '0');
    return AyahAudioItem(
      address: QuranAddress.ayah(2, ayahNumber),
      source: Uri.parse('https://a.test/002$n.mp3'),
      surahName: 'Al-Baqarah',
      reciterName: 'Alafasy',
    );
  }

  late List<Uri> prefetched;
  late JustAudioAyahPlayer player;

  setUp(() {
    prefetched = [];
    player = JustAudioAyahPlayer(
      prefetch: (uri) async => prefetched.add(uri),
    );
  });

  test('A: chỉ số hiện tại đổi -> nạp trước ĐÚNG mục kế (index+1)', () async {
    player.debugSetItemsForTest([item(1), item(2), item(3)]);
    player.debugSimulateIndexChange(0);
    await pumpEventQueue();

    expect(prefetched, [item(2).source]);
  });

  test('B: đang ở mục CUỐI -> không nạp trước gì cả', () async {
    player.debugSetItemsForTest([item(1), item(2), item(3)]);
    player.debugSimulateIndexChange(2); // mục cuối (chỉ số 2 của 3 mục)
    await pumpEventQueue();

    expect(prefetched, isEmpty);
  });

  test('C: playlist RỖNG -> không nạp trước gì cả', () async {
    // Không gọi debugSetItemsForTest — _items rỗng theo mặc định.
    player.debugSimulateIndexChange(0);
    await pumpEventQueue();

    expect(prefetched, isEmpty);
  });

  test('D: chỉ số hiện tại phát lặp lại -> KHÔNG nạp trước lặp lại', () async {
    player.debugSetItemsForTest([item(1), item(2), item(3)]);
    player.debugSimulateIndexChange(0);
    player.debugSimulateIndexChange(0); // lặp lại cùng chỉ số
    player.debugSimulateIndexChange(0);
    await pumpEventQueue();

    expect(prefetched, [item(2).source]); // đúng MỘT lần, không phải ba
  });

  test(
      'Chỉ nạp trước ĐÚNG MỘT mục — không nạp trước nhiều mục cho một lần '
      'đổi chỉ số', () async {
    player.debugSetItemsForTest([item(1), item(2), item(3), item(4)]);
    player.debugSimulateIndexChange(1);
    await pumpEventQueue();

    expect(prefetched, [item(3).source]); // không phải item(4) hay xa hơn
  });

  test(
      'Đổi playlist đặt lại dấu vết nạp-trước — cùng chỉ số SỐ nhưng '
      'playlist MỚI vẫn nạp trước đúng mục kế của playlist mới, không bị '
      'coi là "đã nạp trước" từ playlist cũ', () async {
    player.debugSetItemsForTest([item(1), item(2), item(3)]);
    player.debugSimulateIndexChange(0);
    await pumpEventQueue();
    expect(prefetched, [item(2).source]);

    // Playlist MỚI, cũng bắt đầu ở chỉ số 0 (trùng SỐ với trước, nhưng
    // là Ayah khác hẳn) — nếu dấu vết không được đặt lại, nạp trước sẽ
    // bị chặn nhầm vì "chỉ số 0 đã xử lý rồi".
    player.debugSetItemsForTest([item(10), item(11), item(12)]);
    player.debugSimulateIndexChange(0);
    await pumpEventQueue();

    expect(prefetched, [item(2).source, item(11).source]);
  });

  test('F: nạp trước lỗi KHÔNG làm hỏng đường phát chính (không ném ra ngoài)',
      () async {
    final failing = JustAudioAyahPlayer(
      prefetch: (uri) async => throw Exception('mất mạng giữa chừng'),
    );

    failing.debugSetItemsForTest([item(1), item(2)]);
    // Không có expect(throwsA...) ở đây một cách có chủ ý: khẳng định
    // chính là lời gọi dưới đây KHÔNG ném ra ngoài và test KHÔNG fail.
    failing.debugSimulateIndexChange(0);
    await pumpEventQueue();

    // Đường phát chính (playlist...) vẫn hoạt động bình thường sau một
    // lần nạp-trước lỗi.
    expect(failing.playlist, hasLength(2));
  });
}
