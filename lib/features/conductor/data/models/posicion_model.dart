import '../../domain/entities/posicion_entity.dart';

class PosicionModel extends PosicionEntity {
  PosicionModel({
    required super.latitud,
    required super.longitud,
    required super.altitud,
    required super.velocidad,
    required super.rumbo,
    required super.tiempo,
  });

  /// Factory para crear desde Supabase o SQLite
  factory PosicionModel.fromJson(Map<String, dynamic> json) {
    return PosicionModel(
      latitud: (json['lat_grados'] as num).toDouble(),
      longitud: (json['lon_grados'] as num).toDouble(),
      altitud: (json['alt_msnm_m'] as num?)?.toDouble() ?? 0.0,
      velocidad: (json['velocidad'] as num?)?.toDouble() ?? 0.0,
      rumbo: (json['rumbo'] as num?)?.toDouble() ?? 0.0,
      tiempo: DateTime.parse(json['tiempo'] as String),
    );
  }

  /// Convertir a JSON para enviar a Supabase o SQLite
  Map<String, dynamic> toJson(String idEquipo) {
    return {
      "fk_emisor": idEquipo,
      "lat_grados": latitud,
      "lon_grados": longitud,
      "alt_msnm_m": altitud,
      "velocidad": velocidad,
      "rumbo": rumbo,
      "tiempo": tiempo.toUtc().toIso8601String(),
      "epoca_rx": tiempo.millisecondsSinceEpoch,
    };
  }
}
