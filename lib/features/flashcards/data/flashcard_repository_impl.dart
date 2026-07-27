import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../../lexicon/domain/entities/lexicon_entry.dart';
import '../domain/entities/flashcard.dart';
import '../domain/entities/flashcard_deck.dart';
import '../domain/entities/flashcard_type.dart';
import '../domain/repositories/flashcard_repository.dart';

/// Triển khai FlashcardRepository trên UserDatabase (Drift, nhóm B).
///
/// [newId]/[nowMs] tiêm được để test có kết quả xác định — cùng mẫu
/// BookmarkCollectionRepositoryImpl/SchedulerRepositoryImpl.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên vẹn).
class FlashcardRepositoryImpl implements FlashcardRepository {
  FlashcardRepositoryImpl(
    this._db,
    this._logger, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
  final Logger _logger;
  final String Function() _newId;
  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  Flashcard _toEntity(FlashcardRow row) => Flashcard(
        id: row.id,
        type: FlashcardType.values.asNameMap()[row.type] ?? FlashcardType.lemma,
        lexiconEntryType:
            LexiconEntryType.values.asNameMap()[row.lexiconEntryType] ??
                LexiconEntryType.lemma,
        lexiconEntryId: row.lexiconEntryId,
        deckId: row.deckId,
        note: row.note,
        createdAt: row.createdAt,
      );

  FlashcardDeck _deckToEntity(FlashcardDeckRow row) => FlashcardDeck(
        id: row.id,
        name: row.name,
        createdAt: row.createdAt,
      );

  @override
  Future<String> addFlashcard({
    required FlashcardType type,
    required LexiconEntryType lexiconEntryType,
    required int lexiconEntryId,
    String? deckId,
    String? note,
  }) {
    return withFailureLogging(_logger, 'addFlashcard', () async {
      final now = _nowMs();
      // Cùng LOẠI cả bản còn sống lẫn đã xoá mềm — UNIQUE(lexicon_entry_type,
      // lexicon_entry_id) không phân biệt theo deleted_at, nên thêm lại
      // 1 mục đã gỡ trước đó phải HỒI SINH bản ghi cũ (giữ nguyên id),
      // không insert trùng khoá — cùng mẫu Bookmarks/Favorites/srs_cards.
      final existing = await (_db.select(_db.flashcards)
            ..where(
              (t) =>
                  t.lexiconEntryType.equals(lexiconEntryType.name) &
                  t.lexiconEntryId.equals(lexiconEntryId),
            ))
          .getSingleOrNull();

      if (existing == null) {
        final id = _newId();
        await _db.into(_db.flashcards).insert(
              FlashcardsCompanion.insert(
                id: id,
                type: type.name,
                lexiconEntryType: lexiconEntryType.name,
                lexiconEntryId: lexiconEntryId,
                deckId: Value(deckId),
                note: Value(note),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return id;
      }

      if (existing.deletedAt == null) {
        // Đã có, còn sống -> coi add() là idempotent, trả về id đã có.
        return existing.id;
      }

      await (_db.update(_db.flashcards)..where((t) => t.id.equals(existing.id)))
          .write(
        FlashcardsCompanion(
          type: Value(type.name),
          deckId: Value(deckId),
          note: Value(note),
          deletedAt: const Value(null),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
      return existing.id;
    });
  }

  @override
  Future<void> removeFlashcard(String flashcardId) {
    return withFailureLogging(_logger, 'removeFlashcard', () async {
      await (_db.update(_db.flashcards)..where((t) => t.id.equals(flashcardId)))
          .write(
        FlashcardsCompanion(
          deletedAt: Value(_nowMs()),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> moveFlashcard(String flashcardId, String? deckId) {
    return withFailureLogging(_logger, 'moveFlashcard', () async {
      await (_db.update(_db.flashcards)..where((t) => t.id.equals(flashcardId)))
          .write(
        FlashcardsCompanion(
          deckId: Value(deckId),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Stream<List<Flashcard>> watchAllFlashcards() {
    final q = _db.select(_db.flashcards)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllFlashcards', stream);
  }

  @override
  Future<String> createDeck(String name) {
    return withFailureLogging(_logger, 'createDeck', () async {
      final id = _newId();
      final now = _nowMs();
      await _db.into(_db.flashcardDecks).insert(
            FlashcardDecksCompanion.insert(
              id: id,
              name: name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Future<void> renameDeck(String deckId, String name) {
    return withFailureLogging(_logger, 'renameDeck', () async {
      await (_db.update(_db.flashcardDecks)..where((t) => t.id.equals(deckId)))
          .write(
        FlashcardDecksCompanion(
          name: Value(name),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> deleteDeck(String deckId) {
    return withFailureLogging(_logger, 'deleteDeck', () async {
      final now = _nowMs();
      // Gỡ tham chiếu ở mọi Flashcard đang trỏ tới deck này TRƯỚC KHI
      // xoá mềm deck, cùng transaction — DB không có FK cascade (cùng
      // tiền lệ BookmarkCollectionRepositoryImpl.deleteCollection).
      await _db.transaction(() async {
        await (_db.update(_db.flashcards)
              ..where((t) => t.deckId.equals(deckId)))
            .write(
          FlashcardsCompanion(
            deckId: const Value(null),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
        await (_db.update(_db.flashcardDecks)
              ..where((t) => t.id.equals(deckId)))
            .write(
          FlashcardDecksCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      });
    });
  }

  @override
  Stream<List<FlashcardDeck>> watchAllDecks() {
    final q = _db.select(_db.flashcardDecks)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final stream = q.watch().map((rows) => rows.map(_deckToEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllDecks', stream);
  }
}
