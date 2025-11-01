import 'package:dico/models/word_model.dart';
import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/utils/string_extension.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class WordDetailModel extends StatelessWidget {
  final WordModel word;
  const WordDetailModel({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final isSourceArabic = word.sourceLanguage == Language.AR;
    final isTargetArabic = word.targetLanguage == Language.AR;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final size = MediaQuery.of(context).size;
    print(
      "Avant : '${word.sourceWord}' / Après : '${word.sourceWord.capitalizeFirst()}'",
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLandscape ? size.width * 0.7 : 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Barre décorative
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // 🔹 Contenu principal
                if (isLandscape)
                  _buildLandscapeLayout(isSourceArabic, isTargetArabic)
                else
                  _buildPortraitLayout(isSourceArabic, isTargetArabic),

                const SizedBox(height: 30),

                // 🔹 Boutons Modifier + Supprimer côte à côte
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✏️ Modifier
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: buildBtnUpdate(context),
                      ),
                    ),

                    // 🗑️ Supprimer
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: buildBtnDelete(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 Bouton Fermer
                buildBtnAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔸 Mode portrait
  Widget _buildPortraitLayout(bool isSourceArabic, bool isTargetArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          TranslationUtils.languageToFrWithoutFlag(
            word.sourceLanguage,
          ).capitalizeFirst(),
          style: customLabel(),
        ),
        const SizedBox(height: 6),
        Text(
          word.sourceWord.capitalizeFirst(),
          textAlign: TextAlign.center,
          style: isSourceArabic ? customStyleArabic() : customStyleNotArabic(),
        ),
        const SizedBox(height: 18),
        Text(
          TranslationUtils.languageToFrWithoutFlag(
            word.targetLanguage,
          ).capitalizeFirst(),
          style: customLabel(),
        ),
        const SizedBox(height: 6),
        Text(
          word.translatedWord.capitalizeFirst(),
          textAlign: TextAlign.center,
          style: isTargetArabic ? customStyleArabic() : customStyleNotArabic(),
        ),
        const SizedBox(height: 18),
        Text("Type".capitalizeFirst(), style: customLabel()),
        const SizedBox(height: 6),
        Text(
          TranslationUtils.wordTypeToFr(word.wordType).capitalizeFirst(),
          textAlign: TextAlign.center,
          style: customStyleNotArabic(),
        ),
      ],
    );
  }

  // 🔸 Mode paysage
  Widget _buildLandscapeLayout(bool isSourceArabic, bool isTargetArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                TranslationUtils.languageToFrWithoutFlag(
                  word.sourceLanguage,
                ).capitalizeFirst(),
                style: customLabel(),
              ),
              const SizedBox(height: 6),
              Text(
                word.sourceWord.capitalizeFirst(),
                textAlign: TextAlign.center,
                style: isSourceArabic
                    ? customStyleArabic()
                    : customStyleNotArabic(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                TranslationUtils.languageToFrWithoutFlag(
                  word.targetLanguage,
                ).capitalizeFirst(),
                style: customLabel(),
              ),
              const SizedBox(height: 6),
              Text(
                word.translatedWord,
                textAlign: TextAlign.center,
                style: isTargetArabic
                    ? customStyleArabic()
                    : customStyleNotArabic(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Type", style: customLabel()),
              const SizedBox(height: 6),
              Text(
                TranslationUtils.wordTypeToFr(word.wordType).capitalizeFirst(),
                textAlign: TextAlign.center,
                style: customStyleNotArabic(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✏️ Styles
  TextStyle customStyleNotArabic({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 1.015,
      height: 1.3,
    );
  }

  TextStyle customStyleArabic({double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: fontSize ?? 25,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: 1.4,
    );
  }

  TextStyle customLabel({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      letterSpacing: letterSpacing ?? 1.015,
      color: Colors.grey.shade700,
    );
  }

  // 🔹 Bouton Fermer
  TextButton buildBtnAction(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(LucideIcons.xCircle),
      style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        foregroundColor: const Color(0xFF193CB8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => Navigator.pop(context),
      label: Text(
        "Fermer",
        style: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.05,
        ),
      ),
    );
  }

  // ✏️ Bouton Modifier
  OutlinedButton buildBtnUpdate(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.go("/update-word/${word.id}");
      },
      icon: const Icon(LucideIcons.pencil, size: 12),
      label: Text(
        "Modifier",
        style: GoogleFonts.montserrat(fontSize: 12, letterSpacing: 1.025),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF193CB8),
        side: const BorderSide(color: Color(0xFF193CB8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 🗑️ Bouton Supprimer
  OutlinedButton buildBtnDelete(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(LucideIcons.trash2, size: 12, color: Colors.redAccent),
      label: Text(
        "Supprimer",
        style: GoogleFonts.montserrat(
          fontSize: 12,
          letterSpacing: 1.025,
          color: Colors.redAccent,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  color: Colors.redAccent,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  "Confirmation",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              "Voulez-vous vraiment supprimer « ${word.sourceWord} » ?\nCette action est irréversible.",
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Annuler",
                  style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.trash2, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                label: Text(
                  "Supprimer",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final provider = context.read<DictionaryProvider>();
          await provider.deleteWord(word.id!);
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }
}
