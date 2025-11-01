import 'package:dico/models/word_form_model_entry.dart';
import 'package:dico/models/word_model.dart';
import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddWordsScreen extends StatefulWidget {
  final ValueNotifier<bool> showBars;

  const AddWordsScreen({super.key, required this.showBars});

  @override
  State<AddWordsScreen> createState() => _AddWordsScreenState();
}

class _AddWordsScreenState extends State<AddWordsScreen>
    with WidgetsBindingObserver {
  final List<WordFormEntry> _entries = [WordFormEntry()];
  final List<ExpansibleController> _controllers = [ExpansibleController()];

  String? errorForm;
  String? errorProvider;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.showBars.value = true;
      _lastOrientation = MediaQuery.of(context).orientation;
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final current = MediaQuery.of(context).orientation;
    if (_lastOrientation != current) {
      _lastOrientation = current;
      widget.showBars.value = true;
    }
  }

  void _clearErrors() {
    errorForm = null;
    errorProvider = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final e in _entries) {
      e.sourceController.dispose();
      e.translationController.dispose();
    }
    _entries.clear();
    _controllers.clear();
  }

  void _resetForm() {
    _disposeControllers();
    _entries.add(WordFormEntry());
    _controllers.add(ExpansibleController());
    errorForm = null;
    errorProvider = null;
    if (mounted) setState(() {});
  }

  void _addNewEntry() {
    setState(() {
      _entries.add(WordFormEntry());
      _controllers.add(ExpansibleController());
      _clearErrors();
    });
  }

  Future<void> _saveEntry(WordFormEntry entry, int index) async {
    _clearErrors();
    final provider = context.read<DictionaryProvider>();
    final now = DateTime.now().toIso8601String();

    final existsInDb = await provider.existsInDb(
      sourceWord: entry.sourceController.text.trim(),
      sourceLang: entry.sourceLang,
      targetLang: entry.targetLang,
    );

    if (provider.error != null) {
      setState(() => errorProvider = provider.error);
      return;
    }

    if (existsInDb) {
      setState(() => errorForm = "❌ Ce mot existe déjà dans la base.");
      return;
    }

    final word = WordModel(
      sourceWord: entry.sourceController.text.trim(),
      sourceLanguage: entry.sourceLang,
      translatedWord: entry.translationController.text.trim(),
      targetLanguage: entry.targetLang,
      wordType: entry.wordType,
      createdAt: now,
    );

    try {
      await provider.addWord(word);
      entry.isSaved = true;

      // ✅ Ferme automatiquement l'accordéon du mot enregistré
      _controllers[index].collapse();

      setState(() => errorForm = null);
    } catch (e) {
      setState(() => errorForm = "Erreur lors de l’ajout : $e");
    }
  }

  bool _handleScroll(ScrollNotification notif) {
    if (notif is UserScrollNotification) {
      if (notif.direction == ScrollDirection.reverse && widget.showBars.value) {
        widget.showBars.value = false;
      } else if (notif.direction == ScrollDirection.forward &&
          !widget.showBars.value) {
        widget.showBars.value = true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DictionaryProvider>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          _resetForm(); // 🔄 Reset à la sortie
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(
          animation: widget.showBars,
          builder: (context, _) {
            final bottomPadding = widget.showBars.value ? 100.0 : 20.0;

            return NotificationListener<ScrollNotification>(
              onNotification: _handleScroll,
              child: ListView(
                padding: EdgeInsets.fromLTRB(14, 12, 14, bottomPadding),
                children: [
                  if (errorForm != null || errorProvider != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        errorForm ?? errorProvider ?? "",
                        style: GoogleFonts.montserrat(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  Container(
                    alignment: AlignmentGeometry.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        context.go("/");
                      },
                      icon: const Icon(FontAwesomeIcons.arrowLeft),
                      label: Text(
                        "Retour",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),

                  Text(
                    "Ajouter des mots",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.025,
                      color: const Color.fromARGB(255, 0, 21, 143),
                    ),
                  ),
                  SizedBox(height: 25),

                  // 🔹 Entrées
                  ...List.generate(
                    _entries.length,
                    (index) => _buildEntryForm(
                      _entries[index],
                      index,
                      _controllers[index],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Bouton de reset
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _resetForm,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        "Réinitialiser le formulaire",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 🔹 Bouton flottant d’ajout
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
            (_entries.isNotEmpty &&
                _entries.last.canSubmit &&
                _entries.last.isSaved)
            ? AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 10
                      : 70,
                  right: 8,
                ),
                child: FloatingActionButton.extended(
                  onPressed: _addNewEntry,
                  icon: const Icon(Icons.add),
                  label: Text("Nouveau mot", style: GoogleFonts.montserrat()),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEntryForm(
    WordFormEntry entry,
    int index,
    ExpansibleController controller,
  ) {
    entry.sourceController.addListener(() => setState(() {}));
    entry.translationController.addListener(() => setState(() {}));

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: controller,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            "Mot ${index + 1}",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          ),
          subtitle: entry.isSaved
              ? Text(
                  "✅ Enregistré",
                  style: GoogleFonts.montserrat(color: Colors.green),
                )
              : Text(
                  "Non enregistré",
                  style: GoogleFonts.montserrat(color: Colors.grey.shade600),
                ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField(entry.sourceController, "Mot source"),
                const SizedBox(height: 12),
                _textField(entry.translationController, "Traduction"),
                const SizedBox(height: 12),
                _dropdownLang(entry, true),
                const Icon(Icons.swap_horiz, size: 20),
                _dropdownLang(entry, false),
                const SizedBox(height: 12),
                _dropdownType(entry),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: entry.canSubmit && !entry.isSaved
                      ? () => _saveEntry(entry, index)
                      : null,
                  icon: const Icon(Icons.save),
                  label: Text("Enregistrer", style: GoogleFonts.montserrat()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dropdownLang(WordFormEntry entry, bool isSource) {
    final current = isSource ? entry.sourceLang : entry.targetLang;

    return DropdownButton<Language>(
      value: current,
      isExpanded: true,
      dropdownColor: Colors.white,
      underline: Container(height: 1, color: Colors.grey.shade300),
      items: Language.values.map((lang) {
        final isDisabled = isSource
            ? lang == entry.targetLang
            : lang == entry.sourceLang;
        return DropdownMenuItem(
          value: isDisabled ? null : lang,
          enabled: !isDisabled,
          child: Row(
            children: [
              Icon(
                _flagForLanguage(lang),
                size: 18,
                color: isDisabled ? Colors.grey : Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                TranslationUtils.languageToFr(lang),
                style: GoogleFonts.montserrat(
                  color: isDisabled ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (lang) {
        if (lang == null) return;
        setState(() {
          if (isSource) {
            entry.sourceLang = lang;
          } else {
            entry.targetLang = lang;
          }
        });
      },
    );
  }

  IconData _flagForLanguage(Language lang) {
    switch (lang) {
      case Language.FR:
        return Icons.flag;
      case Language.EN:
        return Icons.language;
      case Language.AR:
        return Icons.translate;
    }
  }

  Widget _dropdownType(WordFormEntry entry) {
    return DropdownButton<WordType>(
      value: entry.wordType,
      isExpanded: true,
      dropdownColor: Colors.white,
      underline: Container(height: 1, color: Colors.grey.shade300),
      items: WordType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            TranslationUtils.wordTypeToFr(type),
            style: GoogleFonts.montserrat(color: Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (t) {
        if (t != null) setState(() => entry.wordType = t);
      },
    );
  }
}
