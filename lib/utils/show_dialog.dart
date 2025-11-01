import 'package:dico/models/word_model.dart';
import 'package:dico/widgets/word_detail_model.dart';
import 'package:flutter/material.dart';

class ShowDialog {
  static Future<void> showDialogCustom(BuildContext context, WordModel word) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final size = MediaQuery.of(context).size;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent, // 👈 pour custom container
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        // 🔹 Le contenu adaptatif
        final child = Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: WordDetailModel(word: word),
            ),
          ),
        );

        // 🔹 Si mode portrait → bottom sheet classique
        if (!isLandscape) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: child,
          );
        }

        // 🔹 Si mode paysage → modal centré et plus large
        return Center(
          child: Container(
            width:
                size.width * 0.7, // 70 % de la largeur (ou ajuste à ton goût)
            constraints: const BoxConstraints(maxWidth: 700),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}
