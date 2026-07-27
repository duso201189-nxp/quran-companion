import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/flashcards/data/flashcard_repository_impl.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

void main() {
  late UserDatabase db;
  late FlashcardRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = FlashcardRepositoryImpl(
      db,
      const ConsoleLogger(),
      newId: () => 'card-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  group('addFlashcard', () {
    test('tạo Flashcard mới, trỏ đúng (lexiconEntryType, lexiconEntryId)',
        () async {
      final id = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );

      final cards = await repo.watchAllFlashcards().first;
      expect(cards, hasLength(1));
      expect(cards.single.id, id);
      expect(cards.single.type, FlashcardType.lemma);
      expect(cards.single.lexiconEntryType, LexiconEntryType.lemma);
      expect(cards.single.lexiconEntryId, 10);
      expect(cards.single.createdAt, fakeNow);
    });

    test('deckId/note tuỳ chọn được lưu đúng', () async {
      await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
        deckId: 'deck-1',
        note: 'ghi chú riêng',
      );

      final card = (await repo.watchAllFlashcards().first).single;
      expect(card.deckId, 'deck-1');
      expect(card.note, 'ghi chú riêng');
    });

    test(
        'thêm lần 2 cho CÙNG (lexiconEntryType, lexiconEntryId) còn sống '
        '-> idempotent, trả về id đã có, không tạo trùng', () async {
      final id1 = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );
      final id2 = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );

      expect(id2, id1);
      expect(await repo.watchAllFlashcards().first, hasLength(1));
    });

    test(
        'thêm lại sau khi đã xoá mềm -> hồi sinh bản ghi cũ (giữ nguyên '
        'id), KHÔNG insert trùng khoá UNIQUE', () async {
      final id = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );
      await repo.removeFlashcard(id);
      expect(await repo.watchAllFlashcards().first, isEmpty);

      fakeNow = 2000;
      final revivedId = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
        note: 'ghi chú mới',
      );

      expect(revivedId, id);
      final cards = await repo.watchAllFlashcards().first;
      expect(cards, hasLength(1));
      expect(cards.single.note, 'ghi chú mới');
    });

    test('2 lexiconEntryId khác nhau -> 2 Flashcard độc lập', () async {
      await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );
      await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 20,
      );

      expect(await repo.watchAllFlashcards().first, hasLength(2));
    });
  });

  group('removeFlashcard', () {
    test('xoá mềm -> biến mất khỏi watchAllFlashcards', () async {
      final id = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );
      await repo.removeFlashcard(id);
      expect(await repo.watchAllFlashcards().first, isEmpty);
    });

    test('id không tồn tại -> không lỗi', () async {
      await repo.removeFlashcard('khong-ton-tai');
    });
  });

  group('watchAllFlashcards', () {
    test('mới nhất trước (sắp theo createdAt giảm dần)', () async {
      fakeNow = 1000;
      await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );
      fakeNow = 2000;
      await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 20,
      );

      final cards = await repo.watchAllFlashcards().first;
      expect(cards.map((c) => c.lexiconEntryId), [20, 10]);
    });
  });

  group('Deck', () {
    test('createDeck rồi watchAllDecks trả đúng', () async {
      final id = await repo.createDeck('Từ vựng Al-Baqarah');
      final decks = await repo.watchAllDecks().first;
      expect(decks, hasLength(1));
      expect(decks.single.id, id);
      expect(decks.single.name, 'Từ vựng Al-Baqarah');
    });

    test('chưa tạo deck nào -> watchAllDecks rỗng', () async {
      expect(await repo.watchAllDecks().first, isEmpty);
    });

    test('renameDeck đổi tên, không đổi id', () async {
      final id = await repo.createDeck('Tên cũ');
      await repo.renameDeck(id, 'Tên mới');
      final decks = await repo.watchAllDecks().first;
      expect(decks.single.id, id);
      expect(decks.single.name, 'Tên mới');
    });

    test(
        'deleteDeck xoá mềm deck VÀ gỡ deckId khỏi mọi Flashcard đang trỏ '
        'tới nó', () async {
      final deckId = await repo.createDeck('Deck A');
      final flashcardId = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
        deckId: deckId,
      );

      await repo.deleteDeck(deckId);

      expect(await repo.watchAllDecks().first, isEmpty);
      final flashcard = (await repo.watchAllFlashcards().first).single;
      expect(flashcard.id, flashcardId);
      expect(flashcard.deckId, isNull);
    });

    test('deleteDeck với id không tồn tại -> không lỗi', () async {
      await repo.deleteDeck('khong-ton-tai');
    });
  });

  group('moveFlashcard', () {
    test('chuyển Flashcard sang deck khác', () async {
      final deckId = await repo.createDeck('Deck đích');
      final flashcardId = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
      );

      await repo.moveFlashcard(flashcardId, deckId);

      final flashcard = (await repo.watchAllFlashcards().first).single;
      expect(flashcard.deckId, deckId);
    });

    test('deckId null -> gỡ khỏi mọi deck', () async {
      final deckId = await repo.createDeck('Deck A');
      final flashcardId = await repo.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 10,
        deckId: deckId,
      );

      await repo.moveFlashcard(flashcardId, null);

      final flashcard = (await repo.watchAllFlashcards().first).single;
      expect(flashcard.deckId, isNull);
    });

    test('flashcardId không tồn tại -> không lỗi', () async {
      await repo.moveFlashcard('khong-ton-tai', 'deck-nao-do');
    });
  });
}
