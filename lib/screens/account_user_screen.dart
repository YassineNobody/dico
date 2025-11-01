import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/widgets/clear_dictionnaire_widget.dart';
import 'package:dico/widgets/export_dictionnaire_widget.dart';
import 'package:dico/widgets/import_dictionnaire_widget.dart';
import 'package:dico/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccountUserScreen extends StatefulWidget {
  final ValueNotifier<bool> showBars;
  const AccountUserScreen({super.key, required this.showBars});

  @override
  State<AccountUserScreen> createState() => _AccountUserScreenState();
}

class _AccountUserScreenState extends State<AccountUserScreen>
    with WidgetsBindingObserver {
  int? wordCount;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DictionaryProvider>();
      _loadStats();
      provider.addListener(_onProviderChanged);
      widget.showBars.value = true; // ✅ on force les barres visibles au début
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
      widget.showBars.value = true; // ✅ réaffiche les barres après rotation
    }
  }

  void _onProviderChanged() => _loadStats();

  @override
  void dispose() {
    context.read<DictionaryProvider>().removeListener(_onProviderChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final provider = context.read<DictionaryProvider>();
    final count = await provider.getCountForActiveLanguages();
    if (mounted) setState(() => wordCount = count);
  }

  bool _handleScroll(ScrollNotification notif) {
    if (notif is UserScrollNotification) {
      if (notif.direction == ScrollDirection.reverse && widget.showBars.value) {
        widget.showBars.value = false; // 🔻 cache barres
      } else if (notif.direction == ScrollDirection.forward &&
          !widget.showBars.value) {
        widget.showBars.value = true; // 🔺 affiche barres
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final src = provider.activeSource;
    final tgt = provider.activeTarget;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: widget.showBars,
        builder: (context, _) {
          final bottomPadding = widget.showBars.value ? 80.0 : 20.0;

          return NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
              children: [
                _buildLangCard(src.name, tgt.name, provider),
                const SizedBox(height: 20),
                _buildStatsCard(),
                const SizedBox(height: 25),
                ImportDictionnaireWidget(),
                const SizedBox(height: 10),
                ExportDictionnaireWidget(),
                const SizedBox(height: 10),
                ClearDictionnaireWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangCard(
    String sourceName,
    String targetName,
    DictionaryProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Langues actives",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$sourceName → $targetName",
            style: GoogleFonts.poppins(fontSize: 17),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showLanguageDialog(provider),
            icon: const Icon(LucideIcons.globe, size: 18),
            label: const Text("Changer les langues"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF193CB8),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Statistiques",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (wordCount == null)
            const CircularProgressIndicator()
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                "$wordCount mots enregistrés",
                key: ValueKey(wordCount),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF193CB8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(DictionaryProvider provider) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Changer les langues",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const LanguageSelectorWidget(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadStats();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193CB8),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Valider"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
