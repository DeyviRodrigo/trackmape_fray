import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/modelo_equipo.dart';

/// ============================================
/// REPOSITORIO MONITOREO - NUEVA ESTRUCTURA
/// ============================================
/// Adaptado para:
/// - posiciones_2 (nueva tabla)
/// - Campo 'activo' en lugar de 'habilitado'
/// - Campo 'nombre' en lugar de 'nombre_equipo_control'
///
class RepositorioMonitoreo {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // ⚠️ LÍMITE MÁXIMO DE REGISTROS POR CONSULTA
  // ============================================================
  static const int _limiteMaximoRegistros = 60000;

  // ============================================================
  // --- SECCIÓN 1: GESTIÓN DE OPERADORES / EQUIPOS ---
  // ============================================================

  /// Stream para la lista de operadores (Pestaña Operadores)
  /// Solo muestra equipos tipo TRACKER y escucha cambios en tiempo real
  Stream<List<ModeloEquipo>> streamEquipos() {
    return _supabase
        .from('equipos_control')
        .stream(primaryKey: ['id_equipo_control'])
        .eq('tipo_equipo_control', 'TRACKER')
        .map((lista) => lista.map((e) => ModeloEquipo.fromJson(e)).toList());
  }

  /// Obtiene la lista estática de equipos con toda su información
  Future<List<Map<String, dynamic>>> obtenerEquiposRaw() async {
    try {
      final res = await _supabase
          .from('equipos_control')
          .select()
          .eq('tipo_equipo_control', 'TRACKER');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error en obtenerEquiposRaw: $e");
      return [];
    }
  }

  /// Actualiza el estado (activo, nombre, etc.) de un equipo
  Future<bool> actualizarEquipo(String id, Map<String, dynamic> datos) async {
    try {
      await _supabase
          .from('equipos_control')
          .update(datos)
          .eq('id_equipo_control', id);
      return true;
    } catch (e) {
      print("Error al actualizar equipo: $e");
      return false;
    }
  }

  // ============================================================
  // --- SECCIÓN 2: MONITOREO EN TIEMPO REAL (STREAM) ---
  // ============================================================

  /// STREAM PRINCIPAL: Escucha todas las posiciones nuevas
  /// CAMBIADO: posiciones → posiciones_2
  Stream<List<Map<String, dynamic>>> obtenerTrayectoriaStream() {
    return _supabase
        .from('posiciones_2')
        .stream(primaryKey: ['id_posicion'])
        .order('tiempo', ascending: true);
  }

  /// Obtiene la última posición conocida de CADA equipo
  /// CAMBIADO: posiciones → posiciones_2
  Future<List<Map<String, dynamic>>> obtenerUltimasPosiciones() async {
    try {
      final respuesta = await _supabase
          .from('posiciones_2')
          .select()
          .order('tiempo', ascending: false)
          .limit(_limiteMaximoRegistros);

      final listaUnica = <String, Map<String, dynamic>>{};
      for (var item in (respuesta as List)) {
        String idEmisor = item['fk_emisor'].toString();
        if (!listaUnica.containsKey(idEmisor)) {
          listaUnica[idEmisor] = Map<String, dynamic>.from(item);
        }
      }
      return listaUnica.values.toList();
    } catch (e) {
      print("Error en obtenerUltimasPosiciones: $e");
      return [];
    }
  }

  /// Stream para detectar la conexión en tiempo real (Semáforo de colores)
  /// CAMBIADO: posiciones → posiciones_2
  Stream<List<Map<String, dynamic>>> streamUltimasConexiones() {
    return _supabase
        .from('posiciones_2')
        .stream(primaryKey: ['id_posicion'])
        .order('tiempo', ascending: false)
        .limit(50);
  }

  // ============================================================
  // --- SECCIÓN 3: SIMULACIÓN ---
  // ============================================================

  /// Obtiene TODOS los datos de un día para la simulación
  /// CAMBIADO: posiciones → posiciones_2
  Future<List<Map<String, dynamic>>> obtenerDatosParaSimulacion(DateTime fecha) async {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0).toIso8601String();
    final fin = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59).toIso8601String();

    final res = await _supabase
        .from('posiciones_2')
        .select()
        .gte('tiempo', inicio)
        .lte('tiempo', fin)
        .order('tiempo', ascending: true)
        .limit(_limiteMaximoRegistros);

    return List<Map<String, dynamic>>.from(res);
  }

  // ============================================================
  // --- SECCIÓN 4: CONSULTA HISTÓRICA ---
  // ============================================================

  /// Obtiene trayectorias por una fecha específica (00:00 a 23:59)
  /// CAMBIADO: posiciones → posiciones_2
  Future<List<Map<String, dynamic>>> obtenerTrayectoriaPorFecha(DateTime fecha) async {
    try {
      final inicioDia = DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0).toIso8601String();
      final finDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59).toIso8601String();

      final res = await _supabase
          .from('posiciones_2')
          .select()
          .gte('tiempo', inicioDia)
          .lte('tiempo', finDia)
          .order('tiempo', ascending: true)
          .limit(_limiteMaximoRegistros);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Error en obtenerTrayectoriaPorFecha: $e");
      return [];
    }
  }
}
