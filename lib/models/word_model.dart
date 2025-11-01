// ignore_for_file: constant_identifier_names

enum Language { FR, EN, AR }

extension LanguageExtension on Language {
  String get code {
    switch (this) {
      case Language.FR:
        return 'FR';
      case Language.EN:
        return 'EN';
      case Language.AR:
        return 'AR';
    }
  }

  static Language fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'FR':
        return Language.FR;
      case 'EN':
        return Language.EN;
      case 'AR':
        return Language.AR;
      default:
        throw ArgumentError('Unknown language: $code');
    }
  }
}

enum WordType {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  pronoun,
  suffix,
  other,
}

extension WordTypeExtension on WordType {
  String get label {
    switch (this) {
      case WordType.noun:
        return 'Noun';
      case WordType.verb:
        return 'Verb';
      case WordType.adjective:
        return 'Adjective';
      case WordType.adverb:
        return 'Adverb';
      case WordType.preposition:
        return 'Preposition';
      case WordType.pronoun:
        return 'Pronoun';
      case WordType.suffix:
        return 'Suffix';
      case WordType.other:
        return 'Other';
    }
  }

  static WordType fromLabel(String? value) {
    switch (value?.toLowerCase()) {
      case 'noun':
        return WordType.noun;
      case 'verb':
        return WordType.verb;
      case 'adjective':
        return WordType.adjective;
      case 'adverb':
        return WordType.adverb;
      case 'preposition':
        return WordType.preposition;
      case 'pronoun':
        return WordType.pronoun;
      case 'suffix':
        return WordType.suffix;
      default:
        return WordType.other;
    }
  }
}

class WordModel {
  final int? id;
  final String sourceWord;
  final Language sourceLanguage;
  final String translatedWord;
  final Language targetLanguage;
  final WordType wordType;
  final String createdAt;

  WordModel({
    this.id,
    required this.sourceWord,
    required this.sourceLanguage,
    required this.translatedWord,
    required this.targetLanguage,
    required this.wordType,
    required this.createdAt,
  });

  // 🧭 Map → Object
  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      sourceWord: map['source_word'] as String,
      sourceLanguage: LanguageExtension.fromCode(map['source_language']),
      translatedWord: map['translated_word'] as String,
      targetLanguage: LanguageExtension.fromCode(map['target_language']),
      wordType: WordTypeExtension.fromLabel(map['word_type']),
      createdAt: map['created_at'] as String,
    );
  }

  // 🧭 Object → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_word': sourceWord,
      'source_language': sourceLanguage.code,
      'translated_word': translatedWord,
      'target_language': targetLanguage.code,
      'word_type': wordType.label,
      'created_at': createdAt,
    };
  }

  // ✨ Nouvelle méthode copyWith
  WordModel copyWith({
    int? id,
    String? sourceWord,
    Language? sourceLanguage,
    String? translatedWord,
    Language? targetLanguage,
    WordType? wordType,
    String? createdAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      sourceWord: sourceWord ?? this.sourceWord,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      translatedWord: translatedWord ?? this.translatedWord,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      wordType: wordType ?? this.wordType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
