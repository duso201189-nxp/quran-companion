import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/ayah_audio_item.dart';
import 'package:quran_companion/core/quran/quran_address.dart';

/// Sprint B2 — bằng nhau theo giá trị của [AyahAudioItem].
///
/// Sprint B1 khai báo `==`/`hashCode` nhưng KHÔNG có test nào chạm tới:
/// độ phủ tệp đó là 1/11 dòng. Đây không phải chuyện làm đẹp con số —
/// `AudioController` giữ lại playlist trong `_items` để "Thử lại" sau
/// lỗi mạng dùng lại đúng danh sách cũ, nên ngữ nghĩa giá trị của lớp
/// này có tải trọng thật.
void main() {
  AyahAudioItem itemWith({
    int surah = 2,
    int ayah = 255,
    String url = 'https://a.test/002255.mp3',
    String surahName = 'Al-Baqarah',
    String reciterName = 'Alafasy',
  }) =>
      AyahAudioItem(
        address: QuranAddress.ayah(surah, ayah),
        source: Uri.parse(url),
        surahName: surahName,
        reciterName: reciterName,
      );

  group('B2 — AyahAudioItem là giá trị', () {
    test('cùng bốn trường -> bằng nhau và cùng hashCode', () {
      expect(itemWith(), itemWith());
      expect(itemWith().hashCode, itemWith().hashCode);
    });

    test('khác địa chỉ -> khác nhau', () {
      expect(itemWith(ayah: 255), isNot(itemWith(ayah: 256)));
    });

    test('khác Surah nhưng cùng số Ayah -> vẫn khác nhau', () {
      // Bẫy nếu ai đó rút danh tính về mỗi số Ayah.
      expect(itemWith(surah: 2, ayah: 1), isNot(itemWith(surah: 3, ayah: 1)));
    });

    test('khác nguồn phát -> khác nhau', () {
      // Cùng Ayah, đổi Qari: cùng ĐỊA CHỈ nhưng khác MỤC PHÁT. Đây là
      // chỗ dễ nhầm nhất — `mediaItemFor` cố ý dùng địa chỉ làm id
      // (nên hai mục này có cùng id trên thông báo), còn bản thân mục
      // playlist thì phải phân biệt được, nếu không "Thử lại" sau khi
      // đổi Qari sẽ tưởng playlist không đổi.
      expect(
        itemWith(url: 'https://a.test/002255.mp3'),
        isNot(itemWith(url: 'https://h.test/002255.mp3')),
      );
    });

    test('khác tên Surah hoặc tên Qari -> khác nhau', () {
      expect(
        itemWith(surahName: 'Al-Baqarah'),
        isNot(itemWith(surahName: 'X')),
      );
      expect(
        itemWith(reciterName: 'Alafasy'),
        isNot(itemWith(reciterName: 'X')),
      );
    });

    test('so sánh được cả DANH SÁCH — cái AudioController thật sự cần', () {
      // `==` trên List dùng identity, nên phép so sánh thật đi qua
      // matcher `equals`, và nó gọi `==` của từng phần tử.
      expect(
        [itemWith(ayah: 1), itemWith(ayah: 2)],
        equals([itemWith(ayah: 1), itemWith(ayah: 2)]),
      );
      expect(
        [itemWith(ayah: 1)],
        isNot(equals([itemWith(ayah: 2)])),
      );
    });

    test('dùng được làm khoá Set/Map', () {
      final seen = {itemWith(ayah: 1), itemWith(ayah: 1), itemWith(ayah: 2)};

      expect(seen, hasLength(2));
    });

    test('in ra nêu địa chỉ và Qari — hai thứ phân biệt khi test đỏ', () {
      expect(itemWith().toString(), 'AyahAudioItem(2:255, Alafasy)');
    });
  });
}
