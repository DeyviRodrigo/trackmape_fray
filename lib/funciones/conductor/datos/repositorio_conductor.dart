import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================
/// REPOSITORIO CONDUCTOR - NUEVA ESTRUCTURA
/// ============================================
/// Adaptado para:
/// - equipos_control con UUID y fk_empresa
/// - posiciones (nueva tabla)
/// - Campo 'activo' en lugar de 'habilitado'
/// - Campo 'nombre' en lugar de 'nombre_equipo_control'
/// - Campo 'id_equipo_fabrica' para ID del celular
///
/// FILTRO: Solo muestra Universidad Nacional de Juliaca
///
class RepositorioConductor {

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // 🏢 EMPRESAS PERMITIDAS (FILTRO)
  // ============================================
  // Agrega aquí los IDs de empresas que quieres mostrar
  // Si está vacío, muestra todas las empresas activas
  static const List<String> _empresasPermitidas = [
    '94b2de0b-6c99-4218-8536-b67b95a301e4',  // Universidad Nacional de Juliaca
  ];

  /// ===============================
  /// OBTENER EMPRESAS DISPONIBLES
  /// ===============================
  /// Filtra solo las empresas permitidas
  Future<List<Map<String, dynamic>>> obtenerEmpresas() async {
    try {
      var query = _supabase
          .from('empresas')
          .select('id_empresa, razon_social, nombre_comercial')
          .eq('activo', true);

      // Aplicar filtro si hay empresas específicas
      if (_empresasPermitidas.isNotEmpty) {
        query = query.inFilter('id_empresa', _empresasPermitidas);
      }

      final resp = await query
          .order('razon_social', ascending: true)
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(resp);
    } catch (e) {
      print("❌ Error obteniendo empresas: $e");
      return [];
    }
  }

  /// ===============================
  /// OBTENER SEDES POR EMPRESA
  /// ===============================
  Future<List<Map<String, dynamic>>> obtenerSedesPorEmpresa(String idEmpresa) async {
    try {
      final resp = await _supabase
          .from('sedes')
          .select()
          .eq('fk_empresa', idEmpresa)
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(resp);
    } catch (e) {
      print("❌ Error obteniendo sedes: $e");
      return [];
    }
  }

  /// ===============================
  /// OBTENER TODAS LAS SEDES
  /// ===============================
  Future<List<Map<String, dynamic>>> obtenerSedes() async {
    try {
      final resp = await _supabase
          .from('sedes')
          .select()
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(resp);
    } catch (e) {
      print("❌ Error obteniendo sedes: $e");
      return [];
    }
  }

  /// ===============================
  /// BUSCAR DISPOSITIVO POR ID FÁBRICA
  /// ===============================
  /// Busca si el celular ya está registrado usando id_equipo_fabrica
  Future<Map<String, dynamic>?> buscarDispositivo(String idFabrica) async {
    try {
      final resp = await _supabase
          .from('equipos_control')
          .select()
          .eq('id_equipo_fabrica', idFabrica)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return resp;

    } catch (e) {
      print("❌ Error buscando dispositivo: $e");
      return null;
    }
  }

  /// ===============================
  /// REGISTRAR DISPOSITIVO
  /// ===============================
  /// Inserta el celular como equipo_control
  /// Ahora con fk_empresa obligatorio y UUID auto-generado
  Future<Map<String, dynamic>> registrarDispositivo({
    required String idFabrica,      // ID del celular (Android ID)
    required String codigo,
    required String nombre,
    required String fkEmpresa,      // UUID de la empresa (obligatorio)
    String? fkSede,                 // UUID de la sede (opcional)
  }) async {

    try {
      // Verificar si ya existe por id_equipo_fabrica
      final existente = await buscarDispositivo(idFabrica);
      if (existente != null) {
        return {
          'exito': false,
          'mensaje': 'Este dispositivo ya está registrado con código: ${existente['codigo_equipo_control']}',
          'id_equipo': existente['id_equipo_control'],
        };
      }

      // Preparar datos para insertar
      final Map<String, dynamic> datosInsert = {
        // FK obligatoria
        "fk_empresa": fkEmpresa,

        // ID del dispositivo físico (celular)
        "id_equipo_fabrica": idFabrica,

        // Datos del conductor
        "codigo_equipo_control": codigo,
        "nombre": nombre,

        // Tipo del equipo - TRACKER para aparecer en operadores
        "tipo_equipo_control": "TRACKER",

        // Estado activo
        "activo": true,
      };

      // FK sede opcional
      if (fkSede != null && fkSede.isNotEmpty) {
        datosInsert["fk_sede"] = fkSede;
      }

      // Insertar nuevo equipo (UUID se genera automáticamente)
      final respuesta = await _supabase
          .from('equipos_control')
          .insert(datosInsert)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      return {
        'exito': true,
        'mensaje': 'Dispositivo registrado correctamente',
        'id_equipo': respuesta['id_equipo_control'],
      };

    } on PostgrestException catch (e) {
      print("❌ PostgrestException: ${e.code} - ${e.message}");

      if (e.code == '23505') {
        return {
          'exito': false,
          'mensaje': 'Este dispositivo ya existe en la base de datos'
        };
      }

      if (e.code == '23503') {
        return {
          'exito': false,
          'mensaje': 'La empresa o sede seleccionada no es válida'
        };
      }

      return {
        'exito': false,
        'mensaje': 'Error de base de datos: ${e.message}'
      };

    } catch (e) {
      print("❌ Error registrando dispositivo: $e");
      return {
        'exito': false,
        'mensaje': 'Error de conexión: $e'
      };
    }
  }

  /// ===============================
  /// OBTENER ID DEL EQUIPO REGISTRADO
  /// ===============================
  /// Retorna el UUID del equipo dado el id_equipo_fabrica
  Future<String?> obtenerIdEquipo(String idFabrica) async {
    try {
      final resp = await _supabase
          .from('equipos_control')
          .select('id_equipo_control')
          .eq('id_equipo_fabrica', idFabrica)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return resp?['id_equipo_control']?.toString();
    } catch (e) {
      print("❌ Error obteniendo ID equipo: $e");
      return null;
    }
  }

  /// ===============================
  /// ENVIAR POSICION GPS
  /// ===============================
  /// Guarda la posición en la tabla posiciones
  Future<bool> enviarPosicion({
    required String idEquipo,  // UUID del equipo (id_equipo_control)
    required double lat,
    required double lon,
  }) async {
    final resultado = await enviarPosicionConDetalle(
      idEquipo: idEquipo,
      lat: lat,
      lon: lon,
    );
    return resultado['exito'] == true;
  }

  /// Versión con detalles del error para debugging
  Future<Map<String, dynamic>> enviarPosicionConDetalle({
    required String idEquipo,  // UUID del equipo
    required double lat,
    required double lon,
    double? altitud,
  }) async {

    try {
      final ahora = DateTime.now();

      final datos = {
        "fk_emisor": idEquipo,
        "lat_grados": lat,
        "lon_grados": lon,
        "tiempo": ahora.toIso8601String(),
        "epoca_rx": ahora.millisecondsSinceEpoch,
      };

      // Agregar altitud si está disponible
      if (altitud != null && altitud != 0.0) {
        datos["alt_msnm_m"] = altitud.round();
      }

      print("📤 INSERT posiciones: $datos");

      await _supabase.from('posiciones').insert(datos)
          .timeout(const Duration(seconds: 10));

      print("✅ Posición insertada correctamente");
      return {
        'exito': true,
        'mensaje': 'Posición enviada'
      };

    } on PostgrestException catch (e) {
      print("❌ PostgrestException: ${e.code} - ${e.message}");

      String mensajeError = e.message;

      if (e.code == '42501') {
        mensajeError = "Sin permiso (RLS). Contacta al admin.";
      } else if (e.code == '23503') {
        mensajeError = "El equipo no existe en equipos_control";
      } else if (e.code == '23502') {
        mensajeError = "Campo requerido faltante: ${e.details}";
      }

      return {
        'exito': false,
        'mensaje': mensajeError,
        'codigo': e.code,
      };

    } on TimeoutException {
      print("❌ Timeout de conexión");
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
