import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/endroits_provider.dart';
import '../widgets/endroits_list.dart';
import 'ajout_endroit.dart';

// Écran principal de l'application, affichant la liste des endroits
// favoris. Étend ConsumerWidget (et non ConsumerStatefulWidget) car
// cette page n'a aucun état local propre : toute la donnée qu'elle
// affiche provient du provider Riverpod.
class EndroitsInterface extends ConsumerWidget {
  const EndroitsInterface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute le provider : à chaque ajout ou suppression d'endroit,
    // ce widget est automatiquement reconstruit avec la liste à jour.
    final endroits = ref.watch(endroitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes endroits préférés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AjoutEndroit(),
                ),
              );
            },
          ),
        ],
      ),
      body: EndroitsList(endroits: endroits),
    );
  }
}
