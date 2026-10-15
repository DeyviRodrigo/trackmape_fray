import '../entities/posicion_entity.dart';

abstract class IConductorRepository {
  /// Envía la posición a la capa de datos (la cual decidirá si usar red local o Supabase)
  Future<bool> enviarPosicion({
    required String idEquipo,
    required PosicionEntity posicion,
  });

  /// Registra el dispositivo en el backend
  Future<Map<String, dynamic>> registrarDispositivo({
    required String idFabrica,
    required String codigo,
    required String nombre,
    required String fkEmpresa,
    String? fkSede,
  });
}
