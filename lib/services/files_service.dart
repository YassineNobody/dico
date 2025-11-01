import 'dart:io';
import 'dart:convert';
import 'package:dico/services/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word_model.dart';

extension DicoExportImport on DBService {
  Future<File?> exportWordsToJson() async {
    final db = await database;
    final result = await db.query('words', orderBy: 'id DESC');

    // 🔹 Ne garde que les champs utiles
    final filtered = result.map((row) {
      return {
        'source_word': row['source_word'],
        'source_language': row['source_language'],
        'translated_word': row['translated_word'],
        'target_language': row['target_language'],
        'word_type': row['word_type'],
      };
    }).toList();

    final jsonString = jsonEncode(filtered);

    final tempFile = File(
      '${Directory.systemTemp.path}/dictionnaire_export.json',
    );
    await tempFile.writeAsString(jsonString, flush: true);

    String? savedPath;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(
          sourceFilePath: tempFile.path,
          fileName: 'dictionnaire_export.json',
        );
        savedPath = await FlutterFileDialog.saveFile(params: params);
      } else {
        final dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath != null) {
          final file = File('$dirPath/dictionnaire_export.json');
          await file.writeAsString(jsonString, flush: true);
          savedPath = file.path;
        }
      }

      if (savedPath == null) return null;
      return File(savedPath);
    } catch (e) {
      print('❌ Erreur export JSON : $e');
      rethrow;
    }
  }

  Future<int> importWordsFromJson() async {
    try {
      File? file;

      // 🔹 Choix du fichier selon la plateforme
      if (Platform.isAndroid || Platform.isIOS) {
        final params = OpenFileDialogParams(
          fileExtensionsFilter: ['json'],
          localOnly: true,
        );
        final pickedPath = await FlutterFileDialog.pickFile(params: params);
        if (pickedPath == null) return 0;
        file = File(pickedPath);
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result == null || result.files.single.path == null) return 0;
        file = File(result.files.single.path!);
      }

      // 🔹 Lecture du JSON
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final db = await database;
      int importedCount = 0;

      for (final e in jsonData) {
        final data = Map<String, dynamic>.from(e);

        // 🔹 Ajoute createdAt et ignore id
        final word = WordModel(
          sourceWord: data['source_word'],
          sourceLanguage: LanguageExtension.fromCode(data['source_language']),
          translatedWord: data['translated_word'],
          targetLanguage: LanguageExtension.fromCode(data['target_language']),
          wordType: WordTypeExtension.fromLabel(data['word_type']),
          createdAt: DateTime.now().toIso8601String(),
        );

        try {
          await db.insert(
            'words',
            word.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          importedCount++;
        } catch (_) {
          // ignore duplicate errors
        }
      }

      return importedCount;
    } catch (e) {
      print('❌ Erreur import JSON : $e');
      rethrow;
    }
  }
}
