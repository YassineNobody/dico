import 'package:dico/models/word_model.dart';
import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FilterTypeWordSelector extends StatefulWidget {
  const FilterTypeWordSelector({super.key});

  @override
  State<FilterTypeWordSelector> createState() => _FilterTypeWordSelectorState();
}

class _FilterTypeWordSelectorState extends State<FilterTypeWordSelector> {
  WordType? _selectedType; // null = tous les mots

  Future<void> _onTypeChanged(
    WordType? newType,
    DictionaryProvider provider,
  ) async {
    setState(() => _selectedType = newType);

    if (newType == null) {
      await provider.loadWords(); // 🔁 tous les mots
    } else {
      await provider.loadByWordType(newType); // 🔁 filtré par type
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WordType?>(
          value: _selectedType,
          isExpanded: false,
          dropdownColor: Colors.white,
          items: [
            // 🔹 Option “Tous les mots”
            DropdownMenuItem<WordType?>(
              value: null,
              child: Text(
                "Tous les mots",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
            ),
            // 🔹 Les autres types
            ...WordType.values.map((entry) {
              return DropdownMenuItem<WordType?>(
                value: entry,
                child: Text(
                  TranslationUtils.wordTypeToFr(entry),
                  style: GoogleFonts.montserrat(
                    fontWeight: entry == _selectedType
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
          onChanged: (newType) => _onTypeChanged(newType, provider),
        ),
      ),
    );
  }
}
