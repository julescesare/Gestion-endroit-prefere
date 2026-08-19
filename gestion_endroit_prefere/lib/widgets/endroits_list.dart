import 'package:flutter/material.dart';
import '../modele/endroit.dart';
import '../vue/endroit_detail.dart';

// Widget qui affiche la liste des endroits favoris. StatelessWidget
// car il n'a pas d'état propre : il se contente d'afficher la liste
// reçue en paramètre depuis le provider Riverpod (via EndroitsInterface).
class EndroitsList extends StatelessWidget {
  // La liste des endroits à afficher, fournie par le provider.
  final List<Endroit> endroits;

  const EndroitsList({super.key, required this.endroits});

  @override
  Widget build(BuildContext context) {
    // Liste vide : affiche un message invitant à ajouter un endroit.
    if (endroits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun endroit favori pour le moment.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Appuyez sur + pour en ajouter un.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Liste non vide : construction dynamique avec ListView.builder,
    // plus performant qu'une liste statique car les éléments ne sont
    // construits qu'au moment où ils deviennent visibles à l'écran.
    return ListView.builder(
      itemCount: endroits.length,
      itemBuilder: (context, index) {
        final endroit = endroits[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: FileImage(endroit.image),
          ),
          title: Text(endroit.nom),
          subtitle: endroit.adresse != null ? Text(endroit.adresse!) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EndroitDetail(endroit: endroit),
              ),
            );
          },
        );
      },
    );
  }
}
