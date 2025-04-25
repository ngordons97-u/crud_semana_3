import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'main.dart'; // Asegúrate de tener la clase Computadora ahí

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'computadoras.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE computadoras (
        id TEXT PRIMARY KEY,
        tipo TEXT,
        marca TEXT,
        cpu TEXT,
        ram TEXT,
        hdd TEXT
      )
    ''');
  }

  Future<void> insertComputadora(Computadora comp) async {
    final dbClient = await db;
    await dbClient.insert('computadoras', {
      'id': comp.id,
      'tipo': comp.tipo,
      'marca': comp.marca,
      'cpu': comp.cpu,
      'ram': comp.ram,
      'hdd': comp.hdd,
    });
  }

  Future<List<Computadora>> getComputadoras() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'computadoras',
    );
    return List.generate(maps.length, (i) {
      return Computadora(
        id: maps[i]['id'],
        tipo: maps[i]['tipo'],
        marca: maps[i]['marca'],
        cpu: maps[i]['cpu'],
        ram: maps[i]['ram'],
        hdd: maps[i]['hdd'],
      );
    });
  }

  Future<void> updateComputadora(Computadora comp) async {
    final dbClient = await db;
    await dbClient.update(
      'computadoras',
      {
        'tipo': comp.tipo,
        'marca': comp.marca,
        'cpu': comp.cpu,
        'ram': comp.ram,
        'hdd': comp.hdd,
      },
      where: 'id = ?',
      whereArgs: [comp.id],
    );
  }

  Future<void> deleteComputadora(String id) async {
    final dbClient = await db;
    await dbClient.delete('computadoras', where: 'id = ?', whereArgs: [id]);
  }
}
