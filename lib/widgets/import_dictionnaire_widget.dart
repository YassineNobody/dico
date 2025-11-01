import 'package:dico/providers/dictionary_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ImportDictionnaireWidget extends StatefulWidget {
  const ImportDictionnaireWidget({super.key});

  @override
  State<ImportDictionnaireWidget> createState() =>
      _ImportDictionnaireWidgetState();
}

class _ImportDictionnaireWidgetState extends State<ImportDictionnaireWidget> {
  bool _isImporting = false;

  Future<void> _handleImport() async {
    final provider = context.read<DictionaryProvider>();
    setState(() => _isImporting = true);

    try {
      final count = await provider.importFromJson();
      if (!mounted) return;

      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ $count mots importés avec succès !"),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucun mot importé."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur : ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250, // 🔹 même largeur que l’export
        height: 45, // 🔹 même hauteur
        child: OutlinedButton.icon(
          onPressed: _isImporting ? null : _handleImport,
          icon: _isImporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.upload, color: Color(0xFF198754)),
          label: Text(
            _isImporting ? "Import en cours..." : "Importer un dictionnaire",
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF198754),
            ),
            textAlign: TextAlign.center,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF198754), width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: const Color(0xFF198754),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
