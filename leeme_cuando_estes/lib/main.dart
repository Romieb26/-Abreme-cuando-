import 'package:flutter/material.dart';
import 'screens/boot_screen.dart';

void main() {
  runApp(const LeemeCuandoEstesApp());
}

/// Paleta HUD sci-fi: fondo oscuro + acentos cian/dorado.
class HudColors {
  static const bg = Color(0xFF0A0E14);
  static const panel = Color(0xFF10151F);
  static const cyan = Color(0xFF4FE3FF);
  static const gold = Color(0xFFFFC857);
  static const steel = Color(0xFF2C3440);
  static const textLight = Color(0xFFDCEEF5);
  static const textMuted = Color(0xFF7C8896);
}

class LeemeCuandoEstesApp extends StatelessWidget {
  const LeemeCuandoEstesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Léeme cuando estés...',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: HudColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: HudColors.cyan,
          brightness: Brightness.dark,
          background: HudColors.bg,
          primary: HudColors.cyan,
          secondary: HudColors.gold,
        ),
      ),
      home: const BootScreen(),
    );
  }
}
