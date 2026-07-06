import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/database/user/user_tables.dart';
import '../domain/entities/ayah_annotation.dart';
import '../domain/repositories/user_content_repository.dart';

/// Triển khai UserContentRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định.
class UserContentRepositoryImpl implements UserContentRepository {
  UserContentRepositoryImpl(
    this._db, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
  final String Function() _newId;
  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  // ------------------------- watch -------------------------

  @override
  Stream<Map<int, AyahAnnotation>> watchAnnotationsForAyahs(
    List<int> ayahIds,
  ) {
    Expression<bool> alive(SyncColumns t) => t.deletedAt.isNull();

    final bookmarks = (_db.select(_db.bookmarks)
          ..where((t) => t.ayahId.isIn(ayahIds) & alive(t)))
        .watch();
    final highlights = (_db.select(_db.highlights)
          ..where((t) => t.ayahId.isIn(ayahIds) & alive(t)))
        .watch();
    final notes = (_db.select(_db.notes)
          ..where((t) => t.ayahId.isIn(ayahIds) & alive(t)))
        .watch();
    final statuses = (_db.select(_db.ayahStatuses)
          ..where((t) => t.ayahId.isIn(ayahIds) & alive(t)))
        .watch();
    final favorites = (_db.select(_db.favorites)
          ..where((t) => t.ayahId.isIn(ayahIds) & alive(t)))
        .watch();

    return _combineLatest5(bookmarks, highlights, notes, statuses,
        favorites, (bm, hl, nt, st, fv) {
      final map = <int, _MutableAnnotation>{};
      _MutableAnnotation of(int id) =>
          map.putIfAbsent(id, _MutableAnnotation.new);

      for (final row in bm) {
        of(row.ayahId).bookmarked = true;
      }
      for (final row in hl) {
        of(row.ayahId).colors.add(row.color);
      }
      for (final row in nt) {
        of(row.ayahId).note = row.content;
      }
      for (final row in st) {
        of(row.ayahId).status = AyahStatus.values.asNameMap()[row.status] ??
            AyahStatus.none;
      }
      for (final row in fv) {
        of(row.ayahId).favorited = true;
      }
      return {
        for (final e in map.entries) e.key: e.value.build(),
      };
    });
  }

  // ------------------------- write -------------------------

  @override
  Future<void> toggleBookmark(int ayahId) async {
    final now = _nowMs();
    final existing = await (_db.select(_db.bookmarks)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.bookmarks).insert(
            BookmarksCompanion.insert(
              id: _newId(),
              ayahId: ayahId,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }
    // Đảo trạng thái sống/xóa của bản ghi hiện có (giữ nguyên UUID
    // để bản sync là update, không phải delete+insert).
    await (_db.update(_db.bookmarks)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      BookmarksCompanion(
        deletedAt: Value(existing.deletedAt == null ? now : null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> toggleFavorite(int ayahId) async {
    final now = _nowMs();
    final existing = await (_db.select(_db.favorites)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.favorites).insert(
            FavoritesCompanion.insert(
              id: _newId(),
              ayahId: ayahId,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.favorites)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      FavoritesCompanion(
        deletedAt: Value(existing.deletedAt == null ? now : null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> toggleHighlight(int ayahId, String colorName) async {
    final now = _nowMs();
    final existing = await (_db.select(_db.highlights)
          ..where(
            (t) => t.ayahId.equals(ayahId) & t.color.equals(colorName),
          ))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.highlights).insert(
            HighlightsCompanion.insert(
              id: _newId(),
              ayahId: ayahId,
              color: colorName,
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.highlights)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      HighlightsCompanion(
        deletedAt: Value(existing.deletedAt == null ? now : null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> saveNote(int ayahId, String content) async {
    final now = _nowMs();
    final trimmed = content.trim();
    final existing = await (_db.select(_db.notes)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();

    if (trimmed.isEmpty) {
      if (existing != null && existing.deletedAt == null) {
        await (_db.update(_db.notes)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          NotesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      }
      return;
    }

    if (existing == null) {
      await _db.into(_db.notes).insert(
            NotesCompanion.insert(
              id: _newId(),
              ayahId: ayahId,
              content: trimmed,
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.notes)..where((t) => t.id.equals(existing.id)))
        .write(
      NotesCompanion(
        content: Value(trimmed),
        deletedAt: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> setStatus(int ayahId, AyahStatus status) async {
    final now = _nowMs();
    final existing = await (_db.select(_db.ayahStatuses)
          ..where((t) => t.ayahId.equals(ayahId)))
        .getSingleOrNull();

    if (status == AyahStatus.none) {
      if (existing != null && existing.deletedAt == null) {
        await (_db.update(_db.ayahStatuses)
              ..where((t) => t.id.equals(existing.id)))
            .write(
          AyahStatusesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      }
      return;
    }

    if (existing == null) {
      await _db.into(_db.ayahStatuses).insert(
            AyahStatusesCompanion.insert(
              id: _newId(),
              ayahId: ayahId,
              status: status.name,
              updatedAt: now,
            ),
          );
      return;
    }
    await (_db.update(_db.ayahStatuses)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      AyahStatusesCompanion(
        status: Value(status.name),
        deletedAt: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }
}

class _MutableAnnotation {
  bool bookmarked = false;
  bool favorited = false;
  final Set<String> colors = {};
  String? note;
  AyahStatus status = AyahStatus.none;

  AyahAnnotation build() => AyahAnnotation(
        bookmarked: bookmarked,
        favorited: favorited,
        highlightColors: colors,
        note: note,
        status: status,
      );
}

/// combineLatest cho 5 stream — phát khi cả 5 đã có giá trị đầu,
/// sau đó phát mỗi lần bất kỳ stream nào đổi. Không thêm dependency
/// rxdart chỉ vì một hàm.
Stream<R> _combineLatest5<A, B, C, D, E, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  Stream<D> d,
  Stream<E> e,
  R Function(A, B, C, D, E) combiner,
) {
  late StreamController<R> controller;
  A? va;
  B? vb;
  C? vc;
  D? vd;
  E? ve;
  var ha = false, hb = false, hc = false, hd = false, he = false;
  final subs = <StreamSubscription<void>>[];

  void emit() {
    if (ha && hb && hc && hd && he) {
      controller.add(
        combiner(va as A, vb as B, vc as C, vd as D, ve as E),
      );
    }
  }

  controller = StreamController<R>(
    onListen: () {
      subs.addAll([
        a.listen((v) {
          va = v;
          ha = true;
          emit();
        }, onError: controller.addError),
        b.listen((v) {
          vb = v;
          hb = true;
          emit();
        }, onError: controller.addError),
        c.listen((v) {
          vc = v;
          hc = true;
          emit();
        }, onError: controller.addError),
        d.listen((v) {
          vd = v;
          hd = true;
          emit();
        }, onError: controller.addError),
        e.listen((v) {
          ve = v;
          he = true;
          emit();
        }, onError: controller.addError),
      ]);
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
    },
  );
  return controller.stream;
}
