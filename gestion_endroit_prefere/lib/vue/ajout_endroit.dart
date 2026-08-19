import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/endroits_provider.dart';
import '../widgets/image_prise.dart';
import '../widgets/localisation_prise.dart';

// Formulaire complet d'ajout d'un endroit favori. Étend
// ConsumerStatefulWidget pour avoir à la fois un état local
// (contrôleur de texte, photo, localisation) ET un accès aux
// providers Riverpod (pour appeler ajouterEndroit()).
class AjoutEndroit extends ConsumerStatefulWidget {
  const AjoutEndroit({super.key});

  @override
  ConsumerState<AjoutEndroit> createState() => _AjoutEndroitState();
}

class _AjoutEndroitState extends ConsumerState<AjoutEndroit> {
  // Contrôle le champ de saisie du nom de l'endroit.
  final TextEditingController _nomController = TextEditingController();

  // Photo reçue depuis le widget ImagePrise.
  File? _imageSelectionnee;

  // Coordonnées et adresse reçues depuis le widget LocalisationPrise.
  double? _latitude;
  double? _longitude;
  String? _adresse;

  // Libère le contrôleur de texte pour éviter les fuites mémoire.
  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  // Callback passé à ImagePrise : met à jour la photo sélectionnée.
  void _surPhotoSelectionnee(File image) {
    setState(() {
      _imageSelectionnee = image;
    });
  }

  // Callback passé à LocalisationPrise : met à jour les coordonnées
  // et l'adresse une fois la position obtenue.
  void _surLocalisationSelectionnee(double lat, double lng, String adresse) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _adresse = adresse;
    });
  }

  // Valide que le nom et la photo sont renseignés, puis enregistre
  // l'endroit via le provider et ferme la page.
  Future<void> _enregistrerEndroit() async {
    final nom = _nomController.text.trim();

    if (nom.isEmpty || _imageSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner un nom et prendre une photo.'),
        ),
      );
      return;
    }

    await ref.read(endroitsProvider.notifier).ajouterEndroit(
          nom: nom,
          image: _imageSelectionnee!,
          latitude: _latitude,
          longitude: _longitude,
          adresse: _adresse,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajout d\'un nouvel endroit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ de saisie du nom de l'endroit.
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'endroit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Section photo.
            const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ImagePrise(onPhotoSelectionnee: _surPhotoSelectionnee),
            const SizedBox(height: 16),

            // Section localisation.
            const Text(
              'Localisation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LocalisationPrise(
              onLocalisationSelectionnee: _surLocalisationSelectionnee,
            ),
            const SizedBox(height: 24),

            // Bouton d'enregistrement.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enregistrerEndroit,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer l\'endroit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
