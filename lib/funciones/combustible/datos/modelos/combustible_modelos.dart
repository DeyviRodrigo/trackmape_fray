class VehiculoCombustible {
  final String idVehiculo;
  final String fkEmpresa;
  final String placa;
  final String? marca;
  final String? modelo;
  final String? tipoCombustible;
  final double? rendimientoKmGalon;
  final double? capacidadTanque;
  final bool activo;
  final String? fkEquipoControl;

  const VehiculoCombustible({
    required this.idVehiculo,
    required this.fkEmpresa,
    required this.placa,
    this.marca,
    this.modelo,
    this.tipoCombustible,
    this.rendimientoKmGalon,
    this.capacidadTanque,
    this.activo = true,
    this.fkEquipoControl,
  });

  factory VehiculoCombustible.fromJson(Map<String, dynamic> json) {
    return VehiculoCombustible(
      idVehiculo: json['id_vehiculo']?.toString() ?? '',
      fkEmpresa: json['fk_empresa']?.toString() ?? '',
      placa: json['placa']?.toString() ?? 'S/N',
      marca: _asString(json['marca']),
      modelo: _asString(json['modelo']),
      tipoCombustible: _asString(json['tipo_combustible']),
      rendimientoKmGalon: _asDouble(json['rendimiento_km_galon']),
      capacidadTanque: _asDouble(json['capacidad_tanque']),
      activo: json['activo'] != false,
      fkEquipoControl: _asString(json['fk_equipo_control']),
    );
  }

  String get nombreMostrar {
    final detalle = [
      marca,
      modelo,
    ].where((valor) => valor != null && valor.trim().isNotEmpty).join(' ');
    return detalle.isEmpty ? placa : '$placa - $detalle';
  }

  bool get tieneParametrosConsumo {
    return (rendimientoKmGalon ?? 0) > 0 && (capacidadTanque ?? 0) > 0;
  }

  double get autonomiaTanqueKm {
    final rendimiento = rendimientoKmGalon ?? 0;
    final capacidad = capacidadTanque ?? 0;
    return rendimiento > 0 && capacidad > 0 ? rendimiento * capacidad : 0;
  }
}

class IngresoCombustible {
  final int idIngreso;
  final String? fkVehiculo;
  final DateTime? fechaHora;
  final int galones;
  final double total;
  final DateTime? createdAt;

  const IngresoCombustible({
    required this.idIngreso,
    required this.galones,
    required this.total,
    this.fkVehiculo,
    this.fechaHora,
    this.createdAt,
  });

  factory IngresoCombustible.fromJson(Map<String, dynamic> json) {
    return IngresoCombustible(
      idIngreso: (json['id_ing_comb'] as num?)?.toInt() ?? 0,
      fkVehiculo: _asString(json['fk_vehiculo']),
      fechaHora: _asDate(json['fecha_hora']),
      galones: (json['galones'] as num?)?.toInt() ?? 0,
      total: _asDouble(json['total']) ?? 0,
      createdAt: _asDate(json['created_at']),
    );
  }
}

class PosicionCombustible {
  final double latitud;
  final double longitud;
  final DateTime tiempo;

  const PosicionCombustible({
    required this.latitud,
    required this.longitud,
    required this.tiempo,
  });

  factory PosicionCombustible.fromJson(Map<String, dynamic> json) {
    return PosicionCombustible(
      latitud: _asDouble(json['lat_grados']) ?? 0,
      longitud: _asDouble(json['lon_grados']) ?? 0,
      tiempo: _asDate(json['tiempo']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get esValida => latitud != 0 && longitud != 0;
}

class TramoConsumoCombustible {
  final int numero;
  final DateTime inicio;
  final DateTime fin;
  final double kilometros;
  final double galonesConsumidos;
  final double porcentajeTanque;
  final double costoEstimado;
  final double velocidadPromedioKmh;

  const TramoConsumoCombustible({
    required this.numero,
    required this.inicio,
    required this.fin,
    required this.kilometros,
    required this.galonesConsumidos,
    required this.porcentajeTanque,
    required this.costoEstimado,
    required this.velocidadPromedioKmh,
  });
}

class DashboardCombustible {
  final VehiculoCombustible vehiculo;
  final List<TramoConsumoCombustible> tramos;
  final List<IngresoCombustible> ingresos;
  final double kilometrosTotales;
  final double galonesConsumidos;
  final double galonesIngresados;
  final double costoIngresado;
  final double costoEstimadoConsumo;
  final double porcentajeTanqueConsumido;
  final double galonesRestantesEstimados;

  const DashboardCombustible({
    required this.vehiculo,
    required this.tramos,
    required this.ingresos,
    required this.kilometrosTotales,
    required this.galonesConsumidos,
    required this.galonesIngresados,
    required this.costoIngresado,
    required this.costoEstimadoConsumo,
    required this.porcentajeTanqueConsumido,
    required this.galonesRestantesEstimados,
  });
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
