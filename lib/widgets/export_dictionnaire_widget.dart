import 'package:dico/providers/dictionary_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ExportDictionnaireWidget extends StatefulWidget {
  const ExportDictionnaireWidget({super.key});

  @override
  State<ExportDictionnaireWidget> createState() =>
      _ExportDictionnaireWidgetState();
}

class _ExportDictionnaireWidgetState extends State<ExportDictionnaireWidget> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    final provider = context.read<DictionaryProvider>();
    setState(() => _isExporting = true);

    try {
      final file = await provider.exportToJson();

      if (!mounted) return;

      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Export réussi !\nFichier enregistré dans :\n${file.path}",
              style: const TextStyle(height: 1.3),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Export annulé."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur d’export : ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250, // 🔹 largeur fixe du bouton
        height: 45, // 🔹 hauteur stable
        child: OutlinedButton.icon(
          onPressed: _isExporting ? null : _handleExport,
          icon: _isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.download, color: Color(0xFF193CB8)),
          label: Text(
            _isExporting ? "Export en cours..." : "Exporter le dictionnaire",
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF193CB8),
            ),
            textAlign: TextAlign.center,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF193CB8), width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: const Color(0xFF193CB8),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
