import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/shared/utils/transliteration.dart';

void main() {
  group('cleanTransliteration', () {
    test('nguyên âm dài: <u>a</u> -> ā', () {
      expect(cleanTransliteration('All<u>a</U>hi'), 'Allāhi');
      expect(cleanTransliteration('M<u>a</u>liki'), 'Māliki');
      expect(cleanTransliteration('Iyy<u>a</u>ka'), 'Iyyāka');
    });

    test('câu thật từ dữ liệu Tanzil', () {
      expect(
        cleanTransliteration(
          'Bismi All<u>a</U>hi a<b>l</B>rra<u>h</U>m<u>a</U>ni '
          'a<b>l</B>rra<u>h</U>eem<b>i</b>',
        ),
        'Bismi Allāhi alrraḥmāni alrraḥeemi',
      );
      expect(cleanTransliteration('<u>tha</u>lika'), 'dhālika');
    });

    test('phụ âm nhấn: <u>s</u> -> ṣ, hỗn hợp <u>at</u> -> āṭ', () {
      expect(cleanTransliteration('<u>S</u>ir<u>at</u>a'), 'Ṣirāṭa');
      expect(cleanTransliteration('almagh<u>d</u>oobi'), 'almaghḍoobi');
    });

    test('digraph <u>th</u> -> dh', () {
      expect(cleanTransliteration('alla<u>th</u>eena'), 'alladheena');
    });

    test('AA -> ʿ (ayn)', () {
      expect(cleanTransliteration('naAAbudu'), 'naʿbudu');
      expect(cleanTransliteration('AAalayhim'), 'ʿalayhim');
    });

    test('hamza: gạch nối giữa hai chữ -> ʾ', () {
      expect(cleanTransliteration('mal<u>a</u>-ikati'), 'malāʾikati');
    });

    test('<b> bỏ thẻ giữ chữ, thẻ đóng viết hoa vẫn xử lý', () {
      expect(cleanTransliteration('a<b>l</b>ddeen<b>i</b>'), 'alddeeni');
      expect(cleanTransliteration('M<u>a</U>liki'), 'Māliki');
    });

    test('không còn ký tự < > trong kết quả', () {
      const sample =
          '<u>S</u>ir<u>at</u>a alla<u>th</u>eena anAAamta AAalayhim '
          'ghayri almagh<u>d</u>oobi AAalayhim wal<u>a</u> '
          'a<b>l</b><u>dda</u>lleen<b>a</b>';
      final out = cleanTransliteration(sample);
      expect(out.contains('<'), isFalse);
      expect(out.contains('>'), isFalse);
      expect(out, contains('Ṣirāṭa'));
      expect(out, contains('ʿalayhim'));
    });

    test('chuỗi sạch giữ nguyên', () {
      expect(cleanTransliteration('Allāhu akbar'), 'Allāhu akbar');
    });
  });
}
