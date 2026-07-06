// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ayahId},
      ];
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final int ayahId;
  final int createdAt;
  const BookmarkRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BookmarkRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          int? createdAt}) =>
      BookmarkRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        createdAt: createdAt ?? this.createdAt,
      );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, updatedAt, deletedAt, isDirty, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int ayahId,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        ayahId = Value(ayahId),
        createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? ayahId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? ayahId,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTable extends Highlights
    with TableInfo<$HighlightsTable, HighlightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, ayahId, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights';
  @override
  VerificationContext validateIntegrity(Insertable<HighlightRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ayahId, color},
      ];
  @override
  HighlightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HighlightRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $HighlightsTable createAlias(String alias) {
    return $HighlightsTable(attachedDatabase, alias);
  }
}

class HighlightRow extends DataClass implements Insertable<HighlightRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final int ayahId;

  /// Tên màu ('amber', 'green'...) — một Ayah nhiều màu được.
  final String color;
  const HighlightRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ayah_id'] = Variable<int>(ayahId);
    map['color'] = Variable<String>(color);
    return map;
  }

  HighlightsCompanion toCompanion(bool nullToAbsent) {
    return HighlightsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      ayahId: Value(ayahId),
      color: Value(color),
    );
  }

  factory HighlightRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HighlightRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'ayahId': serializer.toJson<int>(ayahId),
      'color': serializer.toJson<String>(color),
    };
  }

  HighlightRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          String? color}) =>
      HighlightRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        color: color ?? this.color,
      );
  HighlightRow copyWithCompanion(HighlightsCompanion data) {
    return HighlightRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HighlightRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, updatedAt, deletedAt, isDirty, ayahId, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HighlightRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.ayahId == this.ayahId &&
          other.color == this.color);
}

class HighlightsCompanion extends UpdateCompanion<HighlightRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<String> color;
  final Value<int> rowid;
  const HighlightsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HighlightsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int ayahId,
    required String color,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        ayahId = Value(ayahId),
        color = Value(color);
  static Insertable<HighlightRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? ayahId,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (ayahId != null) 'ayah_id': ayahId,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HighlightsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? ayahId,
      Value<String>? color,
      Value<int>? rowid}) {
    return HighlightsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, ayahId, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ayahId},
      ];
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final int ayahId;

  /// Nội dung — Markdown cơ bản (**đậm**, *nghiêng*).
  final String content;
  const NoteRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ayah_id'] = Variable<int>(ayahId);
    map['content'] = Variable<String>(content);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      ayahId: Value(ayahId),
      content: Value(content),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'ayahId': serializer.toJson<int>(ayahId),
      'content': serializer.toJson<String>(content),
    };
  }

  NoteRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          String? content}) =>
      NoteRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        content: content ?? this.content,
      );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, updatedAt, deletedAt, isDirty, ayahId, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.ayahId == this.ayahId &&
          other.content == this.content);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<String> content;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int ayahId,
    required String content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        ayahId = Value(ayahId),
        content = Value(content);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? ayahId,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (ayahId != null) 'ayah_id': ayahId,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? ayahId,
      Value<String>? content,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ayahId},
      ];
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final int ayahId;
  final int createdAt;
  const FavoriteRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FavoriteRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          int? createdAt}) =>
      FavoriteRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, updatedAt, deletedAt, isDirty, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int ayahId,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        ayahId = Value(ayahId),
        createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? ayahId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? ayahId,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return FavoritesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AyahStatusesTable extends AyahStatuses
    with TableInfo<$AyahStatusesTable, AyahStatusRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, ayahId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_statuses';
  @override
  VerificationContext validateIntegrity(Insertable<AyahStatusRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ayahId},
      ];
  @override
  AyahStatusRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahStatusRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $AyahStatusesTable createAlias(String alias) {
    return $AyahStatusesTable(attachedDatabase, alias);
  }
}

class AyahStatusRow extends DataClass implements Insertable<AyahStatusRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final int ayahId;

  /// 'learning' | 'learned' | 'review' — không có dòng = chưa đọc.
  final String status;
  const AyahStatusRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ayah_id'] = Variable<int>(ayahId);
    map['status'] = Variable<String>(status);
    return map;
  }

  AyahStatusesCompanion toCompanion(bool nullToAbsent) {
    return AyahStatusesCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      ayahId: Value(ayahId),
      status: Value(status),
    );
  }

  factory AyahStatusRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahStatusRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'ayahId': serializer.toJson<int>(ayahId),
      'status': serializer.toJson<String>(status),
    };
  }

  AyahStatusRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          String? status}) =>
      AyahStatusRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        status: status ?? this.status,
      );
  AyahStatusRow copyWithCompanion(AyahStatusesCompanion data) {
    return AyahStatusRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahStatusRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, updatedAt, deletedAt, isDirty, ayahId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahStatusRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.ayahId == this.ayahId &&
          other.status == this.status);
}

class AyahStatusesCompanion extends UpdateCompanion<AyahStatusRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<String> status;
  final Value<int> rowid;
  const AyahStatusesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahStatusesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required int ayahId,
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        ayahId = Value(ayahId),
        status = Value(status);
  static Insertable<AyahStatusRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? ayahId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (ayahId != null) 'ayah_id': ayahId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahStatusesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? ayahId,
      Value<String>? status,
      Value<int>? rowid}) {
    return AyahStatusesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahStatusesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('ayahId: $ayahId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $HighlightsTable highlights = $HighlightsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $AyahStatusesTable ayahStatuses = $AyahStatusesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [bookmarks, highlights, notes, favorites, ayahStatuses];
}

typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<int> ayahId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$UserDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, BaseReferences<_$UserDatabase, $BookmarksTable, BookmarkRow>),
    BookmarkRow,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$UserDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required int ayahId,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, BaseReferences<_$UserDatabase, $BookmarksTable, BookmarkRow>),
    BookmarkRow,
    PrefetchHooks Function()>;
typedef $$HighlightsTableCreateCompanionBuilder = HighlightsCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required String color,
  Value<int> rowid,
});
typedef $$HighlightsTableUpdateCompanionBuilder = HighlightsCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<int> ayahId,
  Value<String> color,
  Value<int> rowid,
});

class $$HighlightsTableFilterComposer
    extends Composer<_$UserDatabase, $HighlightsTable> {
  $$HighlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));
}

class $$HighlightsTableOrderingComposer
    extends Composer<_$UserDatabase, $HighlightsTable> {
  $$HighlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
}

class $$HighlightsTableAnnotationComposer
    extends Composer<_$UserDatabase, $HighlightsTable> {
  $$HighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$HighlightsTableTableManager extends RootTableManager<
    _$UserDatabase,
    $HighlightsTable,
    HighlightRow,
    $$HighlightsTableFilterComposer,
    $$HighlightsTableOrderingComposer,
    $$HighlightsTableAnnotationComposer,
    $$HighlightsTableCreateCompanionBuilder,
    $$HighlightsTableUpdateCompanionBuilder,
    (
      HighlightRow,
      BaseReferences<_$UserDatabase, $HighlightsTable, HighlightRow>
    ),
    HighlightRow,
    PrefetchHooks Function()> {
  $$HighlightsTableTableManager(_$UserDatabase db, $HighlightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HighlightsCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            color: color,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required int ayahId,
            required String color,
            Value<int> rowid = const Value.absent(),
          }) =>
              HighlightsCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            color: color,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HighlightsTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $HighlightsTable,
    HighlightRow,
    $$HighlightsTableFilterComposer,
    $$HighlightsTableOrderingComposer,
    $$HighlightsTableAnnotationComposer,
    $$HighlightsTableCreateCompanionBuilder,
    $$HighlightsTableUpdateCompanionBuilder,
    (
      HighlightRow,
      BaseReferences<_$UserDatabase, $HighlightsTable, HighlightRow>
    ),
    HighlightRow,
    PrefetchHooks Function()>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required String content,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<int> ayahId,
  Value<String> content,
  Value<int> rowid,
});

class $$NotesTableFilterComposer extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer
    extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer
    extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$NotesTableTableManager extends RootTableManager<
    _$UserDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, BaseReferences<_$UserDatabase, $NotesTable, NoteRow>),
    NoteRow,
    PrefetchHooks Function()> {
  $$NotesTableTableManager(_$UserDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required int ayahId,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, BaseReferences<_$UserDatabase, $NotesTable, NoteRow>),
    NoteRow,
    PrefetchHooks Function()>;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<int> ayahId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$UserDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$UserDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$UserDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$UserDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (FavoriteRow, BaseReferences<_$UserDatabase, $FavoritesTable, FavoriteRow>),
    FavoriteRow,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(_$UserDatabase db, $FavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required int ayahId,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (FavoriteRow, BaseReferences<_$UserDatabase, $FavoritesTable, FavoriteRow>),
    FavoriteRow,
    PrefetchHooks Function()>;
typedef $$AyahStatusesTableCreateCompanionBuilder = AyahStatusesCompanion
    Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required String status,
  Value<int> rowid,
});
typedef $$AyahStatusesTableUpdateCompanionBuilder = AyahStatusesCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<int> ayahId,
  Value<String> status,
  Value<int> rowid,
});

class $$AyahStatusesTableFilterComposer
    extends Composer<_$UserDatabase, $AyahStatusesTable> {
  $$AyahStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$AyahStatusesTableOrderingComposer
    extends Composer<_$UserDatabase, $AyahStatusesTable> {
  $$AyahStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$AyahStatusesTableAnnotationComposer
    extends Composer<_$UserDatabase, $AyahStatusesTable> {
  $$AyahStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AyahStatusesTableTableManager extends RootTableManager<
    _$UserDatabase,
    $AyahStatusesTable,
    AyahStatusRow,
    $$AyahStatusesTableFilterComposer,
    $$AyahStatusesTableOrderingComposer,
    $$AyahStatusesTableAnnotationComposer,
    $$AyahStatusesTableCreateCompanionBuilder,
    $$AyahStatusesTableUpdateCompanionBuilder,
    (
      AyahStatusRow,
      BaseReferences<_$UserDatabase, $AyahStatusesTable, AyahStatusRow>
    ),
    AyahStatusRow,
    PrefetchHooks Function()> {
  $$AyahStatusesTableTableManager(_$UserDatabase db, $AyahStatusesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahStatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> ayahId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AyahStatusesCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required int ayahId,
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              AyahStatusesCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            ayahId: ayahId,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AyahStatusesTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $AyahStatusesTable,
    AyahStatusRow,
    $$AyahStatusesTableFilterComposer,
    $$AyahStatusesTableOrderingComposer,
    $$AyahStatusesTableAnnotationComposer,
    $$AyahStatusesTableCreateCompanionBuilder,
    $$AyahStatusesTableUpdateCompanionBuilder,
    (
      AyahStatusRow,
      BaseReferences<_$UserDatabase, $AyahStatusesTable, AyahStatusRow>
    ),
    AyahStatusRow,
    PrefetchHooks Function()>;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$HighlightsTableTableManager get highlights =>
      $$HighlightsTableTableManager(_db, _db.highlights);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$AyahStatusesTableTableManager get ayahStatuses =>
      $$AyahStatusesTableTableManager(_db, _db.ayahStatuses);
}
