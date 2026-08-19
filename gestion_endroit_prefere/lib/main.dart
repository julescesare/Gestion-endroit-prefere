import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vue/endroits_interface.dart';

// Point d'entrée de l'application.
void main() {
  // ProviderScope est obligatoire pour que Riverpod v2 fonctionne :
  // il initialise le système de providers et le rend accessible
  // à tous les widgets descendants de l'application.
  runApp(
    const ProviderScope(
      child: MonApplication(),
    ),
  );
}

// Widget racine de l'application. StatelessWidget car il ne fait
// que configurer le MaterialApp, sans état propre.
class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion d\'endroits favoris',
      debugShowCheckedModeBanner: false,

      // Active les composants visuels Material 3 (formes, couleurs,
      // typographie mises à jour par rapport à Material 2).
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),

      // Page d'accueil de l'application.
      home: const EndroitsInterface(),
    );
  }
}
