// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, SurahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameArabicMeta =
      const VerificationMeta('nameArabic');
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
      'name_arabic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameLatinMeta =
      const VerificationMeta('nameLatin');
  @override
  late final GeneratedColumn<String> nameLatin = GeneratedColumn<String>(
      'name_latin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameViMeta = const VerificationMeta('nameVi');
  @override
  late final GeneratedColumn<String> nameVi = GeneratedColumn<String>(
      'name_vi', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ayahCountMeta =
      const VerificationMeta('ayahCount');
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
      'ayah_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _revelationPlaceMeta =
      const VerificationMeta('revelationPlace');
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
      'revelation_place', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderRevealedMeta =
      const VerificationMeta('orderRevealed');
  @override
  late final GeneratedColumn<int> orderRevealed = GeneratedColumn<int>(
      'order_revealed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nameArabic,
        nameLatin,
        nameVi,
        nameEn,
        ayahCount,
        revelationPlace,
        orderRevealed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(Insertable<SurahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
          _nameArabicMeta,
          nameArabic.isAcceptableOrUnknown(
              data['name_arabic']!, _nameArabicMeta));
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_latin')) {
      context.handle(_nameLatinMeta,
          nameLatin.isAcceptableOrUnknown(data['name_latin']!, _nameLatinMeta));
    } else if (isInserting) {
      context.missing(_nameLatinMeta);
    }
    if (data.containsKey('name_vi')) {
      context.handle(_nameViMeta,
          nameVi.isAcceptableOrUnknown(data['name_vi']!, _nameViMeta));
    } else if (isInserting) {
      context.missing(_nameViMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('ayah_count')) {
      context.handle(_ayahCountMeta,
          ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta));
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
          _revelationPlaceMeta,
          revelationPlace.isAcceptableOrUnknown(
              data['revelation_place']!, _revelationPlaceMeta));
    } else if (isInserting) {
      context.missing(_revelationPlaceMeta);
    }
    if (data.containsKey('order_revealed')) {
      context.handle(
          _orderRevealedMeta,
          orderRevealed.isAcceptableOrUnknown(
              data['order_revealed']!, _orderRevealedMeta));
    } else if (isInserting) {
      context.missing(_orderRevealedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nameArabic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_arabic'])!,
      nameLatin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_latin'])!,
      nameVi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_vi'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      ayahCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_count'])!,
      revelationPlace: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}revelation_place'])!,
      orderRevealed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_revealed'])!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class SurahRow extends DataClass implements Insertable<SurahRow> {
  /// 1..114
  final int id;
  final String nameArabic;
  final String nameLatin;
  final String nameVi;
  final String nameEn;
  final int ayahCount;

  /// 'mecca' | 'madinah'
  final String revelationPlace;
  final int orderRevealed;
  const SurahRow(
      {required this.id,
      required this.nameArabic,
      required this.nameLatin,
      required this.nameVi,
      required this.nameEn,
      required this.ayahCount,
      required this.revelationPlace,
      required this.orderRevealed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_latin'] = Variable<String>(nameLatin);
    map['name_vi'] = Variable<String>(nameVi);
    map['name_en'] = Variable<String>(nameEn);
    map['ayah_count'] = Variable<int>(ayahCount);
    map['revelation_place'] = Variable<String>(revelationPlace);
    map['order_revealed'] = Variable<int>(orderRevealed);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      id: Value(id),
      nameArabic: Value(nameArabic),
      nameLatin: Value(nameLatin),
      nameVi: Value(nameVi),
      nameEn: Value(nameEn),
      ayahCount: Value(ayahCount),
      revelationPlace: Value(revelationPlace),
      orderRevealed: Value(orderRevealed),
    );
  }

  factory SurahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahRow(
      id: serializer.fromJson<int>(json['id']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameLatin: serializer.fromJson<String>(json['nameLatin']),
      nameVi: serializer.fromJson<String>(json['nameVi']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
      revelationPlace: serializer.fromJson<String>(json['revelationPlace']),
      orderRevealed: serializer.fromJson<int>(json['orderRevealed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameLatin': serializer.toJson<String>(nameLatin),
      'nameVi': serializer.toJson<String>(nameVi),
      'nameEn': serializer.toJson<String>(nameEn),
      'ayahCount': serializer.toJson<int>(ayahCount),
      'revelationPlace': serializer.toJson<String>(revelationPlace),
      'orderRevealed': serializer.toJson<int>(orderRevealed),
    };
  }

  SurahRow copyWith(
          {int? id,
          String? nameArabic,
          String? nameLatin,
          String? nameVi,
          String? nameEn,
          int? ayahCount,
          String? revelationPlace,
          int? orderRevealed}) =>
      SurahRow(
        id: id ?? this.id,
        nameArabic: nameArabic ?? this.nameArabic,
        nameLatin: nameLatin ?? this.nameLatin,
        nameVi: nameVi ?? this.nameVi,
        nameEn: nameEn ?? this.nameEn,
        ayahCount: ayahCount ?? this.ayahCount,
        revelationPlace: revelationPlace ?? this.revelationPlace,
        orderRevealed: orderRevealed ?? this.orderRevealed,
      );
  SurahRow copyWithCompanion(SurahsCompanion data) {
    return SurahRow(
      id: data.id.present ? data.id.value : this.id,
      nameArabic:
          data.nameArabic.present ? data.nameArabic.value : this.nameArabic,
      nameLatin: data.nameLatin.present ? data.nameLatin.value : this.nameLatin,
      nameVi: data.nameVi.present ? data.nameVi.value : this.nameVi,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      orderRevealed: data.orderRevealed.present
          ? data.orderRevealed.value
          : this.orderRevealed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahRow(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('nameVi: $nameVi, ')
          ..write('nameEn: $nameEn, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('orderRevealed: $orderRevealed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameArabic, nameLatin, nameVi, nameEn,
      ayahCount, revelationPlace, orderRevealed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahRow &&
          other.id == this.id &&
          other.nameArabic == this.nameArabic &&
          other.nameLatin == this.nameLatin &&
          other.nameVi == this.nameVi &&
          other.nameEn == this.nameEn &&
          other.ayahCount == this.ayahCount &&
          other.revelationPlace == this.revelationPlace &&
          other.orderRevealed == this.orderRevealed);
}

class SurahsCompanion extends UpdateCompanion<SurahRow> {
  final Value<int> id;
  final Value<String> nameArabic;
  final Value<String> nameLatin;
  final Value<String> nameVi;
  final Value<String> nameEn;
  final Value<int> ayahCount;
  final Value<String> revelationPlace;
  final Value<int> orderRevealed;
  const SurahsCompanion({
    this.id = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameLatin = const Value.absent(),
    this.nameVi = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.orderRevealed = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.id = const Value.absent(),
    required String nameArabic,
    required String nameLatin,
    required String nameVi,
    required String nameEn,
    required int ayahCount,
    required String revelationPlace,
    required int orderRevealed,
  })  : nameArabic = Value(nameArabic),
        nameLatin = Value(nameLatin),
        nameVi = Value(nameVi),
        nameEn = Value(nameEn),
        ayahCount = Value(ayahCount),
        revelationPlace = Value(revelationPlace),
        orderRevealed = Value(orderRevealed);
  static Insertable<SurahRow> custom({
    Expression<int>? id,
    Expression<String>? nameArabic,
    Expression<String>? nameLatin,
    Expression<String>? nameVi,
    Expression<String>? nameEn,
    Expression<int>? ayahCount,
    Expression<String>? revelationPlace,
    Expression<int>? orderRevealed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameLatin != null) 'name_latin': nameLatin,
      if (nameVi != null) 'name_vi': nameVi,
      if (nameEn != null) 'name_en': nameEn,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (orderRevealed != null) 'order_revealed': orderRevealed,
    });
  }

  SurahsCompanion copyWith(
      {Value<int>? id,
      Value<String>? nameArabic,
      Value<String>? nameLatin,
      Value<String>? nameVi,
      Value<String>? nameEn,
      Value<int>? ayahCount,
      Value<String>? revelationPlace,
      Value<int>? orderRevealed}) {
    return SurahsCompanion(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameLatin: nameLatin ?? this.nameLatin,
      nameVi: nameVi ?? this.nameVi,
      nameEn: nameEn ?? this.nameEn,
      ayahCount: ayahCount ?? this.ayahCount,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      orderRevealed: orderRevealed ?? this.orderRevealed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameLatin.present) {
      map['name_latin'] = Variable<String>(nameLatin.value);
    }
    if (nameVi.present) {
      map['name_vi'] = Variable<String>(nameVi.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (orderRevealed.present) {
      map['order_revealed'] = Variable<int>(orderRevealed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('nameVi: $nameVi, ')
          ..write('nameEn: $nameEn, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('orderRevealed: $orderRevealed')
          ..write(')'))
        .toString();
  }
}

class $AyahsTable extends Ayahs with TableInfo<$AyahsTable, AyahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _surahIdMeta =
      const VerificationMeta('surahId');
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
      'surah_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surahs (id)'));
  static const VerificationMeta _ayahNumberMeta =
      const VerificationMeta('ayahNumber');
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
      'ayah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _textUthmaniMeta =
      const VerificationMeta('textUthmani');
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
      'text_uthmani', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
      'juz', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  @override
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
      'hizb', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
      'page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sajdahMeta = const VerificationMeta('sajdah');
  @override
  late final GeneratedColumn<bool> sajdah = GeneratedColumn<bool>(
      'sajdah', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("sajdah" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, surahId, ayahNumber, textUthmani, juz, hizb, page, sajdah];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayahs';
  @override
  VerificationContext validateIntegrity(Insertable<AyahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(_surahIdMeta,
          surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta));
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
          _ayahNumberMeta,
          ayahNumber.isAcceptableOrUnknown(
              data['ayah_number']!, _ayahNumberMeta));
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
          _textUthmaniMeta,
          textUthmani.isAcceptableOrUnknown(
              data['text_uthmani']!, _textUthmaniMeta));
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
          _juzMeta, juz.isAcceptableOrUnknown(data['juz']!, _juzMeta));
    }
    if (data.containsKey('hizb')) {
      context.handle(
          _hizbMeta, hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta));
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    }
    if (data.containsKey('sajdah')) {
      context.handle(_sajdahMeta,
          sajdah.isAcceptableOrUnknown(data['sajdah']!, _sajdahMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AyahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      surahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_id'])!,
      ayahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_number'])!,
      textUthmani: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_uthmani'])!,
      juz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}juz']),
      hizb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hizb']),
      page: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page']),
      sajdah: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sajdah'])!,
    );
  }

  @override
  $AyahsTable createAlias(String alias) {
    return $AyahsTable(attachedDatabase, alias);
  }
}

class AyahRow extends DataClass implements Insertable<AyahRow> {
  /// Đánh số toàn cục 1..6236.
  final int id;
  final int surahId;

  /// Số Ayah trong Surah.
  final int ayahNumber;
  final String textUthmani;
  final int? juz;
  final int? hizb;
  final int? page;

  /// Ayah có vị trí quỳ lạy (sajdah tilawah) hay không.
  final bool sajdah;
  const AyahRow(
      {required this.id,
      required this.surahId,
      required this.ayahNumber,
      required this.textUthmani,
      this.juz,
      this.hizb,
      this.page,
      required this.sajdah});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['text_uthmani'] = Variable<String>(textUthmani);
    if (!nullToAbsent || juz != null) {
      map['juz'] = Variable<int>(juz);
    }
    if (!nullToAbsent || hizb != null) {
      map['hizb'] = Variable<int>(hizb);
    }
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    map['sajdah'] = Variable<bool>(sajdah);
    return map;
  }

  AyahsCompanion toCompanion(bool nullToAbsent) {
    return AyahsCompanion(
      id: Value(id),
      surahId: Value(surahId),
      ayahNumber: Value(ayahNumber),
      textUthmani: Value(textUthmani),
      juz: juz == null && nullToAbsent ? const Value.absent() : Value(juz),
      hizb: hizb == null && nullToAbsent ? const Value.absent() : Value(hizb),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      sajdah: Value(sajdah),
    );
  }

  factory AyahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahRow(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      textUthmani: serializer.fromJson<String>(json['textUthmani']),
      juz: serializer.fromJson<int?>(json['juz']),
      hizb: serializer.fromJson<int?>(json['hizb']),
      page: serializer.fromJson<int?>(json['page']),
      sajdah: serializer.fromJson<bool>(json['sajdah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'textUthmani': serializer.toJson<String>(textUthmani),
      'juz': serializer.toJson<int?>(juz),
      'hizb': serializer.toJson<int?>(hizb),
      'page': serializer.toJson<int?>(page),
      'sajdah': serializer.toJson<bool>(sajdah),
    };
  }

  AyahRow copyWith(
          {int? id,
          int? surahId,
          int? ayahNumber,
          String? textUthmani,
          Value<int?> juz = const Value.absent(),
          Value<int?> hizb = const Value.absent(),
          Value<int?> page = const Value.absent(),
          bool? sajdah}) =>
      AyahRow(
        id: id ?? this.id,
        surahId: surahId ?? this.surahId,
        ayahNumber: ayahNumber ?? this.ayahNumber,
        textUthmani: textUthmani ?? this.textUthmani,
        juz: juz.present ? juz.value : this.juz,
        hizb: hizb.present ? hizb.value : this.hizb,
        page: page.present ? page.value : this.page,
        sajdah: sajdah ?? this.sajdah,
      );
  AyahRow copyWithCompanion(AyahsCompanion data) {
    return AyahRow(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber:
          data.ayahNumber.present ? data.ayahNumber.value : this.ayahNumber,
      textUthmani:
          data.textUthmani.present ? data.textUthmani.value : this.textUthmani,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
      page: data.page.present ? data.page.value : this.page,
      sajdah: data.sajdah.present ? data.sajdah.value : this.sajdah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahRow(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('page: $page, ')
          ..write('sajdah: $sajdah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, surahId, ayahNumber, textUthmani, juz, hizb, page, sajdah);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahRow &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.textUthmani == this.textUthmani &&
          other.juz == this.juz &&
          other.hizb == this.hizb &&
          other.page == this.page &&
          other.sajdah == this.sajdah);
}

class AyahsCompanion extends UpdateCompanion<AyahRow> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> ayahNumber;
  final Value<String> textUthmani;
  final Value<int?> juz;
  final Value<int?> hizb;
  final Value<int?> page;
  final Value<bool> sajdah;
  const AyahsCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.page = const Value.absent(),
    this.sajdah = const Value.absent(),
  });
  AyahsCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int ayahNumber,
    required String textUthmani,
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.page = const Value.absent(),
    this.sajdah = const Value.absent(),
  })  : surahId = Value(surahId),
        ayahNumber = Value(ayahNumber),
        textUthmani = Value(textUthmani);
  static Insertable<AyahRow> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<String>? textUthmani,
    Expression<int>? juz,
    Expression<int>? hizb,
    Expression<int>? page,
    Expression<bool>? sajdah,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (juz != null) 'juz': juz,
      if (hizb != null) 'hizb': hizb,
      if (page != null) 'page': page,
      if (sajdah != null) 'sajdah': sajdah,
    });
  }

  AyahsCompanion copyWith(
      {Value<int>? id,
      Value<int>? surahId,
      Value<int>? ayahNumber,
      Value<String>? textUthmani,
      Value<int?>? juz,
      Value<int?>? hizb,
      Value<int?>? page,
      Value<bool>? sajdah}) {
    return AyahsCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      textUthmani: textUthmani ?? this.textUthmani,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      page: page ?? this.page,
      sajdah: sajdah ?? this.sajdah,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (sajdah.present) {
      map['sajdah'] = Variable<bool>(sajdah.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahsCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('page: $page, ')
          ..write('sajdah: $sajdah')
          ..write(')'))
        .toString();
  }
}

class $TranslationSourcesTable extends TranslationSources
    with TableInfo<$TranslationSourcesTable, TranslationSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _licenseMeta =
      const VerificationMeta('license');
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
      'license', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        name,
        language,
        author,
        type,
        isEnabled,
        displayOrder,
        license,
        sourceUrl,
        version,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_sources';
  @override
  VerificationContext validateIntegrity(
      Insertable<TranslationSourceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('license')) {
      context.handle(_licenseMeta,
          license.isAcceptableOrUnknown(data['license']!, _licenseMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslationSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationSourceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      license: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $TranslationSourcesTable createAlias(String alias) {
    return $TranslationSourcesTable(attachedDatabase, alias);
  }
}

class TranslationSourceRow extends DataClass
    implements Insertable<TranslationSourceRow> {
  final int id;

  /// Định danh ổn định: 'vi_main', 'en_sahih', 'translit_latin'...
  final String code;
  final String name;
  final String language;
  final String? author;

  /// 'translation' | 'transliteration' | 'tafsir'
  final String type;
  final bool isEnabled;
  final int displayOrder;

  /// Giấy phép sử dụng (vd: 'Tanzil terms', 'CC BY-ND'...).
  final String? license;

  /// URL gốc của nguồn.
  final String? sourceUrl;

  /// Phiên bản nguồn (nếu nguồn công bố).
  final String? version;

  /// Ngày import (ISO 8601).
  final String? updatedAt;
  const TranslationSourceRow(
      {required this.id,
      required this.code,
      required this.name,
      required this.language,
      this.author,
      required this.type,
      required this.isEnabled,
      required this.displayOrder,
      this.license,
      this.sourceUrl,
      this.version,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['type'] = Variable<String>(type);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TranslationSourcesCompanion toCompanion(bool nullToAbsent) {
    return TranslationSourcesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      language: Value(language),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      type: Value(type),
      isEnabled: Value(isEnabled),
      displayOrder: Value(displayOrder),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TranslationSourceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationSourceRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      author: serializer.fromJson<String?>(json['author']),
      type: serializer.fromJson<String>(json['type']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      license: serializer.fromJson<String?>(json['license']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      version: serializer.fromJson<String?>(json['version']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'author': serializer.toJson<String?>(author),
      'type': serializer.toJson<String>(type),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'license': serializer.toJson<String?>(license),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'version': serializer.toJson<String?>(version),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  TranslationSourceRow copyWith(
          {int? id,
          String? code,
          String? name,
          String? language,
          Value<String?> author = const Value.absent(),
          String? type,
          bool? isEnabled,
          int? displayOrder,
          Value<String?> license = const Value.absent(),
          Value<String?> sourceUrl = const Value.absent(),
          Value<String?> version = const Value.absent(),
          Value<String?> updatedAt = const Value.absent()}) =>
      TranslationSourceRow(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        language: language ?? this.language,
        author: author.present ? author.value : this.author,
        type: type ?? this.type,
        isEnabled: isEnabled ?? this.isEnabled,
        displayOrder: displayOrder ?? this.displayOrder,
        license: license.present ? license.value : this.license,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        version: version.present ? version.value : this.version,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  TranslationSourceRow copyWithCompanion(TranslationSourcesCompanion data) {
    return TranslationSourceRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      language: data.language.present ? data.language.value : this.language,
      author: data.author.present ? data.author.value : this.author,
      type: data.type.present ? data.type.value : this.type,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      license: data.license.present ? data.license.value : this.license,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationSourceRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('license: $license, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, language, author, type,
      isEnabled, displayOrder, license, sourceUrl, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationSourceRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.language == this.language &&
          other.author == this.author &&
          other.type == this.type &&
          other.isEnabled == this.isEnabled &&
          other.displayOrder == this.displayOrder &&
          other.license == this.license &&
          other.sourceUrl == this.sourceUrl &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class TranslationSourcesCompanion
    extends UpdateCompanion<TranslationSourceRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> language;
  final Value<String?> author;
  final Value<String> type;
  final Value<bool> isEnabled;
  final Value<int> displayOrder;
  final Value<String?> license;
  final Value<String?> sourceUrl;
  final Value<String?> version;
  final Value<String?> updatedAt;
  const TranslationSourcesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.author = const Value.absent(),
    this.type = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.license = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TranslationSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    required String language,
    this.author = const Value.absent(),
    required String type,
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.license = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        language = Value(language),
        type = Value(type);
  static Insertable<TranslationSourceRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? author,
    Expression<String>? type,
    Expression<bool>? isEnabled,
    Expression<int>? displayOrder,
    Expression<String>? license,
    Expression<String>? sourceUrl,
    Expression<String>? version,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (author != null) 'author': author,
      if (type != null) 'type': type,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (displayOrder != null) 'display_order': displayOrder,
      if (license != null) 'license': license,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TranslationSourcesCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? language,
      Value<String?>? author,
      Value<String>? type,
      Value<bool>? isEnabled,
      Value<int>? displayOrder,
      Value<String?>? license,
      Value<String?>? sourceUrl,
      Value<String?>? version,
      Value<String?>? updatedAt}) {
    return TranslationSourcesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      language: language ?? this.language,
      author: author ?? this.author,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
      license: license ?? this.license,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationSourcesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('license: $license, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TranslationsTable extends Translations
    with TableInfo<$TranslationsTable, TranslationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES translation_sources (id)'));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ayahs (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [sourceId, ayahId, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translations';
  @override
  VerificationContext validateIntegrity(Insertable<TranslationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['text']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, ayahId};
  @override
  TranslationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationRow(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text'])!,
    );
  }

  @override
  $TranslationsTable createAlias(String alias) {
    return $TranslationsTable(attachedDatabase, alias);
  }
}

class TranslationRow extends DataClass implements Insertable<TranslationRow> {
  final int sourceId;
  final int ayahId;

  /// Getter không thể tên `text` (trùng hàm builder của Drift)
  /// nên đặt `content`, ánh xạ sang cột SQL 'text'.
  final String content;
  const TranslationRow(
      {required this.sourceId, required this.ayahId, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<int>(sourceId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['text'] = Variable<String>(content);
    return map;
  }

  TranslationsCompanion toCompanion(bool nullToAbsent) {
    return TranslationsCompanion(
      sourceId: Value(sourceId),
      ayahId: Value(ayahId),
      content: Value(content),
    );
  }

  factory TranslationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationRow(
      sourceId: serializer.fromJson<int>(json['sourceId']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<int>(sourceId),
      'ayahId': serializer.toJson<int>(ayahId),
      'content': serializer.toJson<String>(content),
    };
  }

  TranslationRow copyWith({int? sourceId, int? ayahId, String? content}) =>
      TranslationRow(
        sourceId: sourceId ?? this.sourceId,
        ayahId: ayahId ?? this.ayahId,
        content: content ?? this.content,
      );
  TranslationRow copyWithCompanion(TranslationsCompanion data) {
    return TranslationRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationRow(')
          ..write('sourceId: $sourceId, ')
          ..write('ayahId: $ayahId, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, ayahId, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationRow &&
          other.sourceId == this.sourceId &&
          other.ayahId == this.ayahId &&
          other.content == this.content);
}

class TranslationsCompanion extends UpdateCompanion<TranslationRow> {
  final Value<int> sourceId;
  final Value<int> ayahId;
  final Value<String> content;
  final Value<int> rowid;
  const TranslationsCompanion({
    this.sourceId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationsCompanion.insert({
    required int sourceId,
    required int ayahId,
    required String content,
    this.rowid = const Value.absent(),
  })  : sourceId = Value(sourceId),
        ayahId = Value(ayahId),
        content = Value(content);
  static Insertable<TranslationRow> custom({
    Expression<int>? sourceId,
    Expression<int>? ayahId,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (content != null) 'text': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationsCompanion copyWith(
      {Value<int>? sourceId,
      Value<int>? ayahId,
      Value<String>? content,
      Value<int>? rowid}) {
    return TranslationsCompanion(
      sourceId: sourceId ?? this.sourceId,
      ayahId: ayahId ?? this.ayahId,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('ayahId: $ayahId, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecitersTable extends Reciters
    with TableInfo<$RecitersTable, ReciterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecitersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameArabicMeta =
      const VerificationMeta('nameArabic');
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
      'name_arabic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlTemplateMeta =
      const VerificationMeta('audioUrlTemplate');
  @override
  late final GeneratedColumn<String> audioUrlTemplate = GeneratedColumn<String>(
      'audio_url_template', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bitrateKbpsMeta =
      const VerificationMeta('bitrateKbps');
  @override
  late final GeneratedColumn<int> bitrateKbps = GeneratedColumn<int>(
      'bitrate_kbps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _licenseMeta =
      const VerificationMeta('license');
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
      'license', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        code,
        name,
        nameArabic,
        audioUrlTemplate,
        bitrateKbps,
        license,
        sourceUrl,
        isEnabled,
        displayOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reciters';
  @override
  VerificationContext validateIntegrity(Insertable<ReciterRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
          _nameArabicMeta,
          nameArabic.isAcceptableOrUnknown(
              data['name_arabic']!, _nameArabicMeta));
    }
    if (data.containsKey('audio_url_template')) {
      context.handle(
          _audioUrlTemplateMeta,
          audioUrlTemplate.isAcceptableOrUnknown(
              data['audio_url_template']!, _audioUrlTemplateMeta));
    } else if (isInserting) {
      context.missing(_audioUrlTemplateMeta);
    }
    if (data.containsKey('bitrate_kbps')) {
      context.handle(
          _bitrateKbpsMeta,
          bitrateKbps.isAcceptableOrUnknown(
              data['bitrate_kbps']!, _bitrateKbpsMeta));
    }
    if (data.containsKey('license')) {
      context.handle(_licenseMeta,
          license.isAcceptableOrUnknown(data['license']!, _licenseMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReciterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReciterRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameArabic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_arabic']),
      audioUrlTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}audio_url_template'])!,
      bitrateKbps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bitrate_kbps']),
      license: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
    );
  }

  @override
  $RecitersTable createAlias(String alias) {
    return $RecitersTable(attachedDatabase, alias);
  }
}

class ReciterRow extends DataClass implements Insertable<ReciterRow> {
  final int id;
  final String code;
  final String name;
  final String? nameArabic;

  /// Mẫu URL audio, vd:
  /// https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3
  final String audioUrlTemplate;
  final int? bitrateKbps;
  final String? license;
  final String? sourceUrl;
  final bool isEnabled;
  final int displayOrder;
  const ReciterRow(
      {required this.id,
      required this.code,
      required this.name,
      this.nameArabic,
      required this.audioUrlTemplate,
      this.bitrateKbps,
      this.license,
      this.sourceUrl,
      required this.isEnabled,
      required this.displayOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameArabic != null) {
      map['name_arabic'] = Variable<String>(nameArabic);
    }
    map['audio_url_template'] = Variable<String>(audioUrlTemplate);
    if (!nullToAbsent || bitrateKbps != null) {
      map['bitrate_kbps'] = Variable<int>(bitrateKbps);
    }
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  RecitersCompanion toCompanion(bool nullToAbsent) {
    return RecitersCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      nameArabic: nameArabic == null && nullToAbsent
          ? const Value.absent()
          : Value(nameArabic),
      audioUrlTemplate: Value(audioUrlTemplate),
      bitrateKbps: bitrateKbps == null && nullToAbsent
          ? const Value.absent()
          : Value(bitrateKbps),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      isEnabled: Value(isEnabled),
      displayOrder: Value(displayOrder),
    );
  }

  factory ReciterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReciterRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      nameArabic: serializer.fromJson<String?>(json['nameArabic']),
      audioUrlTemplate: serializer.fromJson<String>(json['audioUrlTemplate']),
      bitrateKbps: serializer.fromJson<int?>(json['bitrateKbps']),
      license: serializer.fromJson<String?>(json['license']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'nameArabic': serializer.toJson<String?>(nameArabic),
      'audioUrlTemplate': serializer.toJson<String>(audioUrlTemplate),
      'bitrateKbps': serializer.toJson<int?>(bitrateKbps),
      'license': serializer.toJson<String?>(license),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  ReciterRow copyWith(
          {int? id,
          String? code,
          String? name,
          Value<String?> nameArabic = const Value.absent(),
          String? audioUrlTemplate,
          Value<int?> bitrateKbps = const Value.absent(),
          Value<String?> license = const Value.absent(),
          Value<String?> sourceUrl = const Value.absent(),
          bool? isEnabled,
          int? displayOrder}) =>
      ReciterRow(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        nameArabic: nameArabic.present ? nameArabic.value : this.nameArabic,
        audioUrlTemplate: audioUrlTemplate ?? this.audioUrlTemplate,
        bitrateKbps: bitrateKbps.present ? bitrateKbps.value : this.bitrateKbps,
        license: license.present ? license.value : this.license,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        isEnabled: isEnabled ?? this.isEnabled,
        displayOrder: displayOrder ?? this.displayOrder,
      );
  ReciterRow copyWithCompanion(RecitersCompanion data) {
    return ReciterRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      nameArabic:
          data.nameArabic.present ? data.nameArabic.value : this.nameArabic,
      audioUrlTemplate: data.audioUrlTemplate.present
          ? data.audioUrlTemplate.value
          : this.audioUrlTemplate,
      bitrateKbps:
          data.bitrateKbps.present ? data.bitrateKbps.value : this.bitrateKbps,
      license: data.license.present ? data.license.value : this.license,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReciterRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('audioUrlTemplate: $audioUrlTemplate, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('license: $license, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, nameArabic, audioUrlTemplate,
      bitrateKbps, license, sourceUrl, isEnabled, displayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReciterRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.nameArabic == this.nameArabic &&
          other.audioUrlTemplate == this.audioUrlTemplate &&
          other.bitrateKbps == this.bitrateKbps &&
          other.license == this.license &&
          other.sourceUrl == this.sourceUrl &&
          other.isEnabled == this.isEnabled &&
          other.displayOrder == this.displayOrder);
}

class RecitersCompanion extends UpdateCompanion<ReciterRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> nameArabic;
  final Value<String> audioUrlTemplate;
  final Value<int?> bitrateKbps;
  final Value<String?> license;
  final Value<String?> sourceUrl;
  final Value<bool> isEnabled;
  final Value<int> displayOrder;
  const RecitersCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.audioUrlTemplate = const Value.absent(),
    this.bitrateKbps = const Value.absent(),
    this.license = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  RecitersCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    this.nameArabic = const Value.absent(),
    required String audioUrlTemplate,
    this.bitrateKbps = const Value.absent(),
    this.license = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.displayOrder = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        audioUrlTemplate = Value(audioUrlTemplate);
  static Insertable<ReciterRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? nameArabic,
    Expression<String>? audioUrlTemplate,
    Expression<int>? bitrateKbps,
    Expression<String>? license,
    Expression<String>? sourceUrl,
    Expression<bool>? isEnabled,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (audioUrlTemplate != null) 'audio_url_template': audioUrlTemplate,
      if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
      if (license != null) 'license': license,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  RecitersCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String?>? nameArabic,
      Value<String>? audioUrlTemplate,
      Value<int?>? bitrateKbps,
      Value<String?>? license,
      Value<String?>? sourceUrl,
      Value<bool>? isEnabled,
      Value<int>? displayOrder}) {
    return RecitersCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      audioUrlTemplate: audioUrlTemplate ?? this.audioUrlTemplate,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      license: license ?? this.license,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (audioUrlTemplate.present) {
      map['audio_url_template'] = Variable<String>(audioUrlTemplate.value);
    }
    if (bitrateKbps.present) {
      map['bitrate_kbps'] = Variable<int>(bitrateKbps.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecitersCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('audioUrlTemplate: $audioUrlTemplate, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('license: $license, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

class $MetaEntriesTable extends MetaEntries
    with TableInfo<$MetaEntriesTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaEntriesTable createAlias(String alias) {
    return $MetaEntriesTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MetaEntriesCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory MetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) => MetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  MetaRow copyWithCompanion(MetaEntriesCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaEntriesCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaEntriesCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return MetaEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $AyahsTable ayahs = $AyahsTable(this);
  late final $TranslationSourcesTable translationSources =
      $TranslationSourcesTable(this);
  late final $TranslationsTable translations = $TranslationsTable(this);
  late final $RecitersTable reciters = $RecitersTable(this);
  late final $MetaEntriesTable metaEntries = $MetaEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [surahs, ayahs, translationSources, translations, reciters, metaEntries];
}

typedef $$SurahsTableCreateCompanionBuilder = SurahsCompanion Function({
  Value<int> id,
  required String nameArabic,
  required String nameLatin,
  required String nameVi,
  required String nameEn,
  required int ayahCount,
  required String revelationPlace,
  required int orderRevealed,
});
typedef $$SurahsTableUpdateCompanionBuilder = SurahsCompanion Function({
  Value<int> id,
  Value<String> nameArabic,
  Value<String> nameLatin,
  Value<String> nameVi,
  Value<String> nameEn,
  Value<int> ayahCount,
  Value<String> revelationPlace,
  Value<int> orderRevealed,
});

final class $$SurahsTableReferences
    extends BaseReferences<_$AppDatabase, $SurahsTable, SurahRow> {
  $$SurahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AyahsTable, List<AyahRow>> _ayahsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.ayahs,
          aliasName: 'surahs__id__ayahs__surah_id');

  $$AyahsTableProcessedTableManager get ayahsRefs {
    final manager = $$AyahsTableTableManager($_db, $_db.ayahs)
        .filter((f) => f.surahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ayahsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SurahsTableFilterComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameLatin => $composableBuilder(
      column: $table.nameLatin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameVi => $composableBuilder(
      column: $table.nameVi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahCount => $composableBuilder(
      column: $table.ayahCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderRevealed => $composableBuilder(
      column: $table.orderRevealed, builder: (column) => ColumnFilters(column));

  Expression<bool> ayahsRefs(
      Expression<bool> Function($$AyahsTableFilterComposer f) f) {
    final $$AyahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ayahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyahsTableFilterComposer(
              $db: $db,
              $table: $db.ayahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurahsTableOrderingComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameLatin => $composableBuilder(
      column: $table.nameLatin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameVi => $composableBuilder(
      column: $table.nameVi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahCount => $composableBuilder(
      column: $table.ayahCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderRevealed => $composableBuilder(
      column: $table.orderRevealed,
      builder: (column) => ColumnOrderings(column));
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => column);

  GeneratedColumn<String> get nameLatin =>
      $composableBuilder(column: $table.nameLatin, builder: (column) => column);

  GeneratedColumn<String> get nameVi =>
      $composableBuilder(column: $table.nameVi, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
      column: $table.revelationPlace, builder: (column) => column);

  GeneratedColumn<int> get orderRevealed => $composableBuilder(
      column: $table.orderRevealed, builder: (column) => column);

  Expression<T> ayahsRefs<T extends Object>(
      Expression<T> Function($$AyahsTableAnnotationComposer a) f) {
    final $$AyahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ayahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyahsTableAnnotationComposer(
              $db: $db,
              $table: $db.ayahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurahsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, $$SurahsTableReferences),
    SurahRow,
    PrefetchHooks Function({bool ayahsRefs})> {
  $$SurahsTableTableManager(_$AppDatabase db, $SurahsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nameArabic = const Value.absent(),
            Value<String> nameLatin = const Value.absent(),
            Value<String> nameVi = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<int> ayahCount = const Value.absent(),
            Value<String> revelationPlace = const Value.absent(),
            Value<int> orderRevealed = const Value.absent(),
          }) =>
              SurahsCompanion(
            id: id,
            nameArabic: nameArabic,
            nameLatin: nameLatin,
            nameVi: nameVi,
            nameEn: nameEn,
            ayahCount: ayahCount,
            revelationPlace: revelationPlace,
            orderRevealed: orderRevealed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nameArabic,
            required String nameLatin,
            required String nameVi,
            required String nameEn,
            required int ayahCount,
            required String revelationPlace,
            required int orderRevealed,
          }) =>
              SurahsCompanion.insert(
            id: id,
            nameArabic: nameArabic,
            nameLatin: nameLatin,
            nameVi: nameVi,
            nameEn: nameEn,
            ayahCount: ayahCount,
            revelationPlace: revelationPlace,
            orderRevealed: orderRevealed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SurahsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ayahsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ayahsRefs) db.ayahs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ayahsRefs)
                    await $_getPrefetchedData<SurahRow, $SurahsTable, AyahRow>(
                        currentTable: table,
                        referencedTable:
                            $$SurahsTableReferences._ayahsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurahsTableReferences(db, table, p0).ayahsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.surahId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SurahsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, $$SurahsTableReferences),
    SurahRow,
    PrefetchHooks Function({bool ayahsRefs})>;
typedef $$AyahsTableCreateCompanionBuilder = AyahsCompanion Function({
  Value<int> id,
  required int surahId,
  required int ayahNumber,
  required String textUthmani,
  Value<int?> juz,
  Value<int?> hizb,
  Value<int?> page,
  Value<bool> sajdah,
});
typedef $$AyahsTableUpdateCompanionBuilder = AyahsCompanion Function({
  Value<int> id,
  Value<int> surahId,
  Value<int> ayahNumber,
  Value<String> textUthmani,
  Value<int?> juz,
  Value<int?> hizb,
  Value<int?> page,
  Value<bool> sajdah,
});

final class $$AyahsTableReferences
    extends BaseReferences<_$AppDatabase, $AyahsTable, AyahRow> {
  $$AyahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahsTable _surahIdTable(_$AppDatabase db) =>
      db.surahs.createAlias('ayahs__surah_id__surahs__id');

  $$SurahsTableProcessedTableManager get surahId {
    final $_column = $_itemColumn<int>('surah_id')!;

    final manager = $$SurahsTableTableManager($_db, $_db.surahs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TranslationsTable, List<TranslationRow>>
      _translationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.translations,
              aliasName: 'ayahs__id__translations__ayah_id');

  $$TranslationsTableProcessedTableManager get translationsRefs {
    final manager = $$TranslationsTableTableManager($_db, $_db.translations)
        .filter((f) => f.ayahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_translationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AyahsTableFilterComposer extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sajdah => $composableBuilder(
      column: $table.sajdah, builder: (column) => ColumnFilters(column));

  $$SurahsTableFilterComposer get surahId {
    final $$SurahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableFilterComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> translationsRefs(
      Expression<bool> Function($$TranslationsTableFilterComposer f) f) {
    final $$TranslationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.translations,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationsTableFilterComposer(
              $db: $db,
              $table: $db.translations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AyahsTableOrderingComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sajdah => $composableBuilder(
      column: $table.sajdah, builder: (column) => ColumnOrderings(column));

  $$SurahsTableOrderingComposer get surahId {
    final $$SurahsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableOrderingComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AyahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => column);

  GeneratedColumn<String> get textUthmani => $composableBuilder(
      column: $table.textUthmani, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<bool> get sajdah =>
      $composableBuilder(column: $table.sajdah, builder: (column) => column);

  $$SurahsTableAnnotationComposer get surahId {
    final $$SurahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableAnnotationComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> translationsRefs<T extends Object>(
      Expression<T> Function($$TranslationsTableAnnotationComposer a) f) {
    final $$TranslationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.translations,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationsTableAnnotationComposer(
              $db: $db,
              $table: $db.translations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AyahsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AyahsTable,
    AyahRow,
    $$AyahsTableFilterComposer,
    $$AyahsTableOrderingComposer,
    $$AyahsTableAnnotationComposer,
    $$AyahsTableCreateCompanionBuilder,
    $$AyahsTableUpdateCompanionBuilder,
    (AyahRow, $$AyahsTableReferences),
    AyahRow,
    PrefetchHooks Function({bool surahId, bool translationsRefs})> {
  $$AyahsTableTableManager(_$AppDatabase db, $AyahsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> surahId = const Value.absent(),
            Value<int> ayahNumber = const Value.absent(),
            Value<String> textUthmani = const Value.absent(),
            Value<int?> juz = const Value.absent(),
            Value<int?> hizb = const Value.absent(),
            Value<int?> page = const Value.absent(),
            Value<bool> sajdah = const Value.absent(),
          }) =>
              AyahsCompanion(
            id: id,
            surahId: surahId,
            ayahNumber: ayahNumber,
            textUthmani: textUthmani,
            juz: juz,
            hizb: hizb,
            page: page,
            sajdah: sajdah,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int surahId,
            required int ayahNumber,
            required String textUthmani,
            Value<int?> juz = const Value.absent(),
            Value<int?> hizb = const Value.absent(),
            Value<int?> page = const Value.absent(),
            Value<bool> sajdah = const Value.absent(),
          }) =>
              AyahsCompanion.insert(
            id: id,
            surahId: surahId,
            ayahNumber: ayahNumber,
            textUthmani: textUthmani,
            juz: juz,
            hizb: hizb,
            page: page,
            sajdah: sajdah,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AyahsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({surahId = false, translationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (translationsRefs) db.translations],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (surahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surahId,
                    referencedTable: $$AyahsTableReferences._surahIdTable(db),
                    referencedColumn:
                        $$AyahsTableReferences._surahIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (translationsRefs)
                    await $_getPrefetchedData<AyahRow, $AyahsTable,
                            TranslationRow>(
                        currentTable: table,
                        referencedTable:
                            $$AyahsTableReferences._translationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AyahsTableReferences(db, table, p0)
                                .translationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ayahId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AyahsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AyahsTable,
    AyahRow,
    $$AyahsTableFilterComposer,
    $$AyahsTableOrderingComposer,
    $$AyahsTableAnnotationComposer,
    $$AyahsTableCreateCompanionBuilder,
    $$AyahsTableUpdateCompanionBuilder,
    (AyahRow, $$AyahsTableReferences),
    AyahRow,
    PrefetchHooks Function({bool surahId, bool translationsRefs})>;
typedef $$TranslationSourcesTableCreateCompanionBuilder
    = TranslationSourcesCompanion Function({
  Value<int> id,
  required String code,
  required String name,
  required String language,
  Value<String?> author,
  required String type,
  Value<bool> isEnabled,
  Value<int> displayOrder,
  Value<String?> license,
  Value<String?> sourceUrl,
  Value<String?> version,
  Value<String?> updatedAt,
});
typedef $$TranslationSourcesTableUpdateCompanionBuilder
    = TranslationSourcesCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> name,
  Value<String> language,
  Value<String?> author,
  Value<String> type,
  Value<bool> isEnabled,
  Value<int> displayOrder,
  Value<String?> license,
  Value<String?> sourceUrl,
  Value<String?> version,
  Value<String?> updatedAt,
});

final class $$TranslationSourcesTableReferences extends BaseReferences<
    _$AppDatabase, $TranslationSourcesTable, TranslationSourceRow> {
  $$TranslationSourcesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TranslationsTable, List<TranslationRow>>
      _translationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.translations,
              aliasName: 'translation_sources__id__translations__source_id');

  $$TranslationsTableProcessedTableManager get translationsRefs {
    final manager = $$TranslationsTableTableManager($_db, $_db.translations)
        .filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_translationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TranslationSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationSourcesTable> {
  $$TranslationSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> translationsRefs(
      Expression<bool> Function($$TranslationsTableFilterComposer f) f) {
    final $$TranslationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.translations,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationsTableFilterComposer(
              $db: $db,
              $table: $db.translations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TranslationSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationSourcesTable> {
  $$TranslationSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TranslationSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationSourcesTable> {
  $$TranslationSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> translationsRefs<T extends Object>(
      Expression<T> Function($$TranslationsTableAnnotationComposer a) f) {
    final $$TranslationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.translations,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationsTableAnnotationComposer(
              $db: $db,
              $table: $db.translations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TranslationSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TranslationSourcesTable,
    TranslationSourceRow,
    $$TranslationSourcesTableFilterComposer,
    $$TranslationSourcesTableOrderingComposer,
    $$TranslationSourcesTableAnnotationComposer,
    $$TranslationSourcesTableCreateCompanionBuilder,
    $$TranslationSourcesTableUpdateCompanionBuilder,
    (TranslationSourceRow, $$TranslationSourcesTableReferences),
    TranslationSourceRow,
    PrefetchHooks Function({bool translationsRefs})> {
  $$TranslationSourcesTableTableManager(
      _$AppDatabase db, $TranslationSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationSourcesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> license = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> version = const Value.absent(),
            Value<String?> updatedAt = const Value.absent(),
          }) =>
              TranslationSourcesCompanion(
            id: id,
            code: code,
            name: name,
            language: language,
            author: author,
            type: type,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            license: license,
            sourceUrl: sourceUrl,
            version: version,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String name,
            required String language,
            Value<String?> author = const Value.absent(),
            required String type,
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> license = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<String?> version = const Value.absent(),
            Value<String?> updatedAt = const Value.absent(),
          }) =>
              TranslationSourcesCompanion.insert(
            id: id,
            code: code,
            name: name,
            language: language,
            author: author,
            type: type,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
            license: license,
            sourceUrl: sourceUrl,
            version: version,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TranslationSourcesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({translationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (translationsRefs) db.translations],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (translationsRefs)
                    await $_getPrefetchedData<TranslationSourceRow,
                            $TranslationSourcesTable, TranslationRow>(
                        currentTable: table,
                        referencedTable: $$TranslationSourcesTableReferences
                            ._translationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TranslationSourcesTableReferences(db, table, p0)
                                .translationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sourceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TranslationSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TranslationSourcesTable,
    TranslationSourceRow,
    $$TranslationSourcesTableFilterComposer,
    $$TranslationSourcesTableOrderingComposer,
    $$TranslationSourcesTableAnnotationComposer,
    $$TranslationSourcesTableCreateCompanionBuilder,
    $$TranslationSourcesTableUpdateCompanionBuilder,
    (TranslationSourceRow, $$TranslationSourcesTableReferences),
    TranslationSourceRow,
    PrefetchHooks Function({bool translationsRefs})>;
typedef $$TranslationsTableCreateCompanionBuilder = TranslationsCompanion
    Function({
  required int sourceId,
  required int ayahId,
  required String content,
  Value<int> rowid,
});
typedef $$TranslationsTableUpdateCompanionBuilder = TranslationsCompanion
    Function({
  Value<int> sourceId,
  Value<int> ayahId,
  Value<String> content,
  Value<int> rowid,
});

final class $$TranslationsTableReferences
    extends BaseReferences<_$AppDatabase, $TranslationsTable, TranslationRow> {
  $$TranslationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TranslationSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.translationSources
          .createAlias('translations__source_id__translation_sources__id');

  $$TranslationSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager =
        $$TranslationSourcesTableTableManager($_db, $_db.translationSources)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AyahsTable _ayahIdTable(_$AppDatabase db) =>
      db.ayahs.createAlias('translations__ayah_id__ayahs__id');

  $$AyahsTableProcessedTableManager get ayahId {
    final $_column = $_itemColumn<int>('ayah_id')!;

    final manager = $$AyahsTableTableManager($_db, $_db.ayahs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  $$TranslationSourcesTableFilterComposer get sourceId {
    final $$TranslationSourcesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.translationSources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationSourcesTableFilterComposer(
              $db: $db,
              $table: $db.translationSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyahsTableFilterComposer get ayahId {
    final $$AyahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyahsTableFilterComposer(
              $db: $db,
              $table: $db.ayahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  $$TranslationSourcesTableOrderingComposer get sourceId {
    final $$TranslationSourcesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.translationSources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TranslationSourcesTableOrderingComposer(
              $db: $db,
              $table: $db.translationSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyahsTableOrderingComposer get ayahId {
    final $$AyahsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyahsTableOrderingComposer(
              $db: $db,
              $table: $db.ayahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $$TranslationSourcesTableAnnotationComposer get sourceId {
    final $$TranslationSourcesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sourceId,
            referencedTable: $db.translationSources,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TranslationSourcesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.translationSources,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$AyahsTableAnnotationComposer get ayahId {
    final $$AyahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayahs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyahsTableAnnotationComposer(
              $db: $db,
              $table: $db.ayahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TranslationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TranslationsTable,
    TranslationRow,
    $$TranslationsTableFilterComposer,
    $$TranslationsTableOrderingComposer,
    $$TranslationsTableAnnotationComposer,
    $$TranslationsTableCreateCompanionBuilder,
    $$TranslationsTableUpdateCompanionBuilder,
    (TranslationRow, $$TranslationsTableReferences),
    TranslationRow,
    PrefetchHooks Function({bool sourceId, bool ayahId})> {
  $$TranslationsTableTableManager(_$AppDatabase db, $TranslationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> sourceId = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TranslationsCompanion(
            sourceId: sourceId,
            ayahId: ayahId,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int sourceId,
            required int ayahId,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              TranslationsCompanion.insert(
            sourceId: sourceId,
            ayahId: ayahId,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TranslationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sourceId = false, ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceId,
                    referencedTable:
                        $$TranslationsTableReferences._sourceIdTable(db),
                    referencedColumn:
                        $$TranslationsTableReferences._sourceIdTable(db).id,
                  ) as T;
                }
                if (ayahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ayahId,
                    referencedTable:
                        $$TranslationsTableReferences._ayahIdTable(db),
                    referencedColumn:
                        $$TranslationsTableReferences._ayahIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TranslationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TranslationsTable,
    TranslationRow,
    $$TranslationsTableFilterComposer,
    $$TranslationsTableOrderingComposer,
    $$TranslationsTableAnnotationComposer,
    $$TranslationsTableCreateCompanionBuilder,
    $$TranslationsTableUpdateCompanionBuilder,
    (TranslationRow, $$TranslationsTableReferences),
    TranslationRow,
    PrefetchHooks Function({bool sourceId, bool ayahId})>;
typedef $$RecitersTableCreateCompanionBuilder = RecitersCompanion Function({
  Value<int> id,
  required String code,
  required String name,
  Value<String?> nameArabic,
  required String audioUrlTemplate,
  Value<int?> bitrateKbps,
  Value<String?> license,
  Value<String?> sourceUrl,
  Value<bool> isEnabled,
  Value<int> displayOrder,
});
typedef $$RecitersTableUpdateCompanionBuilder = RecitersCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> name,
  Value<String?> nameArabic,
  Value<String> audioUrlTemplate,
  Value<int?> bitrateKbps,
  Value<String?> license,
  Value<String?> sourceUrl,
  Value<bool> isEnabled,
  Value<int> displayOrder,
});

class $$RecitersTableFilterComposer
    extends Composer<_$AppDatabase, $RecitersTable> {
  $$RecitersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrlTemplate => $composableBuilder(
      column: $table.audioUrlTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bitrateKbps => $composableBuilder(
      column: $table.bitrateKbps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));
}

class $$RecitersTableOrderingComposer
    extends Composer<_$AppDatabase, $RecitersTable> {
  $$RecitersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrlTemplate => $composableBuilder(
      column: $table.audioUrlTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bitrateKbps => $composableBuilder(
      column: $table.bitrateKbps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));
}

class $$RecitersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecitersTable> {
  $$RecitersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
      column: $table.nameArabic, builder: (column) => column);

  GeneratedColumn<String> get audioUrlTemplate => $composableBuilder(
      column: $table.audioUrlTemplate, builder: (column) => column);

  GeneratedColumn<int> get bitrateKbps => $composableBuilder(
      column: $table.bitrateKbps, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);
}

class $$RecitersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecitersTable,
    ReciterRow,
    $$RecitersTableFilterComposer,
    $$RecitersTableOrderingComposer,
    $$RecitersTableAnnotationComposer,
    $$RecitersTableCreateCompanionBuilder,
    $$RecitersTableUpdateCompanionBuilder,
    (ReciterRow, BaseReferences<_$AppDatabase, $RecitersTable, ReciterRow>),
    ReciterRow,
    PrefetchHooks Function()> {
  $$RecitersTableTableManager(_$AppDatabase db, $RecitersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecitersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecitersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecitersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> nameArabic = const Value.absent(),
            Value<String> audioUrlTemplate = const Value.absent(),
            Value<int?> bitrateKbps = const Value.absent(),
            Value<String?> license = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
          }) =>
              RecitersCompanion(
            id: id,
            code: code,
            name: name,
            nameArabic: nameArabic,
            audioUrlTemplate: audioUrlTemplate,
            bitrateKbps: bitrateKbps,
            license: license,
            sourceUrl: sourceUrl,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String name,
            Value<String?> nameArabic = const Value.absent(),
            required String audioUrlTemplate,
            Value<int?> bitrateKbps = const Value.absent(),
            Value<String?> license = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
          }) =>
              RecitersCompanion.insert(
            id: id,
            code: code,
            name: name,
            nameArabic: nameArabic,
            audioUrlTemplate: audioUrlTemplate,
            bitrateKbps: bitrateKbps,
            license: license,
            sourceUrl: sourceUrl,
            isEnabled: isEnabled,
            displayOrder: displayOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecitersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecitersTable,
    ReciterRow,
    $$RecitersTableFilterComposer,
    $$RecitersTableOrderingComposer,
    $$RecitersTableAnnotationComposer,
    $$RecitersTableCreateCompanionBuilder,
    $$RecitersTableUpdateCompanionBuilder,
    (ReciterRow, BaseReferences<_$AppDatabase, $RecitersTable, ReciterRow>),
    ReciterRow,
    PrefetchHooks Function()>;
typedef $$MetaEntriesTableCreateCompanionBuilder = MetaEntriesCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaEntriesTableUpdateCompanionBuilder = MetaEntriesCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetaEntriesTable,
    MetaRow,
    $$MetaEntriesTableFilterComposer,
    $$MetaEntriesTableOrderingComposer,
    $$MetaEntriesTableAnnotationComposer,
    $$MetaEntriesTableCreateCompanionBuilder,
    $$MetaEntriesTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()> {
  $$MetaEntriesTableTableManager(_$AppDatabase db, $MetaEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaEntriesCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaEntriesCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MetaEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetaEntriesTable,
    MetaRow,
    $$MetaEntriesTableFilterComposer,
    $$MetaEntriesTableOrderingComposer,
    $$MetaEntriesTableAnnotationComposer,
    $$MetaEntriesTableCreateCompanionBuilder,
    $$MetaEntriesTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$AyahsTableTableManager get ayahs =>
      $$AyahsTableTableManager(_db, _db.ayahs);
  $$TranslationSourcesTableTableManager get translationSources =>
      $$TranslationSourcesTableTableManager(_db, _db.translationSources);
  $$TranslationsTableTableManager get translations =>
      $$TranslationsTableTableManager(_db, _db.translations);
  $$RecitersTableTableManager get reciters =>
      $$RecitersTableTableManager(_db, _db.reciters);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db, _db.metaEntries);
}
