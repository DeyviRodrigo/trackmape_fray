import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/funciones/combustible/datos/modelos/combustible_modelos.dart';

class RepositorioCombustible {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<VehiculoCombustible>> obtenerVehiculos() async {
    try {
      return await _obtenerVehiculos(incluirEquipoControl: true);
    } on PostgrestException {
      return _obtenerVehiculos(incluirEquipoControl: false);
    }
  }

  Future<List<VehiculoCombustible>> _obtenerVehiculos({
    required bool incluirEquipoControl,
  }) async {
    final campos = [
      'id_vehiculo',
      'fk_empresa',
      'placa',
      'marca',
      'modelo',
      'tipo_combustible',
      'rendimiento_km_galon',
      'capacidad_tanque',
      'activo',
      if (incluirEquipoControl) 'fk_equipo_control',
    ].join(', ');

    final response = await _supabase
        .from('vehiculos')
        .select(campos)
        .eq('activo', true)
        .order('placa', ascending: true)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map(VehiculoCombustible.fromJson).toList();
  }

  Future<IngresoCombustible> registrarIngreso({
    required String idVehiculo,
    required DateTime fechaHora,
    required int galones,
    required double total,
  }) async {
    final response = await _supabase
        .from('ingresos_combustible')
        .insert({
          'fk_vehiculo': idVehiculo,
          'fecha_hora': fechaHora.toIso8601String(),
          'galones': galones,
          'total': total,
        })
        .select(
          'id_ing_comb, fk_vehiculo, fecha_hora, galones, total, created_at',
        )
        .single()
        .timeout(const Duration(seconds: 10));

    return IngresoCombustible.fromJson(response);
  }

  Future<List<IngresoCombustible>> obtenerIngresos({
    required String idVehiculo,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    final response = await _supabase
        .from('ingresos_combustible')
        .select(
          'id_ing_comb, fk_vehiculo, fecha_hora, galones, total, created_at',
        )
        .eq('fk_vehiculo', idVehiculo)
        .gte('fecha_hora', inicio.toIso8601String())
        .lte('fecha_hora', fin.toIso8601String())
        .order('fecha_hora', ascending: true)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map(IngresoCombustible.fromJson).toList();
  }

  Future<List<PosicionCombustible>> obtenerPosiciones({
    required String fkEmisor,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    if (fkEmisor.trim().isEmpty) return [];

    final response = await _supabase
        .from('posiciones')
        .select('lat_grados, lon_grados, tiempo')
        .eq('fk_emisor', fkEmisor.trim())
        .gte('tiempo', inicio.toIso8601String())
        .lte('tiempo', fin.toIso8601String())
        .order('tiempo', ascending: true)
        .timeout(const Duration(seconds: 15));

    return List<Map<String, dynamic>>.from(response)
        .map(PosicionCombustible.fromJson)
        .where((posicion) => posicion.esValida)
        .toList();
  }

  Future<DashboardCombustible> obtenerDashboard({
    required VehiculoCombustible vehiculo,
    required String fkEmisor,
    required DateTime inicio,
    required DateTime fin,
    required double kilometrosPorTramo,
  }) async {
    final ingresos = await obtenerIngresos(
      idVehiculo: vehiculo.idVehiculo,
      inicio: inicio,
      fin: fin,
    );
    final posiciones = await obtenerPosiciones(
      fkEmisor: fkEmisor,
      inicio: inicio,
      fin: fin,
    );

    final galonesIngresados = ingresos.fold<double>(
      0,
      (total, ingreso) => total + ingreso.galones,
    );
    final costoIngresado = ingresos.fold<double>(
      0,
      (total, ingreso) => total + ingreso.total,
    );
    final costoPromedioGalon = galonesIngresados > 0
        ? costoIngresado / galonesIngresados
        : 0.0;
    final tramos = _calcularTramos(
      posiciones: posiciones,
      vehiculo: vehiculo,
      kilometrosPorTramo: kilometrosPorTramo,
      costoPromedioGalon: costoPromedioGalon,
    );

    final kilometrosTotales = tramos.fold<double>(
      0,
      (total, tramo) => total + tramo.kilometros,
    );
    final galonesConsumidos = tramos.fold<double>(
      0,
      (total, tramo) => total + tramo.galonesConsumidos,
    );
    final costoEstimado = tramos.fold<double>(
      0,
      (total, tramo) => total + tramo.costoEstimado,
    );
    final capacidad = vehiculo.capacidadTanque ?? 0;
    final galonesDisponibles = capacidad > 0
        ? math.min(capacidad, galonesIngresados)
        : galonesIngresados;
    final porcentajeTanque = capacidad > 0
        ? (galonesConsumidos / capacidad) * 100
        : 0.0;

    return DashboardCombustible(
      vehiculo: vehiculo,
      tramos: tramos,
      ingresos: ingresos,
      kilometrosTotales: kilometrosTotales,
      galonesConsumidos: galonesConsumidos,
      galonesIngresados: galonesIngresados,
      costoIngresado: costoIngresado,
      costoEstimadoConsumo: costoEstimado,
      porcentajeTanqueConsumido: porcentajeTanque,
      galonesRestantesEstimados: math.max(
        0,
        galonesDisponibles - galonesConsumidos,
      ),
    );
  }
}

List<TramoConsumoCombustible> _calcularTramos({
  required List<PosicionCombustible> posiciones,
  required VehiculoCombustible vehiculo,
  required double kilometrosPorTramo,
  required double costoPromedioGalon,
}) {
  if (posiciones.length < 2 || !vehiculo.tieneParametrosConsumo) return [];

  final rendimiento = vehiculo.rendimientoKmGalon!;
  final capacidad = vehiculo.capacidadTanque!;
  final objetivoKm = kilometrosPorTramo <= 0 ? 5.0 : kilometrosPorTramo;
  final tramos = <TramoConsumoCombustible>[];

  DateTime? inicioTramo;
  DateTime? finTramo;
  double kmAcumulados = 0;
  int segundosAcumulados = 0;

  for (var index = 1; index < posiciones.length; index++) {
    final anterior = posiciones[index - 1];
    final actual = posiciones[index];
    final segundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
    if (segundos <= 0) continue;

    final metros = _haversineMeters(
      anterior.latitud,
      anterior.longitud,
      actual.latitud,
      actual.longitud,
    );
    final kilometros = metros / 1000;
    final velocidad = kilometros / (segundos / 3600);

    if (velocidad > 150 || kilometros <= 0) continue;

    inicioTramo ??= anterior.tiempo;
    finTramo = actual.tiempo;
    kmAcumulados += kilometros;
    segundosAcumulados += segundos;

    if (kmAcumulados >= objetivoKm) {
      tramos.add(
        _crearTramo(
          numero: tramos.length + 1,
          inicio: inicioTramo,
          fin: finTramo,
          kilometros: kmAcumulados,
          segundos: segundosAcumulados,
          rendimientoKmGalon: rendimiento,
          capacidadTanque: capacidad,
          costoPromedioGalon: costoPromedioGalon,
        ),
      );
      inicioTramo = null;
      finTramo = null;
      kmAcumulados = 0;
      segundosAcumulados = 0;
    }
  }

  if (inicioTramo != null && finTramo != null && kmAcumulados > 0) {
    tramos.add(
      _crearTramo(
        numero: tramos.length + 1,
        inicio: inicioTramo,
        fin: finTramo,
        kilometros: kmAcumulados,
        segundos: segundosAcumulados,
        rendimientoKmGalon: rendimiento,
        capacidadTanque: capacidad,
        costoPromedioGalon: costoPromedioGalon,
      ),
    );
  }

  return tramos;
}

TramoConsumoCombustible _crearTramo({
  required int numero,
  required DateTime inicio,
  required DateTime fin,
  required double kilometros,
  required int segundos,
  required double rendimientoKmGalon,
  required double capacidadTanque,
  required double costoPromedioGalon,
}) {
  final galones = kilometros / rendimientoKmGalon;
  return TramoConsumoCombustible(
    numero: numero,
    inicio: inicio,
    fin: fin,
    kilometros: kilometros,
    galonesConsumidos: galones,
    porcentajeTanque: capacidadTanque > 0
        ? (galones / capacidadTanque) * 100
        : 0,
    costoEstimado: galones * costoPromedioGalon,
    velocidadPromedioKmh: segundos > 0 ? kilometros / (segundos / 3600) : 0,
  );
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _degToRad(double deg) => deg * (math.pi / 180);
