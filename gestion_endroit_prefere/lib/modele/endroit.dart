import 'dart:io';
import 'package:uuid/uuid.dart';

// Instance globale du générateur d'UUID, utilisée pour créer
// un identifiant unique à chaque nouvel endroit.
const uuid = Uuid();

class Endroit {
  // Identifiant unique généré automatiquement (UUID v4).
  final String id;

  // Nom de l'endroit saisi par l'utilisateur.
  final String nom;

  // Photo prise avec la caméra (fichier local sur l'appareil).
  final File image;

  // Coordonnées GPS optionnelles (nulles si l'utilisateur
  // n'a pas souhaité enregistrer sa localisation).
  final double? latitude;
  final double? longitude;

  // Adresse lisible dérivée des coordonnées GPS.
  final String? adresse;

  // Constructeur : l'id est généré automatiquement via uuid.v4()
  // grâce à la syntaxe d'initialisation Dart (après le ':').
  Endroit({
    String? id,
    required this.nom,
    required this.image,
    this.latitude,
    this.longitude,
    this.adresse,
  }) : id = id ?? uuid.v4();

  // Getter utilisé dans la page de détails pour savoir si l'on
  // doit afficher la carte Google Maps ou non.
  bool get aLocalisation => latitude != null && longitude != null;

  // --- Persistance SQLite ---

  // Convertit l'objet Endroit en Map pour l'insertion en base.
  // On ne stocke pas le fichier File lui-même : on enregistre
  // uniquement son chemin (String), car SQLite ne peut stocker
  // que des types simples (int, String, double, etc.).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'imagePath': image.path,
      'latitude': latitude,
      'longitude': longitude,
      'adresse': adresse,
    };
  }

  // Reconstruit un objet Endroit à partir d'une ligne de la base
  // de données (Map).
  factory Endroit.fromMap(Map<String, dynamic> map) {
    return Endroit(
      id: map['id'] as String,
      nom: map['nom'] as String,
      image: File(map['imagePath'] as String),
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      adresse: map['adresse'] as String?,
    );
  }
}
