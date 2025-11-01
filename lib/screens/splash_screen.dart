import 'package:dico/providers/dictionary_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Animation douce (rotation + fondu)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Démarrage du chargement après affichage initial
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final dictProvider = context.read<DictionaryProvider>();
      await dictProvider.loadWords();

      if (!mounted) return;

      if (dictProvider.error != null) {
        context.go("/error-request", extra: dictProvider.error);
      } else {
        context.go("/");
      }
    } catch (e, st) {
      debugPrint("Unexpected error: $e\n$st");
      if (!mounted) return;
      context.go('/error-request', extra: "Unexpected error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟢 Logo ou icône du dico
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Chargement des données...",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
