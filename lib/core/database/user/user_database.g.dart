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
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
      'collection_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        updatedAt,
        deletedAt,
        isDirty,
        ayahId,
        createdAt,
        collectionId
      ];
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
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
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
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id']),
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

  /// NULL = chưa phân loại vào bộ sưu tập nào — trạng thái hợp lệ
  /// vĩnh viễn, không phải tạm thời chờ migrate. Không khai báo FK
  /// Drift-level (không có tiền lệ trong file này); tính toàn vẹn do
  /// tầng repository đảm nhiệm, giống cách ayah_id được xử lý.
  final String? collectionId;
  const BookmarkRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.ayahId,
      required this.createdAt,
      this.collectionId});
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
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
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
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
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
      collectionId: serializer.fromJson<String?>(json['collectionId']),
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
      'collectionId': serializer.toJson<String?>(collectionId),
    };
  }

  BookmarkRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          int? ayahId,
          int? createdAt,
          Value<String?> collectionId = const Value.absent()}) =>
      BookmarkRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        ayahId: ayahId ?? this.ayahId,
        createdAt: createdAt ?? this.createdAt,
        collectionId:
            collectionId.present ? collectionId.value : this.collectionId,
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
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
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
          ..write('createdAt: $createdAt, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, updatedAt, deletedAt, isDirty,
      ayahId, createdAt, collectionId);
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
          other.createdAt == this.createdAt &&
          other.collectionId == this.collectionId);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> ayahId;
  final Value<int> createdAt;
  final Value<String?> collectionId;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.collectionId = const Value.absent(),
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
    this.collectionId = const Value.absent(),
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
    Expression<String>? collectionId,
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
      if (collectionId != null) 'collection_id': collectionId,
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
      Value<String?>? collectionId,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
      collectionId: collectionId ?? this.collectionId,
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
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
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
          ..write('collectionId: $collectionId, ')
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

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surahIdMeta =
      const VerificationMeta('surahId');
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
      'surah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahFromMeta =
      const VerificationMeta('ayahFrom');
  @override
  late final GeneratedColumn<int> ayahFrom = GeneratedColumn<int>(
      'ayah_from', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahToMeta = const VerificationMeta('ayahTo');
  @override
  late final GeneratedColumn<int> ayahTo = GeneratedColumn<int>(
      'ayah_to', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationSecMeta =
      const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
      'duration_sec', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        updatedAt,
        deletedAt,
        isDirty,
        date,
        surahId,
        ayahFrom,
        ayahTo,
        durationSec,
        note,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<StudySessionRow> instance,
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
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('surah_id')) {
      context.handle(_surahIdMeta,
          surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta));
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_from')) {
      context.handle(_ayahFromMeta,
          ayahFrom.isAcceptableOrUnknown(data['ayah_from']!, _ayahFromMeta));
    } else if (isInserting) {
      context.missing(_ayahFromMeta);
    }
    if (data.containsKey('ayah_to')) {
      context.handle(_ayahToMeta,
          ayahTo.isAcceptableOrUnknown(data['ayah_to']!, _ayahToMeta));
    } else if (isInserting) {
      context.missing(_ayahToMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
          _durationSecMeta,
          durationSec.isAcceptableOrUnknown(
              data['duration_sec']!, _durationSecMeta));
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
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
  StudySessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySessionRow(
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
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      surahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_id'])!,
      ayahFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_from'])!,
      ayahTo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_to'])!,
      durationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_sec'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySessionRow extends DataClass implements Insertable<StudySessionRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;

  /// Ngày đọc, dạng 'yyyy-MM-dd' — khớp định dạng StatsStore.dayKey
  /// hiện có (SharedPreferences), để không cần quy đổi epoch↔ngày
  /// khi đối chiếu hai nguồn dữ liệu trong giai đoạn chuyển tiếp.
  final String date;
  final int surahId;

  /// Chỉ số Ayah 0-based trong Surah — khớp ReadingPositionStore.
  final int ayahFrom;
  final int ayahTo;
  final int durationSec;
  final String? note;
  final int createdAt;
  const StudySessionRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.date,
      required this.surahId,
      required this.ayahFrom,
      required this.ayahTo,
      required this.durationSec,
      this.note,
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
    map['date'] = Variable<String>(date);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_from'] = Variable<int>(ayahFrom);
    map['ayah_to'] = Variable<int>(ayahTo);
    map['duration_sec'] = Variable<int>(durationSec);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      date: Value(date),
      surahId: Value(surahId),
      ayahFrom: Value(ayahFrom),
      ayahTo: Value(ayahTo),
      durationSec: Value(durationSec),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StudySessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      date: serializer.fromJson<String>(json['date']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahFrom: serializer.fromJson<int>(json['ayahFrom']),
      ayahTo: serializer.fromJson<int>(json['ayahTo']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      note: serializer.fromJson<String?>(json['note']),
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
      'date': serializer.toJson<String>(date),
      'surahId': serializer.toJson<int>(surahId),
      'ayahFrom': serializer.toJson<int>(ayahFrom),
      'ayahTo': serializer.toJson<int>(ayahTo),
      'durationSec': serializer.toJson<int>(durationSec),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StudySessionRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          String? date,
          int? surahId,
          int? ayahFrom,
          int? ayahTo,
          int? durationSec,
          Value<String?> note = const Value.absent(),
          int? createdAt}) =>
      StudySessionRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        date: date ?? this.date,
        surahId: surahId ?? this.surahId,
        ayahFrom: ayahFrom ?? this.ayahFrom,
        ayahTo: ayahTo ?? this.ayahTo,
        durationSec: durationSec ?? this.durationSec,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  StudySessionRow copyWithCompanion(StudySessionsCompanion data) {
    return StudySessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      date: data.date.present ? data.date.value : this.date,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahFrom: data.ayahFrom.present ? data.ayahFrom.value : this.ayahFrom,
      ayahTo: data.ayahTo.present ? data.ayahTo.value : this.ayahTo,
      durationSec:
          data.durationSec.present ? data.durationSec.value : this.durationSec,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('date: $date, ')
          ..write('surahId: $surahId, ')
          ..write('ayahFrom: $ayahFrom, ')
          ..write('ayahTo: $ayahTo, ')
          ..write('durationSec: $durationSec, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, updatedAt, deletedAt, isDirty,
      date, surahId, ayahFrom, ayahTo, durationSec, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.date == this.date &&
          other.surahId == this.surahId &&
          other.ayahFrom == this.ayahFrom &&
          other.ayahTo == this.ayahTo &&
          other.durationSec == this.durationSec &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StudySessionsCompanion extends UpdateCompanion<StudySessionRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<String> date;
  final Value<int> surahId;
  final Value<int> ayahFrom;
  final Value<int> ayahTo;
  final Value<int> durationSec;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.date = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahFrom = const Value.absent(),
    this.ayahTo = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        date = Value(date),
        surahId = Value(surahId),
        ayahFrom = Value(ayahFrom),
        ayahTo = Value(ayahTo),
        durationSec = Value(durationSec),
        createdAt = Value(createdAt);
  static Insertable<StudySessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<String>? date,
    Expression<int>? surahId,
    Expression<int>? ayahFrom,
    Expression<int>? ayahTo,
    Expression<int>? durationSec,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (date != null) 'date': date,
      if (surahId != null) 'surah_id': surahId,
      if (ayahFrom != null) 'ayah_from': ayahFrom,
      if (ayahTo != null) 'ayah_to': ayahTo,
      if (durationSec != null) 'duration_sec': durationSec,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<String>? date,
      Value<int>? surahId,
      Value<int>? ayahFrom,
      Value<int>? ayahTo,
      Value<int>? durationSec,
      Value<String?>? note,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      date: date ?? this.date,
      surahId: surahId ?? this.surahId,
      ayahFrom: ayahFrom ?? this.ayahFrom,
      ayahTo: ayahTo ?? this.ayahTo,
      durationSec: durationSec ?? this.durationSec,
      note: note ?? this.note,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahFrom.present) {
      map['ayah_from'] = Variable<int>(ayahFrom.value);
    }
    if (ayahTo.present) {
      map['ayah_to'] = Variable<int>(ayahTo.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('date: $date, ')
          ..write('surahId: $surahId, ')
          ..write('ayahFrom: $ayahFrom, ')
          ..write('ayahTo: $ayahTo, ')
          ..write('durationSec: $durationSec, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KhatmCyclesTable extends KhatmCycles
    with TableInfo<$KhatmCyclesTable, KhatmCycleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KhatmCyclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
      'target_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentAyahIdMeta =
      const VerificationMeta('currentAyahId');
  @override
  late final GeneratedColumn<int> currentAyahId = GeneratedColumn<int>(
      'current_ayah_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        updatedAt,
        deletedAt,
        isDirty,
        name,
        startedAt,
        targetDate,
        completedAt,
        currentAyahId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'khatm_cycles';
  @override
  VerificationContext validateIntegrity(Insertable<KhatmCycleRow> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('current_ayah_id')) {
      context.handle(
          _currentAyahIdMeta,
          currentAyahId.isAcceptableOrUnknown(
              data['current_ayah_id']!, _currentAyahIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KhatmCycleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KhatmCycleRow(
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_date']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      currentAyahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_ayah_id'])!,
    );
  }

  @override
  $KhatmCyclesTable createAlias(String alias) {
    return $KhatmCyclesTable(attachedDatabase, alias);
  }
}

class KhatmCycleRow extends DataClass implements Insertable<KhatmCycleRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final String name;
  final int startedAt;

  /// Ngày mục tiêu hoàn thành, dạng 'yyyy-MM-dd' — tuỳ chọn.
  final String? targetDate;

  /// NULL = đang đọc (chu kỳ chưa hoàn thành).
  final int? completedAt;

  /// Ayah ID 1..6236 — vị trí hiện tại trong chu kỳ.
  final int currentAyahId;
  const KhatmCycleRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.name,
      required this.startedAt,
      this.targetDate,
      this.completedAt,
      required this.currentAyahId});
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
    map['name'] = Variable<String>(name);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['current_ayah_id'] = Variable<int>(currentAyahId);
    return map;
  }

  KhatmCyclesCompanion toCompanion(bool nullToAbsent) {
    return KhatmCyclesCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      name: Value(name),
      startedAt: Value(startedAt),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      currentAyahId: Value(currentAyahId),
    );
  }

  factory KhatmCycleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KhatmCycleRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      name: serializer.fromJson<String>(json['name']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      currentAyahId: serializer.fromJson<int>(json['currentAyahId']),
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
      'name': serializer.toJson<String>(name),
      'startedAt': serializer.toJson<int>(startedAt),
      'targetDate': serializer.toJson<String?>(targetDate),
      'completedAt': serializer.toJson<int?>(completedAt),
      'currentAyahId': serializer.toJson<int>(currentAyahId),
    };
  }

  KhatmCycleRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          String? name,
          int? startedAt,
          Value<String?> targetDate = const Value.absent(),
          Value<int?> completedAt = const Value.absent(),
          int? currentAyahId}) =>
      KhatmCycleRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        name: name ?? this.name,
        startedAt: startedAt ?? this.startedAt,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        currentAyahId: currentAyahId ?? this.currentAyahId,
      );
  KhatmCycleRow copyWithCompanion(KhatmCyclesCompanion data) {
    return KhatmCycleRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      currentAyahId: data.currentAyahId.present
          ? data.currentAyahId.value
          : this.currentAyahId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KhatmCycleRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetDate: $targetDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentAyahId: $currentAyahId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, updatedAt, deletedAt, isDirty,
      name, startedAt, targetDate, completedAt, currentAyahId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KhatmCycleRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.targetDate == this.targetDate &&
          other.completedAt == this.completedAt &&
          other.currentAyahId == this.currentAyahId);
}

class KhatmCyclesCompanion extends UpdateCompanion<KhatmCycleRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<String> name;
  final Value<int> startedAt;
  final Value<String?> targetDate;
  final Value<int?> completedAt;
  final Value<int> currentAyahId;
  final Value<int> rowid;
  const KhatmCyclesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.currentAyahId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KhatmCyclesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String name,
    required int startedAt,
    this.targetDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.currentAyahId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        name = Value(name),
        startedAt = Value(startedAt);
  static Insertable<KhatmCycleRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<String>? name,
    Expression<int>? startedAt,
    Expression<String>? targetDate,
    Expression<int>? completedAt,
    Expression<int>? currentAyahId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (targetDate != null) 'target_date': targetDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (currentAyahId != null) 'current_ayah_id': currentAyahId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KhatmCyclesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<String>? name,
      Value<int>? startedAt,
      Value<String?>? targetDate,
      Value<int?>? completedAt,
      Value<int>? currentAyahId,
      Value<int>? rowid}) {
    return KhatmCyclesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      currentAyahId: currentAyahId ?? this.currentAyahId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (currentAyahId.present) {
      map['current_ayah_id'] = Variable<int>(currentAyahId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KhatmCyclesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetDate: $targetDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentAyahId: $currentAyahId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarkCollectionsTable extends BookmarkCollections
    with TableInfo<$BookmarkCollectionsTable, BookmarkCollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkCollectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, updatedAt, deletedAt, isDirty, name, emoji, displayOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_collections';
  @override
  VerificationContext validateIntegrity(
      Insertable<BookmarkCollectionRow> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
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
  BookmarkCollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkCollectionRow(
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
    );
  }

  @override
  $BookmarkCollectionsTable createAlias(String alias) {
    return $BookmarkCollectionsTable(attachedDatabase, alias);
  }
}

class BookmarkCollectionRow extends DataClass
    implements Insertable<BookmarkCollectionRow> {
  final String id;
  final String? userId;
  final int updatedAt;
  final int? deletedAt;
  final bool isDirty;
  final String name;
  final String? emoji;
  final int displayOrder;
  const BookmarkCollectionRow(
      {required this.id,
      this.userId,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty,
      required this.name,
      this.emoji,
      required this.displayOrder});
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
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  BookmarkCollectionsCompanion toCompanion(bool nullToAbsent) {
    return BookmarkCollectionsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      name: Value(name),
      emoji:
          emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      displayOrder: Value(displayOrder),
    );
  }

  factory BookmarkCollectionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkCollectionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
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
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  BookmarkCollectionRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent(),
          bool? isDirty,
          String? name,
          Value<String?> emoji = const Value.absent(),
          int? displayOrder}) =>
      BookmarkCollectionRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
        name: name ?? this.name,
        emoji: emoji.present ? emoji.value : this.emoji,
        displayOrder: displayOrder ?? this.displayOrder,
      );
  BookmarkCollectionRow copyWithCompanion(BookmarkCollectionsCompanion data) {
    return BookmarkCollectionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkCollectionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, updatedAt, deletedAt, isDirty, name, emoji, displayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkCollectionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.displayOrder == this.displayOrder);
}

class BookmarkCollectionsCompanion
    extends UpdateCompanion<BookmarkCollectionRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<bool> isDirty;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<int> displayOrder;
  final Value<int> rowid;
  const BookmarkCollectionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkCollectionsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        name = Value(name);
  static Insertable<BookmarkCollectionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<bool>? isDirty,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? displayOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (displayOrder != null) 'display_order': displayOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkCollectionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<bool>? isDirty,
      Value<String>? name,
      Value<String?>? emoji,
      Value<int>? displayOrder,
      Value<int>? rowid}) {
    return BookmarkCollectionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      displayOrder: displayOrder ?? this.displayOrder,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkCollectionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('displayOrder: $displayOrder, ')
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
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $KhatmCyclesTable khatmCycles = $KhatmCyclesTable(this);
  late final $BookmarkCollectionsTable bookmarkCollections =
      $BookmarkCollectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bookmarks,
        highlights,
        notes,
        favorites,
        ayahStatuses,
        studySessions,
        khatmCycles,
        bookmarkCollections
      ];
}

typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required int ayahId,
  required int createdAt,
  Value<String?> collectionId,
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
  Value<String?> collectionId,
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

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);
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
            Value<String?> collectionId = const Value.absent(),
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
            collectionId: collectionId,
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
            Value<String?> collectionId = const Value.absent(),
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
            collectionId: collectionId,
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
typedef $$StudySessionsTableCreateCompanionBuilder = StudySessionsCompanion
    Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required String date,
  required int surahId,
  required int ayahFrom,
  required int ayahTo,
  required int durationSec,
  Value<String?> note,
  required int createdAt,
  Value<int> rowid,
});
typedef $$StudySessionsTableUpdateCompanionBuilder = StudySessionsCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<String> date,
  Value<int> surahId,
  Value<int> ayahFrom,
  Value<int> ayahTo,
  Value<int> durationSec,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$StudySessionsTableFilterComposer
    extends Composer<_$UserDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surahId => $composableBuilder(
      column: $table.surahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahFrom => $composableBuilder(
      column: $table.ayahFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahTo => $composableBuilder(
      column: $table.ayahTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$UserDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surahId => $composableBuilder(
      column: $table.surahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahFrom => $composableBuilder(
      column: $table.ayahFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahTo => $composableBuilder(
      column: $table.ayahTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$UserDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahFrom =>
      $composableBuilder(column: $table.ayahFrom, builder: (column) => column);

  GeneratedColumn<int> get ayahTo =>
      $composableBuilder(column: $table.ayahTo, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudySessionsTableTableManager extends RootTableManager<
    _$UserDatabase,
    $StudySessionsTable,
    StudySessionRow,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (
      StudySessionRow,
      BaseReferences<_$UserDatabase, $StudySessionsTable, StudySessionRow>
    ),
    StudySessionRow,
    PrefetchHooks Function()> {
  $$StudySessionsTableTableManager(_$UserDatabase db, $StudySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> surahId = const Value.absent(),
            Value<int> ayahFrom = const Value.absent(),
            Value<int> ayahTo = const Value.absent(),
            Value<int> durationSec = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            date: date,
            surahId: surahId,
            ayahFrom: ayahFrom,
            ayahTo: ayahTo,
            durationSec: durationSec,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required String date,
            required int surahId,
            required int ayahFrom,
            required int ayahTo,
            required int durationSec,
            Value<String?> note = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            date: date,
            surahId: surahId,
            ayahFrom: ayahFrom,
            ayahTo: ayahTo,
            durationSec: durationSec,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudySessionsTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $StudySessionsTable,
    StudySessionRow,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (
      StudySessionRow,
      BaseReferences<_$UserDatabase, $StudySessionsTable, StudySessionRow>
    ),
    StudySessionRow,
    PrefetchHooks Function()>;
typedef $$KhatmCyclesTableCreateCompanionBuilder = KhatmCyclesCompanion
    Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required String name,
  required int startedAt,
  Value<String?> targetDate,
  Value<int?> completedAt,
  Value<int> currentAyahId,
  Value<int> rowid,
});
typedef $$KhatmCyclesTableUpdateCompanionBuilder = KhatmCyclesCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<String> name,
  Value<int> startedAt,
  Value<String?> targetDate,
  Value<int?> completedAt,
  Value<int> currentAyahId,
  Value<int> rowid,
});

class $$KhatmCyclesTableFilterComposer
    extends Composer<_$UserDatabase, $KhatmCyclesTable> {
  $$KhatmCyclesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentAyahId => $composableBuilder(
      column: $table.currentAyahId, builder: (column) => ColumnFilters(column));
}

class $$KhatmCyclesTableOrderingComposer
    extends Composer<_$UserDatabase, $KhatmCyclesTable> {
  $$KhatmCyclesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentAyahId => $composableBuilder(
      column: $table.currentAyahId,
      builder: (column) => ColumnOrderings(column));
}

class $$KhatmCyclesTableAnnotationComposer
    extends Composer<_$UserDatabase, $KhatmCyclesTable> {
  $$KhatmCyclesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get currentAyahId => $composableBuilder(
      column: $table.currentAyahId, builder: (column) => column);
}

class $$KhatmCyclesTableTableManager extends RootTableManager<
    _$UserDatabase,
    $KhatmCyclesTable,
    KhatmCycleRow,
    $$KhatmCyclesTableFilterComposer,
    $$KhatmCyclesTableOrderingComposer,
    $$KhatmCyclesTableAnnotationComposer,
    $$KhatmCyclesTableCreateCompanionBuilder,
    $$KhatmCyclesTableUpdateCompanionBuilder,
    (
      KhatmCycleRow,
      BaseReferences<_$UserDatabase, $KhatmCyclesTable, KhatmCycleRow>
    ),
    KhatmCycleRow,
    PrefetchHooks Function()> {
  $$KhatmCyclesTableTableManager(_$UserDatabase db, $KhatmCyclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KhatmCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KhatmCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KhatmCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<String?> targetDate = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> currentAyahId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KhatmCyclesCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            name: name,
            startedAt: startedAt,
            targetDate: targetDate,
            completedAt: completedAt,
            currentAyahId: currentAyahId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required String name,
            required int startedAt,
            Value<String?> targetDate = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> currentAyahId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KhatmCyclesCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            name: name,
            startedAt: startedAt,
            targetDate: targetDate,
            completedAt: completedAt,
            currentAyahId: currentAyahId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KhatmCyclesTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $KhatmCyclesTable,
    KhatmCycleRow,
    $$KhatmCyclesTableFilterComposer,
    $$KhatmCyclesTableOrderingComposer,
    $$KhatmCyclesTableAnnotationComposer,
    $$KhatmCyclesTableCreateCompanionBuilder,
    $$KhatmCyclesTableUpdateCompanionBuilder,
    (
      KhatmCycleRow,
      BaseReferences<_$UserDatabase, $KhatmCyclesTable, KhatmCycleRow>
    ),
    KhatmCycleRow,
    PrefetchHooks Function()>;
typedef $$BookmarkCollectionsTableCreateCompanionBuilder
    = BookmarkCollectionsCompanion Function({
  required String id,
  Value<String?> userId,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  required String name,
  Value<String?> emoji,
  Value<int> displayOrder,
  Value<int> rowid,
});
typedef $$BookmarkCollectionsTableUpdateCompanionBuilder
    = BookmarkCollectionsCompanion Function({
  Value<String> id,
  Value<String?> userId,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<bool> isDirty,
  Value<String> name,
  Value<String?> emoji,
  Value<int> displayOrder,
  Value<int> rowid,
});

class $$BookmarkCollectionsTableFilterComposer
    extends Composer<_$UserDatabase, $BookmarkCollectionsTable> {
  $$BookmarkCollectionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));
}

class $$BookmarkCollectionsTableOrderingComposer
    extends Composer<_$UserDatabase, $BookmarkCollectionsTable> {
  $$BookmarkCollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));
}

class $$BookmarkCollectionsTableAnnotationComposer
    extends Composer<_$UserDatabase, $BookmarkCollectionsTable> {
  $$BookmarkCollectionsTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);
}

class $$BookmarkCollectionsTableTableManager extends RootTableManager<
    _$UserDatabase,
    $BookmarkCollectionsTable,
    BookmarkCollectionRow,
    $$BookmarkCollectionsTableFilterComposer,
    $$BookmarkCollectionsTableOrderingComposer,
    $$BookmarkCollectionsTableAnnotationComposer,
    $$BookmarkCollectionsTableCreateCompanionBuilder,
    $$BookmarkCollectionsTableUpdateCompanionBuilder,
    (
      BookmarkCollectionRow,
      BaseReferences<_$UserDatabase, $BookmarkCollectionsTable,
          BookmarkCollectionRow>
    ),
    BookmarkCollectionRow,
    PrefetchHooks Function()> {
  $$BookmarkCollectionsTableTableManager(
      _$UserDatabase db, $BookmarkCollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkCollectionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkCollectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> emoji = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarkCollectionsCompanion(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            name: name,
            emoji: emoji,
            displayOrder: displayOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            required String name,
            Value<String?> emoji = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarkCollectionsCompanion.insert(
            id: id,
            userId: userId,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            name: name,
            emoji: emoji,
            displayOrder: displayOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarkCollectionsTableProcessedTableManager = ProcessedTableManager<
    _$UserDatabase,
    $BookmarkCollectionsTable,
    BookmarkCollectionRow,
    $$BookmarkCollectionsTableFilterComposer,
    $$BookmarkCollectionsTableOrderingComposer,
    $$BookmarkCollectionsTableAnnotationComposer,
    $$BookmarkCollectionsTableCreateCompanionBuilder,
    $$BookmarkCollectionsTableUpdateCompanionBuilder,
    (
      BookmarkCollectionRow,
      BaseReferences<_$UserDatabase, $BookmarkCollectionsTable,
          BookmarkCollectionRow>
    ),
    BookmarkCollectionRow,
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
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$KhatmCyclesTableTableManager get khatmCycles =>
      $$KhatmCyclesTableTableManager(_db, _db.khatmCycles);
  $$BookmarkCollectionsTableTableManager get bookmarkCollections =>
      $$BookmarkCollectionsTableTableManager(_db, _db.bookmarkCollections);
}
