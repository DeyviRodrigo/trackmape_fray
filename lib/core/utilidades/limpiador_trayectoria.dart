import 'dart:math' as math;

class PuntoTrayectoria<T> {
  final double latitud;
  final double longitud;
  final DateTime tiempo;
  final T payload;

  const PuntoTrayectoria({
    required this.latitud,
    required this.longitud,
    required this.tiempo,
    required this.payload,
  });
}

class TramoTrayectoria<T> {
  final PuntoTrayectoria<T> inicio;
  final PuntoTrayectoria<T> fin;
  final double distanciaMetros;
  final double velocidadKmh;
  final int deltaSegundos;

  const TramoTrayectoria({
    required this.inicio,
    required this.fin,
    required this.distanciaMetros,
    required this.velocidadKmh,
    required this.deltaSegundos,
  });
}

class EstadisticasTrayectoria {
  final double mediaDistanciaMetros;
  final double medianaDistanciaMetros;
  final double percentil90DistanciaMetros;
  final double mediaVelocidadKmh;
  final double medianaVelocidadKmh;
  final double percentil90VelocidadKmh;
  final double umbralDistanciaMetros;
  final double umbralVelocidadKmh;
  final int tramosAnalizados;
  final int puntosDescartados;

  const EstadisticasTrayectoria({
    required this.mediaDistanciaMetros,
    required this.medianaDistanciaMetros,
    required this.percentil90DistanciaMetros,
    required this.mediaVelocidadKmh,
    required this.medianaVelocidadKmh,
    required this.percentil90VelocidadKmh,
    required this.umbralDistanciaMetros,
    required this.umbralVelocidadKmh,
    required this.tramosAnalizados,
    required this.puntosDescartados,
  });

  static const vacia = EstadisticasTrayectoria(
    mediaDistanciaMetros: 0,
    medianaDistanciaMetros: 0,
    percentil90DistanciaMetros: 0,
    mediaVelocidadKmh: 0,
    medianaVelocidadKmh: 0,
    percentil90VelocidadKmh: 0,
    umbralDistanciaMetros: 0,
    umbralVelocidadKmh: 0,
    tramosAnalizados: 0,
    puntosDescartados: 0,
  );
}

class ResultadoLimpiezaTrayectoria<T> {
  final List<PuntoTrayectoria<T>> puntos;
  final List<List<PuntoTrayectoria<T>>> segmentos;
  final EstadisticasTrayectoria estadisticas;

  const ResultadoLimpiezaTrayectoria({
    required this.puntos,
    required this.segmentos,
    required this.estadisticas,
  });
}

class LimpiadorTrayectoria {
  const LimpiadorTrayectoria({
    this.velocidadOperativaMaximaKmh = 35.0,
    this.velocidadDescarteDuroKmh = 80.0,
    this.factorMedianaDistancia = 5.0,
    this.factorMediaDistancia = 4.0,
    this.factorMedianaVelocidad = 4.0,
    this.factorMediaVelocidad = 3.0,
    this.anguloMaximoGrados = 45.0,
    this.factorDesvioMaximo = 1.8,
    this.deltaSegundosMaximoReconexion = 60,
    this.distanciaMinimaBaseMetros = 40.0,
  });

  final double velocidadOperativaMaximaKmh;
  final double velocidadDescarteDuroKmh;
  final double factorMedianaDistancia;
  final double factorMediaDistancia;
  final double factorMedianaVelocidad;
  final double factorMediaVelocidad;
  final double anguloMaximoGrados;
  final double factorDesvioMaximo;
  final int deltaSegundosMaximoReconexion;
  final double distanciaMinimaBaseMetros;

  ResultadoLimpiezaTrayectoria<T> limpiar<T>(List<PuntoTrayectoria<T>> puntos) {
    if (puntos.isEmpty) {
      return const ResultadoLimpiezaTrayectoria(
        puntos: [],
        segmentos: [],
        estadisticas: EstadisticasTrayectoria.vacia,
      );
    }

    final ordenados = [...puntos]
      ..sort((a, b) => a.tiempo.compareTo(b.tiempo));

    final base = _construirTramosBase(ordenados);
    final estadisticasBase = _calcularEstadisticasBase(base);

    final aceptados = <PuntoTrayectoria<T>>[];
    var puntosDescartados = 0;

    for (final punto in ordenados) {
      if (!coordenadaEsValida(punto.latitud, punto.longitud)) {
        puntosDescartados++;
        continue;
      }

      if (aceptados.isEmpty) {
        aceptados.add(punto);
        continue;
      }

      final ancla = aceptados.last;
      if (!_tramoValido(ancla, punto, estadisticasBase)) {
        puntosDescartados++;
        continue;
      }

      aceptados.add(punto);

      while (aceptados.length >= 3) {
        final a = aceptados[aceptados.length - 3];
        final b = aceptados[aceptados.length - 2];
        final c = aceptados[aceptados.length - 1];

        if (!_esOutlierPorGiro(a, b, c, estadisticasBase)) {
          break;
        }

        aceptados.removeAt(aceptados.length - 2);
        puntosDescartados++;
      }
    }

    final segmentos = _segmentarAceptados(aceptados);
    final estadisticasFinales = _calcularEstadisticasFinales(
      aceptados,
      estadisticasBase,
      puntosDescartados,
    );

    return ResultadoLimpiezaTrayectoria(
      puntos: aceptados,
      segmentos: segmentos,
      estadisticas: estadisticasFinales,
    );
  }

  bool coordenadaEsValida(double latitud, double longitud) {
    if (latitud == 0 || longitud == 0) {
      return false;
    }

    if (latitud < -90 || latitud > 90) {
      return false;
    }

    if (longitud < -180 || longitud > 180) {
      return false;
    }

    if (latitud < -20 || latitud > -10) {
      return false;
    }

    if (longitud < -75 || longitud > -65) {
      return false;
    }

    return true;
  }

  double distanciaMetros(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        (math.cos((lat2 - lat1) * p) / 2) +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  double velocidadKmh<T>(PuntoTrayectoria<T> a, PuntoTrayectoria<T> b) {
    final deltaSegundos = b.tiempo.difference(a.tiempo).inSeconds;
    if (deltaSegundos <= 0) {
      return 0.0;
    }

    final distancia = distanciaMetros(
      a.latitud,
      a.longitud,
      b.latitud,
      b.longitud,
    );
    return (distancia / deltaSegundos) * 3.6;
  }

  List<TramoTrayectoria<T>> _construirTramosBase<T>(
    List<PuntoTrayectoria<T>> puntos,
  ) {
    final tramos = <TramoTrayectoria<T>>[];

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final actual = puntos[i];

      if (!coordenadaEsValida(anterior.latitud, anterior.longitud) ||
          !coordenadaEsValida(actual.latitud, actual.longitud)) {
        continue;
      }

      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0 || deltaSegundos > deltaSegundosMaximoReconexion) {
        continue;
      }

      final distancia = distanciaMetros(
        anterior.latitud,
        anterior.longitud,
        actual.latitud,
        actual.longitud,
      );
      final velocidad = (distancia / deltaSegundos) * 3.6;

      tramos.add(
        TramoTrayectoria(
          inicio: anterior,
          fin: actual,
          distanciaMetros: distancia,
          velocidadKmh: velocidad,
          deltaSegundos: deltaSegundos,
        ),
      );
    }

    return tramos;
  }

  EstadisticasTrayectoria _calcularEstadisticasBase<T>(
    List<TramoTrayectoria<T>> tramos,
  ) {
    if (tramos.isEmpty) {
      return EstadisticasTrayectoria(
        mediaDistanciaMetros: 0,
        medianaDistanciaMetros: 0,
        percentil90DistanciaMetros: 0,
        mediaVelocidadKmh: 0,
        medianaVelocidadKmh: 0,
        percentil90VelocidadKmh: 0,
        umbralDistanciaMetros: distanciaMinimaBaseMetros,
        umbralVelocidadKmh: velocidadOperativaMaximaKmh,
        tramosAnalizados: 0,
        puntosDescartados: 0,
      );
    }

    final distancias = tramos.map((t) => t.distanciaMetros).toList()..sort();
    final velocidades = tramos.map((t) => t.velocidadKmh).toList()..sort();

    final mediaDistancia = _media(distancias);
    final medianaDistancia = _mediana(distancias);
    final percentil90Distancia = _percentil(distancias, 0.9);
    final mediaVelocidad = _media(velocidades);
    final medianaVelocidad = _mediana(velocidades);
    final percentil90Velocidad = _percentil(velocidades, 0.9);

    final umbralDistancia = math.max(
      distanciaMinimaBaseMetros,
      math.max(
        medianaDistancia * factorMedianaDistancia,
        math.max(
          mediaDistancia * factorMediaDistancia,
          percentil90Distancia * 1.8,
        ),
      ),
    );

    final umbralVelocidad = math.min(
      velocidadDescarteDuroKmh,
      math.max(
        velocidadOperativaMaximaKmh,
        math.max(
          medianaVelocidad * factorMedianaVelocidad,
          math.max(
            mediaVelocidad * factorMediaVelocidad,
            percentil90Velocidad * 1.7,
          ),
        ),
      ),
    );

    return EstadisticasTrayectoria(
      mediaDistanciaMetros: mediaDistancia,
      medianaDistanciaMetros: medianaDistancia,
      percentil90DistanciaMetros: percentil90Distancia,
      mediaVelocidadKmh: mediaVelocidad,
      medianaVelocidadKmh: medianaVelocidad,
      percentil90VelocidadKmh: percentil90Velocidad,
      umbralDistanciaMetros: umbralDistancia,
      umbralVelocidadKmh: umbralVelocidad,
      tramosAnalizados: tramos.length,
      puntosDescartados: 0,
    );
  }

  EstadisticasTrayectoria _calcularEstadisticasFinales<T>(
    List<PuntoTrayectoria<T>> aceptados,
    EstadisticasTrayectoria base,
    int puntosDescartados,
  ) {
    final tramos = _construirTramosBase(aceptados);
    if (tramos.isEmpty) {
      return EstadisticasTrayectoria(
        mediaDistanciaMetros: base.mediaDistanciaMetros,
        medianaDistanciaMetros: base.medianaDistanciaMetros,
        percentil90DistanciaMetros: base.percentil90DistanciaMetros,
        mediaVelocidadKmh: base.mediaVelocidadKmh,
        medianaVelocidadKmh: base.medianaVelocidadKmh,
        percentil90VelocidadKmh: base.percentil90VelocidadKmh,
        umbralDistanciaMetros: base.umbralDistanciaMetros,
        umbralVelocidadKmh: base.umbralVelocidadKmh,
        tramosAnalizados: base.tramosAnalizados,
        puntosDescartados: puntosDescartados,
      );
    }

    final distancias = tramos.map((t) => t.distanciaMetros).toList()..sort();
    final velocidades = tramos.map((t) => t.velocidadKmh).toList()..sort();

    return EstadisticasTrayectoria(
      mediaDistanciaMetros: _media(distancias),
      medianaDistanciaMetros: _mediana(distancias),
      percentil90DistanciaMetros: _percentil(distancias, 0.9),
      mediaVelocidadKmh: _media(velocidades),
      medianaVelocidadKmh: _mediana(velocidades),
      percentil90VelocidadKmh: _percentil(velocidades, 0.9),
      umbralDistanciaMetros: base.umbralDistanciaMetros,
      umbralVelocidadKmh: base.umbralVelocidadKmh,
      tramosAnalizados: tramos.length,
      puntosDescartados: puntosDescartados,
    );
  }

  List<List<PuntoTrayectoria<T>>> _segmentarAceptados<T>(
    List<PuntoTrayectoria<T>> puntos,
  ) {
    if (puntos.isEmpty) {
      return const [];
    }

    final segmentos = <List<PuntoTrayectoria<T>>>[];
    var segmentoActual = <PuntoTrayectoria<T>>[];

    for (final punto in puntos) {
      if (segmentoActual.isEmpty) {
        segmentoActual = [punto];
        continue;
      }

      final anterior = segmentoActual.last;
      final deltaSegundos = punto.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0 || deltaSegundos > deltaSegundosMaximoReconexion) {
        if (segmentoActual.length >= 2) {
          segmentos.add(segmentoActual);
        }
        segmentoActual = [punto];
        continue;
      }

      segmentoActual.add(punto);
    }

    if (segmentoActual.length >= 2) {
      segmentos.add(segmentoActual);
    }

    return segmentos;
  }

  bool _tramoValido<T>(
    PuntoTrayectoria<T> anterior,
    PuntoTrayectoria<T> actual,
    EstadisticasTrayectoria estadisticas,
  ) {
    final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
    if (deltaSegundos <= 0) {
      return false;
    }

    if (deltaSegundos > deltaSegundosMaximoReconexion) {
      return false;
    }

    final distancia = distanciaMetros(
      anterior.latitud,
      anterior.longitud,
      actual.latitud,
      actual.longitud,
    );
    final velocidad = (distancia / deltaSegundos) * 3.6;

    if (velocidad > estadisticas.umbralVelocidadKmh) {
      return false;
    }

    final umbralDistanciaPorTiempo = math.max(
      estadisticas.umbralDistanciaMetros,
      (estadisticas.umbralVelocidadKmh / 3.6) * deltaSegundos,
    );

    if (distancia > umbralDistanciaPorTiempo) {
      return false;
    }

    return true;
  }

  bool _esOutlierPorGiro<T>(
    PuntoTrayectoria<T> a,
    PuntoTrayectoria<T> b,
    PuntoTrayectoria<T> c,
    EstadisticasTrayectoria estadisticas,
  ) {
    final angulo = _anguloGrados(a, b, c);
    if (angulo <= anguloMaximoGrados) {
      return false;
    }

    final directo = distanciaMetros(a.latitud, a.longitud, c.latitud, c.longitud);
    if (directo <= 0) {
      return false;
    }

    final porB =
        distanciaMetros(a.latitud, a.longitud, b.latitud, b.longitud) +
        distanciaMetros(b.latitud, b.longitud, c.latitud, c.longitud);

    if (porB <= directo * factorDesvioMaximo) {
      return false;
    }

    return _tramoValido(a, c, estadisticas);
  }

  double _anguloGrados<T>(
    PuntoTrayectoria<T> a,
    PuntoTrayectoria<T> b,
    PuntoTrayectoria<T> c,
  ) {
    final v1x = b.longitud - a.longitud;
    final v1y = b.latitud - a.latitud;
    final v2x = c.longitud - b.longitud;
    final v2y = c.latitud - b.latitud;

    final norma1 = math.sqrt((v1x * v1x) + (v1y * v1y));
    final norma2 = math.sqrt((v2x * v2x) + (v2y * v2y));
    if (norma1 == 0 || norma2 == 0) {
      return 0;
    }

    final coseno = ((v1x * v2x) + (v1y * v2y)) / (norma1 * norma2);
    final ajustado = coseno.clamp(-1.0, 1.0);
    return math.acos(ajustado) * (180 / math.pi);
  }

  double _media(List<double> valores) {
    if (valores.isEmpty) {
      return 0;
    }

    return valores.reduce((a, b) => a + b) / valores.length;
  }

  double _mediana(List<double> valores) {
    if (valores.isEmpty) {
      return 0;
    }

    final mitad = valores.length ~/ 2;
    if (valores.length.isOdd) {
      return valores[mitad];
    }

    return (valores[mitad - 1] + valores[mitad]) / 2;
  }

  double _percentil(List<double> valores, double percentil) {
    if (valores.isEmpty) {
      return 0;
    }

    final posicion = (valores.length - 1) * percentil;
    final inferior = posicion.floor();
    final superior = posicion.ceil();

    if (inferior == superior) {
      return valores[inferior];
    }

    final peso = posicion - inferior;
    return valores[inferior] + ((valores[superior] - valores[inferior]) * peso);
  }
}
