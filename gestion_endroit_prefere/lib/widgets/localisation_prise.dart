import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Widget qui obtient la position GPS de l'utilisateur, la convertit
// en adresse lisible, et affiche une mini-carte Google Maps.
// StatefulWidget car il gère localement l'état de chargement et
// les coordonnées avant de les transmettre au parent.
class LocalisationPrise extends StatefulWidget {
  // Callback appelé dès que la position est obtenue, pour transmettre
  // latitude, longitude et adresse au widget parent (AjoutEndroit).
  final void Function(double lat, double lng, String adresse)
      onLocalisationSelectionnee;

  const LocalisationPrise({
    super.key,
    required this.onLocalisationSelectionnee,
  });

  @override
  State<LocalisationPrise> createState() => _LocalisationPriseState();
}

class _LocalisationPriseState extends State<LocalisationPrise> {
  // Coordonnées GPS, nulles tant que la position n'est pas obtenue.
  double? _latitude;
  double? _longitude;

  // Adresse lisible dérivée des coordonnées.
  String? _adresse;

  // Indique si la récupération GPS est en cours (affichage du loader).
  bool _chargement = false;

  // Vérifie les permissions, récupère la position GPS, la convertit
  // en adresse, puis met à jour l'état et prévient le widget parent.
  Future<void> _obtenirLocalisation() async {
    setState(() {
      _chargement = true;
    });

    try {
      // Vérifie que le service de localisation est activé sur l'appareil.
      final serviceActif = await Geolocator.isLocationServiceEnabled();
      if (!serviceActif) {
        throw Exception('Le service de localisation est désactivé.');
      }

      // Vérifie l'état actuel de la permission de localisation.
      LocationPermission permission = await Geolocator.checkPermission();

      // Si la permission n'a jamais été demandée ou a été refusée,
      // on la demande explicitement à l'utilisateur.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée.');
        }
      }

      // Refus permanent : on ne peut plus rien demander, il faut
      // que l'utilisateur active la permission depuis les paramètres.
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permission de localisation refusée définitivement.',
        );
      }

      // Récupère la position GPS actuelle de l'appareil.
      final position = await Geolocator.getCurrentPosition();

      // Convertit les coordonnées en adresse lisible (ex: "Paris, France").
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String adresseTexte = 'Adresse inconnue';
      if (placemarks.isNotEmpty) {
        final lieu = placemarks.first;
        adresseTexte = [lieu.locality, lieu.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _adresse = adresseTexte;
        _chargement = false;
      });

      widget.onLocalisationSelectionnee(
        position.latitude,
        position.longitude,
        adresseTexte,
      );
    } catch (e) {
      // En cas d'erreur (permission refusée, service désactivé, etc.),
      // on arrête le chargement et on informe l'utilisateur.
      setState(() {
        _chargement = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de localisation : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chargement en cours : affiche un indicateur.
    if (_chargement) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Position disponible : affiche la mini-carte avec marqueur et adresse.
    if (_latitude != null && _longitude != null) {
      final position = LatLng(_latitude!, _longitude!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 150,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                      markerId: const MarkerId('endroit'), position: position),
                },
                zoomControlsEnabled: false,
                liteModeEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_adresse != null) Text(_adresse!),
        ],
      );
    }

    // Aucune position obtenue : affiche le bouton de déclenchement.
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _obtenirLocalisation,
        icon: const Icon(Icons.location_on),
        label: const Text('Obtenir ma localisation'),
      ),
    );
  }
}
