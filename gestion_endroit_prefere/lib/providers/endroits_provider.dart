import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modele/endroit.dart';
import '../services/database_service.dart';

// Gère l'état de la liste des endroits favoris, avec synchronisation
// automatique vers la base de données SQLite à chaque modification.
class EndroitsNotifier extends Notifier<List<Endroit>> {
  // Instance du service de base de données.
  final DatabaseService _dbService = DatabaseService();

  // Méthode imposée par Riverpod v2, appelée une seule fois à la
  // création du provider. Elle doit retourner l'état initial de
  // façon synchrone : on part donc d'une liste vide, puis on
  // déclenche le chargement asynchrone depuis SQLite juste après.
  @override
  List<Endroit> build() {
    _chargerEndroits();
    return [];
  }

  // Charge les endroits déjà enregistrés en base au démarrage de
  // l'application, et met à jour le state une fois les données
  // récupérées (l'interface se reconstruit alors automatiquement
  // grâce à ref.watch dans EndroitsInterface).
  Future<void> _chargerEndroits() async {
    final endroits = await _dbService.recupererEndroits();
    state = endroits;
  }

  // Ajoute un nouvel endroit : l'insère en base, puis met à jour
  // le state en le plaçant en tête de la liste.
  Future<void> ajouterEndroit({
    required String nom,
    required image,
    double? latitude,
    double? longitude,
    String? adresse,
  }) async {
    final endroit = Endroit(
      nom: nom,
      image: image,
      latitude: latitude,
      longitude: longitude,
      adresse: adresse,
    );

    await _dbService.insererEndroit(endroit);
    state = [endroit, ...state];
  }

  // Supprime un endroit : le retire de la base, puis met à jour
  // le state en filtrant la liste.
  Future<void> supprimerEndroit(String id) async {
    await _dbService.supprimerEndroit(id);
    state = state.where((endroit) => endroit.id != id).toList();
  }
}

// Provider global exposé à toute l'application.
final endroitsProvider = NotifierProvider<EndroitsNotifier, List<Endroit>>(
  EndroitsNotifier.new,
);
