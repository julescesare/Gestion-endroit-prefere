import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../modele/endroit.dart';

// Page affichant les informations complètes d'un endroit : sa photo,
// son nom, son adresse et sa localisation sur une carte Google Maps.
// StatelessWidget car elle ne fait qu'afficher les données de l'objet
// endroit reçu en paramètre, sans état propre à gérer.
class EndroitDetail extends StatelessWidget {
  // L'objet endroit dont on affiche les détails.
  final Endroit endroit;

  const EndroitDetail({super.key, required this.endroit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(endroit.nom)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo de l'endroit, pleine largeur, hauteur fixe.
          Image.file(
            endroit.image,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l'endroit.
                Text(
                  endroit.nom,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Adresse, affichée uniquement si elle n'est pas nulle.
                if (endroit.adresse != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    endroit.adresse!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),

          // Carte Google Maps affichée uniquement si l'endroit possède
          // une localisation (aLocalisation == true). Expanded pour
          // occuper tout l'espace restant de l'écran.
          if (endroit.aLocalisation)
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(endroit.latitude!, endroit.longitude!),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(endroit.id),
                    position: LatLng(endroit.latitude!, endroit.longitude!),
                  ),
                },
              ),
            ),
        ],
      ),
    );
  }
}
