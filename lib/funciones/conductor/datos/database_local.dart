import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ============================================
/// 💾 SERVICIO DE BASE DE DATOS LOCAL (SQLite)
/// ============================================
/// Almacena posiciones GPS cuando no hay internet
/// y las sincroniza cuando vuelve la conexión.
///
class DatabaseLocal {

  static Database? _database;
  static final DatabaseLocal instance = DatabaseLocal._init();

  DatabaseLocal._init();

  /// Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trackmape_local.db');
    return _database!;
  }

  /// Inicializar la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Crear las tablas
  Future<void> _createDB(Database db, int version) async {

    // Tabla para posiciones pendientes de sincronizar
    await db.execute('''
      CREATE TABLE posiciones_pendientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fk_emisor TEXT NOT NULL,
        lat_grados REAL NOT NULL,
        lon_grados REAL NOT NULL,
        alt_msnm REAL,
        tiempo TEXT NOT NULL,
        epoca_rx INTEGER NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        intentos INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Índice para búsquedas rápidas
    await db.execute('''
      CREATE INDEX idx_sincronizado ON posiciones_pendientes(sincronizado)
    ''');

    print("✅ SQLite: Base de datos creada");
  }

  // ============================================
  // 📝 GUARDAR POSICIÓN LOCALMENTE
  // ============================================
  Future<int> guardarPosicionLocal({
    required String fkEmisor,
    required double lat,
    required double lon,
    double? altitud,
  }) async {
    final db = await database;
    final ahora = DateTime.now();

    final id = await db.insert('posiciones_pendientes', {
      'fk_emisor': fkEmisor,
      'lat_grados': lat,
      'lon_grados': lon,
      'alt_msnm': altitud,
      'tiempo': ahora.toIso8601String(),
      'epoca_rx': ahora.millisecondsSinceEpoch,
      'sincronizado': 0,
      'intentos': 0,
    });

    print("💾 SQLite: Posición guardada localmente (ID: $id)");
    return id;
  }

  // ============================================
  // 📤 OBTENER POSICIONES PENDIENTES
  // ============================================
  Future<List<Map<String, dynamic>>> obtenerPendientes({int limite = 50}) async {
    final db = await database;

    return await db.query(
      'posiciones_pendientes',
      where: 'sincronizado = 0 AND intentos < 5',
      orderBy: 'tiempo ASC',
      limit: limite,
    );
  }

  // ============================================
  // ✅ MARCAR COMO SINCRONIZADO
  // ============================================
  Future<void> marcarSincronizado(int id) async {
    final db = await database;

    await db.update(
      'posiciones_pendientes',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );

    print("✅ SQLite: Posición $id sincronizada");
  }

  // ============================================
  // ❌ INCREMENTAR INTENTOS FALLIDOS
  // ============================================
  Future<void> incrementarIntentos(int id) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE posiciones_pendientes 
      SET intentos = intentos + 1 
      WHERE id = ?
    ''', [id]);
  }

  // ============================================
  // 🔢 CONTAR PENDIENTES
  // ============================================
  Future<int> contarPendientes() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as total 
      FROM posiciones_pendientes 
      WHERE sincronizado = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================
  // 🧹 LIMPIAR REGISTROS SINCRONIZADOS
  // ============================================
  /// Elimina registros que ya fueron sincronizados
  /// para no ocupar espacio innecesariamente
  Future<int> limpiarSincronizados() async {
    final db = await database;

    final eliminados = await db.delete(
      'posiciones_pendientes',
      where: 'sincronizado = 1',
    );

    if (eliminados > 0) {
      print("🧹 SQLite: $eliminados registros limpiados");
    }

    return eliminados;
  }

  // ============================================
  // 🗑️ LIMPIAR REGISTROS CON MUCHOS INTENTOS
  // ============================================
  /// Elimina registros que fallaron más de 5 veces
  Future<int> limpiarFallidos() async {
    final db = await database;

    final eliminados = await db.delete(
      'posiciones_pendientes',
      where: 'intentos >= 5',
    );

    if (eliminados > 0) {
      print("🗑️ SQLite: $eliminados registros fallidos eliminados");
    }

    return eliminados;
  }

  // ============================================
  // 📊 ESTADÍSTICAS
  // ============================================
  Future<Map<String, int>> obtenerEstadisticas() async {
    final db = await database;

    final pendientes = await db.rawQuery('''
      SELECT COUNT(*) as total FROM posiciones_pendientes WHERE sincronizado = 0
    ''');

    final sincronizados = await db.rawQuery('''
      SELECT COUNT(*) as total FROM posiciones_pendientes WHERE sincronizado = 1
    ''');

    final fallidos = await db.rawQuery('''
      SELECT COUNT(*) as total FROM posiciones_pendientes WHERE intentos >= 5
    ''');

    return {
      'pendientes': Sqflite.firstIntValue(pendientes) ?? 0,
      'sincronizados': Sqflite.firstIntValue(sincronizados) ?? 0,
      'fallidos': Sqflite.firstIntValue(fallidos) ?? 0,
    };
  }

  // ============================================
  // 🔒 CERRAR BASE DE DATOS
  // ============================================
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}