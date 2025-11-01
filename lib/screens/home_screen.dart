import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/utils/translation_utils.dart';
import 'package:dico/widgets/filter_type_word_selector.dart';
import 'package:dico/widgets/item_list_word.dart';
import 'package:dico/widgets/language_selector.dart';
import 'package:dico/widgets/search_word_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool> showBars;
  const HomeScreen({super.key, required this.showBars});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
      widget.showBars.value = true; // réaffiche les barres après rotation
    }
  }

  bool _handleScroll(ScrollNotification notif) {
    if (notif is UserScrollNotification) {
      if (notif.direction == ScrollDirection.reverse && widget.showBars.value) {
        // 🔻 Scroll vers le bas → cacher les barres
        widget.showBars.value = false;
      } else if (notif.direction == ScrollDirection.forward &&
          !widget.showBars.value) {
        // 🔺 Scroll vers le haut → réafficher les barres
        widget.showBars.value = true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final words = provider.words;
    final source = provider.activeSource;
    final target = provider.activeTarget;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    const double landscapeMaxWidth = 500;
    return Scaffold(
      body: AnimatedBuilder(
        animation: widget.showBars,
        builder: (context, _) {
          // 🔹 Si la barre du bas est cachée, on laisse 0 padding
          // 🔹 Si elle est visible, on laisse une marge douce pour pas que le contenu soit collé
          final bottomPadding = widget.showBars.value ? 80.0 : 20.0;

          return NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: ListView(
              padding: EdgeInsets.fromLTRB(14, 12, 14, bottomPadding),
              children: [
                // 🔹 Sélecteur de langues
                Center(
                  child: Container(
                    width: isLandscape ? landscapeMaxWidth : double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const LanguageSelectorWidget(),
                  ),
                ),
                const SizedBox(height: 14),

                // 🔹 Filtre et tri
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape
                          ? landscapeMaxWidth
                          : double.infinity,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Trier",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.015,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              LucideIcons.arrowDownNarrowWide,
                              size: 16,
                            ),
                          ],
                        ),
                        const FilterTypeWordSelector(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 🔍 Recherche
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape
                          ? landscapeMaxWidth
                          : double.infinity,
                    ),
                    child: const SearchWordInput(),
                  ),
                ),
                const SizedBox(height: 16),

                // 🧾 Liste
                if (words.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.book,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Aucun mot trouvé pour :",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          "${TranslationUtils.languageToFr(source)} → ${TranslationUtils.languageToFr(target)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(
                    words.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ItemListWord(
                        word: words[index],
                        isLandscape: isLandscape,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
