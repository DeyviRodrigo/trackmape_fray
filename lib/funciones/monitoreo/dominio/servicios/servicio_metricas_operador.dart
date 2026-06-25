import 'dart:math' as math;

import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';

class ConfiguracionMetricasOperador {
  final List<PuntoControlDescarga> puntosDescarga;
  final List<PuntoControlCarga> puntosCarga;
  final int frecuenciaBaseSegundos;
  final int gapMaximoRecuperableSegundos;
  final double radioEntradaCargaMetros;
  final double radioSalidaCargaMetros;
  final double radioEntradaChuteMetros;
  final double radioSalidaChuteMetros;
  final Duration separacionMinimaEventoOperacion;
  final double velocidadDetenidoMaximaKmh;
  final Duration tiempoDetenidoPermitidoMinimo;
  final double tarifaHoraCargadorFrontal;
  final double tarifaHoraVolquete;
  final double velocidadMaximaCargadorKmh;
  final double velocidadMaximaVolqueteKmh;

  const ConfiguracionMetricasOperador({
    required this.puntosDescarga,
    required this.puntosCarga,
    required this.frecuenciaBaseSegundos,
    required this.gapMaximoRecuperableSegundos,
    required this.radioEntradaCargaMetros,
    required this.radioSalidaCargaMetros,
    required this.radioEntradaChuteMetros,
    required this.radioSalidaChuteMetros,
    required this.separacionMinimaEventoOperacion,
    required this.velocidadDetenidoMaximaKmh,
    required this.tiempoDetenidoPermitidoMinimo,
    required this.tarifaHoraCargadorFrontal,
    required this.tarifaHoraVolquete,
    required this.velocidadMaximaCargadorKmh,
    required this.velocidadMaximaVolqueteKmh,
  });

  double get radioChuteMetros => radioEntradaChuteMetros;
  double get radioCargaMetros => radioEntradaCargaMetros;

  static const porDefecto = ConfiguracionMetricasOperador(
    puntosDescarga: [],
    puntosCarga: [],
    frecuenciaBaseSegundos: 5,
    gapMaximoRecuperableSegundos: 20,
    radioEntradaCargaMetros: 0.0,
    radioSalidaCargaMetros: 0.0,
    radioEntradaChuteMetros: 0.0,
    radioSalidaChuteMetros: 0.0,
    separacionMinimaEventoOperacion: Duration(minutes: 1),
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

class PuntoControlCarga {
  final double latitud;
  final double longitud;

  const PuntoControlCarga({
    required this.latitud,
    required this.longitud,
  });
}

class MetricasOperadorDiarias {
  final int ciclos;
  final int llegadasDetectadas;
  final int entradasCarga;
  final int llegadasDescarga;
  final int cantidadChutes;
  final int cantidadPuntosCarga;
  final double radioEntradaCargaMetros;
  final double radioSalidaCargaMetros;
  final double radioEntradaChuteMetros;
  final double radioSalidaChuteMetros;
  final double radioChuteMetros;
  final double? promedioCicloMin;
  final double? modaCicloMin;
  final double? mediaCicloMin;
  final double? maxCicloMin;
  final double? minCicloMin;
  final double recorridoKm;
  final double? tiempoPerdidoAlteracionMin;
  final double? sobretiempoTotalMin;
  final double sobretiempoPermitidoMin;
  final double? pagoIneficiencia;
  final double? costoIneficiencia;
  final String almuerzoDesayunoInfo;
  final bool tieneMuestraSuficiente;

  const MetricasOperadorDiarias({
    required this.ciclos,
    required this.llegadasDetectadas,
    required this.entradasCarga,
    required this.llegadasDescarga,
    required this.cantidadChutes,
    required this.cantidadPuntosCarga,
    required this.radioEntradaCargaMetros,
    required this.radioSalidaCargaMetros,
    required this.radioEntradaChuteMetros,
    required this.radioSalidaChuteMetros,
    required this.radioChuteMetros,
    required this.promedioCicloMin,
    required this.modaCicloMin,
    required this.mediaCicloMin,
    required this.maxCicloMin,
    required this.minCicloMin,
    required this.recorridoKm,
    required this.tiempoPerdidoAlteracionMin,
    required this.sobretiempoTotalMin,
    required this.sobretiempoPermitidoMin,
    required this.pagoIneficiencia,
    required this.costoIneficiencia,
    required this.almuerzoDesayunoInfo,
    required this.tieneMuestraSuficiente,
  });

  static const vacia = MetricasOperadorDiarias(
    ciclos: 0,
    llegadasDetectadas: 0,
    entradasCarga: 0,
    llegadasDescarga: 0,
    cantidadChutes: 0,
    cantidadPuntosCarga: 0,
    radioEntradaCargaMetros: 0,
    radioSalidaCargaMetros: 0,
    radioEntradaChuteMetros: 0,
    radioSalidaChuteMetros: 0,
    radioChuteMetros: 0,
    promedioCicloMin: null,
    modaCicloMin: null,
    mediaCicloMin: null,
    maxCicloMin: null,
    minCicloMin: null,
    recorridoKm: 0,
    tiempoPerdidoAlteracionMin: null,
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

class ResultadoProcesadoOperador {
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosNormalizados;
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosReales;
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosReconstruidos;
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosCombinados;
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosLimpios;
  final List<List<PuntoTrayectoria<Map<String, dynamic>>>> segmentosOperativos;
  final List<List<PuntoTrayectoria<Map<String, dynamic>>>> segmentosReconstruidos;
  final int conteoPuntosSinteticos;
  final int conteoSaltosDescartados;
  final ResumenMovimientoOperador resumenMovimiento;
  final MetricasOperadorDiarias metricas;
  final AuditoriaOperacion auditoriaOperacion;

  const ResultadoProcesadoOperador({
    required this.puntosNormalizados,
    required this.puntosReales,
    required this.puntosReconstruidos,
    required this.puntosCombinados,
    required this.puntosLimpios,
    required this.segmentosOperativos,
    required this.segmentosReconstruidos,
    required this.conteoPuntosSinteticos,
    required this.conteoSaltosDescartados,
    required this.resumenMovimiento,
    required this.metricas,
    required this.auditoriaOperacion,
  });

  List<PuntoTrayectoria<Map<String, dynamic>>> get puntosCrudosValidos =>
      puntosNormalizados;
  List<List<PuntoTrayectoria<Map<String, dynamic>>>> get segmentosAnaliticos =>
      segmentosOperativos;
  MetricasOperadorDiarias get metricasOperativas => metricas;

  static const vacio = ResultadoProcesadoOperador(
    puntosNormalizados: [],
    puntosReales: [],
    puntosReconstruidos: [],
    puntosCombinados: [],
    puntosLimpios: [],
    segmentosOperativos: [],
    segmentosReconstruidos: [],
    conteoPuntosSinteticos: 0,
    conteoSaltosDescartados: 0,
    resumenMovimiento: ResumenMovimientoOperador.vacio,
    metricas: MetricasOperadorDiarias.vacia,
    auditoriaOperacion: AuditoriaOperacion.vacia,
  );
}

class AuditoriaOperacion {
  final int cargasSinCierre;
  final int descargasSinCargaPrevia;
  final int ciclosRecuperadosPorInterpolacion;
  final int gapsLargos;
  final int outliersDuracion;

  const AuditoriaOperacion({
    required this.cargasSinCierre,
    required this.descargasSinCargaPrevia,
    required this.ciclosRecuperadosPorInterpolacion,
    required this.gapsLargos,
    required this.outliersDuracion,
  });

  static const vacia = AuditoriaOperacion(
    cargasSinCierre: 0,
    descargasSinCargaPrevia: 0,
    ciclosRecuperadosPorInterpolacion: 0,
    gapsLargos: 0,
    outliersDuracion: 0,
  );
}

class ServicioMetricasOperador {
  final LimpiadorTrayectoria _limpiador;
  final ConfiguracionMetricasOperador _config;
  static const Duration _ttlResultadoProcesado = Duration(minutes: 5);
  static final Map<String, _CacheResultadoProcesado> _cacheResultados = {};

  const ServicioMetricasOperador({
    LimpiadorTrayectoria limpiador = const LimpiadorTrayectoria(),
    ConfiguracionMetricasOperador config =
        ConfiguracionMetricasOperador.porDefecto,
  })  : _limpiador = limpiador,
        _config = config;

  ResultadoProcesadoOperador procesarDatosUnidad({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
  }) {
    final puntosNormalizados = _normalizarPuntos(puntosCrudos);
    if (puntosNormalizados.isEmpty) {
      return ResultadoProcesadoOperador.vacio;
    }

    final cacheKey = _construirClaveCache(equipo, puntosNormalizados);
    final cache = _cacheResultados[cacheKey];
    if (cache != null && !cache.expirado(_ttlResultadoProcesado)) {
      return cache.resultado;
    }

    final reconstruccion = _reconstruirTrayectoria(
      puntosNormalizados: puntosNormalizados,
    );
    final puntosCombinados = reconstruccion.puntosCombinados;
    final segmentosReconstruidos = _segmentarPuntosReconstruidos(
      equipo,
      puntosCombinados,
    );
    final puntosVisibles = _compactarSegmentos(segmentosReconstruidos);
    final segmentosOperativos = _segmentarPuntosOperativos(
      equipo,
      puntosCombinados,
    );
    final resumenMovimiento = _calcularResumenDesdeSegmentos(
      segmentosOperativos,
      registrosValidos: puntosNormalizados.length,
    );
    final resultadoMetricas = _calcularMetricasDesdePuntos(
      equipo: equipo,
      puntosOperacion: puntosCombinados,
      resumenMovimiento: resumenMovimiento,
      gapsLargos: reconstruccion.saltosDescartados,
    );

    final resultado = ResultadoProcesadoOperador(
      puntosNormalizados: puntosNormalizados,
      puntosReales: puntosNormalizados,
      puntosReconstruidos: reconstruccion.puntosReconstruidos,
      puntosCombinados: puntosCombinados,
      puntosLimpios: puntosVisibles,
      segmentosOperativos: segmentosOperativos,
      segmentosReconstruidos: segmentosReconstruidos,
      conteoPuntosSinteticos: puntosVisibles
          .where((punto) => punto.payload['__interpolado'] == true)
          .length,
      conteoSaltosDescartados: reconstruccion.saltosDescartados +
          _contarSaltosDescartados(
            puntosCombinados.length,
            puntosVisibles.length,
          ),
      resumenMovimiento: resumenMovimiento,
      metricas: resultadoMetricas.metricas,
      auditoriaOperacion: resultadoMetricas.auditoria,
    );
    _cacheResultados[cacheKey] = _CacheResultadoProcesado(resultado);
    return resultado;
  }

  MetricasOperadorDiarias calcularMetricasDiarias({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
  }) {
    return procesarDatosUnidad(
      equipo: equipo,
      puntosCrudos: puntosCrudos,
    ).metricas;
  }

  ResumenMovimientoOperador calcularResumenMovimiento({
    required ModeloEquipo equipo,
    required List<Map<String, dynamic>> puntosCrudos,
  }) {
    return procesarDatosUnidad(
      equipo: equipo,
      puntosCrudos: puntosCrudos,
    ).resumenMovimiento;
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

  _ResultadoReconstruccion _reconstruirTrayectoria({
    required List<PuntoTrayectoria<Map<String, dynamic>>> puntosNormalizados,
  }) {
    if (puntosNormalizados.isEmpty) {
      return const _ResultadoReconstruccion(
        puntosCombinados: [],
        puntosReconstruidos: [],
        saltosDescartados: 0,
      );
    }

    final puntosCombinados = <PuntoTrayectoria<Map<String, dynamic>>>[
      puntosNormalizados.first,
    ];
    final puntosReconstruidos = <PuntoTrayectoria<Map<String, dynamic>>>[];
    var saltosDescartados = 0;

    for (var i = 1; i < puntosNormalizados.length; i++) {
      final anterior = puntosNormalizados[i - 1];
      final actual = puntosNormalizados[i];
      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;

      if (deltaSegundos <= 0) {
        saltosDescartados++;
        continue;
      }

      if (deltaSegundos > _config.gapMaximoRecuperableSegundos) {
        saltosDescartados++;
        puntosCombinados.add(actual);
        continue;
      }

      if (deltaSegundos > _config.frecuenciaBaseSegundos) {
        final cantidadIntermedios =
            (deltaSegundos ~/ _config.frecuenciaBaseSegundos) - 1;

        for (var paso = 1; paso <= cantidadIntermedios; paso++) {
          final fraccion =
              (paso * _config.frecuenciaBaseSegundos) / deltaSegundos;
          final tiempoInterpolado = anterior.tiempo.add(
            Duration(seconds: paso * _config.frecuenciaBaseSegundos),
          );
          final latInterpolada =
              anterior.latitud + ((actual.latitud - anterior.latitud) * fraccion);
          final lonInterpolada = anterior.longitud +
              ((actual.longitud - anterior.longitud) * fraccion);

          final payload = <String, dynamic>{
            ...actual.payload,
            'lat_grados': latInterpolada,
            'lon_grados': lonInterpolada,
            'tiempo': tiempoInterpolado.toIso8601String(),
            '__interpolado': true,
          };

          final sintetico = PuntoTrayectoria<Map<String, dynamic>>(
            latitud: latInterpolada,
            longitud: lonInterpolada,
            tiempo: tiempoInterpolado,
            payload: payload,
          );
          puntosReconstruidos.add(sintetico);
          puntosCombinados.add(sintetico);
        }
      }

      puntosCombinados.add(actual);
    }

    return _ResultadoReconstruccion(
      puntosCombinados: puntosCombinados,
      puntosReconstruidos: puntosReconstruidos,
      saltosDescartados: saltosDescartados,
    );
  }

  List<List<PuntoTrayectoria<Map<String, dynamic>>>> _segmentarPuntosReconstruidos(
    ModeloEquipo equipo,
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
  ) {
    if (puntos.length < 2) return const [];

    final segmentos = <List<PuntoTrayectoria<Map<String, dynamic>>>>[];
    List<PuntoTrayectoria<Map<String, dynamic>>> actual = [puntos.first];
    final velocidadMaximaVisual = _resolverVelocidadVisualMaximaKmh(equipo);

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final siguiente = puntos[i];
      final deltaSegundos = siguiente.tiempo.difference(anterior.tiempo).inSeconds;
      final distancia = _limpiador.distanciaMetros(
        anterior.latitud,
        anterior.longitud,
        siguiente.latitud,
        siguiente.longitud,
      );
      final velocidad = _limpiador.velocidadKmh(anterior, siguiente);

      final esGapInvalido =
          deltaSegundos <= 0 ||
          deltaSegundos > _config.gapMaximoRecuperableSegundos;
      final esSaltoVisualAbsurdo =
          distancia > 1 &&
          (velocidad.isNaN ||
              velocidad.isInfinite ||
              velocidad > velocidadMaximaVisual);

      if (esGapInvalido || esSaltoVisualAbsurdo) {
        if (actual.length >= 2) {
          segmentos.add(actual);
        }
        actual = [siguiente];
        continue;
      }

      actual.add(siguiente);
    }

    if (actual.length >= 2) {
      segmentos.add(actual);
    }

    return segmentos;
  }

  List<PuntoTrayectoria<Map<String, dynamic>>> _compactarSegmentos(
    List<List<PuntoTrayectoria<Map<String, dynamic>>>> segmentos,
  ) {
    final puntos = <PuntoTrayectoria<Map<String, dynamic>>>[];

    for (final segmento in segmentos) {
      for (final punto in segmento) {
        if (puntos.isEmpty || !_esMismoPunto(puntos.last, punto)) {
          puntos.add(punto);
        }
      }
    }

    return puntos;
  }

  int _contarSaltosDescartados(int totalPuntos, int puntosVisibles) {
    final descartados = totalPuntos - puntosVisibles;
    return descartados < 0 ? 0 : descartados;
  }

  List<List<PuntoTrayectoria<Map<String, dynamic>>>> _segmentarPuntosOperativos(
    ModeloEquipo equipo,
    List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
  ) {
    if (puntos.length < 2) return const [];

    final velocidadMaximaPermitida = _resolverVelocidadMaximaKmh(equipo);
    final segmentos = <List<PuntoTrayectoria<Map<String, dynamic>>>>[];
    List<PuntoTrayectoria<Map<String, dynamic>>> actual = [];

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final siguiente = puntos[i];
      final deltaSegundos = siguiente.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0 ||
          deltaSegundos > _config.gapMaximoRecuperableSegundos) {
        if (actual.length >= 2) segmentos.add(actual);
        actual = [siguiente];
        continue;
      }

      final velocidad = _limpiador.velocidadKmh(anterior, siguiente);
      final distancia = _limpiador.distanciaMetros(
        anterior.latitud,
        anterior.longitud,
        siguiente.latitud,
        siguiente.longitud,
      );

      final esTramoValido = !velocidad.isNaN &&
          !velocidad.isInfinite &&
          distancia >= 2 &&
          velocidad <= velocidadMaximaPermitida;

      if (!esTramoValido) {
        if (actual.length >= 2) segmentos.add(actual);
        actual = [];
        continue;
      }

      if (actual.isEmpty) {
        actual = [anterior, siguiente];
      } else if (!_esMismoPunto(actual.last, siguiente)) {
        actual.add(siguiente);
      }
    }

    if (actual.length >= 2) {
      segmentos.add(actual);
    }

    return segmentos;
  }

  ResumenMovimientoOperador _calcularResumenDesdeSegmentos(
    List<List<PuntoTrayectoria<Map<String, dynamic>>>> segmentos, {
    required int registrosValidos,
  }) {
    if (segmentos.isEmpty) {
      return ResumenMovimientoOperador(
        velocidadActualKmh: 0,
        velocidadMaximaKmh: 0,
        velocidadPromedioKmh: 0,
        recorridoKm: 0,
        tramosValidos: 0,
        registrosValidos: registrosValidos,
      );
    }

    var velocidadActual = 0.0;
    var velocidadMaxima = 0.0;
    var recorridoKm = 0.0;
    var sumaVelocidades = 0.0;
    var tramosValidos = 0;

    for (final segmento in segmentos) {
      for (var i = 1; i < segmento.length; i++) {
        final anterior = segmento[i - 1];
        final actual = segmento[i];
        final velocidad = _limpiador.velocidadKmh(anterior, actual);
        final distancia = _limpiador.distanciaMetros(
          anterior.latitud,
          anterior.longitud,
          actual.latitud,
          actual.longitud,
        );

        velocidadActual = velocidad;
        if (velocidad > velocidadMaxima) {
          velocidadMaxima = velocidad;
        }

        recorridoKm += distancia / 1000;
        sumaVelocidades += velocidad;
        tramosValidos++;
      }
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

  _ResultadoMetricas _calcularMetricasDesdePuntos({
    required ModeloEquipo equipo,
    required List<PuntoTrayectoria<Map<String, dynamic>>> puntosOperacion,
    required ResumenMovimientoOperador resumenMovimiento,
    required int gapsLargos,
  }) {
    if (puntosOperacion.isEmpty) {
      return const _ResultadoMetricas(
        metricas: MetricasOperadorDiarias.vacia,
        auditoria: AuditoriaOperacion.vacia,
      );
    }

    final operacion = _detectarOperacionCargaDescarga(
      equipo: equipo,
      puntos: puntosOperacion,
    );
    final ciclos = operacion.ciclos;
    final tieneMuestraSuficiente = ciclos.isNotEmpty;

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
    double? tiempoPerdidoAlteracionMin;
    double? pagoIneficiencia;
    double? costoIneficiencia;

    if (tieneMuestraSuficiente && promedio != null) {
      final sobretiempoBrutoMin = ciclos.fold<double>(
        0,
        (total, ciclo) {
          final exceso = math.max(
            0.0,
            ciclo.tiempoCicloMin - promedio,
          );
          return total + exceso;
        },
      );
      tiempoPerdidoAlteracionMin = ciclos.fold<double>(
        0,
        (total, ciclo) {
          final exceso = math.max(
            0.0,
            ciclo.tiempoCicloMin - promedio - ciclo.tiempoDetenidoPermitidoMin,
          );
          return total + exceso;
        },
      );
      sobretiempoTotalMin = math.max(
        0.0,
        sobretiempoBrutoMin - sobretiempoPermitidoMin,
      );

      final tarifaHora = _resolverTarifaHora(equipo);
      pagoIneficiencia = (sobretiempoTotalMin / 60) * tarifaHora;
      costoIneficiencia = pagoIneficiencia;
    }

    final metricas = MetricasOperadorDiarias(
      ciclos: ciclos.length,
      llegadasDetectadas: operacion.llegadasDescarga,
      entradasCarga: operacion.entradasCarga,
      llegadasDescarga: operacion.llegadasDescarga,
      cantidadChutes: _config.puntosDescarga.length,
      cantidadPuntosCarga: _config.puntosCarga.length,
      radioEntradaCargaMetros: _config.radioEntradaCargaMetros,
      radioSalidaCargaMetros: _config.radioSalidaCargaMetros,
      radioEntradaChuteMetros: _config.radioEntradaChuteMetros,
      radioSalidaChuteMetros: _config.radioSalidaChuteMetros,
      radioChuteMetros: _config.radioChuteMetros,
      promedioCicloMin: promedio,
      modaCicloMin: moda,
      mediaCicloMin: promedio,
      maxCicloMin: maximo,
      minCicloMin: minimo,
      recorridoKm: resumenMovimiento.recorridoKm,
      tiempoPerdidoAlteracionMin: tiempoPerdidoAlteracionMin,
      sobretiempoTotalMin: sobretiempoTotalMin,
      sobretiempoPermitidoMin: sobretiempoPermitidoMin,
      pagoIneficiencia: pagoIneficiencia,
      costoIneficiencia: costoIneficiencia,
      almuerzoDesayunoInfo: '${sobretiempoPermitidoMin.toStringAsFixed(1)} min',
      tieneMuestraSuficiente: tieneMuestraSuficiente,
    );
    final auditoria = AuditoriaOperacion(
      cargasSinCierre: operacion.cargasSinCierre,
      descargasSinCargaPrevia: operacion.descargasSinCargaPrevia,
      ciclosRecuperadosPorInterpolacion: operacion.ciclosRecuperadosPorInterpolacion,
      gapsLargos: gapsLargos,
      outliersDuracion: ciclos
          .where((ciclo) => ciclo.tiempoCicloMin >= 40)
          .length,
    );

    return _ResultadoMetricas(
      metricas: metricas,
      auditoria: auditoria,
    );
  }

  bool _esMismoPunto(
    PuntoTrayectoria<Map<String, dynamic>> a,
    PuntoTrayectoria<Map<String, dynamic>> b,
  ) {
    return a.tiempo == b.tiempo &&
        a.latitud == b.latitud &&
        a.longitud == b.longitud;
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

  double _resolverVelocidadVisualMaximaKmh(ModeloEquipo equipo) {
    final descriptor = _resolverDescriptorEquipo(equipo);

    if (descriptor.contains('CARGADOR')) {
      return 55.0;
    }

    if (descriptor.contains('VOLQUETE')) {
      return 90.0;
    }

    return 90.0;
  }

  String _resolverDescriptorEquipo(ModeloEquipo equipo) {
    final descriptor = [
      equipo.tipoEquipo,
      equipo.nombre,
      equipo.codigo,
    ].whereType<String>().join(' ').toUpperCase();
    return descriptor;
  }

  bool _esVolquete(ModeloEquipo equipo) {
    return _resolverDescriptorEquipo(equipo).contains('VOLQUETE');
  }

  _ResultadoOperacion _detectarOperacionCargaDescarga({
    required ModeloEquipo equipo,
    required List<PuntoTrayectoria<Map<String, dynamic>>> puntos,
  }) {
    if (!_esVolquete(equipo) || puntos.isEmpty) {
      return const _ResultadoOperacion(
        entradasCarga: 0,
        llegadasDescarga: 0,
        cargasSinCierre: 0,
        descargasSinCargaPrevia: 0,
        ciclosRecuperadosPorInterpolacion: 0,
        ciclos: [],
      );
    }

    var entradasCarga = 0;
    var llegadasDescarga = 0;
    var cargasSinCierre = 0;
    var descargasSinCargaPrevia = 0;
    var ciclosRecuperadosPorInterpolacion = 0;
    final ciclos = <_CicloOperativo>[];
    final cargasArmadas = <DateTime>[];

    var dentroCarga = false;
    int? chuteActual;
    DateTime? ultimoTiempo;
    DateTime? ultimaCargaRegistrada;
    DateTime? ultimaDescargaRegistrada;

    for (final punto in puntos) {
      if (ultimoTiempo != null) {
        final deltaSegundos = punto.tiempo.difference(ultimoTiempo).inSeconds;
        if (deltaSegundos > _config.gapMaximoRecuperableSegundos) {
          dentroCarga = false;
          chuteActual = null;
        }
      }

      final indiceCarga = _indiceCargaEnRango(
        punto,
        radioMetros: dentroCarga
            ? _config.radioSalidaCargaMetros
            : _config.radioEntradaCargaMetros,
      );

      if (!dentroCarga && indiceCarga != null) {
        final puedeRegistrarCarga =
            ultimaCargaRegistrada == null ||
            punto.tiempo.difference(ultimaCargaRegistrada) >=
                _config.separacionMinimaEventoOperacion;

        if (!puedeRegistroEvento(
          puedeRegistrar: puedeRegistrarCarga,
          punto: punto,
          ultimoTiempoEvento: ultimaCargaRegistrada,
        )) {
          dentroCarga = true;
          chuteActual = null;
          ultimoTiempo = punto.tiempo;
          continue;
        }

        dentroCarga = true;
        entradasCarga++;
        if (cargasArmadas.isNotEmpty) {
          cargasSinCierre += cargasArmadas.length;
          cargasArmadas.clear();
        }
        cargasArmadas.add(punto.tiempo);
        ultimaCargaRegistrada = punto.tiempo;
        chuteActual = null;
      } else if (dentroCarga && indiceCarga == null) {
        dentroCarga = false;
      }

      final indiceDescarga = _indiceChuteEnRango(
        punto,
        radioMetros: chuteActual != null
            ? _config.radioSalidaChuteMetros
            : _config.radioEntradaChuteMetros,
      );

      final entraPrimeraDescarga = indiceDescarga != null && chuteActual == null;
      final cambiaDeChute =
          indiceDescarga != null && chuteActual != null && chuteActual != indiceDescarga;

      if (entraPrimeraDescarga || cambiaDeChute) {
        final puedeRegistrarDescarga =
            ultimaDescargaRegistrada == null ||
            punto.tiempo.difference(ultimaDescargaRegistrada) >=
                _config.separacionMinimaEventoOperacion;

        if (!puedeRegistroEvento(
          puedeRegistrar: puedeRegistrarDescarga,
          punto: punto,
          ultimoTiempoEvento: ultimaDescargaRegistrada,
        )) {
          chuteActual = indiceDescarga;
          ultimoTiempo = punto.tiempo;
          continue;
        }

        llegadasDescarga++;
        ultimaDescargaRegistrada = punto.tiempo;

        if (cargasArmadas.isNotEmpty) {
          final tiempoInicioCiclo = cargasArmadas.removeLast();
          final usoInterpolacion = puntos.any(
            (p) =>
                p.payload['__interpolado'] == true &&
                !p.tiempo.isBefore(tiempoInicioCiclo) &&
                !p.tiempo.isAfter(punto.tiempo),
          );
          final tiempoCicloMin =
              punto.tiempo.difference(tiempoInicioCiclo).inSeconds / 60.0;
          if (tiempoCicloMin > 0) {
            final tiempoDetenidoPermitidoMin = _calcularTiempoDetenidoPermitidoMin(
              puntos: puntos,
              inicio: tiempoInicioCiclo,
              fin: punto.tiempo,
            );

            ciclos.add(
              _CicloOperativo(
                tiempoCicloMin: tiempoCicloMin,
                tiempoDetenidoPermitidoMin: tiempoDetenidoPermitidoMin,
                chuteInicio: indiceDescarga!,
                chuteFin: indiceDescarga,
              ),
            );
            if (usoInterpolacion) {
              ciclosRecuperadosPorInterpolacion++;
            }
          }
        } else {
          descargasSinCargaPrevia++;
        }
      }

      chuteActual = indiceDescarga;
      ultimoTiempo = punto.tiempo;
    }

    cargasSinCierre = cargasArmadas.length;

    return _ResultadoOperacion(
      entradasCarga: entradasCarga,
      llegadasDescarga: llegadasDescarga,
      cargasSinCierre: cargasSinCierre,
      descargasSinCargaPrevia: descargasSinCargaPrevia,
      ciclosRecuperadosPorInterpolacion: ciclosRecuperadosPorInterpolacion,
      ciclos: ciclos,
    );
  }

  int? _indiceCargaEnRango(
    PuntoTrayectoria<Map<String, dynamic>> punto, {
    required double radioMetros,
  }) {
    for (var i = 0; i < _config.puntosCarga.length; i++) {
      final carga = _config.puntosCarga[i];
      final distancia = _limpiador.distanciaMetros(
        punto.latitud,
        punto.longitud,
        carga.latitud,
        carga.longitud,
      );
      if (distancia <= radioMetros) {
        return i;
      }
    }
    return null;
  }

  int? _indiceChuteEnRango(
    PuntoTrayectoria<Map<String, dynamic>> punto, {
    required double radioMetros,
  }) {
    for (var i = 0; i < _config.puntosDescarga.length; i++) {
      final chute = _config.puntosDescarga[i];
      final distancia = _limpiador.distanciaMetros(
        punto.latitud,
        punto.longitud,
        chute.latitud,
        chute.longitud,
      );
      if (distancia <= radioMetros) {
        return i;
      }
    }
    return null;
  }

  bool puedeRegistroEvento({
    required bool puedeRegistrar,
    required PuntoTrayectoria<Map<String, dynamic>> punto,
    required DateTime? ultimoTiempoEvento,
  }) {
    if (puedeRegistrar) return true;
    if (ultimoTiempoEvento == null) return true;
    return punto.tiempo.difference(ultimoTiempoEvento) >=
        _config.separacionMinimaEventoOperacion;
  }

  String _construirClaveCache(
    ModeloEquipo equipo,
    List<PuntoTrayectoria<Map<String, dynamic>>> puntosNormalizados,
  ) {
    final primero = puntosNormalizados.first.tiempo.toIso8601String();
    final ultimo = puntosNormalizados.last.tiempo.toIso8601String();
    return '${equipo.id}|${puntosNormalizados.length}|$primero|$ultimo';
  }
}

class _CacheResultadoProcesado {
  final ResultadoProcesadoOperador resultado;
  final DateTime creadoEn;

  _CacheResultadoProcesado(this.resultado) : creadoEn = DateTime.now();

  bool expirado(Duration ttl) => DateTime.now().difference(creadoEn) > ttl;
}

class _ResultadoReconstruccion {
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosCombinados;
  final List<PuntoTrayectoria<Map<String, dynamic>>> puntosReconstruidos;
  final int saltosDescartados;

  const _ResultadoReconstruccion({
    required this.puntosCombinados,
    required this.puntosReconstruidos,
    required this.saltosDescartados,
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

class _ResultadoOperacion {
  final int entradasCarga;
  final int llegadasDescarga;
  final int cargasSinCierre;
  final int descargasSinCargaPrevia;
  final int ciclosRecuperadosPorInterpolacion;
  final List<_CicloOperativo> ciclos;

  const _ResultadoOperacion({
    required this.entradasCarga,
    required this.llegadasDescarga,
    required this.cargasSinCierre,
    required this.descargasSinCargaPrevia,
    required this.ciclosRecuperadosPorInterpolacion,
    required this.ciclos,
  });
}

class _ResultadoMetricas {
  final MetricasOperadorDiarias metricas;
  final AuditoriaOperacion auditoria;

  const _ResultadoMetricas({
    required this.metricas,
    required this.auditoria,
  });
}
