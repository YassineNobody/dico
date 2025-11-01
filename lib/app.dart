import 'package:dico/screens/account_user_screen.dart';
import 'package:dico/screens/add_words_screen.dart';
import 'package:dico/screens/error_request_screen.dart';
import 'package:dico/screens/home_screen.dart';
import 'package:dico/screens/splash_screen.dart';
import 'package:dico/screens/update_word_screen.dart';
import 'package:dico/widgets/my_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

CustomTransitionPage<T> slidePage<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class DictApp extends StatefulWidget {
  const DictApp({super.key});

  @override
  State<DictApp> createState() => _DictAppState();
}

class _DictAppState extends State<DictApp> {
  final ValueNotifier<bool> showBars = ValueNotifier(true);

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => slidePage(const SplashScreen()),
      ),
      GoRoute(
        path: '/error-request',
        pageBuilder: (context, state) {
          final msg = state.extra as String? ?? "Erreur inconnue";
          return slidePage(
            ErrorRequestPage(
              message: msg,
              onRetry: () => context.go('/splash'),
            ),
          );
        },
      ),

      // 🧭 Navigation principale AVEC UpdateWord dedans
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ValueListenableBuilder<bool>(
            valueListenable: showBars,
            builder: (context, visible, _) {
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 138, 170, 189),
                extendBody: true,
                body: Column(
                  children: [
                    // 🔹 AppBar animée
                    SafeArea(
                      top: true,
                      bottom: false,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: visible ? 60 : 0,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: visible
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: AnimatedOpacity(
                          opacity: visible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Dictionnaire",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 23, 76, 119),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 🔹 Corps principal
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: navigationShell,
                      ),
                    ),
                  ],
                ),

                // 🔹 Bottom nav
                bottomNavigationBar: AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0, 1.4),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: MyBottomNavigation(
                      currentIndex: navigationShell.currentIndex,
                      onDestinationSelected: navigationShell.goBranch,
                    ),
                  ),
                ),
              );
            },
          );
        },
        branches: [
          // 🏠 Branche principale
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    slidePage(HomeScreen(showBars: showBars)),
                routes: [
                  // 👇 Route enfant de Home : conserve AppBar + BottomNav
                  GoRoute(
                    path: 'update-word/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return slidePage(
                        UpdateWordScreen(id: id, showBars: showBars),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // ➕ Branche ajout
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add-word',
                pageBuilder: (context, state) =>
                    slidePage(AddWordsScreen(showBars: showBars)),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                pageBuilder: (context, state) =>
                    slidePage(AccountUserScreen(showBars: showBars)),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Dico App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF193CB8)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: _router,
    );
  }
}
