import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/equipo_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/punto_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/resumen_rendimiento.dart';

enum ValidationStatus { initial, loading, success, failure }

class SegmentoTrayectoria extends Equatable {
  final PuntoRendimiento inicio;
  final PuntoRendimiento fin;
  final Color color;
  final double velocidadKmh;
  final double distanciaMetros;
  final int deltaSegundos;
  final String estado;
  final String motivo;
  final bool esVisible;
  final double latitudInicioDibujo;
  final double longitudInicioDibujo;
  final double latitudFinDibujo;
  final double longitudFinDibujo;

  const SegmentoTrayectoria({
    required this.inicio,
    required this.fin,
    required this.color,
    required this.velocidadKmh,
    required this.distanciaMetros,
    required this.deltaSegundos,
    required this.estado,
    required this.motivo,
    required this.esVisible,
    required this.latitudInicioDibujo,
    required this.longitudInicioDibujo,
    required this.latitudFinDibujo,
    required this.longitudFinDibujo,
  });

  @override
  List<Object?> get props => [
        inicio,
        fin,
        color,
        velocidadKmh,
        distanciaMetros,
        deltaSegundos,
        estado,
        motivo,
        esVisible,
        latitudInicioDibujo,
        longitudInicioDibujo,
        latitudFinDibujo,
        longitudFinDibujo,
      ];
}

class PuntoRendimientoDetallado extends Equatable {
  final DateTime tiempoInicio;
  final PuntoRendimiento punto;
  final double velocidadKmh;
  final double distanciaMetros;
  final int deltaSegundos;
  final Color color;
  final String estado;
  final String motivo;

  const PuntoRendimientoDetallado({
    required this.tiempoInicio,
    required this.punto,
    required this.velocidadKmh,
    required this.distanciaMetros,
    required this.deltaSegundos,
    required this.color,
    required this.estado,
    required this.motivo,
  });

  @override
  List<Object?> get props => [
        tiempoInicio,
        punto,
        velocidadKmh,
        distanciaMetros,
        deltaSegundos,
        color,
        estado,
        motivo,
      ];
}

class ValidationState extends Equatable {
  final ValidationStatus status;
  final List<EquipoRendimiento> equipos;
  final String? equipoSeleccionadoId;
  final DateTime fechaSeleccionada;
  final List<PuntoRendimiento> puntos;
  final List<SegmentoTrayectoria> segmentos;
  final SegmentoTrayectoria? segmentoSeleccionado;
  final List<PuntoRendimientoDetallado> detalles;
  final ResumenRendimiento? resumen;
  final EstadisticasTrayectoria estadisticas;
  final String? error;
  final int totalRegistrosBrutos;
  final int totalRegistrosValidos;
  final int tramosDescartados;
  final double velocidadCorregidaPromedioKmh;
  final bool cargandoEquipo;

  const ValidationState({
    this.status = ValidationStatus.initial,
    this.equipos = const [],
    this.equipoSeleccionadoId,
    required this.fechaSeleccionada,
    this.puntos = const [],
    this.segmentos = const [],
    this.segmentoSeleccionado,
    this.detalles = const [],
    this.resumen,
    this.estadisticas = EstadisticasTrayectoria.vacia,
    this.error,
    this.totalRegistrosBrutos = 0,
    this.totalRegistrosValidos = 0,
    this.tramosDescartados = 0,
    this.velocidadCorregidaPromedioKmh = 0,
    this.cargandoEquipo = false,
  });

  factory ValidationState.initial() {
    return ValidationState(
      fechaSeleccionada: DateTime.now(),
    );
  }

  EquipoRendimiento? get equipoSeleccionado {
    final id = equipoSeleccionadoId;
    if (id == null) {
      return null;
    }
    for (final equipo in equipos) {
      if (equipo.idEquipoControl == id) {
        return equipo;
      }
    }
    return null;
  }

  ValidationState copyWith({
    ValidationStatus? status,
    List<EquipoRendimiento>? equipos,
    String? equipoSeleccionadoId,
    DateTime? fechaSeleccionada,
    List<PuntoRendimiento>? puntos,
    List<SegmentoTrayectoria>? segmentos,
    SegmentoTrayectoria? segmentoSeleccionado,
    List<PuntoRendimientoDetallado>? detalles,
    ResumenRendimiento? resumen,
    EstadisticasTrayectoria? estadisticas,
    String? error,
    int? totalRegistrosBrutos,
    int? totalRegistrosValidos,
    int? tramosDescartados,
    double? velocidadCorregidaPromedioKmh,
    bool? cargandoEquipo,
    bool clearError = false,
    bool clearResumen = false,
  }) {
    return ValidationState(
      status: status ?? this.status,
      equipos: equipos ?? this.equipos,
      equipoSeleccionadoId: equipoSeleccionadoId ?? this.equipoSeleccionadoId,
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      puntos: puntos ?? this.puntos,
      segmentos: segmentos ?? this.segmentos,
      segmentoSeleccionado: segmentoSeleccionado ?? this.segmentoSeleccionado,
      detalles: detalles ?? this.detalles,
      resumen: clearResumen ? null : (resumen ?? this.resumen),
      estadisticas: clearResumen
          ? EstadisticasTrayectoria.vacia
          : (estadisticas ?? this.estadisticas),
      error: clearError ? null : error ?? this.error,
      totalRegistrosBrutos: totalRegistrosBrutos ?? this.totalRegistrosBrutos,
      totalRegistrosValidos: totalRegistrosValidos ?? this.totalRegistrosValidos,
      tramosDescartados: tramosDescartados ?? this.tramosDescartados,
      velocidadCorregidaPromedioKmh:
          velocidadCorregidaPromedioKmh ?? this.velocidadCorregidaPromedioKmh,
      cargandoEquipo: cargandoEquipo ?? this.cargandoEquipo,
    );
  }

  @override
  List<Object?> get props => [
        status,
        equipos,
        equipoSeleccionadoId,
        fechaSeleccionada,
        puntos,
        segmentos,
        segmentoSeleccionado,
        detalles,
        resumen,
        estadisticas,
        error,
        totalRegistrosBrutos,
        totalRegistrosValidos,
        tramosDescartados,
        velocidadCorregidaPromedioKmh,
        cargandoEquipo,
      ];
}
