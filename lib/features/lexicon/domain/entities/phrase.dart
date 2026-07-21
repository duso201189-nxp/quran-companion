import 'lexicon_entry.dart';

/// Một cụm từ cố định nhiều từ (idiom/biểu thức) trải dài qua nhiều
/// WordInstance (vd. بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ) — Sprint
/// 12 Phase 0.1 mục 2/3. NGANG HÀNG với Lemma, KHÔNG phải hậu duệ
/// trong phân cấp Root->Lemma->Lexeme->WordInstance — Phrase TỔNG HỢP
/// nhiều WordInstance lại, không nằm bên trong phân cấp đó.
class Phrase implements LexiconEntry {
  const Phrase({
    required this.id,
    required this.arabic,
    this.transliteration,
    this.meaningVi,
    this.meaningEn,
    this.wordInstanceIds = const [],
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.phrase;

  /// Toàn văn cụm từ.
  final String arabic;
  final String? transliteration;
  final String? meaningVi;
  final String? meaningEn;

  /// Danh sách WordInstance cấu thành cụm từ, theo đúng thứ tự xuất
  /// hiện.
  final List<int> wordInstanceIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phrase &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          arabic == other.arabic &&
          transliteration == other.transliteration &&
          meaningVi == other.meaningVi &&
          meaningEn == other.meaningEn &&
          _intListEquals(wordInstanceIds, other.wordInstanceIds);

  @override
  int get hashCode => Object.hash(
        id,
        arabic,
        transliteration,
        meaningVi,
        meaningEn,
        Object.hashAll(wordInstanceIds),
      );
}

/// So sánh 2 List<int> theo giá trị — thuần Dart, không phụ thuộc
/// package:flutter/foundation.dart (domain không được import Flutter).
bool _intListEquals(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
