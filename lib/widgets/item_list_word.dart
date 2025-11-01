import 'package:dico/models/word_model.dart';
import 'package:dico/utils/show_dialog.dart';
import 'package:dico/utils/string_extension.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemListWord extends StatelessWidget {
  final bool isLandscape;
  final double maxWidth;
  final WordModel word;

  const ItemListWord({
    super.key,
    required this.isLandscape,
    this.maxWidth = double.infinity,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    final isSourceArabic = word.sourceLanguage == Language.AR;
    final isTargetArabic = word.targetLanguage == Language.AR;

    // 🔢 Largeur max dynamique pour tablette / paysage
    final double dynamicMaxWidth = isLandscape
        ? (MediaQuery.of(context).size.width * 0.7).clamp(500, 800)
        : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dynamicMaxWidth),
        child: InkWell(
          onTap: () => ShowDialog.showDialogCustom(context, word),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // 🔹 Garde ton Row avec spaceBetween
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bloc source
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${TranslationUtils.languageToFrWithoutFlag(word.sourceLanguage).capitalizeFirst()} : ",
                        style: customLabel(),
                      ),
                      Flexible(
                        child: Text(
                          word.sourceWord.capitalizeFirst(),
                          overflow: TextOverflow.ellipsis,
                          style: isSourceArabic
                              ? customStyleArabic()
                              : customStyleNotArabic(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Bloc cible
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${TranslationUtils.languageToFrWithoutFlag(word.targetLanguage).capitalizeFirst()} : ",
                        style: customLabel(),
                      ),
                      Flexible(
                        child: Text(
                          word.translatedWord.capitalizeFirst(),
                          overflow: TextOverflow.ellipsis,
                          style: isTargetArabic
                              ? customStyleArabic()
                              : customStyleNotArabic(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✏️ Styles
  TextStyle customStyleNotArabic({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 1.015,
    );
  }

  TextStyle customStyleArabic({double? fontSize, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }

  TextStyle customLabel({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      letterSpacing: letterSpacing ?? 1.015,
      color: Colors.grey.shade700,
    );
  }
}
