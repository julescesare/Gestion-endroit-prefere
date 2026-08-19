import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../modele/endroit.dart';

// Service qui centralise toutes les opérations liées à la base
// de données SQLite : ouverture, création de la table, et
// opérations CRUD (insert, delete, getAll).
//
// Implémenté en singleton : une seule instance de la base est
// ouverte pendant toute la durée de vie de l'application.
class DatabaseService {
  // Instance unique (pattern singleton).
  static final DatabaseService _instance = DatabaseService._interne();
  factory DatabaseService() => _instance;
  DatabaseService._interne();

  // Référence vers la base de données. Nullable car elle n'est
  // ouverte qu'à la première utilisation (lazy initialization).
  static Database? _database;

  // Getter asynchrone : retourne la base déjà ouverte, ou l'initialise
  // si ce n'est pas encore fait.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialiserBase();
    return _database!;
  }

  // Ouvre (ou crée) le fichier de base de données sur l'appareil.
  Future<Database> _initialiserBase() async {
    // Récupère le dossier standard des bases de données de l'appareil.
    final cheminBase = await getDatabasesPath();
    final chemin = join(cheminBase, 'endroits_favoris.db');

    return openDatabase(
      chemin,
      version: 1,
      onCreate: (db, version) async {
        // Création de la table endroits, avec des colonnes
        // correspondant exactement à Endroit.toMap().
        await db.execute('''
          CREATE TABLE endroits(
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            adresse TEXT
          )
        ''');
      },
    );
  }

  // Insère un nouvel endroit dans la base.
  Future<void> insererEndroit(Endroit endroit) async {
    final db = await database;
    await db.insert(
      'endroits',
      endroit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupère tous les endroits enregistrés, triés du plus récent
  // au plus ancien (on se base sur l'ordre d'insertion via rowid).
  Future<List<Endroit>> recupererEndroits() async {
    final db = await database;
    final maps = await db.query('endroits', orderBy: 'rowid DESC');

    return maps.map((map) => Endroit.fromMap(map)).toList();
  }

  // Supprime un endroit de la base à partir de son id.
  Future<void> supprimerEndroit(String id) async {
    final db = await database;
    await db.delete(
      'endroits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
