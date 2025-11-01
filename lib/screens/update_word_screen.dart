import 'package:dico/models/word_model.dart';
import 'package:dico/providers/dictionary_provider.dart';
import 'package:dico/widgets/update_word_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UpdateWordScreen extends StatefulWidget {
  final String id;
  final ValueNotifier<bool> showBars;

  const UpdateWordScreen({super.key, required this.id, required this.showBars});

  @override
  State<UpdateWordScreen> createState() => _UpdateWordScreenState();
}

class _UpdateWordScreenState extends State<UpdateWordScreen>
    with WidgetsBindingObserver {
  WordModel? _word;
  bool _isLoading = true;
  String? _error;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWord();

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

  Future<void> _loadWord() async {
    try {
      final provider = context.read<DictionaryProvider>();
      final int parsedId = int.tryParse(widget.id) ?? -1;

      if (parsedId == -1) {
        setState(() => _error = "ID invalide.");
        return;
      }

      final word = await provider.getById(parsedId);

      if (!mounted) return;

      if (word == null) {
        setState(() => _error = "Aucun mot trouvé avec l'ID $parsedId.");
      } else {
        setState(() {
          _word = word;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = "Erreur : ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: widget.showBars,
        builder: (context, _) {
          final bottomPadding = widget.showBars.value ? 80.0 : 20.0;

          return NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: ListView(
              padding: EdgeInsets.fromLTRB(14, 12, 14, bottomPadding),
              children: [
                Material(
                  color: Colors.white,
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (_error != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (_word == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "Mot introuvable.",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
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
                            UpdateWordForm(word: _word!),
                          ],
                        );
                      }
                    },
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
