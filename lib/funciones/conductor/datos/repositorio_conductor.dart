import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioConductor {

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Verifica si el dispositivo ya está registrado
  Future<Map<String, dynamic>?> buscarDispositivo(String idDispositivo) async {

    final resp = await _supabase
        .from('equipos_control')
        .select()
        .eq('id_equipo_control', idDispositivo)
        .maybeSingle();

    return resp;
  }

  /// Registrar nuevo dispositivo en la base de datos
  Future<void> registrarDispositivo({
    required String id,
    required String codigo,
    required String nombre,
  }) async {

    await _supabase.from('equipos_control').insert({
      "id_equipo_control": id,
      "codigo_equipo_control": codigo,
      "nombre_equipo_control": nombre,
      "tipo_equipo_control": "GPS_MOVIL",
      "habilitado": true
    });

  }

  /// Enviar posición a la tabla posiciones
  Future<void> enviarPosicion({
    required String idDispositivo,
    required double lat,
    required double lon,
  }) async {

    await _supabase.from('posiciones').insert({
      "fk_emisor": idDispositivo,
      "lat_grados": lat,
      "lon_grados": lon,
      "tiempo": DateTime.now().toIso8601String()
    });

  }

}