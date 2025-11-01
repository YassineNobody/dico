import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onDestinationSelected;

  const MyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: const Color.from(
          alpha: 1,
          red: 248,
          green: 250,
          blue: 247.858,
        ),
        indicatorColor: const Color(0xFF193CB8).withValues(alpha: 0.1),
        height: 60,
        elevation: 6,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          // 🏠 Accueil
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.house, size: 18),
            selectedIcon: Icon(
              FontAwesomeIcons.house,
              color: Color(0xFF193CB8),
              size: 18,
            ),
            label: "",
          ),

          // ➕ Ajout de mot
          NavigationDestination(
            icon: Icon(LucideIcons.plusSquare, size: 20),
            selectedIcon: Icon(
              LucideIcons.plusSquare,
              color: Color(0xFF193CB8),
              size: 20,
            ),
            label: "",
          ),

          // 👤 Compte utilisateur
          NavigationDestination(
            icon: Icon(LucideIcons.user, size: 20),
            selectedIcon: Icon(
              LucideIcons.user,
              color: Color(0xFF193CB8),
              size: 20,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
