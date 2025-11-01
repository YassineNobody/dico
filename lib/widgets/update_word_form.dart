import 'package:dico/models/word_model.dart';
import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class UpdateWordForm extends StatefulWidget {
  final WordModel word;

  const UpdateWordForm({super.key, required this.word});

  @override
  State<UpdateWordForm> createState() => _UpdateWordFormState();
}

class _UpdateWordFormState extends State<UpdateWordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sourceController;
  late TextEditingController _translatedController;
  WordType? _selectedType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(text: widget.word.sourceWord);
    _translatedController = TextEditingController(
      text: widget.word.translatedWord,
    );
    _selectedType = widget.word.wordType;
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // ✅ Fermer le clavier avant validation
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final updatedWord = widget.word.copyWith(
      sourceWord: _sourceController.text.trim(),
      translatedWord: _translatedController.text.trim(),
      wordType: _selectedType ?? widget.word.wordType,
    );

    try {
      final provider = context.read<DictionaryProvider>();
      await provider.updateWord(updatedWord);

      // ✅ Retour direct à la home après succès
      if (mounted) context.go("/");
    } catch (e) {
      // ⚠️ SnackBar uniquement pour les erreurs
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📝 Mot source
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: "Mot source",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 20),

              // 🌍 Traduction
              TextFormField(
                controller: _translatedController,
                decoration: const InputDecoration(
                  labelText: "Traduction",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 20),

              // 🏷️ Type de mot
              DropdownButtonFormField<WordType>(
                initialValue: _selectedType, // ✅ au lieu de value:
                decoration: const InputDecoration(
                  labelText: "Type de mot",
                  border: OutlineInputBorder(),
                ),
                items: WordType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(TranslationUtils.wordTypeToFr(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              const SizedBox(height: 30),

              // 🔘 Bouton Mettre à jour
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isSubmitting ? "Mise à jour..." : "Mettre à jour",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.05,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF193CB8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
