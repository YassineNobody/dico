import '../models/word_model.dart';

class TranslationUtils {
  /// 🔤 Traduire une langue (Language) en français
  static String languageToFr(Language lang) {
    switch (lang) {
      case Language.FR:
        return '🇫🇷 Français';
      case Language.EN:
        return '🇬🇧 Anglais';
      case Language.AR:
        return '🇸🇦 Arabe';
    }
  }

  static String languageToFrWithoutFlag(Language lang) {
    switch (lang) {
      case Language.FR:
        return 'Français';
      case Language.EN:
        return 'Anglais';
      case Language.AR:
        return 'Arabe';
    }
  }

  /// 🏷️ Traduire un type de mot (WordType) en français
  static String wordTypeToFr(WordType type) {
    switch (type) {
      case WordType.noun:
        return 'Nom';
      case WordType.verb:
        return 'Verbe';
      case WordType.adjective:
        return 'Adjectif';
      case WordType.adverb:
        return 'Adverbe';
      case WordType.preposition:
        return 'Préposition';
      case WordType.pronoun:
        return 'Pronom';
      case WordType.suffix:
        return 'Suffixe';
      case WordType.other:
        return 'Autre';
    }
  }

  /// 🔁 Inverse : obtenir un WordType depuis une étiquette française
  static WordType wordTypeFromFr(String fr) {
    switch (fr.toLowerCase()) {
      case 'nom':
        return WordType.noun;
      case 'verbe':
        return WordType.verb;
      case 'adjectif':
        return WordType.adjective;
      case 'adverbe':
        return WordType.adverb;
      case 'préposition':
        return WordType.preposition;
      case 'pronom':
        return WordType.pronoun;
      case 'suffixe':
        return WordType.suffix;
      default:
        return WordType.other;
    }
  }
}
