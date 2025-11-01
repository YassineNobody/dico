import 'dart:io';

import 'package:dico/models/word_model.dart';
import 'package:dico/services/db_service.dart';
import 'package:dico/services/files_service.dart';
import 'package:dico/services/notification_service.dart';
import 'package:flutter/material.dart';

class DictionaryProvider extends ChangeNotifier {
  final DBService _db = DBService();
  final NotificationService _notificationService = NotificationService();

  List<WordModel> _words = [];
  List<WordModel> get words => List.unmodifiable(_words);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // 🌍 Langues actives par défaut (FR → AR)
  Language _activeSource = Language.FR;
  Language _activeTarget = Language.AR;

  Language get activeSource => _activeSource;
  Language get activeTarget => _activeTarget;

  // -------------------------------------------------------
  // 🌐 Gestion des langues
  // -------------------------------------------------------

  void setActiveLanguages(Language source, Language target) {
    if (source == target) return; // évite FR->FR
    _activeSource = source;
    _activeTarget = target;
    loadByLanguages(source, target);
  }

  // -------------------------------------------------------
  // 🔹 CRUD : opérations principales
  // -------------------------------------------------------

  Future<void> addWord(WordModel word) async {
    try {
      clearError();
      await _db.insertWord(word);
      await _notificationService.showNotification(
        title: '✅ Tu viens d\'ajouter ${word.translatedWord}',
        body: "Super tu as ajoutés un nouveau dans ton dico !",
      );
      await loadWords();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> updateWord(WordModel word) async {
    try {
      clearError();
      await _db.updateWord(word);
      await _notificationService.showNotification(
        title: "⭐ Tu viens de modifier ${word.translatedWord} !",
        body: "Tu viens de modifier les données d'un mot dans ton dico !",
      );
      await loadWords();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> deleteWord(int id) async {
    try {
      clearError();
      await _db.deleteWord(id);
      _words.removeWhere((w) => w.id == id);
      await _notificationService.showNotification(
        title: "💔 Nous sommes en deuil",
        body:
            "C'est le coeur lourds qu'un de nos soldat disparaît à tout jamais",
      );
      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // -------------------------------------------------------
  // 🔍 Chargement et recherche
  // -------------------------------------------------------

  Future<void> loadWords() async =>
      loadByLanguages(_activeSource, _activeTarget);

  Future<void> searchWords(String query) async {
    try {
      clearError();
      _isLoading = true;
      notifyListeners();

      _words = query.isEmpty
          ? await _db.getByLanguages(_activeSource, _activeTarget)
          : await _db.search(query, _activeSource, _activeTarget);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByLanguages(Language source, Language target) async {
    try {
      clearError();
      _isLoading = true;
      notifyListeners();

      _words = await _db.getByLanguages(source, target);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadByWordType(WordType type) async {
    try {
      clearError();
      _isLoading = true;
      notifyListeners();

      _words = await _db.getByType(type, _activeSource, _activeTarget);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // 🧱 Lecture unique et vérification
  // -------------------------------------------------------

  Future<WordModel?> getById(int id) async {
    try {
      clearError();
      return await _db.getWordById(id);
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  Future<bool> existsInDb({
    required String sourceWord,
    required Language sourceLang,
    required Language targetLang,
  }) async {
    try {
      clearError();
      return await _db.existsWord(sourceWord, sourceLang, targetLang);
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<int> getCountForActiveLanguages() async {
    try {
      clearError();
      return await _db.countWordsByLanguages(_activeSource, _activeTarget);
    } catch (e) {
      _setError(e);
      return 0;
    }
  }

  Future<File?> exportToJson() async {
    try {
      clearError();
      final file = await _db.exportWordsToJson();
      if (file == null) return null;

      await _notificationService.showNotification(
        title: "📦 Export réussi !",
        body: "Ton dictionnaire a été sauvegardé dans ${file.path}",
      );
      return file;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  Future<int> importFromJson() async {
    try {
      clearError();
      final count = await _db.importWordsFromJson();

      if (count > 0) {
        await _notificationService.showNotification(
          title: "📥 Import terminé !",
          body: "$count mots ont été ajoutés à ton dictionnaire.",
        );
        await loadWords(); // recharge après import
      }
      return count;
    } catch (e) {
      _setError(e);
      return 0;
    }
  }

  Future<void> clearAllWords() async {
    try {
      clearError();
      final deletedCount = await _db.clearAllWords();

      _words.clear(); // vide aussi la liste locale
      notifyListeners();

      await _notificationService.showNotification(
        title: "🗑️ Dictionnaire vidé",
        body: "$deletedCount mots ont été supprimés avec succès.",
      );
    } catch (e) {
      _setError(e);
    }
  }

  // -------------------------------------------------------
  // ⚙️ Helpers
  // -------------------------------------------------------

  void clearError() => _error = null;

  void _setError(Object e) {
    _error = e.toString();
    notifyListeners();
  }
}
