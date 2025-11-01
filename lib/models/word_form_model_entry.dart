import 'package:dico/models/word_model.dart';
import 'package:flutter/material.dart';

class WordFormEntry {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  Language sourceLang;
  Language targetLang;
  WordType wordType;
  bool isValid = false;
  bool isSaved = false;

  WordFormEntry({
    this.sourceLang = Language.FR,
    this.targetLang = Language.AR,
    this.wordType = WordType.noun,
  }) {
    // ✅ On écoute les champs texte pour revalider automatiquement
    sourceController.addListener(_validate);
    translationController.addListener(_validate);

    // ✅ Validation initiale dès la création
    _validate();
  }

  bool get canSubmit =>
      sourceController.text.trim().isNotEmpty &&
      translationController.text.trim().isNotEmpty &&
      sourceLang != targetLang &&
      // ignore: unnecessary_null_comparison
      wordType != null; // ← toujours vrai, mais utile pour clarté

  void _validate() {
    isValid = canSubmit;
  }

  void dispose() {
    sourceController.dispose();
    translationController.dispose();
  }
}
