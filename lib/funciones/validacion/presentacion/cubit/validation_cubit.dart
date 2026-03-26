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

  static const double _velocidadVerdeMaxima = 15.0;
  static const double _velocidadNaranjaMaxima = 35.0;
  static const double _velocidadMaximaPermitida = 100.0;

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
          detalles: const [],
          totalRegistrosBrutos: 0,
          totalRegistrosValidos: 0,
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

      final puntosLimpios = _limpiarPuntos(puntosCrudos);
      final segmentos = _construirSegmentos(puntosLimpios);
      final detalles = _construirDetalles(puntosLimpios);
      final resumen = _procesador.procesar(puntosLimpios);

      emit(
        state.copyWith(
          status: ValidationStatus.success,
          puntos: puntosLimpios,
          segmentos: segmentos,
          detalles: detalles.reversed.toList(),
          resumen: resumen,
          totalRegistrosBrutos: puntosCrudos.length,
          totalRegistrosValidos: puntosLimpios.length,
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

  List<PuntoRendimiento> _limpiarPuntos(List<PuntoRendimiento> puntos) {
    if (puntos.isEmpty) {
      return const [];
    }

    final ordenados = [...puntos]..sort((a, b) => a.tiempo.compareTo(b.tiempo));
    final resultado = <PuntoRendimiento>[];

    for (final punto in ordenados) {
      if (!_coordenadaEsValida(punto)) {
        continue;
      }

      if (resultado.isEmpty) {
        resultado.add(punto);
        continue;
      }

      final anterior = resultado.last;
      final deltaSegundos = punto.tiempo.difference(anterior.tiempo).inSeconds;
      if (deltaSegundos <= 0) {
        continue;
      }

      final distancia = _distanciaMetros(anterior, punto);
      final velocidad = (distancia / deltaSegundos) * 3.6;

      if (velocidad > _velocidadMaximaPermitida) {
        continue;
      }

      resultado.add(punto);
    }

    return resultado;
  }

  List<SegmentoTrayectoria> _construirSegmentos(List<PuntoRendimiento> puntos) {
    if (puntos.length < 2) {
      return const [];
    }

    final segmentos = <SegmentoTrayectoria>[];

    for (var i = 1; i < puntos.length; i++) {
      final inicio = puntos[i - 1];
      final fin = puntos[i];
      final deltaSegundos = fin.tiempo.difference(inicio.tiempo).inSeconds;
      if (deltaSegundos <= 0) {
        continue;
      }

      final distanciaMetros = _distanciaMetros(inicio, fin);
      final velocidadKmh = (distanciaMetros / deltaSegundos) * 3.6;

      segmentos.add(
        SegmentoTrayectoria(
          inicio: inicio,
          fin: fin,
          color: _colorPorVelocidad(velocidadKmh),
          velocidadKmh: velocidadKmh,
          distanciaMetros: distanciaMetros,
        ),
      );
    }

    return segmentos;
  }

  List<PuntoRendimientoDetallado> _construirDetalles(
    List<PuntoRendimiento> puntos,
  ) {
    if (puntos.isEmpty) {
      return const [];
    }

    final detalles = <PuntoRendimientoDetallado>[];

    for (var i = 0; i < puntos.length; i++) {
      if (i == 0) {
        detalles.add(
          PuntoRendimientoDetallado(
            punto: puntos[i],
            velocidadKmh: 0,
            distanciaMetros: 0,
            color: Colors.greenAccent,
            estado: 'Inicio',
          ),
        );
        continue;
      }

      final anterior = puntos[i - 1];
      final actual = puntos[i];
      final deltaSegundos = actual.tiempo.difference(anterior.tiempo).inSeconds;
      final distanciaMetros = deltaSegundos <= 0 ? 0.0 : _distanciaMetros(anterior, actual);
      final velocidadKmh =
          deltaSegundos <= 0 ? 0.0 : (distanciaMetros / deltaSegundos) * 3.6;
      final color = _colorPorVelocidad(velocidadKmh);

      detalles.add(
        PuntoRendimientoDetallado(
          punto: actual,
          velocidadKmh: velocidadKmh,
          distanciaMetros: distanciaMetros,
          color: color,
          estado: _estadoPorVelocidad(velocidadKmh),
        ),
      );
    }

    return detalles;
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

  String _estadoPorVelocidad(double velocidadKmh) {
    if (velocidadKmh <= _velocidadVerdeMaxima) {
      return 'Normal';
    }
    if (velocidadKmh <= _velocidadNaranjaMaxima) {
      return 'Atencion';
    }
    return 'Critico';
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
}
