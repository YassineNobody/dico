import 'package:flutter/material.dart';
import 'package:dico/models/word_model.dart';
import 'package:provider/provider.dart';
import 'package:dico/providers/dictionary_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();

    final source = provider.activeSource;
    final target = provider.activeTarget;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔹 Langue source
        _buildDropdownContainer(
          context,
          DropdownButton<Language>(
            value: source,
            isExpanded: false,
            dropdownColor: Colors.white,
            underline: const SizedBox.shrink(), // enlève la ligne par défaut
            items: Language.values.map((lang) {
              final isDisabled = lang == target;
              return DropdownMenuItem(
                value: isDisabled ? null : lang,
                enabled: !isDisabled,
                child: Text(
                  _label(lang),
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : Colors.black,
                    fontWeight: lang == source
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (lang) {
              if (lang != null && lang != target) {
                provider.setActiveLanguages(lang, target);
              }
            },
          ),
        ),

        const SizedBox(width: 8),

        // 🔁 Bouton de switch
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.swap_horiz, size: 22),
            tooltip: "Inverser les langues",
            color: Colors.blueAccent,
            onPressed: () {
              if (source != target) {
                provider.setActiveLanguages(target, source);
              }
            },
          ),
        ),

        const SizedBox(width: 8),

        // 🔹 Langue cible
        _buildDropdownContainer(
          context,
          DropdownButton<Language>(
            value: target,
            isExpanded: false,
            dropdownColor: Colors.white,
            underline: const SizedBox.shrink(),
            items: Language.values.map((lang) {
              final isDisabled = lang == source;
              return DropdownMenuItem(
                value: isDisabled ? null : lang,
                enabled: !isDisabled,
                child: Text(
                  _label(lang),
                  style: TextStyle(
                    color: isDisabled ? Colors.grey : Colors.black,
                    fontWeight: lang == target
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (lang) {
              if (lang != null && lang != source) {
                provider.setActiveLanguages(source, lang);
              }
            },
          ),
        ),
      ],
    );
  }

  /// 🧱 Petit conteneur stylé autour du Dropdown
  Widget _buildDropdownContainer(BuildContext context, Widget child) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  /// 🌐 Noms des langues
  String _label(Language lang) {
    switch (lang) {
      case Language.FR:
        return '🇫🇷 Français';
      case Language.EN:
        return '🇬🇧 Anglais';
      case Language.AR:
        return '🇸🇦 Arabe';
    }
  }
}
