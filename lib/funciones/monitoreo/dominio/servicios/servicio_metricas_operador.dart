import 'dart:math' as math;

import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';

class ConfiguracionMetricasOperador {
  final List<PuntoControlDescarga> puntosDescarga;
  final double radioChuteMetros;
  final double velocidadDetenidoMaximaKmh;
  final Duration tiempoDetenidoPermitidoMinimo;
  final double tarifaHoraCargadorFrontal;
  final double tarifaHoraVolquete;
  final double velocidadMaximaCargadorKmh;
  final double velocidadMaximaVolqueteKmh;

  const ConfiguracionMetricasOperador({
    required this.puntosDescarga,
    required this.radioChuteMetros,
    required this.velocidadDetenidoMaximaKmh,
    required this.tiempoDetenidoPermitidoMinimo,
    required this.tarifaHoraCargadorFrontal,
    required this.tarifaHoraVolquete,
    required this.velocidadMaximaCargadorKmh,
    required this.velocidadMaximaVolqueteKmh,
  });

  static const porDefecto = ConfiguracionMetricasOperador(
    puntosDescarga: [
      PuntoControlDescarga(latitud: -14.667833, longitud: -69.465853),
      PuntoControlDescarga(latitud: -14.667749, longitud: -69.466246),
      PuntoControlDescarga(latitud: -14.668641, longitud: -69.466983),
      PuntoControlDescarga(latitud: -14.668801, longitud: -69.466919),
      PuntoControlDescarga(latitud: -14.669245, longitud: -69.466820),
    ],
    radioChuteMetros: 12.0,
    velocidadDetenidoMaximaKmh: 1.0,
    tiempoDetenidoPermitidoMinimo: Duration(minutes: 5),
    tarifaHoraCargadorFrontal: 200.0,
    tarifaHoraVolquete: 95.0,
    velocidadMaximaCargadorKmh: 40.0,
    velocidadMaximaVolqueteKmh: 65.0,
  );
}

class PuntoControlDescarga {
  final double latitud;
  final double longitud;

  const PuntoControlDescarga({
    required this.latitud,
    required this.longitud,
  });
}

class MetricasOperadorDiarias {
  final int ciclos;
  final double? promedioCicloMin;
  final double? modaCicloMin;
  final double? mediaCicloMin;
  final double? maxCicloMin;
  final double? minCicloMin;
  final double recorridoKm;
  final double? sobretiempoTotalMin;
  final double sobretiempoPermitidoMin;
  final double? pagoIneficiencia;
  final double? costoIneficiencia;
  final String almuerzoDesayunoInfo;
  final bool tieneMuestraSuficiente;

  const MetricasOperadorDiarias({
    required this.ciclos,
    required this.promedioCicloMin,
    required this.modaCicloMin,
    required this.mediaCicloMin,
    required this.maxCicloMin,
    required this.minCicloMin,
    required this.recorridoKm,
    required this.sobretiempoTotalMin,
    required this.sobretiempoPermitidoMin,
    required this.pagoIneficiencia,
    required this.costoIneficiencia,
    required this.almuerzoDesayunoInfo,
    required this.tieneMuestraSuficiente,
  });

  static const vacia = MetricasOperadorDiarias(
    ciclos: 0,
    promedioCicloMin: null,
    modaCicloMin: null,
    mediaCicloMin: null,
    maxCicloMin: null,
    minCicloMin: null,
    recorridoKm: 0,
    sobretiempoTotalMin: null,
    sobretiempoPermitidoMin: 0,
    pagoIneficiencia: null,
    costoIneficiencia: null,
    almuerzoDesayunoInfo: '0.0 min',
    tieneMuestraSuficiente: false,
  );
}

class ResumenMovimientoOperador {
  final double velocidadActualKmh;
  final double velocidadMaximaKmh;
  final double velocidadPromedioKmh;
  final double recorridoKm;
  final int tramosValidos;
  final int registrosValidos;

  const ResumenMovimientoOperador({
    required this.velocidadActualKmh,
    required this.velocidadMaximaKmh,
    required this.velocidadPromedioKmh,
    required this.recorridoKm,
    required this.tramosValidos,
    required this.registrosValidos,
  });

  static const vacio = ResumenMovimientoOperador(
    velocidadActualKmh: 0,
    velocidadMaximaKmh: 0,
    velocidadPromedioKmh: 0,
    recorridoKm: 0,
    tramosValidos: 0,
    registrosValidos: 0,
  );
}

class ServicioMetricasOperador {
  final LimpiadorTrayectoria _limpiador;
  final ConfiguracionMetricasOperador _config;

  const ServicioMetricasOperador({
    LimpiadorTrayectoria limpiador = const LimpiadorTrayectoria(),
    ConfiguracionMetricasOperador config =
        ConfiguracionMetricasOperador.porDefecto,
  })  : _limpiador = limpiador,
        _config = config;

  MetricasOperadorDiarias calcularMetricasDiarias({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
  }) {
    final puntos = _normalizarPuntos(puntosCrudos);
    if (puntos.isEmpty) {
      return MetricasOperadorDiarias.vacia;
    }

    final resumenMovimiento = calcularResumenMovimiento(
      equipo: equipo,
      puntosCrudos: puntosCrudos,
    );
    final llegadas = _detectarLlegadas(puntos);
    final ciclos = _construirCiclos(puntos, llegadas);
    final tieneMuestraSuficiente = ciclos.length >= 3;

    final duraciones = ciclos.map((ciclo) => ciclo.tiempoCicloMin).toList();
    final promedio = tieneMuestraSuficiente ? _promedio(duraciones) : null;
    final moda = tieneMuestraSuficiente ? _modaRedondeadaMin(duraciones) : null;
    final maximo = tieneMuestraSuficiente ? _maximo(duraciones) : null;
    final minimo = tieneMuestraSuficiente ? _minimo(duraciones) : null;

    final sobretiempoPermitidoMin = ciclos.fold<double>(
      0,
      (total, ciclo) => total + ciclo.tiempoDetenidoPermitidoMin,
    );

    double? sobretiempoTotalMin;
    double? pagoIneficiencia;
    double? costoIneficiencia;

    if (tieneMuestraSuficiente && promedio != null) {
      sobretiempoTotalMin = ciclos.fold<double>(
        0,
        (total, ciclo) {
          final exceso = math.max(
            0.0,
            ciclo.tiempoCicloMin - promedio - ciclo.tiempoDetenidoPermitidoMin,
          );
          return total + exceso;
        },
      );

      final tarifaHora = _resolverTarifaHora(equipo);
      pagoIneficiencia = (sobretiempoTotalMin / 60) * tarifaHora;
      costoIneficiencia = pagoIneficiencia;
    }

    return MetricasOperadorDiarias(
      ciclos: ciclos.length,
      promedioCicloMin: promedio,
      modaCicloMin: moda,
      mediaCicloMin: promedio,
      maxCicloMin: maximo,
      minCicloMin: minimo,
      recorridoKm: resumenMovimiento.recorridoKm,
      sobretiempoTotalMin: sobretiempoTotalMin,
      sobretiempoPermitidoMin: sobretiempoPermitidoMin,
      pagoIneficiencia: pagoIneficiencia,
      costoIneficiencia: costoIneficiencia,
      almuerzoDesayunoInfo: '${sobretiempoPermitidoMin.toStringAsFixed(1)} min',
      tieneMuestraSuficiente: tieneMuestraSuficiente,
    );
  }

  ResumenMovimientoOperador calcularResumenMovimiento({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
  }) {
    final puntosNormalizados = _normalizarPuntos(puntosCrudos);
    final registrosValidos = puntosNormalizados.length;
    if (puntosNormalizados.length < 2) {
      return ResumenMovimientoOperador(
        velocidadActualKmh: 0,
        velocidadMaximaKmh: 0,
        velocidadPromedioKmh: 0,
        recorridoKm: 0,
        tramosValidos: 0,
        registrosValidos: registrosValidos,
      );
    }

    final limpieza = _limpiador.limpiar(puntosNormalizados);
    final puntos = limpieza.puntos;
    if (puntos.length < 2) {
      return ResumenMovimientoOperador(
        velocidadActualKmh: 0,
        velocidadMaximaKmh: 0,
        velocidadPromedioKmh: 0,
        recorridoKm: 0,
        tramosValidos: 0,
        registrosValidos: registrosValidos,
      );
    }

    final velocidadMaximaPermitida = _resolverVelocidadMaximaKmh(equipo);
    var velocidadActual = 0.0;
    var velocidadMaxima = 0.0;
    var recorridoKm = 0.0;
    var sumaVelocidades = 0.0;
    var tramosValidos = 0;

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final actual = puntos[i];
      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0) continue;

      final velocidad = _limpiador.velocidadKmh(anterior, actual);
      final distancia = _limpiador.distanciaMetros(
        anterior.latitud,
        anterior.longitud,
        actual.latitud,
        actual.longitud,
      );

      if (velocidad.isNaN || velocidad.isInfinite) continue;
      if (distancia < 2) continue;
      if (velocidad > velocidadMaximaPermitida) continue;

      velocidadActual = velocidad;
      if (velocidad > velocidadMaxima) {
        velocidadMaxima = velocidad;
      }

      recorridoKm += distancia / 1000;
      sumaVelocidades += velocidad;
      tramosValidos++;
    }

    return ResumenMovimientoOperador(
      velocidadActualKmh: velocidadActual,
      velocidadMaximaKmh: velocidadMaxima,
      velocidadPromedioKmh:
          tramosValidos == 0 ? 0.0 : (sumaVelocidades / tramosValidos),
      recorridoKm: recorridoKm,
      tramosValidos: tramosValidos,
      registrosValidos: registrosValidos,
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
          !_limpiador.coordenadaEsValida(lat, lon)) {
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

  List<_EventoLlegada> _detectarLlegadas(
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
  ) {
    final llegadas = <_EventoLlegada>[];
    var dentroDeChute = false;

    for (final punto in puntos) {
      final indiceChute = _indiceChuteEnRango(punto);
      final estaDentro = indiceChute != null;

      if (estaDentro && !dentroDeChute) {
        llegadas.add(
          _EventoLlegada(
            tiempo: punto.tiempo,
            indiceChute: indiceChute,
          ),
        );
      }

      dentroDeChute = estaDentro;
    }

    return llegadas;
  }

  int? _indiceChuteEnRango(PuntoTrayectoria<Map<String, dynamic>> punto) {
    for (var i = 0; i < _config.puntosDescarga.length; i++) {
      final chute = _config.puntosDescarga[i];
      final distancia = _limpiador.distanciaMetros(
        punto.latitud,
        punto.longitud,
        chute.latitud,
        chute.longitud,
      );
      if (distancia <= _config.radioChuteMetros) {
        return i;
      }
    }
    return null;
  }

  List<_CicloOperativo> _construirCiclos(
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
    List<_EventoLlegada> llegadas,
  ) {
    final ciclos = <_CicloOperativo>[];

    for (var i = 1; i < llegadas.length; i++) {
      final llegadaAnterior = llegadas[i - 1];
      final llegadaActual = llegadas[i];
      final deltaSegundos =
          llegadaActual.tiempo.difference(llegadaAnterior.tiempo).inSeconds;

      if (deltaSegundos <= 0) continue;

      final tiempoCicloMin = deltaSegundos / 60.0;
      final tiempoDetenidoPermitidoMin = _calcularTiempoDetenidoPermitidoMin(
        puntos: puntos,
        inicio: llegadaAnterior.tiempo,
        fin: llegadaActual.tiempo,
      );

      ciclos.add(
        _CicloOperativo(
          tiempoCicloMin: tiempoCicloMin,
          tiempoDetenidoPermitidoMin: tiempoDetenidoPermitidoMin,
          chuteInicio: llegadaAnterior.indiceChute,
          chuteFin: llegadaActual.indiceChute,
        ),
      );
    }

    return ciclos;
  }

  double _calcularTiempoDetenidoPermitidoMin({
    required List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
    required DateTime inicio,
    required DateTime fin,
  }) {
    var acumuladoSegundos = 0;
    var rachaSegundos = 0;

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final actual = puntos[i];

      if (actual.tiempo.isBefore(inicio) || anterior.tiempo.isAfter(fin)) {
        continue;
      }

      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0) {
        continue;
      }

      final velocidad = _limpiador.velocidadKmh(anterior, actual);
      final estaDetenido = velocidad <= _config.velocidadDetenidoMaximaKmh;

      if (estaDetenido) {
        rachaSegundos += deltaSegundos;
      } else {
        if (rachaSegundos >=
            _config.tiempoDetenidoPermitidoMinimo.inSeconds) {
          acumuladoSegundos += rachaSegundos;
        }
        rachaSegundos = 0;
      }
    }

    if (rachaSegundos >= _config.tiempoDetenidoPermitidoMinimo.inSeconds) {
      acumuladoSegundos += rachaSegundos;
    }

    return acumuladoSegundos / 60.0;
  }

  double _promedio(List<double> valores) {
    if (valores.isEmpty) return 0;
    return valores.reduce((a, b) => a + b) / valores.length;
  }

  double _modaRedondeadaMin(List<double> valores) {
    if (valores.isEmpty) return 0;

    final frecuencias = <int, int>{};
    for (final valor in valores) {
      final llave = valor.round();
      frecuencias[llave] = (frecuencias[llave] ?? 0) + 1;
    }

    var moda = frecuencias.entries.first.key;
    var frecuenciaModa = frecuencias.entries.first.value;

    for (final entrada in frecuencias.entries.skip(1)) {
      if (entrada.value > frecuenciaModa ||
          (entrada.value == frecuenciaModa && entrada.key < moda)) {
        moda = entrada.key;
        frecuenciaModa = entrada.value;
      }
    }

    return moda.toDouble();
  }

  double _maximo(List<double> valores) {
    return valores.reduce(math.max);
  }

  double _minimo(List<double> valores) {
    return valores.reduce(math.min);
  }

  double _resolverTarifaHora(ModeloEquipo equipo) {
    final descriptor = _resolverDescriptorEquipo(equipo);

    if (descriptor.contains('CARGADOR')) {
      return _config.tarifaHoraCargadorFrontal;
    }

    if (descriptor.contains('VOLQUETE')) {
      return _config.tarifaHoraVolquete;
    }

    return _config.tarifaHoraVolquete;
  }

  double _resolverVelocidadMaximaKmh(ModeloEquipo equipo) {
    final descriptor = _resolverDescriptorEquipo(equipo);

    if (descriptor.contains('CARGADOR')) {
      return _config.velocidadMaximaCargadorKmh;
    }

    if (descriptor.contains('VOLQUETE')) {
      return _config.velocidadMaximaVolqueteKmh;
    }

    return _config.velocidadMaximaVolqueteKmh;
  }

  String _resolverDescriptorEquipo(ModeloEquipo equipo) {
    final descriptor = [
      equipo.tipoEquipo,
      equipo.nombre,
      equipo.codigo,
    ].whereType<String>().join(' ').toUpperCase();
    return descriptor;
  }
}

class _EventoLlegada {
  final DateTime tiempo;
  final int indiceChute;

  const _EventoLlegada({
    required this.tiempo,
    required this.indiceChute,
  });
}

class _CicloOperativo {
  final double tiempoCicloMin;
  final double tiempoDetenidoPermitidoMin;
  final int chuteInicio;
  final int chuteFin;

  const _CicloOperativo({
    required this.tiempoCicloMin,
    required this.tiempoDetenidoPermitidoMin,
    required this.chuteInicio,
    required this.chuteFin,
  });
}
