import 'dart:math' as math;

import '../modelos/punto_rendimiento.dart';
import '../modelos/resumen_rendimiento.dart';

class ProcesadorRendimientoOperacional {
  const ProcesadorRendimientoOperacional();

  static const double _distanciaMinimaMovimientoMetros = 2.0;
  static const double _velocidadMaximaPermitidaKmh = 100.0;
  static const int _segundosMinimosParada = 30;

  ResumenRendimiento procesar(List<PuntoRendimiento> puntos) {
    if (puntos.length < 2) {
      return ResumenRendimiento(
        distanciaTotalKm: 0,
        tiempoDetenidoHoras: 0,
        tiempoOperativoHoras: 0,
        velocidadPromedioKmh: 0,
        rendimientoKmh: 0,
        puntosValidos: puntos.length,
        puntosDescartados: 0,
        paradasDetectadas: 0,
      );
    }

    final ordenados = [...puntos]..sort((a, b) => a.tiempo.compareTo(b.tiempo));

    var distanciaTotalMetros = 0.0;
    var tiempoDetenidoSegundos = 0;
    var tiempoOperativoSegundos = 0;
    var puntosDescartados = 0;
    var paradasDetectadas = 0;
    var acumuladoDetenidoActual = 0;

    PuntoRendimiento? anterior;

    for (final actual in ordenados) {
      if (!_coordenadaEsValida(actual)) {
        puntosDescartados++;
        continue;
      }

      if (anterior == null) {
        anterior = actual;
        continue;
      }

      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0) {
        puntosDescartados++;
        anterior = actual;
        continue;
      }

      final distanciaMetros = _haversineMetros(
        anterior.latitud,
        anterior.longitud,
        actual.latitud,
        actual.longitud,
      );
      final velocidadKmh = (distanciaMetros / deltaSegundos) * 3.6;

      if (velocidadKmh > _velocidadMaximaPermitidaKmh) {
        puntosDescartados++;
        anterior = actual;
        continue;
      }

      if (distanciaMetros < _distanciaMinimaMovimientoMetros) {
        tiempoDetenidoSegundos += deltaSegundos;
        acumuladoDetenidoActual += deltaSegundos;
      } else {
        if (acumuladoDetenidoActual >= _segundosMinimosParada) {
          paradasDetectadas++;
        }
        acumuladoDetenidoActual = 0;
        distanciaTotalMetros += distanciaMetros;
        tiempoOperativoSegundos += deltaSegundos;
      }

      anterior = actual;
    }

    if (acumuladoDetenidoActual >= _segundosMinimosParada) {
      paradasDetectadas++;
    }

    final distanciaTotalKm = distanciaTotalMetros / 1000.0;
    final tiempoDetenidoHoras = tiempoDetenidoSegundos / 3600.0;
    final tiempoOperativoHoras = tiempoOperativoSegundos / 3600.0;
    final velocidadPromedioKmh = tiempoOperativoHoras > 0
        ? distanciaTotalKm / tiempoOperativoHoras
        : 0.0;

    return ResumenRendimiento(
      distanciaTotalKm: distanciaTotalKm,
      tiempoDetenidoHoras: tiempoDetenidoHoras,
      tiempoOperativoHoras: tiempoOperativoHoras,
      velocidadPromedioKmh: velocidadPromedioKmh,
      rendimientoKmh: velocidadPromedioKmh,
      puntosValidos: ordenados.length - puntosDescartados,
      puntosDescartados: puntosDescartados,
      paradasDetectadas: paradasDetectadas,
    );
  }

  bool _coordenadaEsValida(PuntoRendimiento punto) {
    if (punto.latitud == 0 || punto.longitud == 0) {
      return false;
    }

    return punto.latitud >= -90 &&
        punto.latitud <= 90 &&
        punto.longitud >= -180 &&
        punto.longitud <= 180;
  }

  double _haversineMetros(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radioTierra = 6371000.0;
    final dLat = _gradosARadianes(lat2 - lat1);
    final dLon = _gradosARadianes(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_gradosARadianes(lat1)) *
            math.cos(_gradosARadianes(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) => grados * (math.pi / 180.0);
}
