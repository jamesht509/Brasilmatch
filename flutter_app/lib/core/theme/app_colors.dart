import 'package:flutter/material.dart';

/// Paleta de cores "Sunset Romance"
/// Vibe: Romântico mas moderno, quente sem ser agressivo
class AppColors {
  // Cores principais
  static const Color primary = Color(0xFFFF6B6B);      // Coral vibrante
  static const Color secondary = Color(0xFFFF8E53);    // Laranja pôr-do-sol
  static const Color accent = Color(0xFFFFB84D);       // Dourado quente
  
  // Background & Surfaces
  static const Color background = Color(0xFFFFF8F3);   // Creme suave
  static const Color surface = Color(0xFFFFFFFF);      // Branco puro
  static const Color surfaceVariant = Color(0xFFFFF0E6); // Pêssego claro
  
  // Text
  static const Color textPrimary = Color(0xFF2D1B1B);  // Marrom escuro
  static const Color textSecondary = Color(0xFF6B5B5B); // Marrom médio
  static const Color textHint = Color(0xFF9E8E8E);     // Marrom claro
  
  // Actions
  static const Color like = primary;                    // Verde/Like usa primary
  static const Color nope = Color(0xFFCCCCCC);         // Cinza neutro
  static const Color superLike = accent;                // Dourado
  
  // Status
  static const Color success = Color(0xFF4CAF50);      // Verde
  static const Color error = Color(0xFFE74C3C);        // Vermelho
  static const Color warning = Color(0xFFFFA726);      // Laranja
  static const Color info = Color(0xFF42A5F5);         // Azul
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent],
  );
  
  static const LinearGradient matchGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary, accent],
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
}
