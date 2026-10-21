import 'dart:math' as math;

import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/gis/datos/modelos/modelo_gis.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';

enum EstadoAcopleRutaDiagnostico { acoplado, sinRuta, ambiguo }

class AsignacionRutaDiagnostico {
  const AsignacionRutaDiagnostico({
    required this.punto,
    required this.estado,
    required this.distanciaMetros,
    this.ruta,
  });

  final PuntoTrayectoria<Map<String, dynamic>> punto;
  final EstadoAcopleRutaDiagnostico estado;
  final double distanciaMetros;
  final ElementoOperativo? ruta;
}

class PermanenciaAreaDiagnostico {
  const PermanenciaAreaDiagnostico({
    required this.area,
    required this.inicio,
    required this.fin,
    required this.duracion,
  });

  final ElementoOperativo area;
  final DateTime inicio;
  final DateTime fin;
  final Duration duracion;
}

class ResumenDiagnosticoEquipo {
  const ResumenDiagnosticoEquipo({
    required this.equipo,
    required this.puntosCrudos,
    required this.puntosValidos,
    required this.puntosLimpios,
    required this.puntosDescartados,
    required this.puntosAcoplados,
    required this.puntosSinRuta,
    required this.puntosAmbiguos,
    required this.distanciaLimpiaMetros,
    required this.distanciaAcopladaMetros,
    required this.tiempoMovimiento,
    required this.tiempoDetenido,
    required this.asignaciones,
    required this.permanencias,
    required this.rutasUsadas,
    required this.areasVisitadas,
  });

  final ModeloEquipo equipo;
  final int puntosCrudos;
  final int puntosValidos;
  final int puntosLimpios;
  final int puntosDescartados;
  final int puntosAcoplados;
  final int puntosSinRuta;
  final int puntosAmbiguos;
  final double distanciaLimpiaMetros;
  final double distanciaAcopladaMetros;
  final Duration tiempoMovimiento;
  final Duration tiempoDetenido;
  final List<AsignacionRutaDiagnostico> asignaciones;
  final List<PermanenciaAreaDiagnostico> permanencias;
  final List<ElementoOperativo> rutasUsadas;
  final List<ElementoOperativo> areasVisitadas;

  double get porcentajeAcople {
    if (puntosLimpios == 0) return 0;
    return (puntosAcoplados / puntosLimpios) * 100;
  }

  bool get requiereMasRutas => puntosLimpios > 0 && porcentajeAcople < 70;
}

class ResultadoDiagnosticoOperativo {
  const ResultadoDiagnosticoOperativo({
    required this.fecha,
    required this.resumenes,
    required this.rutas,
    required this.areas,
    required this.puntos,
  });

  final DateTime fecha;
  final List<ResumenDiagnosticoEquipo> resumenes;
  final List<ElementoOperativo> rutas;
  final List<ElementoOperativo> areas;
  final List<ElementoOperativo> puntos;

  int get puntosCrudosTotal =>
      resumenes.fold(0, (total, item) => total + item.puntosCrudos);

  int get puntosLimpiosTotal =>
      resumenes.fold(0, (total, item) => total + item.puntosLimpios);

  int get puntosDescartadosTotal =>
      resumenes.fold(0, (total, item) => total + item.puntosDescartados);
}

class ServicioDiagnosticoOperativo {
  const ServicioDiagnosticoOperativo({
    this.radioAcopleMetros = 35.0,
    this.margenAmbiguoMetros = 8.0,
    this.velocidadDetenidoKmh = 2.0,
    this.permanenciaMinimaArea = const Duration(seconds: 60),
    this.limpiador = const LimpiadorTrayectoria(),
  });

  final double radioAcopleMetros;
  final double margenAmbiguoMetros;
  final double velocidadDetenidoKmh;
  final Duration permanenciaMinimaArea;
  final LimpiadorTrayectoria limpiador;

  ResultadoDiagnosticoOperativo procesar({
    required DateTime fecha,
    required List<ModeloEquipo> equipos,
    required List<Map<String, dynamic>> trayectoria,
    required List<ElementoOperativo> rutas,
    required List<ElementoOperativo> areas,
    required List<ElementoOperativo> puntos,
    String? equipoIdFiltro,
  }) {
    final equiposPorId = {for (final equipo in equipos) equipo.id: equipo};
    final puntosPorEquipo = <String, List<Map<String, dynamic>>>{};

    for (final punto in trayectoria) {
      final id = punto['fk_emisor']?.toString().trim() ?? '';
      if (id.isEmpty) continue;
      if (equipoIdFiltro != null &&
          equipoIdFiltro.isNotEmpty &&
          id != equipoIdFiltro) {
        continue;
      }
      puntosPorEquipo.putIfAbsent(id, () => []).add(punto);
    }

    final resumenes = <ResumenDiagnosticoEquipo>[];
    for (final entry in puntosPorEquipo.entries) {
      final equipo = equiposPorId[entry.key] ?? ModeloEquipo(id: entry.key);
      resumenes.add(
        _procesarEquipo(
          equipo: equipo,
          puntosCrudos: entry.value,
          rutas: rutas,
          areas: areas,
        ),
      );
    }

    resumenes.sort(
      (a, b) => a.equipo.nombreMostrar.compareTo(b.equipo.nombreMostrar),
    );

    return ResultadoDiagnosticoOperativo(
      fecha: fecha,
      resumenes: resumenes,
      rutas: rutas,
      areas: areas,
      puntos: puntos,
    );
  }

  ResumenDiagnosticoEquipo _procesarEquipo({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
    required List<ElementoOperativo> rutas,
    required List<ElementoOperativo> areas,
  }) {
    final normalizados = _normalizarPuntos(puntosCrudos);
    final limpieza = limpiador.limpiar(normalizados);
    final limpios = limpieza.puntos;
    final asignaciones = limpios
        .map((punto) => _asignarRuta(punto: punto, rutas: rutas))
        .toList();
    final rutasUsadasPorId = <String, ElementoOperativo>{};

    for (final asignacion in asignaciones) {
      final ruta = asignacion.ruta;
      if (ruta != null &&
          asignacion.estado != EstadoAcopleRutaDiagnostico.sinRuta) {
        rutasUsadasPorId[ruta.id] = ruta;
      }
    }

    final areasVisitadasPorId = <String, ElementoOperativo>{};
    for (final punto in limpios) {
      final area = _areaParaPunto(punto, areas);
      if (area != null) areasVisitadasPorId[area.id] = area;
    }

    final tiempos = _calcularTiempos(limpios);

    return ResumenDiagnosticoEquipo(
      equipo: equipo,
      puntosCrudos: puntosCrudos.length,
      puntosValidos: normalizados.length,
      puntosLimpios: limpios.length,
      puntosDescartados: limpieza.estadisticas.puntosDescartados,
      puntosAcoplados: asignaciones
          .where((item) => item.estado == EstadoAcopleRutaDiagnostico.acoplado)
          .length,
      puntosSinRuta: asignaciones
          .where((item) => item.estado == EstadoAcopleRutaDiagnostico.sinRuta)
          .length,
      puntosAmbiguos: asignaciones
          .where((item) => item.estado == EstadoAcopleRutaDiagnostico.ambiguo)
          .length,
      distanciaLimpiaMetros: _distanciaTotal(limpios),
      distanciaAcopladaMetros: _distanciaAcoplada(limpios, asignaciones),
      tiempoMovimiento: tiempos.movimiento,
      tiempoDetenido: tiempos.detenido,
      asignaciones: asignaciones,
      permanencias: _detectarPermanencias(limpios, areas),
      rutasUsadas: rutasUsadasPorId.values.toList(),
      areasVisitadas: areasVisitadasPorId.values.toList(),
    );
  }

  List<PuntoTrayectoria<Map<String, dynamic>>> _normalizarPuntos(
    List<Map<String, dynamic>> puntosCrudos,
  ) {
    final puntos = <PuntoTrayectoria<Map<String, dynamic>>>[];

    for (final punto in puntosCrudos) {
      final lat = (punto['lat_grados'] as num?)?.toDouble();
      final lon = (punto['lon_grados'] as num?)?.toDouble();
      final tiempo = DateTime.tryParse(punto['tiempo']?.toString() ?? '');

      if (lat == null ||
          lon == null ||
          tiempo == null ||
          !limpiador.coordenadaEsValida(lat, lon)) {
        continue;
      }

      puntos.add(
        PuntoTrayectoria<Map<String, dynamic>>(
          latitud: lat,
          longitud: lon,
          tiempo: tiempo,
          payload: Map<String, dynamic>.from(punto),
        ),
      );
    }

    puntos.sort((a, b) => a.tiempo.compareTo(b.tiempo));
    return puntos;
  }

  AsignacionRutaDiagnostico _asignarRuta({
    required PuntoTrayectoria<Map<String, dynamic>> punto,
    required List<ElementoOperativo> rutas,
  }) {
    if (rutas.isEmpty) {
      return AsignacionRutaDiagnostico(
        punto: punto,
        estado: EstadoAcopleRutaDiagnostico.sinRuta,
        distanciaMetros: double.infinity,
      );
    }

    _RutaCercana? mejor;
    _RutaCercana? segunda;

    for (final ruta in rutas) {
      final distancia = _distanciaAPolilinea(
        punto: ll.LatLng(punto.latitud, punto.longitud),
        linea: ruta.puntosLinea,
      );
      if (distancia == null) continue;

      final candidata = _RutaCercana(ruta: ruta, distanciaMetros: distancia);
      if (mejor == null || candidata.distanciaMetros < mejor.distanciaMetros) {
        segunda = mejor;
        mejor = candidata;
      } else if (segunda == null ||
          candidata.distanciaMetros < segunda.distanciaMetros) {
        segunda = candidata;
      }
    }

    if (mejor == null || mejor.distanciaMetros > radioAcopleMetros) {
      return AsignacionRutaDiagnostico(
        punto: punto,
        estado: EstadoAcopleRutaDiagnostico.sinRuta,
        distanciaMetros: mejor?.distanciaMetros ?? double.infinity,
        ruta: mejor?.ruta,
      );
    }

    final ambiguo =
        segunda != null &&
        segunda.distanciaMetros <= radioAcopleMetros &&
        (segunda.distanciaMetros - mejor.distanciaMetros).abs() <=
            margenAmbiguoMetros;

    return AsignacionRutaDiagnostico(
      punto: punto,
      estado: ambiguo
          ? EstadoAcopleRutaDiagnostico.ambiguo
          : EstadoAcopleRutaDiagnostico.acoplado,
      distanciaMetros: mejor.distanciaMetros,
      ruta: mejor.ruta,
    );
  }

  List<PermanenciaAreaDiagnostico> _detectarPermanencias(
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
    List<ElementoOperativo> areas,
  ) {
    final permanencias = <PermanenciaAreaDiagnostico>[];
    ElementoOperativo? areaActual;
    DateTime? inicio;
    DateTime? ultimo;

    void cerrar() {
      if (areaActual == null || inicio == null || ultimo == null) return;
      final duracion = ultimo.difference(inicio);
      if (duracion >= permanenciaMinimaArea) {
        permanencias.add(
          PermanenciaAreaDiagnostico(
            area: areaActual,
            inicio: inicio,
            fin: ultimo,
            duracion: duracion,
          ),
        );
      }
    }

    for (final punto in puntos) {
      final area = _areaParaPunto(punto, areas);
      if (area?.id != areaActual?.id) {
        cerrar();
        areaActual = area;
        inicio = area == null ? null : punto.tiempo;
      }
      if (area != null) ultimo = punto.tiempo;
    }

    cerrar();
    return permanencias;
  }

  ElementoOperativo? _areaParaPunto(
    PuntoTrayectoria<Map<String, dynamic>> punto,
    List<ElementoOperativo> areas,
  ) {
    final posicion = ll.LatLng(punto.latitud, punto.longitud);
    for (final area in areas) {
      if (_puntoEnPoligono(posicion, area.puntosPoligono)) return area;
    }
    return null;
  }

  _TiemposMovimiento _calcularTiempos(
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
  ) {
    var movimiento = Duration.zero;
    var detenido = Duration.zero;

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final actual = puntos[i];
      final delta = actual.tiempo.difference(anterior.tiempo);
      if (delta.inSeconds <= 0 || delta.inMinutes > 10) continue;
      final velocidad = limpiador.velocidadKmh(anterior, actual);
      if (velocidad <= velocidadDetenidoKmh) {
        detenido += delta;
      } else {
        movimiento += delta;
      }
    }

    return _TiemposMovimiento(movimiento: movimiento, detenido: detenido);
  }

  double _distanciaTotal(List<PuntoTrayectoria<Map<String, dynamic>>> puntos) {
    var total = 0.0;
    for (var i = 1; i < puntos.length; i++) {
      total += limpiador.distanciaMetros(
        puntos[i - 1].latitud,
        puntos[i - 1].longitud,
        puntos[i].latitud,
        puntos[i].longitud,
      );
    }
    return total;
  }

  double _distanciaAcoplada(
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
    List<AsignacionRutaDiagnostico> asignaciones,
  ) {
    var total = 0.0;
    for (var i = 1; i < puntos.length && i < asignaciones.length; i++) {
      final actual = asignaciones[i];
      final anterior = asignaciones[i - 1];
      if (actual.estado == EstadoAcopleRutaDiagnostico.sinRuta ||
          anterior.estado == EstadoAcopleRutaDiagnostico.sinRuta) {
        continue;
      }
      total += limpiador.distanciaMetros(
        puntos[i - 1].latitud,
        puntos[i - 1].longitud,
        puntos[i].latitud,
        puntos[i].longitud,
      );
    }
    return total;
  }

  double? _distanciaAPolilinea({
    required ll.LatLng punto,
    required List<ll.LatLng> linea,
  }) {
    if (linea.length < 2) return null;
    var mejor = double.infinity;
    for (var i = 1; i < linea.length; i++) {
      final distancia = _distanciaPuntoSegmentoMetros(
        punto: punto,
        a: linea[i - 1],
        b: linea[i],
      );
      if (distancia < mejor) mejor = distancia;
    }
    return mejor;
  }

  double _distanciaPuntoSegmentoMetros({
    required ll.LatLng punto,
    required ll.LatLng a,
    required ll.LatLng b,
  }) {
    final refLat = punto.latitude * math.pi / 180.0;
    final px = _lonAMetros(punto.longitude, refLat);
    final py = _latAMetros(punto.latitude);
    final ax = _lonAMetros(a.longitude, refLat);
    final ay = _latAMetros(a.latitude);
    final bx = _lonAMetros(b.longitude, refLat);
    final by = _latAMetros(b.latitude);
    final dx = bx - ax;
    final dy = by - ay;

    if (dx == 0 && dy == 0) {
      return math.sqrt(math.pow(px - ax, 2) + math.pow(py - ay, 2));
    }

    final t = (((px - ax) * dx) + ((py - ay) * dy)) / ((dx * dx) + (dy * dy));
    final clamped = t.clamp(0.0, 1.0);
    final cx = ax + clamped * dx;
    final cy = ay + clamped * dy;
    return math.sqrt(math.pow(px - cx, 2) + math.pow(py - cy, 2));
  }

  bool _puntoEnPoligono(ll.LatLng punto, List<ll.LatLng> poligono) {
    if (poligono.length < 3) return false;
    var dentro = false;
    var j = poligono.length - 1;

    for (var i = 0; i < poligono.length; i++) {
      final pi = poligono[i];
      final pj = poligono[j];
      final cruza =
          (pi.latitude > punto.latitude) != (pj.latitude > punto.latitude) &&
          punto.longitude <
              (pj.longitude - pi.longitude) *
                      (punto.latitude - pi.latitude) /
                      (pj.latitude - pi.latitude) +
                  pi.longitude;
      if (cruza) dentro = !dentro;
      j = i;
    }

    return dentro;
  }

  double _latAMetros(double lat) => lat * 111320.0;

  double _lonAMetros(double lon, double refLatRad) =>
      lon * 111320.0 * math.cos(refLatRad);
}

class _RutaCercana {
  const _RutaCercana({required this.ruta, required this.distanciaMetros});

  final ElementoOperativo ruta;
  final double distanciaMetros;
}

class _TiemposMovimiento {
  const _TiemposMovimiento({required this.movimiento, required this.detenido});

  final Duration movimiento;
  final Duration detenido;
}
