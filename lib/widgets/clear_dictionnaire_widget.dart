import 'package:dico/providers/dictionary_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class ClearDictionnaireWidget extends StatefulWidget {
  const ClearDictionnaireWidget({super.key});

  @override
  State<ClearDictionnaireWidget> createState() =>
      _ClearDictionnaireWidgetState();
}

class _ClearDictionnaireWidgetState extends State<ClearDictionnaireWidget> {
  bool _isClearing = false;

  Future<void> _handleClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text(
          "⚠️ Cette action va supprimer tous les mots de ton dictionnaire.\n"
          "Souhaites-tu vraiment continuer ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Oui, supprimer tout"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearing = true);
    if (!mounted) return;
    try {
      await context.read<DictionaryProvider>().clearAllWords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Dictionnaire vidé avec succès !"),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erreur : ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 45,
        child: OutlinedButton.icon(
          onPressed: _isClearing ? null : _handleClear,
          icon: _isClearing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.trash2, color: Colors.redAccent),
          label: Text(
            _isClearing ? "Suppression..." : "Vider le dictionnaire",
            style: GoogleFonts.montserrat(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent, width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
