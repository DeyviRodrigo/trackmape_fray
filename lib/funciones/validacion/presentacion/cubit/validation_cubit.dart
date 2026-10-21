import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/equipo_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/punto_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/repositorios/repositorio_rendimiento_operacional.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/servicios/procesador_rendimiento_operacional.dart';

import 'validation_state.dart';

class ValidationCubit extends Cubit<ValidationState> {
  ValidationCubit()
      : _repositorio = RepositorioRendimientoOperacional(),
        _procesador = const ProcesadorRendimientoOperacional(),
        super(ValidationState.initial());

  final RepositorioRendimientoOperacional _repositorio;
  final ProcesadorRendimientoOperacional _procesador;

  static const double _velocidadVerdeMaxima = 18.0;
  static const double _velocidadNaranjaMaxima = 30.0;
  static const double _velocidadRojaMaxima = 40.0;
  static const double _saltoFactorPromedioMovil = 3.0;
  static const double _saltoAceleracionMaxima = 15.0;
  static const double _velocidadAltaInconsistente = 40.0;
  static const double _distanciaAbsurdaMetros = 300.0;

  Future<void> cargarEquipos() async {
    emit(
      state.copyWith(
        status: ValidationStatus.loading,
        cargandoEquipo: false,
        clearError: true,
      ),
    );

    try {
      final equipos = await _repositorio.obtenerEquiposDisponibles();
      final filtrados = equipos
          .where((equipo) => equipo.codigoEquipoControl.trim().startsWith('!'))
          .toList();

      emit(
        state.copyWith(
          status: ValidationStatus.success,
          equipos: filtrados,
          equipoSeleccionadoId:
              filtrados.isNotEmpty ? filtrados.first.idEquipoControl : null,
          puntos: const [],
          segmentos: const [],
          segmentoSeleccionado: null,
          detalles: const [],
          totalRegistrosBrutos: 0,
          totalRegistrosValidos: 0,
          tramosDescartados: 0,
          velocidadCorregidaPromedioKmh: 0,
          cargandoEquipo: false,
          clearError: true,
          clearResumen: true,
        ),
      );

      if (filtrados.isNotEmpty) {
        await cargarRendimiento();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ValidationStatus.failure,
          cargandoEquipo: false,
          error: 'No se pudo cargar equipos_control: $e',
        ),
      );
    }
  }

  Future<void> cambiarFecha(DateTime fecha) async {
    emit(
      state.copyWith(
        fechaSeleccionada: fecha,
      ),
    );
    await cargarRendimiento();
  }

  Future<void> seleccionarEquipo(String? equipoId) async {
    if (equipoId == null || equipoId.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        equipoSeleccionadoId: equipoId,
      ),
    );
    await cargarRendimiento();
  }

  Future<void> cargarRendimiento() async {
    final equipo = state.equipoSeleccionado;
    if (equipo == null) {
      return;
    }

    emit(
      state.copyWith(
        status: ValidationStatus.success,
        cargandoEquipo: true,
        clearError: true,
        clearResumen: true,
      ),
    );

    try {
      final puntosCrudos = await _repositorio.obtenerPuntosPorEquipoYFecha(
        equipo: equipo,
        fecha: state.fechaSeleccionada,
      );

      final puntosCrudosValidos = puntosCrudos.where(_coordenadaEsValida).toList()
        ..sort((a, b) => a.tiempo.compareTo(b.tiempo));
      final procesamiento = _processFilteredSegments(puntosCrudosValidos);
      final segmentos = procesamiento.segmentos;
      final detalles = _construirDetalles(segmentos);
      final resumen = _procesador.procesar(puntosCrudosValidos);

      emit(
        state.copyWith(
          status: ValidationStatus.success,
          puntos: puntosCrudosValidos,
          segmentos: segmentos,
          segmentoSeleccionado: segmentos.isNotEmpty ? segmentos.first : null,
          detalles: detalles.reversed.toList(),
          resumen: resumen,
          totalRegistrosBrutos: puntosCrudos.length,
          totalRegistrosValidos: puntosCrudosValidos.length,
          tramosDescartados: procesamiento.tramosDescartados,
          velocidadCorregidaPromedioKmh: procesamiento.velocidadCorregidaPromedioKmh,
          cargandoEquipo: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ValidationStatus.failure,
          cargandoEquipo: false,
          error: 'No se pudo cargar el rendimiento del equipo: $e',
        ),
      );
    }
  }

  void seleccionarSegmento(SegmentoTrayectoria segmento) {
    emit(
      state.copyWith(
        segmentoSeleccionado: segmento,
      ),
    );
  }

  void seleccionarSegmentoMasCercano({
    required double latitud,
    required double longitud,
  }) {
    if (state.segmentos.isEmpty) {
      return;
    }

    SegmentoTrayectoria? mejor;
    double? mejorDistancia;

    for (final segmento in state.segmentos.where((item) => item.esVisible)) {
      final distancia = _distanciaPuntoASegmentoMetros(
        latitud: latitud,
        longitud: longitud,
        latitudInicio: segmento.latitudInicioDibujo,
        longitudInicio: segmento.longitudInicioDibujo,
        latitudFin: segmento.latitudFinDibujo,
        longitudFin: segmento.longitudFinDibujo,
      );

      if (mejorDistancia == null || distancia < mejorDistancia) {
        mejorDistancia = distancia;
        mejor = segmento;
      }
    }

    if (mejor != null && mejorDistancia != null && mejorDistancia <= 25.0) {
      seleccionarSegmento(mejor);
    }
  }

  List<PuntoRendimientoDetallado> _construirDetalles(
    List<SegmentoTrayectoria> segmentos,
  ) {
    if (segmentos.isEmpty) {
      return const [];
    }

    final detalles = <PuntoRendimientoDetallado>[];

    for (final segmento in segmentos) {
      detalles.add(
        PuntoRendimientoDetallado(
          tiempoInicio: segmento.inicio.tiempo,
          punto: segmento.fin,
          velocidadKmh: segmento.velocidadKmh,
          distanciaMetros: segmento.distanciaMetros,
          deltaSegundos: segmento.deltaSegundos,
          color: segmento.color,
          estado: segmento.estado,
          motivo: segmento.motivo,
        ),
      );
    }

    return detalles;
  }

  _ResultadoSegmentos _processFilteredSegments(List<PuntoRendimiento> puntos) {
    if (puntos.length < 2) {
      return const _ResultadoSegmentos(
        segmentos: [],
        tramosDescartados: 0,
        velocidadCorregidaPromedioKmh: 0,
      );
    }

    final suavizados = _suavizarPuntos(puntos);
    final segmentos = <SegmentoTrayectoria>[];
    final ultimasDistanciasValidas = <double>[];
    double? velocidadAnteriorValida;
    _PuntoSuavizado? ultimoPuntoVisibleDibujo;
    var tramosDescartados = 0;
    var distanciaCorregidaMetros = 0.0;
    var tiempoCorregidoSegundos = 0;

    for (var i = 1; i < puntos.length; i++) {
      final inicio = puntos[i - 1];
      final fin = puntos[i];
      final deltaSegundos = fin.tiempo.difference(inicio.tiempo).inSeconds;
      final distanciaMetros = deltaSegundos <= 0 ? 0.0 : _distanciaMetros(inicio, fin);
      final velocidadKmh =
          deltaSegundos <= 0 ? 0.0 : (distanciaMetros / deltaSegundos) * 3.6;

      final promedioMovilMetros = ultimasDistanciasValidas.isEmpty
          ? 0.0
          : ultimasDistanciasValidas.reduce((a, b) => a + b) /
              ultimasDistanciasValidas.length;

      final saltoGps = promedioMovilMetros > 0 &&
          distanciaMetros > (_saltoFactorPromedioMovil * promedioMovilMetros);
      final aceleracionBrusca = velocidadAnteriorValida != null &&
          (velocidadKmh - velocidadAnteriorValida!).abs() >
              _saltoAceleracionMaxima;
      final coordenadasInvalidas = !_coordenadaEsValida(inicio) || !_coordenadaEsValida(fin);
      final velocidadAltaInconsistente =
          velocidadKmh > _velocidadAltaInconsistente &&
              (saltoGps || aceleracionBrusca);
      final distanciaAbsurda = distanciaMetros > _distanciaAbsurdaMetros;

      String estado;
      String motivo;
      bool esVisible;

      if (deltaSegundos <= 0) {
        estado = 'descartado';
        motivo = 'tiempo <= 0';
        esVisible = false;
      } else if (coordenadasInvalidas) {
        estado = 'descartado';
        motivo = 'coordenadas invalidas';
        esVisible = false;
      } else if (distanciaAbsurda || (saltoGps && velocidadAltaInconsistente)) {
        estado = 'descartado';
        motivo = saltoGps ? 'salto GPS' : 'distancia absurda';
        esVisible = false;
      } else if (aceleracionBrusca) {
        estado = 'sospechoso';
        motivo = 'aceleracion brusca';
        esVisible = true;
      } else if (saltoGps) {
        estado = 'sospechoso';
        motivo = 'salto GPS';
        esVisible = true;
      } else if (velocidadAltaInconsistente) {
        estado = 'sospechoso';
        motivo = 'velocidad alta inconsistente';
        esVisible = true;
      } else {
        estado = 'valido';
        motivo = 'tramo coherente';
        esVisible = true;
      }

      final color = _colorPorSegmento(velocidadKmh, estado);
      final dibujoInicio = ultimoPuntoVisibleDibujo ?? suavizados[i - 1];
      final dibujoFin = suavizados[i];

      segmentos.add(
        SegmentoTrayectoria(
          inicio: inicio,
          fin: fin,
          color: color,
          velocidadKmh: velocidadKmh,
          distanciaMetros: distanciaMetros,
          deltaSegundos: deltaSegundos,
          estado: estado,
          motivo: motivo,
          esVisible: esVisible,
          latitudInicioDibujo: dibujoInicio.latitud,
          longitudInicioDibujo: dibujoInicio.longitud,
          latitudFinDibujo: dibujoFin.latitud,
          longitudFinDibujo: dibujoFin.longitud,
        ),
      );

      if (esVisible) {
        ultimoPuntoVisibleDibujo = dibujoFin;
      }

      if (estado == 'descartado') {
        tramosDescartados++;
      } else {
        distanciaCorregidaMetros += distanciaMetros;
        tiempoCorregidoSegundos += deltaSegundos;
      }

      if (estado == 'valido') {
        ultimasDistanciasValidas.add(distanciaMetros);
        if (ultimasDistanciasValidas.length > 5) {
          ultimasDistanciasValidas.removeAt(0);
        }
        velocidadAnteriorValida = velocidadKmh;
      }
    }

    final velocidadCorregidaPromedioKmh = tiempoCorregidoSegundos > 0
        ? (distanciaCorregidaMetros / tiempoCorregidoSegundos) * 3.6
        : 0.0;

    return _ResultadoSegmentos(
      segmentos: segmentos,
      tramosDescartados: tramosDescartados,
      velocidadCorregidaPromedioKmh: velocidadCorregidaPromedioKmh,
    );
  }

  bool _coordenadaEsValida(PuntoRendimiento punto) {
    if (punto.latitud == 0 || punto.longitud == 0) {
      return false;
    }
    if (punto.latitud < -90 || punto.latitud > 90) {
      return false;
    }
    if (punto.longitud < -180 || punto.longitud > 180) {
      return false;
    }
    if (punto.latitud < -20 || punto.latitud > -10) {
      return false;
    }
    if (punto.longitud < -75 || punto.longitud > -65) {
      return false;
    }
    return true;
  }

  Color _colorPorVelocidad(double velocidadKmh) {
    if (velocidadKmh <= _velocidadVerdeMaxima) {
      return Colors.lightGreenAccent;
    }
    if (velocidadKmh <= _velocidadNaranjaMaxima) {
      return Colors.orangeAccent;
    }
    return Colors.redAccent;
  }

  Color _colorPorSegmento(double velocidadKmh, String estado) {
    if (estado == 'descartado') {
      return Colors.grey.withOpacity(0.35);
    }
    final colorBase = _colorBasePorVelocidad(velocidadKmh);
    if (estado == 'sospechoso') {
      return colorBase.withOpacity(0.75);
    }
    return colorBase;
  }

  Color _colorBasePorVelocidad(double velocidadKmh) {
    if (velocidadKmh <= _velocidadVerdeMaxima) {
      return Colors.lightGreenAccent;
    }
    if (velocidadKmh <= _velocidadNaranjaMaxima) {
      return Colors.orangeAccent;
    }
    if (velocidadKmh <= _velocidadRojaMaxima) {
      return Colors.redAccent;
    }
    return Colors.redAccent;
  }

  List<_PuntoSuavizado> _suavizarPuntos(List<PuntoRendimiento> puntos) {
    final suavizados = <_PuntoSuavizado>[];

    for (var i = 0; i < puntos.length; i++) {
      if (i == 0 || i == puntos.length - 1) {
        suavizados.add(
          _PuntoSuavizado(
            latitud: puntos[i].latitud,
            longitud: puntos[i].longitud,
          ),
        );
        continue;
      }

      final anterior = puntos[i - 1];
      final actual = puntos[i];
      final siguiente = puntos[i + 1];

      suavizados.add(
        _PuntoSuavizado(
          latitud:
              (anterior.latitud + actual.latitud + siguiente.latitud) / 3,
          longitud:
              (anterior.longitud + actual.longitud + siguiente.longitud) / 3,
        ),
      );
    }

    return suavizados;
  }

  double _distanciaMetros(PuntoRendimiento a, PuntoRendimiento b) {
    const p = 0.017453292519943295;
    final x = 0.5 -
        math.cos((b.latitud - a.latitud) * p) / 2 +
        math.cos(a.latitud * p) *
            math.cos(b.latitud * p) *
            (1 - math.cos((b.longitud - a.longitud) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(x)) * 1000;
  }

  double _distanciaPuntoASegmentoMetros({
    required double latitud,
    required double longitud,
    required double latitudInicio,
    required double longitudInicio,
    required double latitudFin,
    required double longitudFin,
  }) {
    final px = longitud;
    final py = latitud;
    final ax = longitudInicio;
    final ay = latitudInicio;
    final bx = longitudFin;
    final by = latitudFin;

    final abx = bx - ax;
    final aby = by - ay;
    final ab2 = (abx * abx) + (aby * aby);

    double t;
    if (ab2 == 0) {
      t = 0;
    } else {
      t = (((px - ax) * abx) + ((py - ay) * aby)) / ab2;
      t = t.clamp(0.0, 1.0);
    }

    final proyectadoX = ax + (abx * t);
    final proyectadoY = ay + (aby * t);

    const factorLat = 111320.0;
    final factorLon =
        factorLat * math.cos(((latitudInicio + latitudFin) / 2) * (math.pi / 180));

    final dx = (px - proyectadoX) * factorLon;
    final dy = (py - proyectadoY) * factorLat;
    return math.sqrt((dx * dx) + (dy * dy));
  }
}

class _PuntoSuavizado {
  final double latitud;
  final double longitud;

  const _PuntoSuavizado({
    required this.latitud,
    required this.longitud,
  });
}

class _ResultadoSegmentos {
  final List<SegmentoTrayectoria> segmentos;
  final int tramosDescartados;
  final double velocidadCorregidaPromedioKmh;

  const _ResultadoSegmentos({
    required this.segmentos,
    required this.tramosDescartados,
    required this.velocidadCorregidaPromedioKmh,
  });
}
