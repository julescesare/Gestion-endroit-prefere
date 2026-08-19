import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Widget qui permet à l'utilisateur de prendre une photo avec
// l'appareil photo. StatefulWidget car il gère localement la
// photo capturée avant de la transmettre au parent.
class ImagePrise extends StatefulWidget {
  // Callback appelé dès qu'une photo est prise, pour transmettre
  // le fichier image au widget parent (AjoutEndroit).
  final void Function(File image) onPhotoSelectionnee;

  const ImagePrise({super.key, required this.onPhotoSelectionnee});

  @override
  State<ImagePrise> createState() => _ImagePriseState();
}

class _ImagePriseState extends State<ImagePrise> {
  // Stocke la photo capturée. Nulle tant qu'aucune photo n'a été prise.
  File? _photoSelectionnee;

  // Instance du sélecteur d'image (caméra / galerie).
  final ImagePicker _picker = ImagePicker();

  // Ouvre la caméra de l'appareil, récupère la photo prise,
  // la convertit en File, met à jour l'état local et prévient
  // le widget parent via le callback.
  Future<void> _prendrePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final image = File(photo.path);
      setState(() {
        _photoSelectionnee = image;
      });
      widget.onPhotoSelectionnee(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aucune photo prise : affiche un bouton pour ouvrir la caméra.
    if (_photoSelectionnee == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _prendrePhoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Prendre une photo'),
        ),
      );
    }

    // Une photo est disponible : affiche son aperçu. Un appui
    // permet de reprendre une nouvelle photo.
    return GestureDetector(
      onTap: _prendrePhoto,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _photoSelectionnee!,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
