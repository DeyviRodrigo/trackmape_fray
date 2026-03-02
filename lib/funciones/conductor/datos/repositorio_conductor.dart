import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioConductor {

  final SupabaseClient _supabase = Supabase.instance.client;

  /// ===============================
  /// OBTENER SEDES DISPONIBLES
  /// ===============================
  /// Consulta todas las sedes para el dropdown
  Future<List<Map<String, dynamic>>> obtenerSedes() async {
    try {
      final resp = await _supabase
          .from('sedes')
          .select()
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(resp);
    } catch (e) {
      print("Error obteniendo sedes: $e");
      return [];
    }
  }

  /// ===============================
  /// BUSCAR DISPOSITIVO
  /// ===============================
  /// Consulta si el dispositivo existe en equipos_control
  Future<Map<String, dynamic>?> buscarDispositivo(String idDispositivo) async {
    try {

      final resp = await _supabase
          .from('equipos_control')
          .select()
          .eq('id_equipo_control', idDispositivo)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return resp;

    } catch (e) {

      print("Error buscando dispositivo: $e");
      return null;

    }
  }

  /// ===============================
  /// REGISTRAR DISPOSITIVO
  /// ===============================
  /// Inserta el celular como equipo_control
  /// Retorna un Map con {exito: bool, mensaje: String}
  Future<Map<String, dynamic>> registrarDispositivo({
    required String id,
    required String codigo,
    required String nombre,
    required String fkSede,  // Ahora viene del dropdown
  }) async {

    try {

      // Primero verificamos si ya existe
      final existente = await buscarDispositivo(id);
      if (existente != null) {
        return {
          'exito': false,
          'mensaje': 'Este dispositivo ya está registrado con código: ${existente['codigo_equipo_control']}'
        };
      }

      await _supabase.from('equipos_control').insert({

        /// PK
        "id_equipo_control": id,

        /// FK a la tabla sedes - Viene del dropdown
        "fk_sede": fkSede,

        /// Datos del conductor
        "codigo_equipo_control": codigo,
        "nombre_equipo_control": nombre,

        /// Tipo del equipo - TRACKER para aparecer en operadores
        "tipo_equipo_control": "TRACKER",

        /// Estado
        "habilitado": true,

      }).timeout(const Duration(seconds: 10));

      return {
        'exito': true,
        'mensaje': 'Dispositivo registrado correctamente'
      };

    } on PostgrestException catch (e) {

      print("Error PostgrestException: ${e.code} - ${e.message}");

      // Errores específicos de Supabase/PostgreSQL
      if (e.code == '23505') {
        return {
          'exito': false,
          'mensaje': 'Este dispositivo ya existe en la base de datos'
        };
      }

      if (e.code == '23503') {
        return {
          'exito': false,
          'mensaje': 'La sede seleccionada no es válida'
        };
      }

      return {
        'exito': false,
        'mensaje': 'Error de base de datos: ${e.message}'
      };

    } catch (e) {

      print("Error registrando dispositivo: $e");
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e'
      };

    }
  }

  /// ===============================
  /// ENVIAR POSICION GPS
  /// ===============================
  /// Guarda la posición en la tabla posiciones
  Future<bool> enviarPosicion({
    required String idDispositivo,
    required double lat,
    required double lon,
  }) async {
    final resultado = await enviarPosicionConDetalle(
      idDispositivo: idDispositivo,
      lat: lat,
      lon: lon,
    );
    return resultado['exito'] == true;
  }

  /// Versión con detalles del error para debugging
  Future<Map<String, dynamic>> enviarPosicionConDetalle({
    required String idDispositivo,
    required double lat,
    required double lon,
    double? altitud,
  }) async {

    try {

      final ahora = DateTime.now();

      final datos = {
        "fk_emisor": idDispositivo,
        "lat_grados": lat,
        "lon_grados": lon,
        "tiempo": ahora.toIso8601String(),
        "epoca_rx": ahora.millisecondsSinceEpoch,
      };

      // Agregar altitud si está disponible
      if (altitud != null && altitud != 0.0) {
        datos["alt_msnm_m"] = altitud.round();
      }

      print("📤 Supabase INSERT posiciones: $datos");

      await _supabase.from('posiciones').insert(datos)
          .timeout(const Duration(seconds: 10));

      print("✅ Supabase: Posición insertada correctamente");
      return {
        'exito': true,
        'mensaje': 'Posición enviada'
      };

    } on PostgrestException catch (e) {

      print("❌ Supabase PostgrestException: ${e.code} - ${e.message}");
      print("   Details: ${e.details}");
      print("   Hint: ${e.hint}");

      String mensajeError = e.message;

      // Errores comunes
      if (e.code == '42501') {
        mensajeError = "Sin permiso (RLS). Contacta al admin.";
      } else if (e.code == '23503') {
        mensajeError = "El dispositivo no existe en equipos_control";
      } else if (e.code == '23502') {
        mensajeError = "Campo requerido faltante: ${e.details}";
      }

      return {
        'exito': false,
        'mensaje': mensajeError,
        'codigo': e.code,
      };

    } on TimeoutException {
      print("❌ Supabase: Timeout de conexión");
      return {
        'exito': false,
        'mensaje': 'Timeout - Sin conexión a internet'
      };

    } catch (e) {
      print("❌ Error enviando posición: $e");
      return {
        'exito': false,
        'mensaje': e.toString()
      };
    }
  }

}