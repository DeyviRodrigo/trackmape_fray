import 'dart:math' as math;

import 'package:latlong2/latlong.dart' as ll;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/core/rutas/ruta_unaj.dart';
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';

enum DashboardSeverity { baja, media, alta }

enum DashboardAlertCategory {
  velocidad,
  ruta,
  detencion,
  mantenimiento,
  ambiente,
  operacion,
}

class DashboardStopArrival {
  final String nombre;
  final DateTime llegadaProgramada;
  final DateTime? llegadaReal;
  final int diferenciaMin;
  final bool evaluada;

  const DashboardStopArrival({
    required this.nombre,
    required this.llegadaProgramada,
    required this.llegadaReal,
    required this.diferenciaMin,
    required this.evaluada,
  });
}

class DashboardAlert {
  final DashboardAlertCategory categoria;
  final DashboardSeverity severidad;
  final String titulo;
  final String detalle;

  const DashboardAlert({
    required this.categoria,
    required this.severidad,
    required this.titulo,
    required this.detalle,
  });
}

class DashboardMetrics {
  final DateTime inicioPeriodo;
  final DateTime finPeriodo;
  final String estadoVehiculo;
  final String unidadPrincipal;
  final int registrosAnalizados;
  final double velocidadActualKmh;
  final double limiteVelocidadKmh;
  final double velocidadMaximaKmh;
  final double combustibleRestantePct;
  final double autonomiaRestanteKm;
  final int minutosDetenido;
  final int detencionesProlongadas;
  final double cumplimientoRutaPct;
  final int desviosRuta;
  final double desvioMaximoMetros;
  final double kilometrosRecorridos;
  final List<DashboardStopArrival> llegadasParadas;
  final double puntualidadPct;
  final double puntualidadPromedioMin;
  final double calidadScore;
  final double ambienteScore;
  final double consumoCombustibleLitros;
  final double emisionesKgCo2;
  final double rendimientoKmLitro;
  final double seguridadScore;
  final int excesosVelocidad;
  final int incidentes;
  final int averias;
  final int diasSinOperacion;
  final List<double> tendenciaCumplimientoRuta;
  final List<double> tendenciaConsumo;
  final List<double> tendenciaDetenciones;
  final List<DashboardAlert> alertas;
  final int vehiculosActivos;
  final int totalVehiculos;
  final int vehiculosSinSenal;

  const DashboardMetrics({
    required this.inicioPeriodo,
    required this.finPeriodo,
    required this.estadoVehiculo,
    required this.unidadPrincipal,
    required this.registrosAnalizados,
    required this.velocidadActualKmh,
    required this.limiteVelocidadKmh,
    required this.velocidadMaximaKmh,
    required this.combustibleRestantePct,
    required this.autonomiaRestanteKm,
    required this.minutosDetenido,
    required this.detencionesProlongadas,
    required this.cumplimientoRutaPct,
    required this.desviosRuta,
    required this.desvioMaximoMetros,
    required this.kilometrosRecorridos,
    required this.llegadasParadas,
    required this.puntualidadPct,
    required this.puntualidadPromedioMin,
    required this.calidadScore,
    required this.ambienteScore,
    required this.consumoCombustibleLitros,
    required this.emisionesKgCo2,
    required this.rendimientoKmLitro,
    required this.seguridadScore,
    required this.excesosVelocidad,
    required this.incidentes,
    required this.averias,
    required this.diasSinOperacion,
    required this.tendenciaCumplimientoRuta,
    required this.tendenciaConsumo,
    required this.tendenciaDetenciones,
    required this.alertas,
    required this.vehiculosActivos,
    required this.totalVehiculos,
    required this.vehiculosSinSenal,
  });

  factory DashboardMetrics.vacio({
    required DateTime inicioPeriodo,
    required DateTime finPeriodo,
  }) {
    return DashboardMetrics(
      inicioPeriodo: inicioPeriodo,
      finPeriodo: finPeriodo,
      estadoVehiculo: 'Sin datos',
      unidadPrincipal: 'Sin unidad',
      registrosAnalizados: 0,
      velocidadActualKmh: 0,
      limiteVelocidadKmh: DashboardRepository.limiteVelocidadKmh,
      velocidadMaximaKmh: 0,
      combustibleRestantePct: 100,
      autonomiaRestanteKm: 0,
      minutosDetenido: 0,
      detencionesProlongadas: 0,
      cumplimientoRutaPct: 0,
      desviosRuta: 0,
      desvioMaximoMetros: 0,
      kilometrosRecorridos: 0,
      llegadasParadas: DashboardRepository.paradasProgramadas(inicioPeriodo),
      puntualidadPct: 0,
      puntualidadPromedioMin: 0,
      calidadScore: 0,
      ambienteScore: 0,
      consumoCombustibleLitros: 0,
      emisionesKgCo2: 0,
      rendimientoKmLitro: 0,
      seguridadScore: 0,
      excesosVelocidad: 0,
      incidentes: 0,
      averias: 0,
      diasSinOperacion: 1,
      tendenciaCumplimientoRuta: const [],
      tendenciaConsumo: const [],
      tendenciaDetenciones: const [],
      alertas: const [
        DashboardAlert(
          categoria: DashboardAlertCategory.operacion,
          severidad: DashboardSeverity.media,
          titulo: 'Sin datos recientes',
          detalle: 'No hay posiciones suficientes para calcular indicadores.',
        ),
      ],
      vehiculosActivos: 0,
      totalVehiculos: 0,
      vehiculosSinSenal: 0,
    );
  }
}

class DashboardRepository {
  DashboardRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const int _limiteRegistros = 60000;
  static const int _segmentosTendencia = 8;
  static const int _maximoSaltoSegundos = 600;
  static const double limiteVelocidadKmh = 60;
  static const double _velocidadRalentiKmh = 3;
  static const double _distanciaDesvioMetros = 140;
  static const double _rendimientoEstimadoKmLitro = 8;
  static const double _capacidadTanqueLitros = 80;
  static const double _kgCo2PorLitro = 2.68;

  Future<DashboardMetrics> obtenerMetricas({
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final finConsulta = (fin ?? DateTime.now()).toUtc();
    final inicioConsulta =
        (inicio ?? finConsulta.subtract(const Duration(hours: 24))).toUtc();

    try {
      final equiposFuture = _obtenerEquipos();
      final incidentesFuture = _contarEventosOpcionales(
        tabla: 'incidentes',
        inicio: inicioConsulta,
        fin: finConsulta,
      );
      final averiasFuture = _contarEventosOpcionales(
        tabla: 'averias',
        inicio: inicioConsulta,
        fin: finConsulta,
      );

      final respuesta = await _supabase
          .from('posiciones')
          .select('fk_emisor, lat_grados, lon_grados, tiempo, velocidad')
          .gte('tiempo', inicioConsulta.toIso8601String())
          .lte('tiempo', finConsulta.toIso8601String())
          .order('tiempo', ascending: true)
          .limit(_limiteRegistros)
          .timeout(const Duration(seconds: 12));

      final registros = List<Map<String, dynamic>>.from(respuesta);
      if (registros.isEmpty) {
        return DashboardMetrics.vacio(
          inicioPeriodo: inicioConsulta,
          finPeriodo: finConsulta,
        );
      }

      return _calcularMetricas(
        registros: registros,
        equipos: await equiposFuture,
        inicioPeriodo: inicioConsulta,
        finPeriodo: finConsulta,
        incidentesRegistrados: await incidentesFuture,
        averiasRegistradas: await averiasFuture,
      );
    } catch (_) {
      return DashboardMetrics.vacio(
        inicioPeriodo: inicioConsulta,
        finPeriodo: finConsulta,
      );
    }
  }

  static List<DashboardStopArrival> paradasProgramadas(DateTime salida) {
    return RutaUnaj.paradasCalculadas
        .map(
          (parada) => DashboardStopArrival(
            nombre: parada.punto.nombre,
            llegadaProgramada: salida.add(parada.llegadaDesdeInicio),
            llegadaReal: null,
            diferenciaMin: 0,
            evaluada: false,
          ),
        )
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _obtenerEquipos() async {
    try {
      final respuesta = await _supabase
          .from('equipos_control')
          .select('id_equipo_control, codigo_equipo_control, activo')
          .eq('tipo_equipo_control', 'TRACKER')
          .timeout(const Duration(seconds: 8));
      return List<Map<String, dynamic>>.from(respuesta);
    } catch (_) {
      return [];
    }
  }

  Future<int> _contarEventosOpcionales({
    required String tabla,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    for (final campoFecha in const ['fecha_hora', 'fecha', 'created_at']) {
      try {
        final respuesta = await _supabase
            .from(tabla)
            .select('id')
            .gte(campoFecha, inicio.toIso8601String())
            .lte(campoFecha, fin.toIso8601String())
            .timeout(const Duration(seconds: 2));
        return List.from(respuesta).length;
      } on PostgrestException {
        continue;
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  DashboardMetrics _calcularMetricas({
    required List<Map<String, dynamic>> registros,
    required List<Map<String, dynamic>> equipos,
    required DateTime inicioPeriodo,
    required DateTime finPeriodo,
    required int incidentesRegistrados,
    required int averiasRegistradas,
  }) {
    final equiposPorId = {
      for (final equipo in equipos)
        if (equipo['id_equipo_control'] != null)
          equipo['id_equipo_control'].toString(): equipo,
    };
    final registrosPorEquipo = _agruparPorEquipo(registros);
    final totalVehiculos = math.max(equipos.length, registrosPorEquipo.length);

    var kilometros = 0.0;
    var velocidadMaxima = 0.0;
    var velocidadActual = 0.0;
    var excesos = 0;
    var segundosTotales = 0;
    var segundosMovimiento = 0;
    var segundosDetenido = 0;
    var detencionesProlongadas = 0;
    var desvios = 0;
    var desvioMaximo = 0.0;
    var registrosValidosRuta = 0;
    var unidadPrincipal = 'Sin unidad';
    DateTime? ultimoTiempoGlobal;

    final cumplimientoPorRegistro = <double>[];
    final consumoPorRegistro = <double>[];
    final detencionPorRegistro = <double>[];

    for (final entry in registrosPorEquipo.entries) {
      final idEquipo = entry.key;
      final puntos = entry.value
        ..sort(
          (a, b) => (_parseFecha(a['tiempo']) ?? DateTime(1970)).compareTo(
            _parseFecha(b['tiempo']) ?? DateTime(1970),
          ),
        );

      Map<String, dynamic>? anterior;
      var segundosDetenidosContinuos = 0;

      for (final actual in puntos) {
        final tiempoActual = _parseFecha(actual['tiempo']);
        final velocidadKmh = _velocidadKmh(actual, anterior);
        velocidadMaxima = math.max(velocidadMaxima, velocidadKmh);

        if (tiempoActual != null &&
            (ultimoTiempoGlobal == null ||
                tiempoActual.isAfter(ultimoTiempoGlobal))) {
          ultimoTiempoGlobal = tiempoActual;
          velocidadActual = velocidadKmh;
          unidadPrincipal =
              equiposPorId[idEquipo]?['codigo_equipo_control']?.toString() ??
              idEquipo;
        }

        if (velocidadKmh > limiteVelocidadKmh) excesos++;

        final posicion = _latLng(actual);
        if (posicion != null) {
          registrosValidosRuta++;
          final desvio = _distanciaARuta(posicion);
          desvioMaximo = math.max(desvioMaximo, desvio);
          if (desvio > _distanciaDesvioMetros) {
            desvios++;
            cumplimientoPorRegistro.add(0);
          } else {
            cumplimientoPorRegistro.add(100);
          }
        }

        if (anterior != null) {
          final tiempoAnterior = _parseFecha(anterior['tiempo']);
          final posicionAnterior = _latLng(anterior);
          if (tiempoActual != null &&
              tiempoAnterior != null &&
              posicion != null &&
              posicionAnterior != null) {
            final segundos = tiempoActual
                .difference(tiempoAnterior)
                .inSeconds
                .abs();
            if (segundos > 0 && segundos <= _maximoSaltoSegundos) {
              segundosTotales += segundos;

              if (velocidadKmh > _velocidadRalentiKmh) {
                segundosMovimiento += segundos;
                segundosDetenidosContinuos = 0;
              } else {
                segundosDetenido += segundos;
                segundosDetenidosContinuos += segundos;
                if (segundosDetenidosContinuos - segundos < 300 &&
                    segundosDetenidosContinuos >= 300) {
                  detencionesProlongadas++;
                }
              }

              final metros = CalculadoraGeodesica.calcularDistanciaMetros(
                posicionAnterior.latitude,
                posicionAnterior.longitude,
                posicion.latitude,
                posicion.longitude,
              );
              if (velocidadKmh <= 150) {
                kilometros += metros / 1000;
              }
            }
          }
        }

        detencionPorRegistro.add(velocidadKmh <= _velocidadRalentiKmh ? 1 : 0);
        anterior = actual;
      }
    }

    final cumplimientoRutaPct = registrosValidosRuta == 0
        ? 0.0
        : ((registrosValidosRuta - desvios) / registrosValidosRuta * 100)
              .clamp(0.0, 100.0)
              .toDouble();
    final llegadas = _calcularLlegadasParadas(registros, inicioPeriodo);
    final evaluadas = llegadas.where((parada) => parada.evaluada).toList();
    final puntuales = evaluadas
        .where((parada) => parada.diferenciaMin.abs() <= 3)
        .length;
    final puntualidadPct = evaluadas.isEmpty
        ? 0.0
        : (puntuales / evaluadas.length * 100).clamp(0.0, 100.0).toDouble();
    final puntualidadPromedio = evaluadas.isEmpty
        ? 0.0
        : evaluadas
                  .map((parada) => parada.diferenciaMin.abs())
                  .reduce((a, b) => a + b) /
              evaluadas.length;

    final consumoLitros = kilometros / _rendimientoEstimadoKmLitro;
    final combustibleRestante =
        (100 - (consumoLitros / _capacidadTanqueLitros * 100))
            .clamp(0.0, 100.0)
            .toDouble();
    final autonomiaRestante =
        _capacidadTanqueLitros *
        (combustibleRestante / 100) *
        _rendimientoEstimadoKmLitro;
    final rendimiento = consumoLitros > 0 ? kilometros / consumoLitros : 0.0;
    final emisiones = consumoLitros * _kgCo2PorLitro;
    final minutosDetenido = (segundosDetenido / 60).round();
    final vehiculosActivos = registrosPorEquipo.entries.where((entry) {
      final ultimo = entry.value
          .map((registro) => _parseFecha(registro['tiempo']))
          .whereType<DateTime>()
          .fold<DateTime?>(null, (prev, item) {
            if (prev == null || item.isAfter(prev)) return item;
            return prev;
          });
      return ultimo != null && finPeriodo.difference(ultimo).inMinutes <= 10;
    }).length;
    final vehiculosSinSenal = math.max(totalVehiculos - vehiculosActivos, 0);
    final diasSinOperacion = registros.isEmpty ? 1 : 0;
    final incidentes =
        incidentesRegistrados + (desvios > 0 ? 1 : 0) + (excesos > 0 ? 1 : 0);
    final averias = averiasRegistradas;

    final productividadMovimiento = segundosTotales == 0
        ? 0.0
        : (segundosMovimiento / segundosTotales * 100)
              .clamp(0.0, 100.0)
              .toDouble();
    final calidadScore = _promedio([
      evaluadas.isEmpty ? cumplimientoRutaPct : puntualidadPct,
      cumplimientoRutaPct,
      productividadMovimiento,
      diasSinOperacion == 0 ? 100 : 60,
    ]);
    final ambienteScore = (100 - consumoLitros * 1.2)
        .clamp(0.0, 100.0)
        .toDouble();
    final seguridadScore = (100 - excesos * 6 - incidentes * 8 - averias * 20)
        .clamp(0.0, 100.0)
        .toDouble();

    final estadoVehiculo = _estadoVehiculo(
      velocidadActual: velocidadActual,
      vehiculosActivos: vehiculosActivos,
      averias: averias,
    );
    consumoPorRegistro.addAll(_distribuir(consumoLitros, registros.length));

    return DashboardMetrics(
      inicioPeriodo: inicioPeriodo,
      finPeriodo: finPeriodo,
      estadoVehiculo: estadoVehiculo,
      unidadPrincipal: unidadPrincipal,
      registrosAnalizados: registros.length,
      velocidadActualKmh: velocidadActual,
      limiteVelocidadKmh: limiteVelocidadKmh,
      velocidadMaximaKmh: velocidadMaxima,
      combustibleRestantePct: combustibleRestante,
      autonomiaRestanteKm: autonomiaRestante,
      minutosDetenido: minutosDetenido,
      detencionesProlongadas: detencionesProlongadas,
      cumplimientoRutaPct: cumplimientoRutaPct,
      desviosRuta: desvios,
      desvioMaximoMetros: desvioMaximo,
      kilometrosRecorridos: kilometros,
      llegadasParadas: llegadas,
      puntualidadPct: puntualidadPct,
      puntualidadPromedioMin: puntualidadPromedio,
      calidadScore: calidadScore,
      ambienteScore: ambienteScore,
      consumoCombustibleLitros: consumoLitros,
      emisionesKgCo2: emisiones,
      rendimientoKmLitro: rendimiento,
      seguridadScore: seguridadScore,
      excesosVelocidad: excesos,
      incidentes: incidentes,
      averias: averias,
      diasSinOperacion: diasSinOperacion,
      tendenciaCumplimientoRuta: _promediarEnSegmentos(
        cumplimientoPorRegistro,
        valorVacio: cumplimientoRutaPct,
      ),
      tendenciaConsumo: _promediarEnSegmentos(consumoPorRegistro),
      tendenciaDetenciones: _promediarEnSegmentos(detencionPorRegistro),
      alertas: _crearAlertas(
        velocidadMaxima: velocidadMaxima,
        desvios: desvios,
        detenciones: detencionesProlongadas,
        combustibleRestante: combustibleRestante,
        vehiculosSinSenal: vehiculosSinSenal,
      ),
      vehiculosActivos: vehiculosActivos,
      totalVehiculos: totalVehiculos,
      vehiculosSinSenal: vehiculosSinSenal,
    );
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorEquipo(
    List<Map<String, dynamic>> registros,
  ) {
    final resultado = <String, List<Map<String, dynamic>>>{};
    for (final registro in registros) {
      final id = registro['fk_emisor']?.toString();
      if (id == null || id.isEmpty) continue;
      resultado.putIfAbsent(id, () => []).add(registro);
    }
    return resultado;
  }

  List<DashboardStopArrival> _calcularLlegadasParadas(
    List<Map<String, dynamic>> registros,
    DateTime salida,
  ) {
    return RutaUnaj.paradasCalculadas
        .map((parada) {
          final programada = salida.add(parada.llegadaDesdeInicio);
          DateTime? real;
          for (final registro in registros) {
            final posicion = _latLng(registro);
            final tiempo = _parseFecha(registro['tiempo']);
            if (posicion == null || tiempo == null) continue;
            final distancia = CalculadoraGeodesica.calcularDistanciaMetros(
              posicion.latitude,
              posicion.longitude,
              parada.coordenadaMarcador.latitude,
              parada.coordenadaMarcador.longitude,
            );
            if (distancia <= 120 && (real == null || tiempo.isBefore(real))) {
              real = tiempo;
            }
          }

          return DashboardStopArrival(
            nombre: parada.punto.nombre,
            llegadaProgramada: programada,
            llegadaReal: real,
            diferenciaMin: real == null
                ? 0
                : real.difference(programada).inMinutes,
            evaluada: real != null,
          );
        })
        .toList(growable: false);
  }

  List<DashboardAlert> _crearAlertas({
    required double velocidadMaxima,
    required int desvios,
    required int detenciones,
    required double combustibleRestante,
    required int vehiculosSinSenal,
  }) {
    final alertas = <DashboardAlert>[];

    if (velocidadMaxima > limiteVelocidadKmh) {
      alertas.add(
        DashboardAlert(
          categoria: DashboardAlertCategory.velocidad,
          severidad: DashboardSeverity.alta,
          titulo: 'Exceso de velocidad',
          detalle:
              'Maximo registrado: ${velocidadMaxima.toStringAsFixed(0)} km/h.',
        ),
      );
    }
    if (desvios > 0) {
      alertas.add(
        DashboardAlert(
          categoria: DashboardAlertCategory.ruta,
          severidad: DashboardSeverity.media,
          titulo: 'Desvios de ruta',
          detalle: '$desvios posiciones se alejaron de la ruta UNAJ.',
        ),
      );
    }
    if (detenciones > 0) {
      alertas.add(
        DashboardAlert(
          categoria: DashboardAlertCategory.detencion,
          severidad: DashboardSeverity.media,
          titulo: 'Detenciones prolongadas',
          detalle: '$detenciones detenciones superaron 5 minutos.',
        ),
      );
    }
    if (combustibleRestante < 20) {
      alertas.add(
        const DashboardAlert(
          categoria: DashboardAlertCategory.ambiente,
          severidad: DashboardSeverity.media,
          titulo: 'Combustible bajo',
          detalle: 'Autonomia estimada reducida para la unidad principal.',
        ),
      );
    }
    if (vehiculosSinSenal > 0) {
      alertas.add(
        DashboardAlert(
          categoria: DashboardAlertCategory.operacion,
          severidad: DashboardSeverity.baja,
          titulo: 'Equipos sin senal',
          detalle: '$vehiculosSinSenal vehiculos no reportan recientemente.',
        ),
      );
    }

    if (alertas.isEmpty) {
      alertas.add(
        const DashboardAlert(
          categoria: DashboardAlertCategory.operacion,
          severidad: DashboardSeverity.baja,
          titulo: 'Operacion estable',
          detalle: 'No hay alertas criticas en el periodo analizado.',
        ),
      );
    }

    return alertas;
  }

  String _estadoVehiculo({
    required double velocidadActual,
    required int vehiculosActivos,
    required int averias,
  }) {
    if (averias > 0) return 'Con averia';
    if (velocidadActual > limiteVelocidadKmh) return 'Exceso de velocidad';
    if (vehiculosActivos > 0) return 'Operativo';
    return 'Sin senal reciente';
  }

  double _velocidadKmh(
    Map<String, dynamic> actual,
    Map<String, dynamic>? anterior,
  ) {
    final registrada = _asDouble(actual['velocidad']);
    if (registrada != null && registrada > 0) return registrada * 3.6;
    if (anterior == null) return 0;

    final p1 = _latLng(anterior);
    final p2 = _latLng(actual);
    final t1 = _parseFecha(anterior['tiempo']);
    final t2 = _parseFecha(actual['tiempo']);
    if (p1 == null || p2 == null || t1 == null || t2 == null) return 0;

    final segundos = t2.difference(t1).inSeconds.abs();
    if (segundos == 0 || segundos > _maximoSaltoSegundos) return 0;

    final metros = CalculadoraGeodesica.calcularDistanciaMetros(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
    return (metros / segundos) * 3.6;
  }

  double _distanciaARuta(ll.LatLng punto) {
    var menor = double.infinity;
    final ruta = RutaUnaj.polilinea;
    for (var i = 0; i < ruta.length - 1; i++) {
      menor = math.min(menor, _distanciaASegmento(punto, ruta[i], ruta[i + 1]));
    }
    return menor;
  }

  double _distanciaASegmento(ll.LatLng punto, ll.LatLng inicio, ll.LatLng fin) {
    final latRef = (punto.latitude + inicio.latitude + fin.latitude) / 3;
    final cosLat = math.cos(latRef * math.pi / 180);
    final ax = inicio.longitude * cosLat;
    final ay = inicio.latitude;
    final bx = fin.longitude * cosLat;
    final by = fin.latitude;
    final px = punto.longitude * cosLat;
    final py = punto.latitude;
    final dx = bx - ax;
    final dy = by - ay;
    final largo = dx * dx + dy * dy;
    final fraccion = largo == 0
        ? 0.0
        : (((px - ax) * dx + (py - ay) * dy) / largo)
              .clamp(0.0, 1.0)
              .toDouble();
    final proyectado = ll.LatLng(
      inicio.latitude + (fin.latitude - inicio.latitude) * fraccion,
      inicio.longitude + (fin.longitude - inicio.longitude) * fraccion,
    );
    return CalculadoraGeodesica.calcularDistanciaMetros(
      punto.latitude,
      punto.longitude,
      proyectado.latitude,
      proyectado.longitude,
    );
  }

  List<double> _promediarEnSegmentos(
    List<double> valores, {
    double valorVacio = 0,
  }) {
    if (valores.isEmpty) return List.filled(_segmentosTendencia, valorVacio);
    final resultado = <double>[];
    for (var i = 0; i < _segmentosTendencia; i++) {
      final inicio = (i * valores.length / _segmentosTendencia).floor();
      final fin = (((i + 1) * valores.length / _segmentosTendencia).ceil())
          .clamp(inicio + 1, valores.length);
      final segmento = valores.sublist(inicio, fin);
      resultado.add(_promedio(segmento));
    }
    return resultado;
  }

  List<double> _distribuir(double total, int cantidad) {
    if (cantidad <= 0) return const [];
    final paso = total / cantidad;
    return List<double>.generate(cantidad, (index) => paso * (index + 1));
  }

  double _promedio(Iterable<num> valores) {
    if (valores.isEmpty) return 0;
    var total = 0.0;
    var cantidad = 0;

    for (final valor in valores) {
      total += valor.toDouble();
      cantidad++;
    }

    return cantidad == 0 ? 0 : total / cantidad;
  }

  ll.LatLng? _latLng(Map<String, dynamic> registro) {
    final lat = _asDouble(registro['lat_grados']);
    final lon = _asDouble(registro['lon_grados']);
    if (lat == null || lon == null) return null;
    return ll.LatLng(lat, lon);
  }

  double? _asDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '');
  }

  DateTime? _parseFecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
