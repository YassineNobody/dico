import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "Confirmer",
  String cancelText = "Annuler",
  Color confirmColor = Colors.red,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 🔒 empêche de fermer en dehors
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Text(message, style: GoogleFonts.poppins(fontSize: 15)),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: GoogleFonts.montserrat(color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText, style: GoogleFonts.montserrat()),
        ),
      ],
    ),
  );

  return result ?? false; // par défaut = false
}
