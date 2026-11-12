
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final lokasi = join(
      await getDatabasesPath(),
      'aiot_peringatan_dini.db',
    );

    return openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_sensor TEXT NOT NULL,
            nilai REAL NOT NULL,
            lokasi_pos TEXT NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE: Menambahkan pembacaan sensor
  Future<int> tambahPembacaan(
      PembacaanSensor data) async {
    final db = await database;
    return db.insert(
      'pembacaan_sensor',
      data.toMap(),
    );
  }

  // READ: Mengambil seluruh riwayat sensor
  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;

    final hasil = await db.query(
      'pembacaan_sensor',
      orderBy: 'id DESC',
    );

    return hasil
        .map((baris) => PembacaanSensor.fromMap(baris))
        .toList();
  }

  // UPDATE: Mengubah pembacaan sensor
  Future<int> ubahPembacaan(
      PembacaanSensor data) async {
    final db = await database;

    return db.update(
      'pembacaan_sensor',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // DELETE: Menghapus pembacaan sensor
  Future<int> hapusPembacaan(int id) async {
    final db = await database;

    return db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
