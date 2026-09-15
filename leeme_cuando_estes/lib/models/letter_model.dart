import 'package:flutter/material.dart';

/// Tipos de efecto especial que se disparan al abrir una carta.
enum LetterEffect { sparkle, rain, shake, hearts }

/// Representa una carta asociada a una emoción.
class Letter {
  final String emotion;   // Ej: "Feliz"
  final String title;     // Ej: "Ábrela cuando estés feliz"
  final String body;      // Texto completo de la carta
  final Color color;      // Color del botón / encabezado
  final IconData icon;    // Icono representativo
  final LetterEffect effect; // Efecto especial al abrir la carta

  const Letter({
    required this.emotion,
    required this.title,
    required this.body,
    required this.color,
    required this.icon,
    this.effect = LetterEffect.sparkle,
  });
}
