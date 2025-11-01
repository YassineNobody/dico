import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dico.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_word TEXT,
            source_language TEXT,
            translated_word TEXT,
            target_language TEXT,
            word_type TEXT,
            created_at TEXT,
            UNIQUE(source_word, source_language, target_language)
          );
          ''');
      },
    );
  }

  // 🔍 Check if a word already exists (to avoid duplicates)
  Future<bool> existsWord(
    String source,
    Language sourceLang,
    Language targetLang,
  ) async {
    final db = await database;

    final result = await db.query(
      'words',
      where: 'source_word = ? AND source_language = ? AND target_language = ?',
      whereArgs: [source, sourceLang.code, targetLang.code],
    );

    return result.isNotEmpty;
  }

  // 🔹 Insert (with duplicate prevention)
  Future<int> insertWord(WordModel word) async {
    final db = await database;

    // Prevent duplicate entries
    final exists = await existsWord(
      word.sourceWord,
      word.sourceLanguage,
      word.targetLanguage,
    );

    if (exists) {
      throw Exception(
        'This word already exists for this language pair (${word.sourceLanguage.code} → ${word.targetLanguage.code}).',
      );
    }

    try {
      return await db.insert('words', word.toMap());
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Duplicate entry detected.');
      }
      rethrow;
    }
  }

  // 🔹 Delete
  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  // 🔹 Get all
  Future<List<WordModel>> getAllWords() async {
    final db = await database;
    final result = await db.query('words', orderBy: 'id DESC');
    return result.map((e) => WordModel.fromMap(e)).toList();
  }

  // 🔹 Get by language pair (flexible version — includes inverse pairs)
  Future<List<WordModel>> getByLanguages(
    Language source,
    Language target,
  ) async {
    final db = await database;

    // 1️⃣ Cherche les mots dans le sens normal (ex: FR → AR)
    final result = await db.query(
      'words',
      where: 'source_language = ? AND target_language = ?',
      whereArgs: [source.code, target.code],
      orderBy: 'id DESC',
    );

    if (result.isNotEmpty) {
      return result.map((e) => WordModel.fromMap(e)).toList();
    }

    // 2️⃣ Si aucun mot trouvé, on cherche dans le sens inverse (ex: AR → FR)
    final inverse = await db.query(
      'words',
      where: 'source_language = ? AND target_language = ?',
      whereArgs: [target.code, source.code],
      orderBy: 'id DESC',
    );

    // 3️⃣ On inverse la traduction pour l’affichage
    return inverse.map((e) {
      final original = WordModel.fromMap(e);
      return WordModel(
        id: original.id,
        sourceWord: original.translatedWord,
        sourceLanguage: source, // on réaffiche selon le sens demandé
        translatedWord: original.sourceWord,
        targetLanguage: target,
        wordType: original.wordType,
        createdAt: original.createdAt,
      );
    }).toList();
  }

  // 🔹 Get all language pairs (e.g., FR→AR, AR→EN)
  Future<List<Map<String, String>>> getLanguagePairs() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT source_language, target_language FROM words
    ''');

    return result
        .map(
          (row) => {
            'source': row['source_language'] as String,
            'target': row['target_language'] as String,
          },
        )
        .toList();
  }

  // 🔎 Recherche flexible — gère les paires inversées automatiquement
  Future<List<WordModel>> search(
    String query,
    Language source,
    Language target,
  ) async {
    final db = await database;

    // 1️⃣ Recherche dans le sens normal (ex: FR → AR)
    final result = await db.query(
      'words',
      where: '''
      (source_word LIKE ? OR translated_word LIKE ?)
      AND source_language = ? AND target_language = ?
    ''',
      whereArgs: ['%$query%', '%$query%', source.code, target.code],
      orderBy: 'id DESC',
    );

    if (result.isNotEmpty) {
      return result.map((e) => WordModel.fromMap(e)).toList();
    }

    // 2️⃣ Si rien trouvé, on cherche dans le sens inverse (ex: AR → FR)
    final inverse = await db.query(
      'words',
      where: '''
      (source_word LIKE ? OR translated_word LIKE ?)
      AND source_language = ? AND target_language = ?
    ''',
      whereArgs: ['%$query%', '%$query%', target.code, source.code],
      orderBy: 'id DESC',
    );

    // 3️⃣ On inverse les résultats pour correspondre à l’affichage courant
    return inverse.map((e) {
      final original = WordModel.fromMap(e);
      return WordModel(
        id: original.id,
        sourceWord: original.translatedWord,
        sourceLanguage: source,
        translatedWord: original.sourceWord,
        targetLanguage: target,
        wordType: original.wordType,
        createdAt: original.createdAt,
      );
    }).toList();
  }

  Future<List<WordModel>> getByType(
    WordType type,
    Language source,
    Language target,
  ) async {
    final db = await database;

    // 🔹 Recherche directe
    final result = await db.query(
      "words",
      where: '''
      word_type = ? 
      AND source_language = ? 
      AND target_language = ?
    ''',
      whereArgs: [type.label, source.code, target.code],
      orderBy: "id DESC",
    );

    if (result.isNotEmpty) {
      return result.map((e) => WordModel.fromMap(e)).toList();
    }

    // 🔹 Recherche inverse
    final inverse = await db.query(
      "words",
      where: '''
      word_type = ? 
      AND source_language = ? 
      AND target_language = ?
    ''',
      whereArgs: [type.label, target.code, source.code],
      orderBy: "id DESC",
    );

    return inverse.map((e) {
      final original = WordModel.fromMap(e);
      return WordModel(
        id: original.id,
        sourceWord: original.translatedWord,
        sourceLanguage: source,
        translatedWord: original.sourceWord,
        targetLanguage: target,
        wordType: original.wordType,
        createdAt: original.createdAt,
      );
    }).toList();
  }

  // 🔹 Update an existing word (with duplicate prevention)
  Future<int> updateWord(WordModel word) async {
    final db = await database;

    if (word.id == null) {
      throw ArgumentError('Cannot update a word without an ID.');
    }

    // Check if another word with same source + languages already exists
    final result = await db.query(
      'words',
      where: '''
        source_word = ? AND source_language = ? 
        AND target_language = ? AND id != ?
      ''',
      whereArgs: [
        word.sourceWord,
        word.sourceLanguage.code,
        word.targetLanguage.code,
        word.id,
      ],
    );

    if (result.isNotEmpty) {
      throw Exception(
        'Another word with the same source and language pair already exists.',
      );
    }

    return await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  // 🔹 Get a single word by ID
  Future<WordModel?> getWordById(int id) async {
    final db = await database;
    final result = await db.query(
      "words",
      where: "id=?",
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return WordModel.fromMap(result.first);
  }

  // 🔢 Compte le nombre de mots pour une paire de langues donnée (source/target)
  Future<int> countWordsByLanguages(Language source, Language target) async {
    final db = await database;

    // 1️⃣ Compte dans le sens normal
    final result = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
    SELECT COUNT(*) FROM words
    WHERE source_language = ? AND target_language = ?
  ''',
        [source.code, target.code],
      ),
    );

    // 2️⃣ Si aucun mot trouvé, on compte dans le sens inverse
    if (result == 0) {
      final inverse = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
      SELECT COUNT(*) FROM words
      WHERE source_language = ? AND target_language = ?
    ''',
          [target.code, source.code],
        ),
      );
      return inverse ?? 0;
    }

    return result ?? 0;
  }

  // 🔥 Supprimer tous les mots du dictionnaire
  Future<int> clearAllWords() async {
    final db = await database;
    // Renvoie le nombre de lignes supprimées
    return await db.delete('words');
  }
}
